#ifndef SPHERE_H
#define SPHERE_H

#include "vec3.h"

typedef enum {REFLECTING, EMITTING} material_t;

typedef struct
{
	vec3_t     center;
	fix16_t    radius;
	vec3_t     color;
	material_t mat;
} sphere_t;

#endif
