#import "LayerInfo.h"


const NSString* SHAPETYPEMULTILINESTRING = @"MULTILINESTRING";
const NSString* SHAPETYPEMULTIPOINT =  @"MULTIPOINT";
const NSString* SHAPETYPEMULTIPOLYGON =  @"MULTIPOLYGON";
const NSString* SHAPETYPELINESTRING = @"LINESTRING";
const NSString* SHAPETYPEPOINT = @"POINT";
const NSString* SHAPETYPEPOLYGON = @"POLYGON";

@implementation LayerInfo

@synthesize fileName;
@synthesize filePath;
@synthesize mapLayer;

@synthesize index;
@synthesize fileSize;
@synthesize numShapes;
@synthesize isLoaded;
@synthesize isVisible;
@synthesize fileType;

@synthesize tableName;
@synthesize geoColumnName;
@synthesize shapeTypeName;
@synthesize projection;

+(AGSGeometryType)AGSGeometryTypeFromTypeName: (NSString*)shapeType
{
    if([shapeType compare:(NSString*)SHAPETYPEMULTIPOINT options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return AGSGeometryTypeMultipoint;
    }
    else if([shapeType compare:(NSString*)SHAPETYPEMULTILINESTRING options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return AGSGeometryTypePolyline;
    }
    else if([shapeType compare:(NSString*)SHAPETYPEMULTIPOLYGON options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return AGSGeometryTypePolygon;
    }
    else if([shapeType compare:(NSString*)SHAPETYPEPOLYGON options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return AGSGeometryTypePolygon;
    }
    return AGSGeometryTypeUndefined;
}

+(AGSSimpleFillSymbolStyle)AGSSimpleFillSymbolStyleFromString:(NSString*)styleName
{
    if (styleName == NULL || [styleName compare:@"null" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleNull;
    else if ([styleName compare:@"backward diagonal" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleBackwardDiagonal;
    else if ([styleName compare:@"cross" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleCross;
    else if ([styleName compare:@"diagonal cross" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleDiagonalCross;
    else if ([styleName compare:@"forward diagonal" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleForwardDiagonal;
    else if ([styleName compare:@"horizontal" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleHorizontal;
    else if ([styleName compare:@"solid" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleSolid;
    else if ([styleName compare:@"vertical" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleFillSymbolStyleVertical;
    else
        return AGSSimpleFillSymbolStyleSolid;
}

+(NSString*)StringFromAGSSimpleFillSymbolStyle:(AGSSimpleFillSymbolStyle)style
{
    switch (style) {
        case AGSSimpleFillSymbolStyleNull:
            return @"Null";
        
        case AGSSimpleFillSymbolStyleBackwardDiagonal:
            return @"Backward Diagonal";
        
        case AGSSimpleFillSymbolStyleDiagonalCross:
            return @"Diagonal Cross";
        
        case AGSSimpleFillSymbolStyleForwardDiagonal:
            return @"Forward Diagonal";
            
        case AGSSimpleFillSymbolStyleCross:
            return @"Cross";
        
        case AGSSimpleFillSymbolStyleHorizontal:
            return @"Horizontal";
        
        case AGSSimpleFillSymbolStyleVertical:
            return @"Vertical";
        
        default:
            return @"Solid";
    }
}

+(AGSSimpleLineSymbolStyle)AGSSimpleLineSymbolStyleFromString:(NSString*)styleName
{
    if (styleName == NULL || [styleName compare:@"null" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleLineSymbolStyleNull;
    else if ([styleName compare:@"dash" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleLineSymbolStyleDash;
    else if ([styleName compare:@"dash dot" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleLineSymbolStyleDashDot;
    else if ([styleName compare:@"dot" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleLineSymbolStyleDot;
    else if ([styleName compare:@"inside frame" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleLineSymbolStyleInsideFrame;
    else if ([styleName compare:@"solid" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleLineSymbolStyleSolid;
    else
        return AGSSimpleLineSymbolStyleSolid;
}

+(NSString*)StringFromAGSSimpleLineSymbolStyle:(AGSSimpleLineSymbolStyle)style
{
    switch (style) {
        case AGSSimpleLineSymbolStyleNull:
            return @"Null";
            
        case AGSSimpleLineSymbolStyleDash:
            return @"Dash";
            
        case AGSSimpleLineSymbolStyleDashDot:
            return @"Dash Dot";
            
        case AGSSimpleLineSymbolStyleDot:
            return @"Dot";
            
        case AGSSimpleLineSymbolStyleInsideFrame:
            return @"Inside Frame";
            
        default:
            return @"Solid";
    }
}

+(AGSSimpleMarkerSymbolStyle)AGSSimpleMarkerSymbolStyleFromString:(NSString*)styleName
{
    if (styleName == NULL || [styleName compare:@"circle" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleMarkerSymbolStyleCircle;
    else if ([styleName compare:@"cross" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleMarkerSymbolStyleCross;
    else if ([styleName compare:@"diamond" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleMarkerSymbolStyleDiamond;
    else if ([styleName compare:@"square" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleMarkerSymbolStyleSquare;
    else if ([styleName compare:@"x" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        return AGSSimpleMarkerSymbolStyleX;
    else
        return AGSSimpleMarkerSymbolStyleCircle;
}

+(NSString*)StringFromAGSSimpleMarkerSymbolStyle:(AGSSimpleMarkerSymbolStyle)style
{
    switch (style) {
        case AGSSimpleMarkerSymbolStyleCircle:
            return @"Circle";
            
        case AGSSimpleMarkerSymbolStyleCross:
            return @"Cross";
            
        case AGSSimpleMarkerSymbolStyleDiamond:
            return @"Diamond";
            
        case AGSSimpleMarkerSymbolStyleSquare:
            return @"Square";
            
        case AGSSimpleMarkerSymbolStyleX:
            return @"x";
            
        default:
            return @"Circle";
    }
}
-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{fileName='%@'\nfilePath='%@'\nnumShapes=%d\nisLoaded=%d\nisVisible=%d\ntableName='%@'}\n", fileName,filePath,numShapes,isLoaded,isVisible,tableName];
    return result;
}
@end
