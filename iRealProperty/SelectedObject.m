#import "SelectedObject.h"
#import "AxDataManager.h"
#import "RealPropInfo.h"
#import "ItemDefinition.h"
#import "Helper.h"


@implementation RowProperty
@synthesize realPropInfo, entity, selected, columns, addedFromMap;
@end

@implementation SelectedProperties

@synthesize memGrid;
@synthesize memGridIndex;
@synthesize taskInProgress;
@synthesize progressValue, progressMaxValue, restricted, searchDefinition;

#pragma mark - Class init
-(id)initWithSearchDefinition:(SearchDefinition2 *)def colDefinition:(NSMutableArray*)col
{
    self = [super init];
    if(self)
    {
        searchDefinition = def;
        colDefinition = col;
        memGrid = [[NSMutableArray alloc]init];
        memGridIndex = [[NSMutableArray alloc]init];
    }
    return self;
}
-(id)initWithRealPropInfo:(RealPropInfo *)realPropInfo
{
    self = [super init];
    if(self)
    {
        searchDefinition = nil;
        colDefinition = nil;
        memGrid = [[NSMutableArray alloc]init];
        memGridIndex = [[NSMutableArray alloc]init];
        RowProperty *row = [[RowProperty alloc]init];
        row.realPropInfo = realPropInfo;
        [memGrid addObject:row];
        [memGridIndex addObject:[NSNumber numberWithInt:0]];
    }
    return self;
}
#pragma mark - Initial creation of the grid
//
// Execute the queries of the searchDefinition paramater. Essentially put all the
// key data into the tables
//
-(void)performQueries
{   
    // Execute in the promary context
    currentSearchContext = [AxDataManager getContext:@"default"];
    @try 
    {
        // re-alloc the object
        memGrid = [[NSMutableArray alloc]init];
        memGridIndex = [[NSMutableArray alloc]init];
        int counter = 0;
        
        // Get the first query
        NSArray *array = [self searchObjectsToAdd:searchDefinition.query];
        
        for(int index=0;index<[array count];index++)
        {
            NSManagedObject *managedObject = [array objectAtIndex:index];
            [self addObjectToTable:managedObject index:counter++ query:searchDefinition.query];
        }      
        
        // Add the join queries -- avoid the same table
        for(QueryDefinition *query in searchDefinition.joinQueries)
        {
            
            NSArray *array = [self searchObjectsToAdd:query];
            for(int index=0;index<[array count];index++)
            {
                NSManagedObject *managedObject = [array objectAtIndex:index];
                if(query.unique==YES  && [self isUnique:managedObject root:query.entityLink]==NO)
                    continue;
                [self addObjectToTable:managedObject index:counter++ query:query];        
            }
        }
    }
    @catch (NSException *exception) 
    {
        NSLog(@"addQueries: %@", exception);
    }
}
//
// Return an object based on the join query that matches the current join predicate
//
-(NSArray *)searchObjectsToAdd:(QueryDefinition *)query
{
    @try 
    {
        NSMutableArray *array = [AxDataManager dataListEntity:query.entityName andPredicate:query.predicate andSortBy:query.entitySortBy sortAscending:query.ascending withContext:[AxDataManager defaultContext]];
        
        return array;
    }
    @catch (NSException *exception) 
    {
        return nil;
    }
}
//
// Return true if the object is not in the _memGrid table
// the comparison is done on the realPropId
//
-(BOOL)isUnique:(NSManagedObject *)managedObject root:(NSString *)root
{
    id value;
    // Retrieve the object
    @try 
    {
        // Get realPropInfo
        if([root caseInsensitiveCompare:NSStringFromClass([managedObject class])]==NSOrderedSame)
            value = managedObject;
        else
            value = [managedObject valueForKeyPath:root];
        if(value==nil || ![value isKindOfClass:[RealPropInfo class]])
            return YES;
        RealPropInfo *info = value;
        
        for(int i=0;i<memGrid.count;i++)
        {
            RowProperty *row = [memGrid objectAtIndex:i];
            
            RealPropInfo *existing = row.realPropInfo;
            // Compare on the ID only 
            if ([info guid] == [existing guid])
                return NO;
        }
    }
    @catch (NSException *exception) 
    {
        NSLog(@"IsUnique failed on %@", root);
        return YES;
    }
    return YES;
}
//
// Add an object to the table -- this is a quick add -- the column 0 is used to stored the RealPropInfo
// the column 1 is used to store the entity that was searched on.
//
-(void)addObjectToTable:(NSManagedObject *)managedObject index:(int)counter query:(QueryDefinition *)qDef
{
    @try
    {
        // Allocate the row of data to store the appropriate information
        RowProperty *row = [[RowProperty alloc]init];
        
        row.columns = [[NSMutableArray alloc]initWithCapacity:[colDefinition count]];
        
        // Column 0
        RealPropInfo *info;
        
        NSArray *paths = [qDef.entityLink componentsSeparatedByString:@"."];
        
        if([[paths objectAtIndex:0] caseInsensitiveCompare:NSStringFromClass([managedObject class])]==NSOrderedSame)
            info = (RealPropInfo *)managedObject;
        else 
        {
            NSRange range = [qDef.entityLink rangeOfString:@"[0]"];
            if(range.length>0)
            {
                // We have a special case...
                NSString *str = [qDef.entityLink stringByReplacingOccurrencesOfString:@"[0]" withString:@""];
                NSArray *array = [str componentsSeparatedByString:@"."];
                // Must be a set
                NSSet *set = [managedObject valueForKey:[array objectAtIndex:0]];
                // managedObject = [set anyObject]; regis: not sure why we override managedObject
                
                info = [[set anyObject] valueForKey:[array objectAtIndex:1]];
            }
            else
                info = [managedObject valueForKeyPath:qDef.entityLink];
        }
        if(![info isKindOfClass:[RealPropInfo class]])
        {
            NSLog(@"Path (%@) does not return realPropInfo", qDef.entityLink);
            return;
        }
        row.realPropInfo = info;
        row.entity = managedObject;
        
        for(ItemDefinition *def in colDefinition)
        {
            [row.columns addObject:[NSNull null]];
        }
        // Add the row of data to the table
        [memGrid addObject:row]; 
        NSNumber *number = [[NSNumber alloc]initWithInt:counter];
        [memGridIndex addObject:number];
    }
    @catch (NSException *exception) 
    {
        NSLog(@"addObjectToTable:%@",exception);
    }
}
#pragma mark - Return data
-(id)getCellDataRowIndex:(int)rowIndex columnIndex:(int)columnIndex
{
    return [self getCellDataRowIndex:rowIndex columnIndex:columnIndex oneValue:NO];
}
//
// Return the content of a cell 
//
// If oneValue is TRUE, loads only that column, else load the entire row
-(id)getCellDataRowIndex:(int)rowIndex columnIndex:(int)columnIndex oneValue:(BOOL)oneValue
{

    if(memGrid==nil)
    {
        NSLog(@"memGrid is null!!!");
        return @"";
    }
    // if the object exists, then return it
    if(rowIndex >= [memGridIndex count])
        return nil;
    NSNumber *index = [memGridIndex objectAtIndex:rowIndex];
    if(index.intValue >= memGrid.count)
        return nil;
    RowProperty *row = [memGrid objectAtIndex:[index intValue]];
    
    NSMutableArray *columns = row.columns;
    
    if(columnIndex >= columns.count)
        return nil;
    
    id object = [columns objectAtIndex:columnIndex];
    
    if(![object isKindOfClass:[NSNull class]])
    {
        ItemDefinition *def = [colDefinition objectAtIndex:columnIndex];

        if([object isKindOfClass:[NSString class]])
            return object;
        return [ItemDefinition convertObjectToString:object withType:def.type];
    }    
    RealPropInfo *info = row.realPropInfo;
    id srcObject = row.entity;
    id result;
    @try 
    {
        NSManagedObject *root;
        for(int index=0;index<[colDefinition count];index++)
        {
            if(oneValue && index!=columnIndex)
                continue;
            ItemDefinition *def = [colDefinition objectAtIndex:index];
            if(def.type == ftAuto)
                continue;
            
            NSRange range = [def.path rangeOfString:@"{"];
            if(range.length!=0)
            {
                // Contains complex strings -- must start from RealPropInfo
                result = [ItemDefinition getStringValue:info    withPath:def.path withType:def.type withLookup:def.lookup];
            }
            else 
            {
                root = [self checkRoot:def.entityName firstEntity:info secondEntity:srcObject];
                
                result = [ItemDefinition getItemValue:root withPath:def.path withType:def.type withLookup:def.lookup];
                if(result==nil)
                    result = @"";
            }
            
            [columns replaceObjectAtIndex:index withObject:result];
        }
        id object = [columns objectAtIndex:columnIndex];
        ItemDefinition *def = [colDefinition objectAtIndex:columnIndex];

        if([object isKindOfClass:[NSString class]])
            return object;
        return [ItemDefinition convertObjectToString:object withType:def.type];
    }
    @catch (NSException *exception) 
    {
        result = @"";
    }
    
    return result;
}

-(NSManagedObject *)checkRoot:(NSString *)path firstEntity:(NSManagedObject *)object1 secondEntity:(NSManagedObject *)object2
{

    NSRange range = [path rangeOfString:@"~"];
    if(range.length >0)
    {

        path = [path substringToIndex:range.location];
    }
    
    NSManagedObject *root;
    NSArray *paths = [path componentsSeparatedByString:@"."];
    
    if([[paths objectAtIndex:0] caseInsensitiveCompare:NSStringFromClass([object1 class])]==NSOrderedSame)
        root = object1;
    else if([[paths objectAtIndex:0] caseInsensitiveCompare:NSStringFromClass([object2 class])]==NSOrderedSame)
        root = object2;
    else 
    {
        root = nil;
    }
    return root;
}

#pragma mark - Filter the results
//
// Filter the grid -- the assumption is that all the data must have been loaded already
//
-(void)performFilters
{
    // go through all the rows of the grid and filter the data out
    
    memGridIndex = [[NSMutableArray alloc]initWithCapacity:[memGrid count]];   // Minimum size
    
    // re-add all the indexes
    for(int index=0;index<[memGrid count];index++)
        [memGridIndex addObject:[[NSNumber alloc]initWithInt:index]];
    
    NSMutableArray *newIndex = [[NSMutableArray alloc]init];
    
    for(int index=0;index<[memGrid count];index++)
    {
        RowProperty *row = [memGrid objectAtIndex:index];
        if([self shouldRowBeSelected:row rowIndex:index])
        {
            NSNumber *num = [[NSNumber alloc]initWithInt:index];
            [newIndex addObject:num];
        }
    }
    memGridIndex = newIndex;
    [self reSort];
}
-(void)reSort
{
    // Need to resort the grid if it was sorted
    for(int index=0;index<[colDefinition count];index++)
    {
        ItemDefinition *col = [colDefinition objectAtIndex:index];
        if(col.filterOptions.sortOption==kFilterAscent)
        {
            [self sortHeaderByColumnIndex:index ascending:YES type:col.type];
            break;
        }
        else if(col.filterOptions.sortOption==kFilterDescent)
        {
            [self sortHeaderByColumnIndex:index ascending:NO type:col.type];
            break;
        }
    }
}

// return YES if the row is part of the filter.
-(BOOL)shouldRowBeSelected:(RowProperty *)row rowIndex:(int)rowIndex
{
    NSMutableArray *columns = row.columns;
    
    for(int i=0;i<[columns count];i++)
    {
        ItemDefinition *def = [colDefinition objectAtIndex:i];
        if(def.filterOptions.filterValue==nil)
        {
            // no filter, so keep looping
            continue;
        }
        if([def.filterOptions.filterValue isKindOfClass:[NSString class]] && [(NSString *)def.filterOptions.filterValue length]==0)
            continue;
        // There is a filter...
        if([[columns objectAtIndex:i] isKindOfClass:[NSNull class]])
            [self getCellDataRowIndex:rowIndex columnIndex:i oneValue:YES];
        
        id rowObject = [columns objectAtIndex:i];
        
        if(def.type==ftText || def.type==ftTextL || def.type==ftLookup)
        {
            NSString *rowStr = [NSString stringWithFormat:@"%@", rowObject];
            
            // Comparing string
            NSString *filterStr = (NSString *)def.filterOptions.filterValue;
            BOOL success = NO;
            NSRange range;
            switch(def.filterOptions.filterOperation)
            {
                case kFilterTextContain:
                    range = [rowStr rangeOfString:filterStr options:NSCaseInsensitiveSearch];
                    if(range.length >0)
                        success = YES;
                    break;
                case kFilterTextDontContain:
                    range = [rowStr rangeOfString:filterStr options:NSCaseInsensitiveSearch];
                    if(range.length ==0)
                        success = YES;
                    break;
                case kFilterTextEqual:
                    if([rowStr caseInsensitiveCompare:filterStr]==NSOrderedSame)
                        success = YES;
                    break;
                case kFilterTextNotEqual:
                    if([rowStr caseInsensitiveCompare:filterStr]!=NSOrderedSame)
                        success = YES;
                    break;
                    
            }
            if(success==NO)
                return NO;
        }
        else if(def.type==ftDate)
        {
            if(![rowObject isKindOfClass:[NSDate class]])
                return NO;
            // Date comparison
            NSTimeInterval val1, val2;
            val1 = [(NSDate *)rowObject timeIntervalSinceReferenceDate];
            val2 = [(NSDate *)def.filterOptions.filterValue timeIntervalSinceReferenceDate];          
            BOOL success = NO;
            switch(def.filterOptions.filterOperation)
            {
                case kFilterNumEqual:
                    if(val1==val2)
                        success = YES;
                    break;
                case kFilterNumNotEqual:
                    if(val1!=val2)
                        success = YES;
                    break;
                case kFilterNumLarger:
                    if(val1 > val2)
                        success = YES;
                    break;
                case kFilterNumLargerEqual:
                    if(val1 >= val2)
                        success = YES;
                    break;
                case kFilterNumLess:
                    if(val1 < val2)
                        success = YES;
                    break;
                case kFilterNumLessEqual:
                    if(val1 <= val2)
                        success = YES;
                    break;
            }
            if(success==NO)
                return NO;
        }
        else if(def.type==ftBool  || def.type==ftInt || def.type==ftCurr || def.type==ftNum || def.type==ftFloat)
        {
            if(![rowObject isKindOfClass:[NSNumber class]])
                return NO;
            double val1 = 0;
            if([rowObject isKindOfClass:[NSNumber class]])
                val1 = [rowObject doubleValue];
            double val2 = 0;
            
            if([def.filterOptions.filterValue isKindOfClass:[NSNumber class]])
                val2 = [(NSNumber *)def.filterOptions.filterValue doubleValue];
            // Comparing numbers
            BOOL success = NO;
            switch(def.filterOptions.filterOperation)
            {
                case kFilterNumEqual:
                    if(val1==val2)
                        success = YES;
                    break;
                case kFilterNumNotEqual:
                    if(val1!=val2)
                        success = YES;
                    break;
                case kFilterNumLarger:
                    if(val1>val2)
                        success = YES;
                    break;
                case kFilterNumLargerEqual:
                    if(val1>=val2)
                        success = YES;
                    break;
                case kFilterNumLess:
                    if(val1<val2)
                        success = YES;
                    break;
                case kFilterNumLessEqual:
                    if(val1<=val2)
                        success = YES;
                    break;
            }
            if(success==NO)
                return NO;
        }
    }
    return YES;
}
#pragma mark - Perform sort
-(void)sortHeaderByColumnIndex:(int)index ascending:(BOOL)sortOptions type:(int)type
{
    if(index>=[colDefinition count])
    {
        NSLog(@"Internal error -- headerSortSelection is wrong");
        return;
    }
    NSLog(@"Number of rows=%d", [memGridIndex count] );
    NSArray *temp = [memGridIndex sortedArrayUsingComparator:^(id a, id b) 
                     {
                         RowProperty *firstRow = [memGrid objectAtIndex:[(NSNumber *)a intValue]];
                         RowProperty *secondRow = [memGrid objectAtIndex:[(NSNumber *)b intValue]];
                         
                         id first = [firstRow.columns objectAtIndex:index];
                         id second = [secondRow.columns objectAtIndex:index];
                         int result = NSOrderedSame;
                         
                         @try {

                             switch (type) {
                                 case ftText:
                                 case ftTextL:
                                case ftLookup:
                                     // Handle string
                                 {
                                     if(![first isKindOfClass:[NSString class]])
                                         first = @"";
                                     if(![second isKindOfClass:[NSString class]])
                                         second = @"";
                                     result =  [first caseInsensitiveCompare:second];
                                 }
                                     break;

                                 case ftAuto:
                                 case ftNum:
                                 case ftBool:
                                 case ftCurr:
                                 case ftPercent:
                                 case ftFloat:
                                 case ftInt:
                                 case ftYear:
                                 {
                                     double val1 = 0, val2 = 0, diff = 0;
                                     if([first isKindOfClass:[NSNumber class]])
                                         val1 = [first doubleValue];
                                     if([second isKindOfClass:[NSNumber class]])
                                         val2 = [second doubleValue];                                 
                                     diff = val1 - val2;
                                     
                                     if(diff<0)
                                         result = NSOrderedAscending;
                                     else if(diff>0)
                                         result = NSOrderedDescending;
                                     else
                                         result = NSOrderedSame;
                                 }
                                 default:
                                     break;
                             }
                         }
                         @catch (NSException *ex) {
                             NSLog(@"sortHeader=%@", ex);
                         }
                         if(sortOptions==YES)
                             return result;
                         // Reverse the direction
                         if(result==NSOrderedSame)
                             return NSOrderedSame;
                         if(result==NSOrderedAscending)
                             return NSOrderedDescending;
                         else
                             return NSOrderedAscending;
                     }];

    [memGridIndex removeAllObjects];
    memGridIndex = [[NSMutableArray alloc]initWithArray:temp]; 
}
-(void)dumpLastColumn
{
    NSLog(@"---");
    for(int index=0;index<memGridIndex.count;index++)
    {
        NSNumber *numb = [memGridIndex objectAtIndex:index];
        RowProperty *row = [memGrid objectAtIndex:[numb intValue]];
        RealPropInfo *info = row.realPropInfo;
        

        
        id first = [row.columns objectAtIndex:row.columns.count-1];
        NSLog(@"%d, index=%d {%@-%@} guid=%@ val=%@", index, [numb intValue], info.major, info.minor, info.guid, first);
    }

}
#pragma mark - retrieve unique entries
//
// Find unique entries. Objects are returned based on the type of the column
// ColumnIndex should 0-based
//
-(NSArray *)retrieveUniqueEntries:(id)grid columnIndex:(int)columnIndex
{
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    for(int i=0;i<[memGrid count];i++)
    {
        RowProperty *row = [memGrid objectAtIndex:i];
        
        id object = [row.columns objectAtIndex:columnIndex];
        BOOL exist = NO;
        
        if(object==nil || object==[NSNull null])
            continue;
        if([object isKindOfClass:[NSString class]] && [object length]==0)
            continue;
        
        // Verify that the object is unique in the list
        for(int index=0;index<[results count];index++)
        {
            id objectStored = [results objectAtIndex:index];
            @try 
            {
                if([objectStored isKindOfClass:[NSString class]])
                {
                    NSString *str1 = objectStored;
                    NSString *str2 = object;
                    if([str1 caseInsensitiveCompare:str2]==NSOrderedSame)
                    {
                        exist = YES;
                        break;
                    }
                }
                else if([objectStored isKindOfClass:[NSNumber class]])
                {
                    double val1 = [objectStored doubleValue];
                    double val2 = [object doubleValue];
                    if(val1==val2)
                    {
                        exist = YES;
                        break;
                    }
                }
                else if([objectStored isKindOfClass:[NSDate class]])
                {
                    NSString *date1 = [Helper stringFromDate:objectStored];
                    NSString *date2 = [Helper stringFromDate:object];
                    
                    if([date1 compare:date2]==NSOrderedSame)
                    {
                        exist = YES;
                        break;
                    }                
                }
                else
                    break;
            }
            @catch (NSException *exception)
            {
                NSLog(@"Exception=%@", exception);
            }
        }
        if(exist)
            continue;
        [results addObject:object];
    }
    BOOL sortOptions = NO;  // to have in ascending mode
    
    NSArray *temp = [results sortedArrayUsingComparator:^(id first, id second) 
                     {
                         double val1 = 0, val2 = 0, diff = 0;
                         
                         
                         if([first isKindOfClass:[NSDate class]])
                         {
                             NSString *string = [Helper stringFromDate:first];
                             val1 = [[Helper dateFromString:string]timeIntervalSinceReferenceDate];
                         }
                         if([second isKindOfClass:[NSDate class]])
                         {
                             NSString *string = [Helper stringFromDate:second];
                             val2 = [[Helper dateFromString:string]timeIntervalSinceReferenceDate];
                         }
                         
                         if([first isKindOfClass:[NSNumber class]])
                             val1 = [first doubleValue];
                         if([second isKindOfClass:[NSNumber class]])
                             val2 = [second doubleValue];            
                         
                         if([first isKindOfClass:[NSString class]] && [second isKindOfClass:[NSString class]])
                         {
                             int result = [first caseInsensitiveCompare:second];
                             
                             if(!sortOptions)
                                 return result;
                             // return reverse
                             if(result==NSOrderedAscending)
                                 return NSOrderedDescending;
                             if(result==NSOrderedDescending)
                                 return NSOrderedAscending;
                             return NSOrderedSame;
                         }
                         
                         diff = val1 - val2;
                         if(sortOptions)
                             diff *= (-1);
                         
                         if(diff<0)
                             return NSOrderedAscending;
                         if(diff>0)
                             return NSOrderedDescending;
                         
                         return NSOrderedSame;
                         
                     }];
    results = [[NSMutableArray alloc]initWithCapacity:temp.count];
    
    ItemDefinition *def = [colDefinition objectAtIndex:columnIndex];
    
    for(id object in temp)
    {
        [results addObject:[ItemDefinition convertObjectToString:object withType:def.type]];
    }
    
    return results;
}

#pragma mark - Utilities function
//
// Load the grid directly in memory using getCellData -- this operation is actually the slowest one
//
-(void)loadMemGrid:(NSNumber *)index
{
    if(taskInProgress)
        currentSearchContext = [AxDataManager createManagedObjectContextFromContextName:@"default"];
    for(int i=0;i<[memGrid count];i++)
    {
        progressValue = i; 
        RowProperty *row = [memGrid objectAtIndex:i];
        
        id object = [row.columns objectAtIndex:[index intValue]];
        if([object isKindOfClass:[NSNull class]])
        {
            [self getCellDataRowIndex:i columnIndex:[index intValue] oneValue:YES];
        }
    }
    taskInProgress = NO;
}
//
// Return the number of objects to load
//
-(int)objectsNotLoaded
{
    int count = 0;
    for(int i=0;i<[memGrid count];i++)
    {
        RowProperty *row = [memGrid objectAtIndex:i];
        NSArray *array = row.columns;
        
        id object = [array objectAtIndex:1];
        if([object isKindOfClass:[NSNull class]])
            count++;
    }
    return count;
}
-(void)deleteAll
{
    for(int i=0;i<[memGrid count]; i++)
    {
        RowProperty *row = [memGrid objectAtIndex:i];
        [row.columns removeAllObjects];
    }

    [memGrid removeAllObjects];
    memGrid = nil;
    memGridIndex = nil;
}
-(void)synchronizeObject:(NSManagedObjectContext *)context
{
    for(int i=0;i<memGrid.count;i++)
    {
        RowProperty *row = [memGrid objectAtIndex:i];
        @try
        {
            
            NSManagedObject *object = row.realPropInfo;
            NSManagedObjectID *objectId = [object objectID];
            NSManagedObject *objectInContext = [context objectWithID:objectId];
            row.realPropInfo = objectInContext;
            
            object = row.entity;
            objectId = [object objectID];
            objectInContext = [context objectWithID:objectId];
            row.entity = objectInContext;         }
        @catch (NSException *exception)
        {
            row.entity = nil;
        }
    }
}
// Mark a row as selected or not
-(void)selectRow:(int)rowIndex selected:(BOOL)sel
{
    NSNumber *index = [memGridIndex objectAtIndex:rowIndex];
    RowProperty *row = [memGrid objectAtIndex:[index intValue]];
    row.selected = sel;
}
-(void)selectAllRows:(BOOL)select
{
    for(RowProperty *row in memGrid)
    {
        row.selected = select;
    }
}
// Switch between selected and not selected

-(void)toggleSelectionMode:(BOOL)selectModeView
{
    if(selectModeView)
    {
        // restore the full grid index
        memGridIndex = memGridIndexSelected;
        selectedMode = NO;
    }
    else
    {
        // Save the full grid Index
        memGridIndexSelected = memGridIndex;
        memGridIndex = [[NSMutableArray alloc]init];
        // Go through the selected and save the current selection
        for(int i=0;i<memGridIndexSelected.count;i++)
        {
            NSNumber *number = [memGridIndexSelected objectAtIndex:i];
            RowProperty *row = [memGrid objectAtIndex:[number intValue]];
            if(row.selected)
                [memGridIndex addObject:number];
        }
        selectedMode = YES;
    }
}
// Return the list of objects that are selected (from the current gridIndex)
-(NSArray *)listOfSelectedRows
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(int i=0;i<memGridIndex.count;i++)
    {
        NSNumber *index = [memGridIndex objectAtIndex:i];
        RowProperty *row = [memGrid objectAtIndex:[index intValue]];
        if(row.selected)
        {
            index = [[NSNumber alloc]initWithInt:i];
            [array addObject:index];
        }
    }
    return array;

}
//
// Retun the ID of a reapPropInfo object
//
-(int)findPropertyId:(int)objectIndex
{
    if(objectIndex<0 || objectIndex >= memGridIndex.count)
        return 0;
    NSNumber *index = [memGridIndex objectAtIndex:objectIndex];
    RowProperty *row = [memGrid objectAtIndex:[index intValue]];
    RealPropInfo *info = row.realPropInfo;

    return info.realPropId;
}

-(NSString*)findParcelNbr:(int)objectIndex
{
    if(objectIndex<0 || objectIndex >= memGridIndex.count)
        return 0;
    NSNumber *index = [memGridIndex objectAtIndex:objectIndex];
    RowProperty *row = [memGrid objectAtIndex:[index intValue]];
    RealPropInfo *info = row.realPropInfo;
    
    return info.parcelNbr;
}

#pragma mark -- Create multiple entries
// Reset the current grid
-(void)createMultipleEntries:(NSArray *)sels
{
    memGrid = nil;
    memGridIndexSelected = nil;
    memGridIndex = nil;
    selectedMode = NO;
    
    memGrid = [[NSMutableArray alloc]init];
    memGridIndex = [[NSMutableArray alloc]init];
    
    for(int i=0;i<sels.count;i++)
    {
        NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:colDefinition.count];
        for(int i=0;i<colDefinition.count;i++)
        {
            [array addObject:[NSNull null]];
        }
        RowProperty *row = [[RowProperty alloc]init];
        NSNumber *number = [sels objectAtIndex:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", number.intValue];
        RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
        
        row.realPropInfo = info;
        row.entity = info;
        row.columns = array;
        row.addedFromMap = YES;
        row.selected = NO;
        [memGrid addObject:row];
        number = [NSNumber numberWithInt:i];
        [memGridIndex addObject:number];
    }
}
-(void)removeEntryByRealPropId:(int)realPropId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", realPropId];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    [self removeEntryByRealPropInfo:info];    
}
-(void)removeEntryByGuId:(NSString*)guid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", guid];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    [self removeEntryByRealPropInfo:info];
}
-(void)removeEntryByRealPropInfo:(RealPropInfo *)realPropInfo
{
    for(int index=0;index<[memGridIndex count];index++)
    {
        int indirect = [[memGridIndex objectAtIndex:index]intValue];
        if(indirect<0 || indirect >=memGrid.count)
            continue;
        RowProperty *row = [memGrid objectAtIndex:indirect];
        RealPropInfo* info = row.realPropInfo;
        if (info.guid == realPropInfo.guid)
        {
            // Remove it from the entry and from the selection grid as well
            [memGrid removeObjectAtIndex:indirect];
            [memGridIndex removeObjectAtIndex:index];
            break;
        }
    }
}
-(void)addEntryByRealPropId:(int)realPropId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", realPropId];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    [self addEntryByRealPropInfo:info];
}
-(void)addEntryByGuId:(NSString *)guid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", guid];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    [self addEntryByRealPropInfo:info];
}
-(void)addEntryByRealPropInfo:(RealPropInfo *)realPropInfo
{
    [self addEntryByRealPropInfo:realPropInfo fromMap:YES selected:YES];
}
-(void)addEntryByRealPropInfo:(RealPropInfo *)realPropInfo fromMap:(BOOL)fromMap selected:(BOOL)selected
{
    if(realPropInfo==nil)
        return;
    
    // Make sure that it does not exist
    for(RowProperty *row in memGrid)
    {
        RealPropInfo* info = row.realPropInfo;
        if(info.guid == realPropInfo.guid)
            return;
    }
    
    int count = [memGrid count];
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:colDefinition.count];
    for(int i=0;i<colDefinition.count;i++)
    {
        [array addObject:[NSNull null]];
    }
    RowProperty *row = [[RowProperty alloc]init];
    row.realPropInfo = realPropInfo;
    row.entity = realPropInfo;
    row.columns = array;
    row.addedFromMap = fromMap;
    row.selected = selected;
    
    [memGrid addObject:row];
    BOOL sMode = selectedMode;
    if(sMode)
        [self toggleSelectionMode:YES];     // restore all index
    NSNumber *number = [NSNumber numberWithInt:count];
    [memGridIndex addObject:number];
    if(count>0 && colDefinition!=nil)
        [self getCellDataRowIndex:count-1 columnIndex:1];
    if(sMode)   // go back to selected
        [self toggleSelectionMode:NO];
}
-(BOOL)isFromMap:(int)uid
{
    for(RowProperty *row in memGrid)
    {
        RealPropInfo *info = row.realPropInfo;
        if(info.realPropId==uid)
            return row.addedFromMap;
    }
    return NO;
}
-(void)toggleEntryByRealPropId:(int)realPropId selection:(BOOL)sel
{
    NSLog(@"toggleEntryByRealPropId");
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", realPropId];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    [self toggleEntryByRealPropInfo:info selection:sel];

}
-(void)toggleEntryByGuId:(NSString *)guid selection:(BOOL)sel
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", guid];
    RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    [self toggleEntryByRealPropInfo:info selection:sel];
}
-(void)toggleEntryByRealPropInfo:(RealPropInfo *)realPropInfo selection:(BOOL)sel
{
    for(int i=0;i<memGrid.count;i++)
    {
        RowProperty *row = [memGrid objectAtIndex:i];
        RealPropInfo *info = row.realPropInfo;
        if(info.guid == realPropInfo.guid)
        {
            row.selected = sel;
            break;
        }
    }
    if(selectedMode)
    {
        [self toggleSelectionMode:YES];
        [self toggleSelectionMode:NO];
    }
}
-(BOOL)isRealPropInfoInIndex:(RealPropInfo *)realPropInfo
{
    for(int index=0;index<[memGridIndex count];index++)
    {
        int indirect = [[memGridIndex objectAtIndex:index]intValue];
        if(indirect<0 || indirect>=memGrid.count)
            continue;
        RowProperty *row = [memGrid objectAtIndex:indirect];
        RealPropInfo* info = row.realPropInfo;
        if(info.guid == realPropInfo.guid)
        {
            return YES;
        }
    }
    return NO;
}
-(RealPropInfo *)objectAtIndex:(int)index
{
    if(index<0 || index>=[memGridIndex count])
        return nil;
    int indirect = [[memGridIndex objectAtIndex:index]intValue];
    if(indirect<0 || indirect>=memGrid.count)
        return nil;
    RowProperty *row = [memGrid objectAtIndex:indirect];
    return row.realPropInfo;
}
-(int)indexOfInfo:(RealPropInfo *)info
{
    for(int i=0;i<memGridIndex.count;i++)
    {
        int indirect = [[memGridIndex objectAtIndex:i]intValue];
        if(indirect<0 || indirect>=memGrid.count)
            continue;
        RowProperty *row = [memGrid objectAtIndex:indirect];
        RealPropInfo *rinfo = row.realPropInfo;
        if(rinfo.guid ==info.guid)
            return i;
    }
    return 0;
}
// If the context is reset, rebuild the list of realpropinfo
-(void)rebuildPropinfoAfterReset
{
    
}
@end
