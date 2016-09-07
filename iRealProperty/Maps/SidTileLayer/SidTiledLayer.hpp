
#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface SidTiledLayer : AGSTiledLayer  {
@protected
	NSString* _dataFramePath;
    NSString* _appDocumentsPath;
    NSString* _sidFileName;
	AGSTileInfo* _tileInfo;
	AGSEnvelope* _fullEnvelope;	
	AGSUnits _units;
}

@property (nonatomic,strong,readwrite) NSString* dataFramePath;
@property (nonatomic,strong,readwrite) NSString* appDocumentsPath;
@property (nonatomic,strong,readwrite) NSString* sidFileName;

- (id)initWithDataFramePath: (NSString *)path error:(NSError**)outError ;



@end
