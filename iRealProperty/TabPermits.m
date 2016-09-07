#import "TabPermits.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "TabHistoryController.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation TabPermits

@synthesize itsController;


-(void) setupBusinessRules:(id)baseEntity
{
    // Work is done in the TabPermitsDetail controller
}


-(void) setupGrid:(id)baseEntity withItem:(ItemDefinition *)item
{
    // Load the information for the grid
    GridController *gController = [[detailController gridList] objectForKey:@"GridPermitDetail"];
    
    Permit *permit = (Permit *)baseEntity;
    
//    NSArray *array = [AxDataManager orderSet:permit.permitDtl property:@"issuedDate" ascending:NO];
    NSArray *array = [AxDataManager orderSet:permit.permitDtl property:@"updateDate" ascending:NO];
    
    [gController setGridContent:array];
    [gController refreshAllContent];
    
}


//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultSort = @"issueDate";
    defaultSortOrderAsc = NO;
    defaultBaseEntity = @"Permit";
    currentIndex = 0;
    tabIndex = kHistPermit;
    RealPropInfo *propinfo = [RealProperty realPropInfo];
    
    self.workingBase = propinfo;
}


//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.permit;
    
    setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
    
    return setEntities;
}


// Save the the details on an existing record.
// This is called by TabBase gridControlBarAction:(NSObject *)grid action:(int)param
// This is called by TabBase shouldSaveData
// for this record when the user clicks the Save (Done) button on the ControlBar
// and the record already exists in core data, the user was just changing it.
-(void)saveCurrentDetails
{

    GridController *gController = [gridController getFirstGridController];
    NSArray *rows = [gController getGridContent];
    NSManagedObject *row = [rows objectAtIndex:currentIndex];
    
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    
    for(Permit *permit in propInfo.permit)
    {
        if(permit==row)
        {
            //   [AxDataManager copyManagedObject:[detailController  workingBase] destination:permit withSets:YES withLinks:YES];
            break;
        }
    }

}
- (void)addNewDetails
{
    Permit *permit = (Permit *)[detailController workingBase];
    RealPropInfo *rpInfo = [RealProperty realPropInfo];
    [rpInfo addPermitObject:permit];
    [RealPropertyApp updateUserDate:self.workingBase];
    permit.rowStatus = @"I";
}
-(BOOL)deleteSelection:(NSManagedObject *)object
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.permit;
    for(Permit *permit in set)
    {
        if(permit==object)
        {
                        
            if([permit.rowStatus isEqualToString:@"I"])
            {
                [info removePermitObject:permit];
                [[AxDataManager defaultContext] deleteObject:permit];
                [[AxDataManager defaultContext]save:nil];
                return NO;
            }
            else if  ([permit.permitNbr rangeOfString:@"DNQ"].location != NSNotFound)
                     
                     {
                         // long is in 'A long string.' this should be it
                         NSLog("found DNQ; prepare record to be delete it")
                         permit.rowStatus = @"D";
                         permit.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                         [[AxDataManager defaultContext]save:nil];
                         [info removePermitObject:permit];
                         return NO;

                     }
                     
            else
            {
                [Helper alertWithOk:@"Permit Business Rule" message:@"Can only delete MDF permits."];

                //permit.rowStatus = @"D";
                return NO;
            }
            break;
        }
    }
    [[AxDataManager defaultContext]save:nil];
    return NO;
}
-(void)switchControlBar:(enum GridControlBarConstant)bar
{
    [super switchControlBar:bar];
    
    if(bar==kGridControlModeDeleteAdd)
    {
        RealPropInfo *info = [RealProperty realPropInfo];
        NSSet *set = info.permit;
        for(Permit *permit in set)
        {
                if([permit.rowStatus isEqualToString:@"I"])
                {
                    [self.controlBar setButtonVisible:YES];
                }
        }
    }
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    [self.itsController segmentUsed:tabIndex];
    self.isDirty = YES;
    Permit *permit = (Permit *)self.detailController.workingBase;
    
    if(![permit isKindOfClass:[Permit class]])
    {
        NSLog(@"Permit: Internal error");
        return;
    }
    
    if(![permit.rowStatus isEqualToString:@"I"] && ![permit.rowStatus isEqualToString:@"D"])
        permit.rowStatus = @"U";
    
    [RealPropertyApp updateUserDate:permit];    

    permit.reviewedBy = [RealPropertyApp getUserName];
    [permit setValue:[Helper localDate] forKey:@"reviewedDate"];
    
    // refresh the screen
   // [detailController setScreenEntities];
}

@end
