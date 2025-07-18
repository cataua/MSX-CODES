/*---------------------------------------------------------------------------*
 * binary.c                                                                  *
 * Copyright (C) 2014  Jacques Pelletier                                     *
 *                                                                           *
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:
  Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *---------------------------------------------------------------------------*/

#include <stdint.h>

#include "binary.h"

const uint8_t Reflect8[256] = {
  0x00,0x80,0x40,0xC0,0x20,0xA0,0x60,0xE0,0x10,0x90,0x50,0xD0,0x30,0xB0,0x70,0xF0,
  0x08,0x88,0x48,0xC8,0x28,0xA8,0x68,0xE8,0x18,0x98,0x58,0xD8,0x38,0xB8,0x78,0xF8,
  0x04,0x84,0x44,0xC4,0x24,0xA4,0x64,0xE4,0x14,0x94,0x54,0xD4,0x34,0xB4,0x74,0xF4,
  0x0C,0x8C,0x4C,0xCC,0x2C,0xAC,0x6C,0xEC,0x1C,0x9C,0x5C,0xDC,0x3C,0xBC,0x7C,0xFC,
  0x02,0x82,0x42,0xC2,0x22,0xA2,0x62,0xE2,0x12,0x92,0x52,0xD2,0x32,0xB2,0x72,0xF2,
  0x0A,0x8A,0x4A,0xCA,0x2A,0xAA,0x6A,0xEA,0x1A,0x9A,0x5A,0xDA,0x3A,0xBA,0x7A,0xFA,
  0x06,0x86,0x46,0xC6,0x26,0xA6,0x66,0xE6,0x16,0x96,0x56,0xD6,0x36,0xB6,0x76,0xF6,
  0x0E,0x8E,0x4E,0xCE,0x2E,0xAE,0x6E,0xEE,0x1E,0x9E,0x5E,0xDE,0x3E,0xBE,0x7E,0xFE,
  0x01,0x81,0x41,0xC1,0x21,0xA1,0x61,0xE1,0x11,0x91,0x51,0xD1,0x31,0xB1,0x71,0xF1,
  0x09,0x89,0x49,0xC9,0x29,0xA9,0x69,0xE9,0x19,0x99,0x59,0xD9,0x39,0xB9,0x79,0xF9,
  0x05,0x85,0x45,0xC5,0x25,0xA5,0x65,0xE5,0x15,0x95,0x55,0xD5,0x35,0xB5,0x75,0xF5,
  0x0D,0x8D,0x4D,0xCD,0x2D,0xAD,0x6D,0xED,0x1D,0x9D,0x5D,0xDD,0x3D,0xBD,0x7D,0xFD,
  0x03,0x83,0x43,0xC3,0x23,0xA3,0x63,0xE3,0x13,0x93,0x53,0xD3,0x33,0xB3,0x73,0xF3,
  0x0B,0x8B,0x4B,0xCB,0x2B,0xAB,0x6B,0xEB,0x1B,0x9B,0x5B,0xDB,0x3B,0xBB,0x7B,0xFB,
  0x07,0x87,0x47,0xC7,0x27,0xA7,0x67,0xE7,0x17,0x97,0x57,0xD7,0x37,0xB7,0x77,0xF7,
  0x0F,0x8F,0x4F,0xCF,0x2F,0xAF,0x6F,0xEF,0x1F,0x9F,0x5F,0xDF,0x3F,0xBF,0x7F,0xFF,
};

uint16_t Reflect16(uint16_t Value16)
{
  return (((uint16_t) Reflect8[u16_lo(Value16)]) << 8) | ((uint16_t) Reflect8[u16_hi(Value16)]);
}

uint32_t Reflect24(uint32_t Value24)
{
  return (
		  (((uint32_t) Reflect8[u32_b0(Value24)]) << 16) |
		  (((uint32_t) Reflect8[u32_b1(Value24)]) << 8)  |
		   ((uint32_t) Reflect8[u32_b2(Value24)])
		  );
}

uint32_t Reflect32(uint32_t Value32)
{
  return (
		  (((uint32_t) Reflect8[u32_b0(Value32)]) << 24) |
		  (((uint32_t) Reflect8[u32_b1(Value32)]) << 16) |
		  (((uint32_t) Reflect8[u32_b2(Value32)]) << 8)  |
		   ((uint32_t) Reflect8[u32_b3(Value32)])
		  );
}

uint64_t Reflect40(uint64_t Value40)
{
  return (
		  (((uint64_t) Reflect8[u64_b0(Value40)]) << 32) |
		  (((uint64_t) Reflect8[u64_b1(Value40)]) << 24) |
		  (((uint64_t) Reflect8[u64_b2(Value40)]) << 16) |
		  (((uint64_t) Reflect8[u64_b3(Value40)]) << 8)  |
		   ((uint64_t) Reflect8[u64_b4(Value40)])
		  );
}

uint64_t Reflect64(uint64_t Value64)
{
  return (
		  (((uint64_t) Reflect8[u64_b0(Value64)]) << 56) |
		  (((uint64_t) Reflect8[u64_b1(Value64)]) << 48) |
		  (((uint64_t) Reflect8[u64_b2(Value64)]) << 40) |
		  (((uint64_t) Reflect8[u64_b3(Value64)]) << 32) |
		  (((uint64_t) Reflect8[u64_b4(Value64)]) << 24) |
		  (((uint64_t) Reflect8[u64_b5(Value64)]) << 16) |
		  (((uint64_t) Reflect8[u64_b6(Value64)]) << 8)  |
		   ((uint64_t) Reflect8[u64_b7(Value64)])
		  );
}

uint8_t u16_hi(uint16_t value)
{
	return (uint8_t)((value & 0xFF00) >> 8);
}

uint8_t u16_lo(uint16_t value)
{
	return (uint8_t)(value & 0x00FF);
}

uint8_t u32_b3(uint32_t value)
{
	return (uint8_t)((value & 0xFF000000) >> 24);
}

uint8_t u32_b2(uint32_t value)
{
	return (uint8_t)((value & 0x00FF0000) >> 16);
}

uint8_t u32_b1(uint32_t value)
{
	return (uint8_t)((value & 0x0000FF00) >> 8);
}

uint8_t u32_b0(uint32_t value)
{
	return (uint8_t)(value & 0x000000FF);
}

uint8_t u64_b7(uint64_t value)
{
	return (uint8_t)((value & 0xFF00000000000000) >> 56);
}

uint8_t u64_b6(uint64_t value)
{
	return (uint8_t)((value & 0x00FF000000000000) >> 48);
}

uint8_t u64_b5(uint64_t value)
{
	return (uint8_t)((value & 0x0000FF0000000000) >> 40);
}

uint8_t u64_b4(uint64_t value)
{
	return (uint8_t)((value & 0x000000FF00000000) >> 32);
}

uint8_t u64_b3(uint64_t value)
{
	return (uint8_t)((value & 0x00000000FF000000) >> 24);
}

uint8_t u64_b2(uint64_t value)
{
	return (uint8_t)((value & 0x0000000000FF0000) >> 16);
}

uint8_t u64_b1(uint64_t value)
{
	return (uint8_t)((value & 0x000000000000FF00) >> 8);
}

uint8_t u64_b0(uint64_t value)
{
	return (uint8_t)(value & 0x00000000000000FF);
}

/* Checksum/CRC conversion to ASCII */
uint8_t nibble2ascii(uint8_t value)
{
  uint8_t result = value & 0x0f;

  if (result > 9) return result + 0x41-0x0A;
  else return result + 0x30;
}

bool cs_isdecdigit(char c)
{
    return (c >= 0x30) && (c < 0x3A);
}

unsigned char tohex(unsigned char c)
{
  if ((c >= '0') && (c < '9'+1))
    return (c - '0');
  if ((c >= 'A') && (c < 'F'+1))
    return (c - 'A' + 0x0A);
  if ((c >= 'a') && (c < 'f'+1))
    return (c - 'a' + 0x0A);

  return 0;
}

unsigned char todecimal(unsigned char c)
{
  if ((c >= '0') && (c < '9'+1))
    return (c - '0');

  return 0;
}


