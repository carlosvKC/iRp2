#import "TabSale.h"
#import "AxDataManager.h"
#import "TabHistoryController.h"

#import "RealPropertyApp.h"



@implementation TabSale

//
// Init the default values of the grid
    - (void)initDefaultValues
        {
            defaultSort         = @"saleDate";
            defaultSortOrderAsc = NO;
            defaultBaseEntity   = @"Sale";
            currentIndex        = 0;
            tabIndex            = kHistSales;
        }



//
// Return the list of rows -- setEntities is assigned the result as well
    - (NSArray *)getDefaultOrderedList
        {
            RealPropInfo *info = [RealProperty realPropInfo];

            NSSet *setParcel = info.saleParcel;

            NSMutableSet    *set = [[NSMutableSet alloc] initWithCapacity:[setParcel count]];
            for (SaleParcel *saleParcel in setParcel)
                {
                    if (saleParcel.sale != nil)
                        {
                            [set addObject:saleParcel.sale];
                        }
                }

            setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];

            return setEntities;

        }



    - (void)switchControlBar:(enum GridControlBarConstant)bar
        {
            [super switchControlBar:bar];

            if (bar == kGridControlModeDeleteAdd)
                [self.controlBar setButtonVisible:NO];
        }



    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
            TabHistoryController *controller = (TabHistoryController *) self.itsController;
            
            // will be possible to delineate wich object in Sales??
            [controller segmentUsed:kHistSales];
            self.isDirty = YES;
            Sale *sale = (Sale *)(detailController.workingBase);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *verifDate = [dateFormatter dateFromString:@"1900-01-01"];
            NSDate *updateDate = [dateFormatter dateFromString:@"1900-01-01"];
            
            
            verifDate = [NSDate date];
            updateDate = [NSDate date];
            NSString *rowStatus=@"U";
            NSString *updatedBy=[RealPropertyApp getUserName];
            NSString *childpath = entity.path;
            if (childpath)
            {
            
            if ([childpath rangeOfString:@"saleVerif"].length == 0) {
                NSLog(@"SaleVerif doesnt exist");
                [sale setValue:rowStatus forKey:@"rowStatus"];
                [sale setValue:updateDate forKey:@"updateDate"];
                [sale setValue:updatedBy forKey:@"updatedBy"];
            }
            else {
                NSLog(@"SaleVerif DOES exist");
                [sale.saleVerif setValue:rowStatus forKey:@"rowStatus"];
                [sale.saleVerif setValue:updateDate forKey:@"updateDate"];
                [sale.saleVerif setValue:updatedBy forKey:@"updatedBy"];
            }
  
            }


        }

@end
