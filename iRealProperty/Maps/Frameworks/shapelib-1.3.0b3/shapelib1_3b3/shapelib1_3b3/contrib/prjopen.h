/******************************************************************************
 * Copyright (c) 2011, Axelerate Inc
 *
 * This code is based in part on the earlier work of Frank Warmerdam and Carl Anderson
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************
 *
 * requires shapelib 1.2
 *   gcc shpproj ../shpopen.o ../dbfopen.o shpgeo.o -lm -lproj -o shpproj
 * 
 * this requires linking with the PROJ4.3 projection library available from
 *
 * ftp://kai.er.usgs.gov/ftp/PROJ.4
 *
 *
 * prjopen must be compiled with -DPROJ4 support
 */
//
//  prjopen.h
//  shapelib1_3b3
//
//  Created by Daniel Rojas on 9/13/11.

#ifndef SHPGEO_H

#define SHPGEO_H

#ifdef __cplusplus
extern "C" {
#endif
#include "proj_api.h"
#include "shpgeo.h"

extern projPJ SHPSetProjectionFromPRJFile ( const char* fileName );

#ifdef __cplusplus
}
#endif

#endif