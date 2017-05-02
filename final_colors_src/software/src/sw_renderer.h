/** 
 * @file sw_renderer.h
 * @brief Provides a simple (and slow) iterative ray tracer in software.
 *
 * This raytracer is based on Peter Shirley's book 'Ray Tracing in One Weekend',
 * published as a kindle book in 2016. His source code is available on github at
 * https://github.com/petershirley/raytracinginoneweekend [2016-10-26].
 */

#ifndef SW_RENDERER_H
#define SW_RENDERER_H

/* Includes *******************************************************************/
#include "defs.h"
#include "vec3.h"
#include "sphere.h"

#ifdef __cplusplus
extern "C"
{
#endif

/* Typedefs *******************************************************************/
/* Exported functions *********************************************************/

/** 
 * @brief Initializes raytracer scene.
 * 
 * @param num_objects  Number of spheres
 * @param spheres      Array of spheres
 * @param max_reflects Maximal number of reflections
 * @param num_samples  Number of samples
 */
void rtInit (uint8_t num_objects, sphere_t *spheres, uint16_t max_reflects, uint16_t num_samples);

/** 
 * @brief Sets the camera position.
 * 
 * @param lookfrom Camera position
 * @param lookat   Camera direction
 * @param vfov     Vertical field of view in degrees
 */
void rtSetCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov, uint8_t frame_address);

/** 
 * @brief Renders a frame. rtInit and rtSetCamera need to be called beforehand.
 *
 * Iterative raytracing algorithm on spheres. For every pixel a ray is sent from
 * 'lookfrom' to 'lookat'. The ray is then checked for an intersection with the
 * closest object and is (possibly) reflected. Every pixel is sampled 'num_samples'
 * times (ie randomize ray direction and average over the samples).
 * Spheres are divided into 2 classes:
 *  - REFLECTING: Rays are perfectly reflected, but are only visible if a reflected
 *                ray hits an emitting object
 *  - EMITTING: Rays are not reflected. If a ray does not hit an emitting object in
 *              at most 'max_reflects' reflections, then the pixel remains black.
 */
void rtRenderFrame (void);

#ifdef __cplusplus
}
#endif

#endif
