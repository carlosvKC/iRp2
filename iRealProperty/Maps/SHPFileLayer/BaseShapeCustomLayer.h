#import <ArcGIS/ArcGIS.h>
#import "shapefil.h"
#import "proj_api.h"
@class LayerInfo;


@interface BaseShapeCustomLayer : AGSGraphicsLayer
{
    // Column name of the related data with value will be display as title in the popup when you click over a shape. 
    NSString* titleColumnName;
    
    // Column name of the related data with value will be display as description in the popup when you click over a shape.
    NSString* descriptionColumName;
    
    // default symbol used to render the shapes.
    AGSSymbol* renderSymbol;
    
    // list of attribute names (columns of the related data) that the shapes in this layer has.
    NSArray* attributeNames;
    
    
}

// properties get set accessors.
@property (nonatomic, strong) NSString* titleColumnName;
@property (nonatomic, strong) NSString* descriptionColumName;
@property (nonatomic, strong) AGSSymbol* renderSymbol;
@property (nonatomic, strong) NSArray* attributeNames;

@end
