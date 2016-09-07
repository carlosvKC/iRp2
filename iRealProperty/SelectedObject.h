#import <Foundation/Foundation.h>
#import "SearchDefinition2.h"

// One row of entry
@interface RowProperty : NSObject
@property(nonatomic, strong) id realPropInfo;   // First column should be first entry
@property(nonatomic, strong) id entity;         // any other entity
@property(nonatomic) BOOL selected;             // Should be selected
@property(nonatomic, strong) NSMutableArray *columns;   // Contains the columns data
@property(nonatomic) BOOL addedFromMap;             // Added from the map
@end

@class SearchDefinition2;            //cvSearchDef
@class RealPropInfo;

// Contains the list of selections accross the 
@interface SelectedProperties : NSObject
{
    SearchDefinition2 *searchDefinition;
    NSMutableArray *colDefinition;  // of type ColDefinition
    NSManagedObjectContext *currentSearchContext;
    NSMutableArray *memGridIndexSelected;
    BOOL selectedMode;

}
// List of RowProperty objects
@property(nonatomic, strong)    NSMutableArray  *memGrid;
// Index of property object -- this list maintains sorting and filtering
@property(nonatomic, strong) NSMutableArray *memGridIndex;
// Indicate if a task is in progress
@property(atomic) BOOL taskInProgress;
// Increate the current value
@property(nonatomic) float progressValue;
@property(nonatomic) float progressMaxValue;
// Keep track if it was restricted or not
@property(nonatomic) BOOL restricted;

@property(nonatomic, strong) SearchDefinition2 *searchDefinition;
// Basic initialization
-(id)initWithSearchDefinition:(SearchDefinition2 *)def colDefinition:(NSMutableArray*)col;
// Init the grid with only one object
-(id)initWithRealPropInfo:(RealPropInfo *)realPropInfo;


-(void)performQueries;
// Execute the current filters
-(void)performFilters;
// Return the # of objects to load
-(int)objectsNotLoaded;
// Delete everything
-(void)deleteAll;
// Syncrhonize object
-(void)synchronizeObject:(NSManagedObjectContext *)context;
// Return the data
-(id)getCellDataRowIndex:(int)rowIndex columnIndex:(int)columnIndex oneValue:(BOOL)oneValue;
-(id)getCellDataRowIndex:(int)rowIndex columnIndex:(int)columnIndex;

-(void)sortHeaderByColumnIndex:(int)index ascending:(BOOL)sortOptions type:(int)type;
-(NSArray *)retrieveUniqueEntries:(id)grid columnIndex:(int)columnIndex;

-(void)selectRow:(int)rowIndex selected:(BOOL)sel;
-(void)selectAllRows:(BOOL)select;

// return true if the object was added from the map
-(BOOL)isFromMap:(int)uid;

// Return if a realPropInfo is in the list of objects
-(BOOL)isRealPropInfoInIndex:(RealPropInfo *)info;

// Toggle between full list and selected list
-(void)toggleSelectionMode:(BOOL)fullMode;
// Return the list of selected object
-(NSArray *)listOfSelectedRows;
-(int)findPropertyId:(int)objectIndex;
-(NSString *)findParcelNbr:(int)objectIndex;

// Add a new entry to the list
-(void)addEntryByRealPropId:(int)realPropId;
-(void)addEntryByGuId:(NSString *)guid;
-(void)addEntryByRealPropInfo:(RealPropInfo *)realPropInfo;

-(void)addEntryByRealPropInfo:(RealPropInfo *)realPropInfo fromMap:(BOOL)fromMap selected:(BOOL)selected;

// toggle from selected to non-selected
-(void)toggleEntryByRealPropId:(int)realPropId selection:(BOOL)sel;
-(void)toggleEntryByGuId:(NSString *)guid selection:(BOOL)sel;
//-(void)toggleEntryByRealPropInfo:(RealPropInfo *)realPropId  selection:(BOOL)sel;
-(void)createMultipleEntries:(NSArray *)sels;
-(void)removeEntryByRealPropId:(int)realPropId;
-(void)removeEntryByGuId:(NSString*)guid;
// Return any object in the selected list
-(RealPropInfo *)objectAtIndex:(int)index;
// Return the index of an object in the list
-(int)indexOfInfo:(RealPropInfo *)info;

// Rebuild the list of real prop info
-(void)rebuildPropinfoAfterReset;

-(void)reSort;

-(void)loadMemGrid:(NSNumber *)index;
@end
