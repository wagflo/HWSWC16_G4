/*******************************************************************************
 * @file main.c
 * @brief Main file for the HWSW 2016 main task.
 *
 * Please use the given functions 'init', 'setCamera' and 'renderFrame' for
 * your project and do not forget to comment your code!
 *
 * To get started, the module 'sw_renderer' provides a simple software-only
 * raytracer. A testscene is given in 'testdata'.
 ******************************************************************************/

/* Includes *******************************************************************/
#include "defs.h"
#include "vec3.h"
#include "sphere.h"
#include "sw_renderer.h"
#include "testdata.h"
#include "display.h"

#include <stdint.h>

#include <stdio.h>
#include <io.h>
#include <malloc.h>
#include <system.h>

#include <sys/alt_timestamp.h>
#include <altera_avalon_timer_regs.h>

/* Defines ********************************************************************/
/* Typedefs *******************************************************************/
/* Variables ******************************************************************/
/* Function prototypes ********************************************************/
/** 
 * @brief Setup hardware
 */
static void setupHW (void);

/** 
 * @brief Initialize raytracer
 * 
 * @param num_objects  Number of spheres
 * @param spheres      Sphere array
 * @param max_reflects Maximal number of reflects
 * @param num_samples  Number of samples per pixel
 */
static void init (
		uint8_t num_objects, sphere_t *spheres,
		uint16_t max_reflects, uint16_t num_samples);

/** 
 * @brief Set camera parameters
 * 
 * @param lookfrom Observer position
 * @param lookat   Observer direction
 * @param vfov     Vertical field of view in degrees
 */
static void setCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov);

/** 
 * @brief Start raytracer
 */
static void renderFrame (void);

/* main ***********************************************************************/
int
main (void)
{
	setupHW ();
	uint8_t fb = 0;
	selectFramebuffer (fb);
	displayClear (0);
	init (TEST_SCENE_SIZE, test_spheres, TEST_NUM_REFLECTS, TEST_NUM_SAMPLES);
	while (1)
	{
		vec3_t lookfrom, lookat;
		fix16_t vfov;
		showFramebuffer (fb);
		fb ^= 0x01;
		selectFramebuffer (fb);
		testGetNextCamera (&lookfrom, &lookat, &vfov);
		setCamera (&lookfrom, &lookat, vfov);

		alt_timestamp_start ();

		renderFrame ();

		printf ("Output: %llu\n", alt_timestamp ());
	}
	return 0;
}

/* Private functions **********************************************************/
static void
setupHW (void)
{
	IOWR_ALTERA_AVALON_TIMER_STATUS(SYSTIMER_BASE, 0); // clear TO bit
	/* display init */
	/* allocate memory for 2 frame buffers (double buffering)*/
	void *framebuffers = malloc (FRAME_HEIGHT * FRAME_WIDTH * sizeof (uint32_t) * 2);
	displayInit ((uint32_t) framebuffers,
		(uint32_t) framebuffers + FRAME_HEIGHT * FRAME_WIDTH * sizeof (uint32_t));
}

static void
init (
	uint8_t num_objects, sphere_t *spheres,
	uint16_t max_reflects, uint16_t num_samples)
{
	rtInit (num_objects, spheres, max_reflects, num_samples);
}

static void
setCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov)
{
	rtSetCamera (lookfrom, lookat, vfov);
}

static void
renderFrame (void)
{
	rtRenderFrame ();
}
