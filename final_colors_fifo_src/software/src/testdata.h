/**
 * @brief Provides a test scene.
 */

#include "sphere.h"
#include "vec3.h"
#include "libfixmath/fix16.h"

#ifndef TESTDATA_H
#define TESTDATA_H

#ifdef __cplusplus
extern "C"
{
#endif

enum {TEST_NUM_SAMPLES = 1};
enum {TEST_NUM_REFLECTS = 5};
enum {TEST_SCENE_SIZE = 5};

extern sphere_t test_spheres[TEST_SCENE_SIZE];

/**
 * @brief Sets the next camera settings.
 *
 * @param lookfrom New position of camera
 * @param lookat   New direction
 * @param vfov     New vertical field of view
 */
void testGetNextCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t *vfov);

#ifdef __cplusplus
}
#endif

#endif
