#ifndef SPHERE_H
#define SPHERE_H

#include "vec3.h"

typedef enum {REFLECTING, EMITTING} material_t;

typedef struct
{
	vec3_t     center;
	fix16_t    radius;
	fix16_t    radius_square;
	fix16_t    rec_radius;
	vec3_t     color;
 	material_t mat;
	vec3_t     oc;
	fix16_t    c;
} sphere_t;

#endif
