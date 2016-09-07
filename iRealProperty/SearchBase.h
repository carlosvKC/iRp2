#import <Foundation/Foundation.h>
#import "SearchGroup.h"

@class GridDefinition;
@class ItemDefinition;

@interface SearchBase : NSObject<NSXMLParserDelegate>
{
    // List of groups
    NSMutableArray *searchGroups;
    // the XML parser
    NSXMLParser *xmlParser; 
        
    // working vars
    int level;
    SearchGroup     *searchGroup;
    NSString        *currElement;
    SearchDefinition2 *searchDefinition;
    SearchItem      *searchItem;
    GridDefinition  *grid;
    ItemDefinition  *itemDefinition;
    NSString        *defaultObject;
}
// Build the search tree
-(id)initWithXMLFile:(NSString *)xmlFile;

@property(nonatomic,retain) NSMutableArray *searchGroups;
@property(nonatomic) BOOL verbose;

-(SearchDefinition2 *)findDefinitionByTitle:(NSString *)titleName;
-(SearchDefinition2 *)findDefaultMapDefinition;
@end
