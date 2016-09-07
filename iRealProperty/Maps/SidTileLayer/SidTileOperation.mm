// Copyright 2010 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//
#import "SidTileOperation.h"


#include "lt_fileSpec.h"
#include "lti_scene.h"
#include "lti_sceneBuffer.h"
#include "lti_navigator.h"
#include "lti_utils.h"
#include "lt_utilStatusStrings.h"

#include "MrSIDImageReader.h"



LT_USE_NAMESPACE(LizardTech);

@implementation SidTileOperation

@synthesize tile=_tile;
@synthesize lod = _lod;
@synthesize target=_target;
@synthesize action=_action;
@synthesize sidFileName=_sidFileName;

- (id)initWithTile:(AGSTile *)tile lod:(AGSLOD *)lod target:(id)target action:(SEL)action andSidFileName: (NSString *)sidFileName{
	
	if (self = [super init]) {
		self.target = target;
		self.action = action;
		self.lod = lod;
        self.tile = tile;
        self.sidFileName = sidFileName;
		
	}
	return self;
}

-(void)main {
	//Fetch the tile for the requested Level, Row, Column
	@try {
        /*if (self.tile.level >= 10) {
            if (_action != nil)
            {
                [_target performSelector:_action withObject:self];
            }
            return;
        }*/
		//Level ('L' followed by 2 decimal digits)
		// NSString *decLevel = [NSString stringWithFormat:@"L%02d",self.tile.level];
		//Row ('R' followed by 8 hex digits)
		// NSString *hexRow = [NSString stringWithFormat:@"R%08x",self.tile.row];
		//Column ('C' followed by 8 hex digits)  
		// NSString *hexCol = [NSString stringWithFormat:@"C%08x",self.tile.column];
		
		// NSString* dir = [NSString stringWithFormat:@"Layers/_alllayers/%@/%@",decLevel,hexRow];
		
        //Get the tile from the sid file
        //_tile.image= [UIImage imageWithData:data];
        
        const LizardTech::LTFileSpec fileSpec([self.sidFileName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
        LizardTech::MrSIDImageReader* reader = MrSIDImageReader::create();
        if(reader == NULL){
            NSLog(@"Sid file was not found at %@", _sidFileName);
            return;
        }
        
        LT_STATUS sts = reader->initialize(fileSpec);
        if (sts != LT_STS_Success)
        {
            const char* status = getLastStatusString(sts);
            NSString* nsStatus = [NSString stringWithCString:status encoding:[NSString defaultCStringEncoding]];
            NSLog(@"ERROR initializing SidTileLayer: %@", nsStatus);
            ((LizardTech::MrSIDImageReader*)reader)->release();
            reader = NULL;

            return;
        }
        
        LizardTech::LTINavigator* nav = new LizardTech::LTINavigator(*((LizardTech::MrSIDImageReader*)reader));
        const LizardTech::LTIGeoCoord& geo = ((LizardTech::MrSIDImageReader*)reader)->getGeoCoord();
        int numBands = reader->getNumBands();
        
        double ulx = _tile.envelope.xmin;
        double uly = _tile.envelope.ymin;
        double lrx = _tile.envelope.xmax;
        double lry = _tile.envelope.ymax;
        //double res = (1.0 / _lod.resolution); //512 / (_tile.envelope.width / geo.getXRes());
        double tileSize = 512.0; // Size of the tile image. The width and the Height have are the same.
        double res = tileSize / (_tile.envelope.width / geo.getXRes());
        // I have inverted the Y because seem like this is necesary for the sid file.
        sts = ((LizardTech::LTINavigator*)nav)->setSceneAsGeoULLR(MIN(ulx, lrx), MAX(uly, lry), MAX(ulx, lrx), MIN(uly, lry), res);
        if (sts != LT_STS_Success)
        {
            const char* status = getLastStatusString(sts);
            NSString* nsStatus = [NSString stringWithCString:status encoding:[NSString defaultCStringEncoding]];
            NSLog(@"ERROR: %@", nsStatus);
            ((LizardTech::MrSIDImageReader*)reader)->release();
            reader = NULL;
            delete nav;
            return;
        }
        nav->clipToImage();
        
        LTIDataType datatype = ((LizardTech::MrSIDImageReader*)reader)->getDataType();
        const lt_uint32 bytesPerSample = LTIUtils::getNumBytes(datatype);
        //double currentMag = ((LizardTech::LTINavigator*)nav)->getMag();
        const LizardTech::LTIScene& scene = ((LizardTech::LTINavigator*)nav)->getScene();
        
        //((LizardTech::LTINavigator*)nav)->zoomTo(_zoomfactor, LTINavigator::STYLE_CLIP);
        int w = scene.getNumCols();
        int h = scene.getNumRows();
    
        const lt_uint32 numPixels = scene.getNumCols() * scene.getNumRows();
        const lt_uint32 bytesPerBands = numPixels * bytesPerSample;
        
        lt_uint8 **bsqData = new lt_uint8 *[numBands];
        for(lt_uint16 i = 0; i < numBands; i++)
            bsqData[i] = new lt_uint8[bytesPerBands];
        
        LTISceneBuffer sceneBuffer(((LizardTech::MrSIDImageReader*)reader)->getPixelProps(),
                                   scene.getNumCols(),
                                   scene.getNumRows(),
                                   reinterpret_cast<void **>(bsqData));
        
        // perform the decode
        sts = ((LizardTech::MrSIDImageReader*)reader)->read(scene, sceneBuffer);
        if (sts != LT_STS_Success)
        {
            const char* status = getLastStatusString(sts);
            NSString* nsStatus = [NSString stringWithCString:status encoding:[NSString defaultCStringEncoding]];
            NSLog(@"ERROR: %@", nsStatus);
        }
        else {
            // NSLog(@"Read time in sec %0.2f", timeQuery - CACurrentMediaTime());
            // timeQuery = CACurrentMediaTime();
            unsigned char *outputData = (unsigned char *)malloc(sizeof(unsigned char) * w * h * 4);
            
            sceneBuffer.exportData(outputData, 4, sizeof(unsigned char) * w * 4, 1);
            
            
            CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
            CGContextRef bitmapContext=CGBitmapContextCreate(outputData, w, h, 8, 4*w, colorSpace,  kCGImageAlphaNoneSkipLast| kCGBitmapByteOrderDefault);
            
            CGImageRef cgImage=CGBitmapContextCreateImage(bitmapContext);
            CGContextRelease(bitmapContext);
            if (w < tileSize || h < tileSize)
            {
                bitmapContext=CGBitmapContextCreate(NULL, tileSize, tileSize, 8, 4*tileSize, colorSpace,  kCGImageAlphaPremultipliedLast| kCGBitmapByteOrderDefault);
                const LizardTech::LTIGeoCoord& newGeo = nav->getGeoCoord();
                double x = (newGeo.getX() - MIN(ulx , lrx)) * res;
                double y = (newGeo.getY() - MIN(uly , lry)) * res;
                if (MIN(ulx , lrx) < newGeo.getX())
                {
                    x = 0;
                }
                if (newGeo.getY() > MIN(uly , lry) )
                {
                    y = tileSize - h;
                }
                CGContextDrawImage(bitmapContext, CGRectMake(x, y, w, h), cgImage);
                cgImage=CGBitmapContextCreateImage(bitmapContext);
                CGContextRelease(bitmapContext);

            }
            
            UIImage * newimage = [UIImage imageWithCGImage:cgImage];
            
            _tile.image = newimage ;
            // NSLog(@"Conver to UIImage in sec %0.2f", timeQuery - CACurrentMediaTime());
            CGImageRelease(cgImage);
            CFRelease(colorSpace);
            free(outputData);
        }
        delete ((LizardTech::LTINavigator*)nav);
        nav = NULL;
        ((LizardTech::MrSIDImageReader*)reader)->release();
        reader = NULL;

        
        
	}
	@catch (NSException *exception) {
		NSLog(@"main: Caught Exception %@: %@", [exception name], [exception reason]);
	}	
	@finally {
		//Invoke the layer's action method
        if (_action != nil)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
        }
        /* this is how to remove the warning... but will require time to change the methods and the reference to use a string name for the selector until this point when the selecter is converted in a method call (assuming that it will work because this selector come from other object. May can be fixed by using some kind of delegate model instead. For the moment is easier just keep the warning here.
         SEL mySelector = NSSelectorFromString(@"someMethod"); if (mySelector != nil) { [_controller performSelector:mySelector]; }
         */
	}
}


- (void)dealloc {
	self.action = nil;
}

@end


