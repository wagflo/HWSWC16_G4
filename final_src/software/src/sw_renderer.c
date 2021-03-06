#include "sw_renderer.h"
#include "display.h"
#include <stdlib.h>
#include <system.h>
#include <io.h>
#include <stdio.h>

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

}

void
rtSetCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov, uint8_t frame_address)
{
	const fix16_t aspect =
		fix16_div (fix16_from_int (FRAME_WIDTH), fix16_from_int (FRAME_HEIGHT));
	const fix16_t rpd = fix16_div (fix16_pi, fix16_from_int (180));

	fix16_t theta = fix16_mul (vfov, rpd);
	fix16_t half_height = fix16_tan (theta >> 1); /* theta/2 */
	fix16_t half_width = fix16_mul (aspect, half_height);

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
	

	//write the frame data
	vec3_t camera_base;
	vec3_t upper_left;
	vec3_t vertical_times_height;
	vec3MulS(&vertical_times_height, fix16_from_int(479), &camera.vertical);
	vec3Add(&upper_left, &camera.lower_left_corner, &vertical_times_height);
	vec3Sub(&camera_base, &upper_left, &camera.origin);
	
	
	printf("Vor camera data \n");
	
	//while (IORD(MM_RAYTRACING_0_BASE, 0x0000) == 0x00000000) {
	   
	//}
	printf("Nach camera data \n");
	
	//write the origin
	//IOWR(MM_RAYTRACING_0_BASE, 0x3011, camera.origin.x[0]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3012, camera.origin.x[1]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3012, camera.origin.x[2]);
	//write the horizontal add
	//IOWR(MM_RAYTRACING_0_BASE, 0x3031, camera.horizontal.x[0]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3032, camera.horizontal.x[1]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3033, camera.horizontal.x[2]);
	//write the vertical add
	//IOWR(MM_RAYTRACING_0_BASE, 0x3041, camera.vertical.x[0]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3042, camera.vertical.x[1]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3043, camera.vertical.x[2]);
	//write the addition base
	//IOWR(MM_RAYTRACING_0_BASE, 0x3021, camera_base.x[0]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3022, camera_base.x[1]);
	//IOWR(MM_RAYTRACING_0_BASE, 0x3023, camera_base.x[2]);
	//write the frame address
	//IOWR(MM_RAYTRACING_0_BASE, 0x3050, 0x00000000 | frame_address);
	//finish the frame
	//IOWR(MM_RAYTRACING_0_BASE, 0xFFFF, 0x00000000);
}

/* result = lower_let_corner + s*horizontal + t*vertical - origin */
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
	for (uint8_t i = 0; i < scene.num_spheres; ++i)
	{
		vec3_t oc;
		vec3Sub (&oc, origin, &scene.spheres[i].center);
		fix16_t b = vec3Dot (&oc, dir);
		fix16_t c = vec3Dot (&oc, &oc) -
			fix16_mul (scene.spheres[i].radius, scene.spheres[i].radius);
		fix16_t discr = fix16_mul (b, b) - fix16_mul (a, c);
		if (discr > 0)
		{
			discr = fix16_sqrt (discr);
			fix16_t t = fix16_div (-b - discr, a);
			/* check first solution */
			if (t > time_min && t < *t_min)
			{
				*t_min = t;
				nearest_obj = &scene.spheres[i];
				continue;
			}
			/* check second solution */
			t = fix16_div (-b + discr, a);
			if (t > time_min && t < *t_min)
			{
				*t_min = t;
				nearest_obj = &scene.spheres[i];
				continue;
			}
		}
	}
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
	fix16_t t = fix16_mul (fix16_one << 1, vec3Dot (v, n));
	vec3MulS (&tmp, t, n);
	vec3Sub (r, v, &tmp);
}

void
rtRenderFrame (void)
{
	const fix16_t f_height_r = fix16_div (fix16_one, fix16_from_int (FRAME_HEIGHT));
	const fix16_t f_width_r = fix16_div (fix16_one, fix16_from_int (FRAME_WIDTH));
	const fix16_t num_samples_r =
		fix16_div (fix16_one, fix16_from_int (scene.num_samples));

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
				fix16_t u = fix16_mul (fix16_from_int (i) + r, f_width_r);
				r = rand () & 0xFFFF;
				fix16_t v = fix16_mul (fix16_from_int (j) + r, f_height_r);
				vec3_t ray_dir;
				getRayDir (&ray_dir, u, v);

				/* reflection loop, break if emitting object or no object is hit */
				sphere_t *nearest_obj = NULL;
				uint16_t k = scene.max_num_reflects;
				for (; k > 0; --k)
				{
					fix16_t tmin;
					nearest_obj = getClosestSphere (&tmin, &ray_origin, &ray_dir);
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
						fix16_t rr = fix16_div (fix16_one, nearest_obj->radius);
						vec3MulS (&n, rr, &n);
						reflect (&ray_dir, &ray_dir, &n);
					}
					else
					{
						/* ray miss */
						break;
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
			vec3Sqrt (&col, &col); /* gamma correction */
			/* pack rgb values into one 32 bit value */
			fix16_t bit_mask = 255 << 16;
			col.x[0] = fix16_mul (col.x[0], bit_mask) & bit_mask;
			bit_mask = 255 << 8;
			col.x[1] = fix16_mul (col.x[1], bit_mask) & bit_mask;
			bit_mask = 255;
			col.x[2] = fix16_mul (col.x[2], bit_mask) & bit_mask;
			uint32_t rgb = col.x[0] | col.x[1] | col.x[2];
			displaySetPixel (FRAME_HEIGHT-1-j, i, rgb);
		}
	}
}
