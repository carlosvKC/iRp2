
#import "InspectionManager.h"
#import "RealPropertyApp.h"
#import "Inspection.h"
#import "AxDataManager.h"
#import "TrackChanges.h"
#import "Helper.h"

@implementation InspectionManager
    //
    // initialize the object with the current prop-id
    //
    -(id)initWithPropId:(int)propId realPropInfo:(RealPropInfo *)info
    {
        self = [super init];
        if(self)
        {
            propertyId = propId;
            realPropInfo = info;
        }
        return self;
    }


    -(void)setCurrentState:(int)state commit:(BOOL)commit
    {
        Inspection *inspection = realPropInfo.inspection;
        
        if(inspection==nil)
        {
            // 2/11/13 HNN all inspection data should be there. The guid on the iPad and server
            // needs to match in order for the synch to work
            
            //inspection = [AxDataManager getNewEntityObject:@"Inspection"];
            //realPropInfo.inspection = inspection;
            //inspection.inspectionId = [TrackChanges getNewId:inspection];
            //inspection.rowStatus = @"I";
            NSLog(@"Error retrieving inspection data");
        }
        else
            inspection.rowStatus = @"U";

        //NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
        // 2/20/13 HNN set inspection assmtyr based on tax year rather than calendar year
        inspection.assmtYr = [RealPropertyApp taxYear]-1;
        inspection.completedBy = [RealPropertyApp getUserName];
        inspection.updatedBy = [RealPropertyApp getUserName];
        inspection.completedDate = [[Helper localDate]timeIntervalSinceReferenceDate];
        inspection.updateDate = inspection.completedDate;

        inspection.inspectionTypeId = 323;
        inspection.inspectionTypeItemId = state;
        
        if(commit)
        {
            NSError* error = NULL;
            if (![[AxDataManager defaultContext]  save:&error]) 
            {
                NSLog(@"Error in saving inspection manager");
                NSLog(@"Error is %@",[error userInfo]);
            }
            [RealPropertyApp setQueryReady:NO];
        }
    }


    -(int)getCurrentState
    {
        Inspection *inspection = realPropInfo.inspection;

        if(inspection==nil)
            return 0;
        return inspection.inspectionTypeItemId;
    }


@end
