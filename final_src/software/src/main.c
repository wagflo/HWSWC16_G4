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
static void setCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov, uint8_t frame_address);

/** 
 * @brief Start raytracer
 */
static void renderFrame (void);

/* main ***********************************************************************/
int
main (void)
{
	printf("Vor setupHW\n");
	setupHW ();
	printf("Nach setupHW\n");
	uint8_t fb = 0;
	uint8_t start = 0;
	selectFramebuffer (fb);
	displayClear (0);
	uint8_t modulo = 0;
	uint32_t color = 0x000000FF;
	while (1)
	{
	  if (start > 0) {
	    uint32_t stall = IORD(MM_INTERFACE_TEST_0_BASE, 0x0001);
	    uint32_t position = IORD(MM_INTERFACE_TEST_0_BASE, 0x0002);
	    printf("         \n");
	    uint32_t counter0 = IORD(MM_INTERFACE_TEST_0_BASE, 0x0003);
	    printf("Stall: %x, position: %x, counter0: %d\n", stall, position, counter0);
	    while (IORD(MM_INTERFACE_TEST_0_BASE, 0x0000) == 0x00000000) {
	      stall = IORD(MM_INTERFACE_TEST_0_BASE, 0x0001);
	      position = IORD(MM_INTERFACE_TEST_0_BASE, 0x0002);
	      counter0 = IORD(MM_INTERFACE_TEST_0_BASE, 0x0003);
	      //printf("Stall: %x, position: %x, counter0: %d\n", stall, position, counter0);
	    }
	    for (int i = 0; i < 1e4; ++i) {
	      printf(" ");
	    }
	    printf("\nDONE\n");
	  }
	  else {
	    start++;
	  }
	  showFramebuffer(fb);
	  fb ^= 0x01;
	  uint32_t address = getAddress(fb);
	  IOWR(MM_INTERFACE_TEST_0_BASE, 0x0002, address);
	  modulo = (modulo + 1) % 3;
	  if (modulo == 0) {
	    color = 0x000000FF;
	  } else if (modulo == 1) {
	    color = 0x0000FF00;
	  } else {
	    color = 0x00FF0000;
	  }
	  IOWR(MM_INTERFACE_TEST_0_BASE, 0x0001, color);
	  IOWR(MM_INTERFACE_TEST_0_BASE, 0xFFFF, 0x00000000);
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
	// HW Reset hopefully
}

static void
init (
	uint8_t num_objects, sphere_t *spheres,
	uint16_t max_reflects, uint16_t num_samples)
{
	rtInit (num_objects, spheres, max_reflects, num_samples);
}

static void
setCamera (vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov, uint8_t frame_address)
{
	rtSetCamera (lookfrom, lookat, vfov, frame_address);
}

static void
renderFrame (void)
{
	rtRenderFrame ();
}
