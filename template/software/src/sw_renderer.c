#include "sw_renderer.h"
#include "display.h"
#include <stdlib.h>
#include "../bsp/system.h"

/* Typedefs *******************************************************************/
typedef struct
{
	vec3_t origin;
	vec3_t lower_left_corner;
	vec3_t horizontal;
	vec3_t vertical;
} camera_t;

typedef struct
{
	uint8_t  num_spheres;
	sphere_t spheres[MAX_NUM_OBJECTS];
	uint16_t max_num_reflects;
	uint16_t num_samples;
} rt_scene_t;


/* Variables ******************************************************************/
static const fix16_t time_min = 0x199A; /* 0.1 in 16.16 */

static camera_t camera;
static rt_scene_t scene;

/* Functions ******************************************************************/
void
rtInit (uint8_t num_objects, sphere_t *spheres, uint16_t max_reflects, uint16_t num_samples)
{
	srand (42); /* init rng */

	if (num_objects > MAX_NUM_OBJECTS)
		num_objects = MAX_NUM_OBJECTS;
	/* copy spheres and set additional parameters */
	for (uint8_t i = 0; i < num_objects; ++i)
	{
		scene.spheres[i] = spheres[i];
		scene.spheres[i].radius_square = ALT_CI_CI_MUL_0(scene.spheres[i].radius, scene.spheres[i].radius);
		ALT_CI_CI_DIV(0, fix16_one, scene.spheres[i].radius);
	}
	
	/* set other parameters */
	scene.num_spheres      = num_objects;
	scene.max_num_reflects = max_reflects;
	scene.num_samples      = num_samples;
	/* set reciprocal radius parameters */
	for (uint8_t i = 0; i < num_objects; ++i)
	{
		scene.spheres[i].rec_radius = ALT_CI_CI_DIV(1,0,0);
	}
}

void
rtSetCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov)
{
	const fix16_t aspect =
		fix16_div (fix16_from_int (FRAME_WIDTH), fix16_from_int (FRAME_HEIGHT));
	const fix16_t rpd = fix16_div (fix16_pi, fix16_from_int (180));

	fix16_t theta = ALT_CI_CI_MUL_0 (vfov, rpd);
	fix16_t half_height = fix16_tan (theta >> 1); /* theta/2 */
	fix16_t half_width = ALT_CI_CI_MUL_0 (aspect, half_height);

	camera.origin = *lookfrom;

	vec3_t u, v, w;
	vec3Sub (&w, lookfrom, lookat);
	vec3UnitVector (&w, &w);

	/* u = unit_vector (cross (vup, w)) */
	vec3_t vup = { {0, fix16_from_int (1), 0} };
	vec3Cross (&u, &vup, &w);
	vec3UnitVector (&u, &u);

	vec3Cross (&v, &w, &u); /* v = cross (w, u) */

	/* horizontal = 2 * half_width * u, vertical similar */
	vec3MulS (&camera.horizontal, half_width<<1, &u);
	vec3MulS (&camera.vertical, half_height<<1, &v);
	/* llc = lookfrom - half_width*u - half_height*v - w */
	vec3MulS (&u, half_width, &u);
	vec3MulS (&v, half_height, &v);
	vec3Sub (&camera.lower_left_corner, lookfrom, &u);
	vec3Sub (&camera.lower_left_corner, &camera.lower_left_corner, &v);
	vec3Sub (&camera.lower_left_corner, &camera.lower_left_corner, &w);
}

/* result = lower_let_corner + s*horizontal + s*vertical - origin */
static inline void
getRayDir (vec3_t *res, fix16_t s, fix16_t t)
{
	vec3_t tmp;
	vec3MulS (&tmp, s, &camera.horizontal);
	vec3MulS (res, t, &camera.vertical);
	vec3Add (res, res, &tmp);
	vec3Add (res, res, &camera.lower_left_corner);
	vec3Sub (res, res, &camera.origin);
}

static inline sphere_t*
getClosestSphere (fix16_t *t_min, vec3_t *origin, vec3_t *dir)
{
	sphere_t *nearest_obj = NULL;
	*t_min = fix16_maximum;
	
	fix16_t a = vec3Dot (dir, dir);
	ALT_CI_CI_DIV(0,*t_min,a);
	fix16_t time_min_a = ALT_CI_CI_MUL_0(time_min, a);
	for (uint8_t i = 0; i < scene.num_spheres; ++i)
	{
		vec3_t oc;
		vec3Sub (&oc, origin, &scene.spheres[i].center);
		fix16_t b = vec3Dot (&oc, dir);
		fix16_t c = vec3Dot (&oc, &oc) - scene.spheres[i].radius_square;
		fix16_t discr = ALT_CI_CI_MUL_0 (b, b) - ALT_CI_CI_MUL_0 (a, c);

		if (discr > 0)
		{
			discr = fix16_sqrt (discr);			
			//fix16_t t = fix16_div (-b - discr, a); --scaling not necessary for decision
			fix16_t t = -b - discr;
			/* check first solution */
			if (t > time_min_a && t < *t_min)
			{
				*t_min = t;
				ALT_CI_CI_DIV(0,*t_min,a);
				nearest_obj = &scene.spheres[i];
				ALT_CI_CI_DIV(1,0,0);
				continue;
			}
			//since discr is positive, -b+discr is ALWAYS than bigger -b-discr
			//therefore, when -b-discr > time_min_a but -b-discr >= *t_min,
			//it cannot hold that -b+discr < *t_min
			//so, calculate -b+discr only in cases where -b-discr <= time_min_a
			else if(t <= time_min_a)
			{
				t = -b + discr;
				if (t > time_min_a && t < *t_min)
				{
					*t_min = t;
					ALT_CI_CI_DIV(0,*t_min,a);
					nearest_obj = &scene.spheres[i];
					ALT_CI_CI_DIV(1,0,0);
				}
			}
		}
	}
	
	*t_min = ALT_CI_CI_DIV(1,0,0);//fix16_div (*t_min, a);
	return nearest_obj;
}

static inline sphere_t*
getClosestFirstSphere (fix16_t *t_min, vec3_t *origin, vec3_t *dir)
{
	sphere_t *nearest_obj = NULL;
	*t_min = fix16_maximum;
	
	fix16_t a = vec3Dot (dir, dir);
	ALT_CI_CI_DIV(0,*t_min,a);
	fix16_t time_min_a = ALT_CI_CI_MUL_0(time_min, a);
	for (uint8_t i = 0; i < scene.num_spheres; ++i)
	{
		fix16_t b = vec3Dot (&scene.spheres[i].oc, dir);
		fix16_t discr = ALT_CI_CI_MUL_0 (b, b) - ALT_CI_CI_MUL_0 (a, scene.spheres[i].c);

		if (discr > 0)
		{
			discr = fix16_sqrt (discr);			
			//fix16_t t = fix16_div (-b - discr, a); --scaling not necessary for decision
			fix16_t t = -b - discr;
			/* check first solution */
			if (t > time_min_a && t < *t_min)
			{
				*t_min = t;
				ALT_CI_CI_DIV(0,*t_min,a);
				nearest_obj = &scene.spheres[i];
				ALT_CI_CI_DIV(1,0,0);
				continue;
			}
			//since discr is positive, -b+discr is ALWAYS than bigger -b-discr
			//therefore, when -b-discr > time_min_a but -b-discr >= *t_min,
			//it cannot hold that -b+discr < *t_min
			//so, calculate -b+discr only in cases where -b-discr <= time_min_a
			else if(t <= time_min_a)
			{
				t = -b + discr;
				if (t > time_min_a && t < *t_min)
				{
					*t_min = t;
					ALT_CI_CI_DIV(0,*t_min,a);
					nearest_obj = &scene.spheres[i];
					ALT_CI_CI_DIV(1,0,0);
				}
			}
		}
	}
	
	*t_min = ALT_CI_CI_DIV(1,0,0);//fix16_div (*t_min, a);
	return nearest_obj;
}

/**
 * @brief Reflect ray v
 *
 * @param r Resulting ray r = v - 2 * dot(v,n) * n
 * @param v Incoming ray
 * @param n Surface normal
 */
static inline void
reflect (vec3_t *r, vec3_t *v, vec3_t *n)
{
	vec3_t tmp;
	fix16_t t = ALT_CI_CI_MUL_0 (fix16_one << 1, vec3Dot (v, n));
	vec3MulS (&tmp, t, n);
	vec3Sub (r, v, &tmp);
}

void
rtRenderFrame (void)
{
	ALT_CI_CI_DIV(0, fix16_one, fix16_from_int (FRAME_HEIGHT));
	ALT_CI_CI_DIV(0, fix16_one, fix16_from_int (FRAME_WIDTH));
	ALT_CI_CI_DIV(0, fix16_one, fix16_from_int (scene.num_samples));
	const fix16_t f_height_r = ALT_CI_CI_DIV(1,0,0);
	//fix16_div (fix16_one, fix16_from_int (FRAME_HEIGHT));
	const fix16_t f_width_r = ALT_CI_CI_DIV(1,0,0);
	//fix16_div (fix16_one, fix16_from_int (FRAME_WIDTH));
	const fix16_t num_samples_r = ALT_CI_CI_DIV(1,0,0);
		//fix16_div (fix16_one, fix16_from_int (scene.num_samples));
	
	for (int16_t i = 0; i < scene.num_spheres; ++i) {
	  vec3Sub (&scene.spheres[i].oc, &camera.origin, &scene.spheres[i].center);
	  scene.spheres[i].c = vec3Dot (&scene.spheres[i].oc, &scene.spheres[i].oc) - scene.spheres[i].radius_square;
	}

	for (int16_t j = FRAME_HEIGHT - 1; j >= 0; --j)
	{
		for (uint16_t i = 0; i < FRAME_WIDTH; ++i)
		{
			vec3_t col = { {0, 0, 0} };

			/* average over samples */
			for (uint16_t s = 0; s < scene.num_samples; ++s)
			{
				vec3_t col_tmp = { {fix16_one, fix16_one, fix16_one} };
				/* set ray origin */
				vec3_t ray_origin = camera.origin;
				/* set ray direction */
				fix16_t r = rand () & 0xFFFF; /* random value in [0, 1.0) */
				fix16_t u = ALT_CI_CI_MUL_0 (fix16_from_int (i) + r, f_width_r);
				r = rand () & 0xFFFF;
				fix16_t v = ALT_CI_CI_MUL_0 (fix16_from_int (j) + r, f_height_r);
				vec3_t ray_dir;
				getRayDir (&ray_dir, u, v);

				/* reflection loop, break if emitting object or no object is hit */
				sphere_t *nearest_obj = NULL;
				uint16_t k = scene.max_num_reflects;
				fix16_t tmin;
				nearest_obj = getClosestSphere (&tmin, &ray_origin, &ray_dir);
				for (; k > 0; --k)
				{
					if (nearest_obj != NULL)
					{
						vec3Mul (&col_tmp, &col_tmp, &nearest_obj->color);
						if (nearest_obj->mat == EMITTING)
							break;
						
						/* if not emitting reflect */
						/* ray_origin = ray_origin + t * ray_dir */
						vec3_t tmp;
						vec3MulS (&tmp, tmin, &ray_dir);
						vec3Add (&ray_origin, &tmp, &ray_origin);
						/* n = (ray_origin - center) / radius  */
						vec3_t n; /* surface normal */
						vec3Sub (&n, &ray_origin, &nearest_obj->center);
						//fix16_t rr = nearest_obj->rec_radius;
						vec3MulS (&n, nearest_obj->rec_radius, &n);
						reflect (&ray_dir, &ray_dir, &n);
					}
					else
					{
						/* ray miss */
						break;
					}
					if (k > 1) {
					  nearest_obj = getClosestSphere (&tmin, &ray_origin, &ray_dir);
					}
				}
				/* ray miss or max num reflects reached */
				if (k == 0 || nearest_obj == NULL)
				{
					col_tmp.x[0] = 0;
					col_tmp.x[1] = 0;
					col_tmp.x[2] = 0;
				}

				vec3Add (&col, &col, &col_tmp);
			}
			/* set pixel */
			vec3MulS (&col, num_samples_r, &col); /* col /= num_samples */
			vec3Sqrt (&col, &col); /* gammagetRayDir correction */
			/* pack rgb values into one 32 bit value */
			fix16_t bit_mask = 255 << 16;
			col.x[0] = ALT_CI_CI_MUL_0 (col.x[0], bit_mask) & bit_mask;
			bit_mask = 255 << 8;
			col.x[1] = ALT_CI_CI_MUL_0 (col.x[1], bit_mask) & bit_mask;
			bit_mask = 255;
			col.x[2] = ALT_CI_CI_MUL_0 (col.x[2], bit_mask) & bit_mask;
			uint32_t rgb = col.x[0] | col.x[1] | col.x[2];
			displaySetPixel (FRAME_HEIGHT-1-j, i, rgb);
		}
	}
}
