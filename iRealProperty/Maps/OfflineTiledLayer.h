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
#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface OfflineTiledLayer : AGSTiledLayer  {
@protected
	NSString* _dataFramePath;
    NSString* _appDocumentsPath;
    NSString* _zipFileName;
	AGSTileInfo* _tileInfo;
	AGSEnvelope* _fullEnvelope;	
	AGSUnits _units;
}

@property (nonatomic,strong,readwrite) NSString* dataFramePath;
@property (nonatomic,strong,readwrite) NSString* appDocumentsPath;
@property (nonatomic,strong,readwrite) NSString* zipFileName;

- (id)initWithDataFramePath: (NSString *)path error:(NSError**)outError ;

+ (NSString *)getMapsDirectory;
+ (NSString *)getPrivateDocsDir;
+ (void) getMapTiles;
+(NSData *) getCDIFile:(NSString *)zipPath andFile:(NSString *)file;

@end
