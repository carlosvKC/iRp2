#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

extern const NSString* SHAPETYPEMULTILINESTRING;
extern const NSString* SHAPETYPEMULTIPOINT;
extern const NSString* SHAPETYPEMULTIPOLYGON;
extern const NSString* SHAPETYPELINESTRING;
extern const NSString* SHAPETYPEPOINT;
extern const NSString* SHAPETYPEPOLYGON;

typedef enum SupportedLayerFileTypes {
    SHPFILETYPE = 0,
    SQLITEFILETYPE = 1,
    CACHEFILETYPE = 2,
    MRSIDFILETYPE = 3
    } enumSupportedLayerFileTypes;
@class AGSLayer;

@interface LayerInfo : NSObject 
{
    NSString* fileName;
    NSString* filePath;
    int fileSize; // size in bytes
    int numShapes;
    int index;
    BOOL isLoaded;
    BOOL isVisible;
    enumSupportedLayerFileTypes fileType;
    
    NSString* tableName;
    NSString* geoColumnName;
    NSString* shapeTypeName;
    NSString* projection;
    AGSLayer* mapLayer;
    
}

@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, strong) NSString* projection;
@property (nonatomic, strong) AGSLayer* mapLayer;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int fileSize;
@property (nonatomic, assign) int numShapes;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) enumSupportedLayerFileTypes fileType;

// spetial metadata
@property (nonatomic, strong) NSString* tableName;
@property (nonatomic, strong) NSString* geoColumnName;
@property (nonatomic, strong) NSString* shapeTypeName;


+(AGSGeometryType)AGSGeometryTypeFromTypeName: (NSString*)shapeType;
+(AGSSimpleFillSymbolStyle)AGSSimpleFillSymbolStyleFromString:(NSString*)styleName;
+(NSString*)StringFromAGSSimpleFillSymbolStyle:(AGSSimpleFillSymbolStyle)style;
+(AGSSimpleLineSymbolStyle)AGSSimpleLineSymbolStyleFromString:(NSString*)styleName;
+(NSString*)StringFromAGSSimpleLineSymbolStyle:(AGSSimpleLineSymbolStyle)style;
+(AGSSimpleMarkerSymbolStyle)AGSSimpleMarkerSymbolStyleFromString:(NSString*)styleName;
+(NSString*)StringFromAGSSimpleMarkerSymbolStyle:(AGSSimpleMarkerSymbolStyle)style;
@end
