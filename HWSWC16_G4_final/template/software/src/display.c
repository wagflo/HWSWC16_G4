#include "display.h"
#include "defs.h"
#include "system.h"
#include <io.h>

static uint32_t frame_buffers[2];

static uint32_t cur_base;

void
displayInit (uint32_t framebuffer0, uint32_t framebuffer1)
{
	IOWR(FRAMEREADER_BASE, 3, 0x0);
	IOWR(FRAMEREADER_BASE, 4, framebuffer0); //frame 0 base address
	IOWR(FRAMEREADER_BASE, 5, FRAME_WIDTH*FRAME_HEIGHT);
	IOWR(FRAMEREADER_BASE, 6, FRAME_WIDTH*FRAME_HEIGHT);
	IOWR(FRAMEREADER_BASE, 8, FRAME_WIDTH);    //frame 0 width
	IOWR(FRAMEREADER_BASE, 9, FRAME_HEIGHT);    //frame 0 height

	IOWR(FRAMEREADER_BASE, 11, framebuffer1); //frame 1 base address
	IOWR(FRAMEREADER_BASE, 12, FRAME_WIDTH*FRAME_HEIGHT);
	IOWR(FRAMEREADER_BASE, 13, FRAME_WIDTH*FRAME_HEIGHT);
	IOWR(FRAMEREADER_BASE, 15, FRAME_WIDTH);    //frame 1 width
	IOWR(FRAMEREADER_BASE, 16, FRAME_HEIGHT);    //frame 1 height

	
	IOWR(MM_RAYTRACING_0_BASE, 0x4010, framebuffer0);
	IOWR(MM_RAYTRACING_0_BASE, 0x4020, framebuffer1);
	//enable frame reader
	IOWR(FRAMEREADER_BASE, 0, 0x1);    //control register

	cur_base = framebuffer0;
	frame_buffers[0] = framebuffer0;
	frame_buffers[1] = framebuffer1;
}

void
selectFramebuffer (alt_u8 fb_num)
{
	cur_base = frame_buffers[(0x01 & fb_num)];
}

void
showFramebuffer (alt_u8 fb_num)
{
	IOWR(FRAMEREADER_BASE, 3, 0x01 & fb_num);
}

void
displaySetPixel (uint32_t y, uint32_t x, uint32_t rgb)
{
	IOWR(cur_base, (y*FRAME_WIDTH + x), rgb);
	return;
}

void
displayClear (uint32_t rgb)
{
	uint32_t i;
	for(i = 0; i < FRAME_WIDTH*FRAME_HEIGHT; ++i)
	{
		IOWR(cur_base, i, rgb);
	}
}

void
displayPattern (void)
{
	uint32_t i,j;
	for(i = 0; i < FRAME_HEIGHT; ++i)
	  for(j = 0; j < FRAME_WIDTH; ++i)
	    {
		IOWR(cur_base, (i*FRAME_WIDTH + j), 0x0f0f0f);
	    }
}

uint32_t getAddress(uint8_t fb) {
  return frame_buffers[fb & 0x01];
}
