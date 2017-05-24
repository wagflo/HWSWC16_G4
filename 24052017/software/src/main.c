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
	printf("Vor setupHW\n");
	setupHW ();
	printf("Nach setupHW\n");
	init(3, &test1_spheres, 7, 16);
	
	uint8_t fb = 0;
	uint8_t start = 0;
	selectFramebuffer (fb);
	displayClear (0);
	uint8_t modulo = 0;
	uint32_t hit1 = 0x00000000;
	uint32_t hit2 = 0x00000000;
	uint32_t hit3 = 0x00000000;
	while (1)
	{
	  vec3_t lookfrom, lookat;
	  fix16_t vfov;
	  testGetNextCamera (&lookfrom, &lookat, &vfov);
	  setCamera (&lookfrom, &lookat, vfov);
	  if (start > 0) {
	    /*uint32_t stall = IORD(MM_INTERFACE_TEST_0_BASE, 0x0001);
	    uint32_t position = IORD(MM_INTERFACE_TEST_0_BASE, 0x0002);
	    printf("         \n");
	    uint32_t counter0 = IORD(MM_INTERFACE_TEST_0_BASE, 0x0003);
	    uint32_t old_counter = counter0;
	    printf("Stall: %x, position: %x, counter0: %d\n", stall, position, counter0);*/
	    while (IORD(MM_INTERFACE_TEST_0_BASE, 0xFF00 | (0x03 & fb)) == 0x00000000) {
	      /*stall = IORD(MM_INTERFACE_TEST_0_BASE, 0x0001);
	      position = IORD(MM_INTERFACE_TEST_0_BASE, 0x0002);
	      counter0 = IORD(MM_INTERFACE_TEST_0_BASE, 0x0003);
	      if (old_counter != counter0) {
		printf("Stall: %x, position: %x, counter0: %d\n", stall, position, counter0);
	      }
	      old_counter = counter0;*/
	      ;
	    }
	    /*for (int i = 0; i < 1e0; ++i) {
	      printf(" ");
	    }*/
	    //printf ("Output: %llu\n", alt_timestamp ());
	  }
	  else {
	    start++;
	  }
	  showFramebuffer(fb);
	  fb ^= 0x01;
	  IOWR(MM_INTERFACE_TEST_0_BASE, 0x3050, 0x00000003 & fb);
	  IOWR(MM_INTERFACE_TEST_0_BASE, 0xFFFF, 0x00000000);
	  //alt_timestamp_start ();
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
	//rtInit (num_objects, spheres, max_reflects, num_samples);
	if (num_objects > MAX_NUM_OBJECTS) {
	  num_objects = MAX_NUM_OBJECTS;
	}
	uint32_t sphere_ena = 0x00000000;
	uint32_t general_data = 0x00000000;
	general_data = general_data | ((0x0000000F & (num_objects - 1)) << 28);
	general_data = general_data | ((0x0000000F & max_reflects) << 24);
	general_data = general_data | ((0x000000FF & num_samples) << 16);

	for (uint8_t i = 0; i < num_objects; ++i) {
		sphere_ena = sphere_ena | (0x00000001 << i);
		uint16_t i_16 = (0x000F & (uint16_t) i) << 8;
		uint16_t spheres_address = 0x1000;
		uint16_t radius2 = 0x0020;
		uint16_t rad_inv = 0x0010;
		uint16_t center = 0x0030;
		uint16_t color = 0x0040;
		uint16_t emitting = 0x0050;
		uint16_t x = 0x0001;
		uint16_t y = 0x0002;
		uint16_t z = 0x0003;
		//Write the radius2 to the memory mapped interface
		uint16_t address = spheres_address | i_16 | radius2;
		uint32_t data = fix16_mul(spheres[i].radius, spheres[i].radius);
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		//write inverse rad to the memory mapped interface
		address = spheres_address | i_16 | rad_inv;
		data = fix16_div(0x00010000, spheres[i].radius);
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		//write the center to the memory mapped interface
		address = spheres_address | i_16 | center | x;
		data = spheres[i].center.x[0];
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		address = spheres_address | i_16 | center | y;
		data = spheres[i].center.x[1];
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		address = spheres_address | i_16 | center | z;
		data = spheres[i].center.x[2];
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		//write the color to the memory mapped interface
		address = spheres_address | i_16 | color | x;
		data = spheres[i].color.x[0];
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		address = spheres_address | i_16 | color | y;
		data = spheres[i].color.x[1];
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		address = spheres_address | i_16 | color | z;
		data = spheres[i].color.x[2];
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
		//write emitting to the memory mapped interface
		address = spheres_address | i_16 | emitting;
		if (spheres[i].mat == EMITTING) {
			data = 0x00000001;
		} else {
			data= 0x00000000;
			
		}
		IOWR(MM_INTERFACE_TEST_0_BASE, address, data);
	}
	//write the general data to the memory mapped interface
	general_data = general_data | (0x0000FFFF & sphere_ena);
	IOWR(MM_INTERFACE_TEST_0_BASE, 0x2000, general_data);
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
