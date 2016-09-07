#import <Foundation/Foundation.h>


@class RendererLabel;
@class AGSPoint;
@class AGSGraphic;

@interface RendererXmlLabel : NSObject<NSXMLParserDelegate> 
{
    NSString    *currentElement;
    
    // the XML parser
    NSXMLParser *xmlParser; 
    
    // Working variables
    RendererLabel *_label;
    // List of labels
    NSMutableArray     *_labels;
}
@property(nonatomic, strong) NSMutableArray *labels;

-(id)initWithXMLFile:(NSString *)xmlFile;
@end
//
// Definition of the <LabelSets> ================================
//
@interface RendererLabel : NSObject
{
@protected
    
    NSString    *_name;
    // Label specs
    int         _minAltitude;
    int         _maxAltitude;
    BOOL        _labelSpec1;
    BOOL        _labelSpec2;
    int         _labelSpecA;
    int         _labelSpecB;
    int         _labelSpecC;
    // Entity
    NSString    *_entity;
    NSString    *_whereClause;
    NSString    *_expression;
    // Font
    NSString    *_fontName;
    CGFloat     _fontSize;
    UIColor     *_fontColor;
    BOOL        _fontItalic;
    BOOL        _fontBold;

    // Managed Context
    NSManagedObjectContext *_currentContext;
    // Cache for the label
    NSMutableDictionary *_cacheLabels;
    NSArray *_emptyArray;
    
}
@property(nonatomic, strong) NSString    *name;
// Label specs
@property(nonatomic) int minAltitude;
@property(nonatomic) int maxAltitude;
@property(nonatomic) BOOL labelSpec1;
@property(nonatomic) BOOL labelSpec2;
@property(nonatomic) int labelSpecA;
@property(nonatomic) int labelSpecB;
@property(nonatomic) int labelSpecC;
// Entity
@property(nonatomic, strong) NSString    *entity;
@property(nonatomic, strong) NSString    *whereClause;
@property(nonatomic, strong) NSString    *expression;
// Font
@property(nonatomic, strong) NSString    *fontName;
@property(nonatomic) CGFloat fontSize;
@property(nonatomic, strong) UIColor     *fontColor;
@property(nonatomic) BOOL fontItalic;
@property(nonatomic) BOOL fontBold;

@property(nonatomic, strong) NSMutableDictionary *variables;

-(NSArray*)getLabelsForGraphic: (AGSGraphic*)graphic withCenter: (AGSPoint*)center;
-(void)cleanUp;

@end
