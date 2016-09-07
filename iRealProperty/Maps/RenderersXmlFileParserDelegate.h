#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
@class RendererLabel;
@interface RenderersXmlFileParserDelegate : NSObject <NSXMLParserDelegate> 
{
@protected
	NSString *_currentElement;
    AGSClassBreaksRenderer* _currentClassBreakRenderer;
    AGSUniqueValueRenderer* _currentUniqueValueRenderer;
    NSMutableArray* _labelSets;
    RendererLabel* _currentLabelSet;
    
    NSString* _rendererName;
    NSMutableArray* _renderers;
    BOOL parsingClassBreakRenderer;
    BOOL parsingUniqueValueRenderer;
    BOOL parsingRI;
    NSString* _RIValue;
    double _RILBrk;
    double _RIUBrk;
    NSString* _RILabel;
    NSString* _RIColor;
    
	NSError* _error;
    BOOL _rootNodeFinded;
    
    NSMutableDictionary* _classBreakRenderers;
    NSMutableDictionary* _uniqueValueRenderers;
    NSMutableDictionary* _labelSetsByRenderer;
}

@property (nonatomic,strong,readwrite) NSString* currentElement;
@property (nonatomic,strong,readwrite) NSError* error;

@property (nonatomic,strong) NSMutableDictionary* classBreakRenderers;
@property (nonatomic,strong) NSMutableDictionary* uniqueValueRenderers;
@property (nonatomic,strong) NSMutableDictionary* labelSetsByRenderer;
@end
