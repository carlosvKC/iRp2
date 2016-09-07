#import <Foundation/Foundation.h>
#import "BaseShapeCustomLayer.h"
@class LayerInfo;

@interface SHPFileLayer : BaseShapeCustomLayer<AGSInfoTemplateDelegate> {
    // pointer to the Shape file;
    SHPHandle sfile;
    
    // pointer to the DBF file containing the attributes of the shapes;
    DBFHandle dfile;
    
    // Path of the shape file.
    NSString* _filePath;
    
    // number of fields in the related data
    int fieldCount;
    
    // number of shapes/records in the shape file
    int recordCount;
    
    // type of shapes in the shape file
    int nShapeType;
    
    // boundaries
    double padfMinBound[4];
    
    double padfMaxBound[4];
    
    // current spation reference of the shape file
    AGSSpatialReference* spacialReference;
    
       
@private    
    // lambert conformal conical projection in case we need to reproject the layer
    projPJ pj_conic;
    
    // web mercator projection in case we need to reproject the layer.
    projPJ pj_latlong;

}

// open shape file and load the shapes into this layer.
-(void)openShapefile:(NSString*) filePath;

// initialization of the layer by opening a shape file.
-(id) initWithFileContents: (NSString*) filePath;
@end
