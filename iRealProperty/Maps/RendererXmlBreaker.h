#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class UniqueValueRenderer;
@class Renderer;
//
// ================================
//
@interface RendererXmlBreaker : NSObject<NSXMLParserDelegate> 
{
@private
    NSString    *currentElement;
    
    // the XML parser
    NSXMLParser *xmlParser; 
    
    // Working variables
    UniqueValueRenderer   *_uniqueValueRenderer;
    Renderer             *_renderer;
    // List of all the renderers
    NSMutableArray     *_allRenderers;

    
}
@property(nonatomic, strong) NSMutableArray *allRenderers;
@property(nonatomic, weak) NSArray *allLabels;

-(id)initWithXMLFile:(NSString *)xmlFile withLabels:(NSArray *)labels;
@end
//
// Definition of each <Renderer>
//
@interface Renderer : NSObject {
@private
    NSString    *_value;
    NSString    *_label;
    UIColor     *_color;
    AGSSimpleFillSymbol *_fillSymbol;

}
@property(nonatomic, strong) NSString *value;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) UIColor *color;
@property(nonatomic, strong) AGSSimpleFillSymbol *fillSymbol;
@end

//
// Definition of the <UniqueValueRenderer> ================================
//

@interface UniqueValueRenderer : AGSClassBreaksRenderer
{
@private
    NSString    *_rendererName;
    NSString    *_entityName;
    int         _lookupId;
    NSString    *_fieldName;
    NSString    *_whereClause;
    NSMutableArray  *_renderers;
    NSMutableArray  *_labelSets;
    NSMutableDictionary  *_variables;
    // Maintain the current context for this tread
    NSManagedObjectContext *_currentContext;
    // Cache for data
    NSMutableDictionary *_graphicCache;
    
    // Null symbol
    AGSSimpleFillSymbol *_graphicNull;
}
@property(nonatomic, strong) NSString *rendererName;
@property(nonatomic, strong) NSString *entityName;
@property(nonatomic) int lookupId;
@property(nonatomic, strong) NSString *fieldName;
@property(nonatomic, strong) NSString *whereClause;
@property(nonatomic, strong) NSMutableArray *renderers;
@property(nonatomic, strong) NSMutableArray *labelSets;
@property(nonatomic, strong) NSMutableDictionary *variables;
-(void)cleanUp;
@end
