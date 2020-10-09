// SPDX-License-Identifier: GPL-2.0-only
/*
 * This file is part of the Arduino_OX767X library.
 * Copyright (c) 2020 Arduino SA. All rights reserved.
 */

#ifndef _OV767X_H_
#define _OV767X_H_

#include <Arduino.h>
#if defined(__IMXRT1062__)  // Teensy 4.x
#include <DMAChannel.h>
#define OV7670_VSYNC 2
#define OV7670_HREF  3
#define OV7670_PLK   4
#define OV7670_XCLK  5
#define OV7670_D0    14 // AD_B1_02 1.18
#define OV7670_D1    15 // AD_B1_03 1.19
#define OV7670_D3    16 // AD_B1_07 1.23
#define OV7670_D2    17 // AD_B1_06 1.22
#define OV7670_D6    20 // AD_B1_10
#define OV7670_D7    21 // AD_B1_11
#define OV7670_D4    22 // AD_B1_08
#define OV7670_D5    23 // AD_B1_09
#else
#define OV7670_VSYNC 8
#define OV7670_HREF  A1
#define OV7670_PLK   A0
#define OV7670_XCLK  9
#define OV7670_D0    10
#define OV7670_D1    1
#define OV7670_D2    0
#define OV7670_D3    2
#define OV7670_D4    3
#define OV7670_D5    5
#define OV7670_D6    6
#define OV7670_D7    4
#endif
enum
{
  YUV422 = 0,
  RGB444 = 1,
  RGB565 = 2,
  // SBGGR8 = 3
  GRAYSCALE = 4
};

enum
{
  VGA = 0,  // 640x480
  CIF = 1,  // 352x240
  QVGA = 2, // 320x240
  QCIF = 3,  // 176x144
  QQVGA = 4,  // 160x120
};

class OV767X
{
public:
  OV767X();
  virtual ~OV767X();

  int begin(int resolution, int format, int fps); // Supported FPS: 1, 5, 10, 15, 30
  void end();

  // must be called after Camera.begin():
  int width() const;
  int height() const;
  int bitsPerPixel() const;
  int bytesPerPixel() const;

  void readFrame(void* buffer);
  void readFrameDMA(void* buffer);

  void testPattern(int pattern = 2);
  void noTestPattern();

  void setSaturation(int saturation); // 0 - 255
  void setHue(int hue); // -180 - 180
  void setBrightness(int brightness); // 0 - 255
  void setContrast(int contrast); // 0 - 127
  void horizontalFlip();
  void noHorizontalFlip();
  void verticalFlip();
  void noVerticalFlip();
  void setGain(int gain); // 0 - 255
  void autoGain();
  void setExposure(int exposure); // 0 - 65535
  void autoExposure();

  // must be called before Camera.begin()
  void setPins(int vsync, int href, int pclk, int xclk, const int dpins[8]);

private:
  void beginXClk();
  void endXClk();

private:
  int _vsyncPin;
  int _hrefPin;
  int _pclkPin;
  int _xclkPin;
  int _dPins[8];

  int _width;
  int _height;
  int _bytesPerPixel;
  bool _grayscale;

  void* _ov7670;

  volatile uint32_t* _vsyncPort;
  uint32_t _vsyncMask;
  volatile uint32_t* _hrefPort;
  uint32_t _hrefMask;
  volatile uint32_t* _pclkPort;
  uint32_t _pclkMask;

  int _saturation;
  int _hue;

  // Lets try adding some DMA support.
  #if defined(__IMXRT1062__)  // Teensy 4.x
      enum {DMABUFFER_SIZE=2560};  // 640x480  so 640*2*2
      static DMAChannel _dmachannel;
      static DMASetting _dmasettings[2];
      static uint32_t _dmaBuffer[DMABUFFER_SIZE];
      uint16_t _rows_per_dma;
      uint16_t _pixels_per_dma;
      uint32_t _rows_left_dma;
      uint16_t *_frame_buffer_pointer;
      uint16_t _dma_index;
      volatile bool _dma_done;
  static void dmaInterrupt(); 
  void processDMAInterrupt();

  #endif
};

extern OV767X Camera;

#endif
