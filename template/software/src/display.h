#include <stdint.h>

#ifndef DISPLAY_H
#define DISPLAY_H

#ifdef __cplusplus
extern "C"
{
#endif

void displayInit (uint32_t framebuffer0, uint32_t framebuffer1);
//selects the buffer which is used by the drawing functions
void selectFramebuffer (uint8_t fb_num);
//selects the buffer which is read by the framereader
void showFramebuffer (uint8_t fb_num);

void displaySetPixel (uint32_t y, uint32_t x, uint32_t rgb);
void displayClear (uint32_t rgb);

#ifdef __cplusplus
}
#endif

#endif
