#import <Foundation/Foundation.h>
#import "ItemDefinition.h"


// ------------- Property definition

@interface PropertyDef : NSObject
    // Field name
    @property(nonatomic, strong) NSString *name;
    // Type of the entity
    @property(nonatomic) enum FieldTypes type;
    // Value if it is lookup property
    @property(nonatomic) int lookup;
    // Indicate if it is sorted alphabetically
    @property(nonatomic) BOOL alphaSorted;
    // Link to another entity
    @property(nonatomic, strong)NSString *link;
    // Indicate if it is a "set" or just one entity
    @property(nonatomic) BOOL isSet;
    // "Unique Id" for this entity
    @property(nonatomic) BOOL isUniqueId;
    // True is the link is reverse linkg
    @property(nonatomic) BOOL isBackLink;
    -(void)print;
@end

// ------------- Entity definition

@interface EntityDef : NSObject
    // name of the entity
    @property(nonatomic, strong) NSString *name;
    // indicate if it is the root object
    @property(nonatomic) BOOL root;

    // All the properties
    @property(nonatomic, strong) NSMutableArray *properties;

    -(void)print;
@end


// ----------- Screen Definition

@interface ScreenDefinition : NSObject 
    // Name of the screen
    @property(nonatomic, strong) NSString *name;
    // Default object
    @property(nonatomic, strong) NSString *defaultEntity;
    // List of all items -- should not be changed
    @property(nonatomic, strong) NSMutableArray *items;
    // List of all the validation objects
    @property(nonatomic, strong) NSMutableArray *validations;
    @property(nonatomic) BOOL repeatHeader;
    @property(nonatomic) int cellHeight;

    -(id)initWithName:(NSString *)label;
@end


// ----------- Validation Definition

@interface Validation : NSObject
    // Evaluate: must contain a valid predicate format for that particular object
    @property(nonatomic, strong) NSString *evaluate;
    // Message to display if the result is incorrect
    @property(nonatomic, strong) NSString *message;
    // true if it is only a warning
    @property(nonatomic) BOOL warning;
@end


// ----------- Grid Definition

@interface GridDefinition : NSObject 
    // Name of the grid
    @property(nonatomic, strong) NSString *name;
    // List of all columns 
    @property(nonatomic, strong) NSMutableArray *columns;
    // Primary view tag for this grid
    @property(nonatomic) int tag;
    // Height of each row
    @property(nonatomic) int rowHeight;
    // Auto column (first column to show a number)
    @property(nonatomic) BOOL autoColumn;
    // Editable level
    @property(nonatomic) int editLevel;
    // Sort
    @property(nonatomic, strong) NSString *sortOption;
    // If descending, then yes
    @property(nonatomic) BOOL sortDescending;
    // default object
    @property(nonatomic,strong) NSString *defaultObject;

    -(id)initWithName:(NSString *)label;
@end

// ----------- Menu Definition

@interface MenuDefinition : NSObject 

// Name of the screen
@property(nonatomic, strong) NSString *name;
// List of all items
@property(nonatomic, strong) NSMutableArray *menus;

-(id)initWithName:(NSString *)label;
@end

// ---- Multiple screen definition
@interface MultiScreenDefinition : NSObject
// Name of the multi-screen object
@property(nonatomic, strong) NSString *name;
// List of all the items
@property(nonatomic, strong) NSMutableArray *screens;

-(id)initWithName:(NSString *)name;
@end

// ------ Each screen definition
@interface MultiScreenItem : NSObject
@property(nonatomic, strong) NSString *path;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *screenName;
@property(nonatomic) BOOL repeatHeader;
@property(nonatomic) int cellHeight;
@property(nonatomic, strong) NSString *sortField;
@property(nonatomic) BOOL sortAscending;
@end


