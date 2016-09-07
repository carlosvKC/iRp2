#import <Foundation/Foundation.h>
#import "MapLayerConfig.h"

@interface LayersXmlFileParser : NSObject<NSXMLParserDelegate> 
{
    NSString    *currentElement;
    
    // the XML parser
    NSXMLParser *xmlParser; 
    
    // Current object to fullfil
    MapLayerConfig  *mapLayerConfig;
    
    int _uid;
    NSTimeInterval timeNow;
}
-(id)initWithXMLFile:(NSString *)xmlFile;

@end
