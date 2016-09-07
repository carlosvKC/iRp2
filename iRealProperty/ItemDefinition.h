#import <Foundation/Foundation.h>
#import "GridFilter.h"
#import "iRealProperty.h"

enum FieldTypes {
    ftText = 0,       // Any text
    ftLookup = 1,         // Text with a  value
    ftAuto = 2,           // Automatic numbering
    ftNum = 3,            // Only numbers 0 to 9 -- but results is in a string
    ftBool = 4,           // A true or false, 1 or 0, Y or N, Empty == false
    ftCurr = 5,           // Any currency -- Display with comma 1,200,000
    ftPercent = 6,        // 0 to percent maxvalue
    ftDate = 7,           // 08/12/2011 for Aug 12, 2011
    ftFloat = 8,          // 0.5  -- only one decimal
    ftInt = 9,            // like ftNum, but destination is a number
    ftYear = 10,           // Only year definition
    ftTextL = 11,          // Text with several lines
    ftGrid = 12,           // A grid -- a grid references another list
    ftEmbedded = 13,       // a UIViewController to load
    ftURL = 14,            // link
    ftImg = 15,            // a reference to an image
    ftLink = 16,            // an entity link
    ftLabel = 17           // a label in the form
};
typedef enum
{
    sortNone = 0,
    sortAscending,
    sortDescending
} columnSorting;

//
// Definition of an item entity
//
@interface ItemDefinition : NSObject

// name of the label for this item
@property(nonatomic, strong) NSString *labelName;
// name of the top object used for this item
@property(nonatomic, strong) NSString *entityName;
// name of the property for this item
@property(nonatomic, strong) NSString *path;
// Tag in the current NIB for this particular item
@property(nonatomic) int tag;
// Type of the item
@property(nonatomic) enum FieldTypes type;
// If automatic, then the field is automatically calculated
@property(nonatomic) BOOL autoField;
// Level of editing (0, 1, 2)
@property(nonatomic) int editLevel;     // default is 0
// if the field is required
@property(nonatomic) BOOL required;
// Lenght of the field
@property(nonatomic) int length;
// Lookup value
@property int lookup;
// true if the ITEM should be sorted alphabetically (insted of the default LUITem table)
@property BOOL alphaSorted;     

// Column width (when it is a column)
@property CGFloat width;

// Used only when in a grid - nil when it is not possible to filter
@property(nonatomic, strong) GridFilterOptions *filterOptions;

// case for percentage
@property(nonatomic) short maxPercentValue;
@property(nonatomic) short percentIncrement;
//cv
@property(nonatomic) short percentIncrementNeg;
@property(nonatomic) short maxPercentValueNeg;


// Action method when there is a button
@property(nonatomic, strong) NSString *actionMethod;


///////////////// to be clean up
@property BOOL tableAttribute;      // true if the table attribute should be used instead of LUItem2
@property(nonatomic, strong) NSString *label;
@property int maxWidth;
////////////////////////////

+(NSString *)formatNumber :(int)value;
// Return an item value from a baseEntity + path
+(id)getItemValue:(NSManagedObject *)baseEntity property:(NSString *)propertyName;
-(NSString *) getStringValue:(NSManagedObject *)baseEntity;

-(id) getItemValue:(NSManagedObject *)baseEntity;

-(NSString *) getStringValueNotNil:(NSManagedObject *)baseEntity;
+(NSString *)getStringValue:(NSManagedObject *)baseEntity withPath:(NSString *)aPath withType:(int)aType withLookup:(int)lookup;
+(int)checkValuesInPredicate:(NSString *)string baseEntity:(NSManagedObject *)baseEntity;
// convert an object of certain type to a string
+(NSString *)convertObjectToString:(id)object withType:(int)aType;
// return an object from a base entity with a complex path
+(id)getItemValue:(NSManagedObject *)baseEntity withPath:(NSString *)aPath withType:(int)aType withLookup:(int)lookup;
+(NSString *)replaceDateFilter:(NSString *)aPath;
+(void)setDistrictId:(int)d;
-(BOOL)isComplex;
@end
