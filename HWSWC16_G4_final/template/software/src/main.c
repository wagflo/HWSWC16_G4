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
	uint8_t fb = 0;
	uint8_t start = 0;
	selectFramebuffer (fb);
	displayClear (0);
	
	displayClear(0xa0a0a0);
	//displayClear(0xa00000);
	
	//printf("Nach displayClear\n");
	showFramebuffer (fb & 0x01);
	//printf("Nach showFrambuffer\n");
	init (TEST_SCENE_SIZE, test_spheres, TEST_NUM_REFLECTS, 1);
	
	alt_timestamp_start ();
	
	printf("Nach Init\n");
	
	
	while (1)
	{
		if (TEST_SCENE_SIZE > 0) {
		  
			//printf("Test scene size should be > 0\n");
			vec3_t lookfrom, lookat;
			fix16_t vfov;

			testGetNextCamera (&lookfrom, &lookat, &vfov);
			setCamera (&lookfrom, &lookat, vfov);
			
			if (start >=1) {
			  //wait until the old picture is written
			  uint16_t read_base = 0xFF00 | (0x01 & fb);
			  
			  uint32_t countFirst = 0; 
			  uint32_t counter0, counter1, controls;
			  uint32_t rdoDirx, rdoDiry, rdoDirz, rdoData, oldRdoData;
			  uint32_t delReflDirx, delReflDiry, delReflDirz, delReflData;
			  uint32_t colInX, colInY, colInZ;
			  oldRdoData = 0x00000000;

			  while (IORD(MM_RAYTRACING_0_BASE, read_base) == 0x00000000) {

			  }
			
			  //show the time if the picture is the first one
			  
			  // printf ("Timestamp: %llu\n", alt_timestamp());
			  
			  //show the picture;
			  showFramebuffer (fb & 0x01);
			
			 
			 
			 for(int i = 0; i < 0; i++) { //4e4; ++i) {
			    printf(" ");
			  }
			 //displayClear(0xa0a0a0);
			}
			
			//printf("%d \n", start);
				
			start++;
			
			//fb = 0x11 & (fb + 1); ******************************************************************************** MK
			
			
			
			
			//write the frame address
			IOWR(MM_RAYTRACING_0_BASE, 0x3050, 0x00000000 | fb);
			//printf("Frame No: %x\n", 0x00000000 | frame_address);
			//finish the frame
			IOWR(MM_RAYTRACING_0_BASE, 0xFFFF, 0x00000000);
			//printf("Nach setCamera\n");
			alt_timestamp_start ();
			
			
		}
		
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
	IORD(MM_RAYTRACING_0_BASE, 0x5000);
	IORD(MM_RAYTRACING_0_BASE, 0x5000);
	IORD(MM_RAYTRACING_0_BASE, 0x5000);
	IORD(MM_RAYTRACING_0_BASE, 0x5000);
	IORD(MM_RAYTRACING_0_BASE, 0x5000);
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
