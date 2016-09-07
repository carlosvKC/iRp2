
/******************************************************************************
 * Copyright (c) 2011,Axelerate INC
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
 *   gcc shpproj shpopen.o dbfopen.o -lm -lproj -o shpproj
 * 
 * this may require linking with the PROJ4 projection library available from
 *
 * http://www.remotesensing.org/proj
 *
 * use -DPROJ4 to compile in Projection support
 */
//  prjopen.c
//  shapelib1_3b3
//
//  Created by Daniel Rojas on 9/13/11.
//  Copyright 2011 Axelerate INC. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include "shapefil.h"

#ifndef NAN
#include "my_nan.h"
#endif
#include "shpgeo.h"
#include "prjopen.h"
/* **************************************************************************
 * SHPSetProjectionFromPRJFile
 *
 * establish a projection handle for use with PROJ4.3 base on .prj file that can come with the shp file
 *
 * act as a wrapper to protect against library changes in PROJ
 *
 * **************************************************************************/
projPJ SHPSetProjectionFromPRJFile ( const char* fileName ) {
#ifdef PROJ4
    projPJ	*p = NULL;
    FILE	*ifp = NULL;
    char	*params[16];
    char	parg[1024];
    int param_cnt = 0;
    int i;
    
    ifp = fopen( asFileName ( fileName, "prj" ),"rt");
    i = 0;
    if ( ifp ) {
        while( fscanf( ifp, "%s", parg) != EOF ) {
            params[i] = malloc ( strlen(parg)+1 );
            strcpy ( params[i], parg);
            i++;
        }
        
        param_cnt = i;
        fclose (ifp);
        
        
        if ( param_cnt > 0 && params[0] )
        { p = pj_init ( param_cnt, params ); }
    }
    return ( p );
#else
    return ( NULL );
#endif
}
