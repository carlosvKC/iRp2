#import <Foundation/Foundation.h>
#import "EntityStructure.h"
#import "MenuItem.h"
#import "Options.h"

@interface EntityBase : NSObject<NSXMLParserDelegate>
{
    BOOL            verbose;
    // the XML parser
    NSXMLParser     *xmlParser; 
    // level
    int             level;
    // Current element
    NSString        *currElement;
    
    //////////////////////////////////////// scratch variables
    EntityDef       *entityDefinition;
    PropertyDef     *propertyDefinition;
    ItemDefinition  *itemDefinition;
    MenuItem        *menuItem;
    NSString        *defaultObject;
    ScreenDefinition *screen;
    GridDefinition   *grid;
    MenuDefinition  *menu;
    MultiScreenDefinition *multiScreenDefinition;
    OptionSection   *optionSection;
    Option          *option;
    Options         *options;
    Validation      *validation;
}

// Core init
-(id)initWithXMLFile:(NSString *)xmlFile;

// retrieve a property from an entity name and property name
+(PropertyDef *)findProperty:(NSString *)entityName property:(NSString *)propertyNane;
+(NSString *)findRelationInObject:(NSManagedObject *)object  entityName:(NSString *)entityName;
+(BOOL) isRelationBack:(NSString *)name property:(NSString *)property;

// Create a dictionary (Entity/Property) that have unique id (in the database)
+(NSDictionary *)getUniqueKeys;

// Return a full grid definition
+(GridDefinition *)getGridWithName:(NSString *)name;
// Get a screen definition
+(ScreenDefinition *)getScreenWithName:(NSString *)name;
// Get the menu definition
+(MenuDefinition *)getMenuWithName:(NSString *)name;

// Get a multi-screen definition
+(MultiScreenDefinition *)getMultiScreenWithName:(NSString *)name;

// Return the type of an object
+(PropertyDef *) getObjectType:(NSString *)entity withPath:(NSString *)path;
// Return entity definition based on a name
+(EntityDef *)getEntityDefinition:(NSString *)entityName;

// Return the list of options
+(Options *)getOptionsDefinition:(NSString *)optionName;

// return the different types
+(int)typeDefinition:(NSString *)str;

// Add the objects
+(void)addGridDefinition:(GridDefinition *)definition;
+(void)addScreenDefinition:(ScreenDefinition *)definition;
+(void)addMenuDefinition:(ScreenDefinition *)definition;
-(void)print;
@end
