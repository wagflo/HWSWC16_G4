#include "testdata.h"

/* 'borrowed' from libfixmath */
#define FIX_FROM_FLOAT(x) ((fix16_t) (x * (fix16_t)(1<<16)))

sphere_t test_spheres[TEST_SCENE_SIZE] = {
// 		{
// 			.center = { {FIX_FROM_FLOAT (0.8), FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.0)} },
// 			.radius = FIX_FROM_FLOAT (0.0),
// 			.color  = { {FIX_FROM_FLOAT (1.0), FIX_FROM_FLOAT (0.3), FIX_FROM_FLOAT (0.3)} },
// 			.mat    = EMITTING
// 		},
// 		{
// 			.center = { {FIX_FROM_FLOAT (0.8), FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.0)} },
// 			.radius = FIX_FROM_FLOAT (0.0),
// 			.color  = { {FIX_FROM_FLOAT (1.0), FIX_FROM_FLOAT (0.3), FIX_FROM_FLOAT (0.3)} },
// 			.mat    = EMITTING
// 		},
		{
			.center = { {FIX_FROM_FLOAT (0.8), FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.0)} }, // 0.8 statt 0.6
			.radius = FIX_FROM_FLOAT (0.5),
			.color  = { {FIX_FROM_FLOAT (1.0), FIX_FROM_FLOAT (0.3), FIX_FROM_FLOAT (0.3)} },
			.mat    = EMITTING
		},
		{
			.center = { {FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.8)} },
			.radius = FIX_FROM_FLOAT (0.5),
			.color  = { {FIX_FROM_FLOAT (0.3), FIX_FROM_FLOAT (1.0), FIX_FROM_FLOAT (0.3)} },
			.mat    = REFLECTING
		},
		{
			.center = { {FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (-0.8)} },
			.radius = FIX_FROM_FLOAT (0.5),
			.color  = { {FIX_FROM_FLOAT (0.3), FIX_FROM_FLOAT (0.3), FIX_FROM_FLOAT (1.0)} },
			.mat    = EMITTING
		},
		{
			.center = { {FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (60.0), FIX_FROM_FLOAT (0.0)} },
			.radius = FIX_FROM_FLOAT (50.0),
			.color  = { {FIX_FROM_FLOAT (1.0), FIX_FROM_FLOAT (1.0), FIX_FROM_FLOAT (1.0)} }, // alle 1.0
			.mat    = EMITTING
		},
		{
			.center = { {FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (-100.5), FIX_FROM_FLOAT (0.0)} },
			.radius = FIX_FROM_FLOAT (70.0), //100.0), <- interessant
			.color  = { {FIX_FROM_FLOAT (0.4), FIX_FROM_FLOAT (0.0), FIX_FROM_FLOAT (0.0)} }, // alle 0.4
			.mat    = EMITTING //REFLECTING <- interessant
		}
};

static fix16_t phi = 0;

void
testGetNextCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t *vfov)
{
	const fix16_t height = 9 << 16;  /* 9.0 */
	const fix16_t radius = 10 << 16; /* 10.0 */
	const fix16_t phi_inc = fix16_pi >> 4; /* 2 pi / 32 == 32 steps */
	lookat->x[0] = 0;
	lookat->x[1] = 0;
	lookat->x[2] = 0;
	*vfov = 20 << 16; /* 20 degrees */
	lookfrom->x[0] = fix16_mul (radius, fix16_cos (phi));
	lookfrom->x[1] = height; /* fixed height */
	lookfrom->x[2] = fix16_mul (radius, fix16_sin (phi));
	phi += phi_inc;
	if (phi > fix16_pi << 1)
		phi -= fix16_pi << 1;
}
