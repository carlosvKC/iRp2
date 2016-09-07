//
//  DashboardToDoData.m
//
//  Created by David Baun on 4/8/14.
//  modified by Carlos Venero 1/1/2015
//

#import "DashboardToDoData.h"
#import "AxDataManager.h"
#import "Bookmark.h"


@implementation DashboardToDoData


    - (id)init
    {
        self = [super init];
        if (self) {

        }
        return self;
    }


    // Returns some results...
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saleId == 1275013"];

    // Does not work... 'keypath Sale.saleParcel.realPropId not found in entity <NSSQLEntity Sale id=31>'
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vYVerifDate < %@ AND Sale.saleParcel.realPropId < 450000", verifDate];

    // Does not work... 'to-many key not allowed here'
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vYVerifDate < %@ AND saleParcel.realPropId < 450000", verifDate];

    // Does not work... 'Unsupported predicate (null)'
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vYVerifDate < %@ AND ALL saleParcel.realPropId < 450000", verifDate];


    -(NSArray *)theToDoItemsforAssmtYr:(int32_t)theYear
                         andRealPropId:(int32_t)theRealPropId
                         andRpGuid:(NSString*)theRpGuid
                         andLndGuid:(NSString*)theLndGuid
                           andPropType:(NSString*)thePropType
                    withManagedContext:(NSManagedObjectContext*)theContext
        {
            if (!theContext)
                {
                    NSLog(@"Failed to provide managed object context, so had to abort DashboardToDoData theToDoItemsForAssmtYr...");
                    return [[NSArray alloc] init];
                }
            
        
            //NSLog(@"Parameters: RealPropId=%i  LandId=%i  PropType=%@",theRealPropId, theLandId, thePropType)
            
            self.managedObjectContext = theContext;
            NSMutableArray *theResults = [[NSMutableArray alloc]init];
            
            //--- add Sales Verification query result (if any) to items that will be displayed on dashboard.
            NSString *salesVerificationQueryResult = [self runSaleVerificationQueryWithRPGuid:theRpGuid andAssmtYear:theYear];
                if (salesVerificationQueryResult)
                    [theResults addObject:salesVerificationQueryResult];
                
            
            //--- add Land Inspection query result (if any) to items that will be displayed on dashboard.
            //            NSString *landInspectionQueryResult = [self runLandInspectionQueryWithRealPropId:theRealPropId];
            //                if (landInspectionQueryResult)
            //                    [theResults addObject:landInspectionQueryResult];
            
            
            //--- add Improvements Inspection query result (if any) to items that will be displayed on dashboard
            //            NSString *improvementsInspectionQueryResult = [self runImprovmInspectionQueryWithRealPropId:theRealPropId];
            //                if (improvementsInspectionQueryResult) 
            //                    [theResults addObject:improvementsInspectionQueryResult];
            
            
            //--- add Bookmark General query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkGeneralQueryResult = [self runBookmarkGeneralQueryWithRPGuid:theRpGuid];
                if (bookmarkGeneralQueryResult)
                    [theResults addObject:bookmarkGeneralQueryResult];
            
            //--- add Bookmark Revisit query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkRevisitQueryResult = [self runBookmarkRevisitQueryWithRPGuid:theRpGuid];
                if (bookmarkRevisitQueryResult)
                    [theResults addObject:bookmarkRevisitQueryResult];
            //cv
            //--- add Bookmark General query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkCallOwnerQueryResult = [self runBookmarkCallOwnerQueryWithRPGuid:theRpGuid];
            if (bookmarkCallOwnerQueryResult)
                [theResults addObject:bookmarkCallOwnerQueryResult];
            
            //--- add Bookmark Revisit query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkGetPlansQueryResult = [self runBookmarkGetPlansQueryWithRPGuid:theRpGuid];
            if (bookmarkGetPlansQueryResult)
                [theResults addObject:bookmarkGetPlansQueryResult];
            
            //--- add Bookmark General query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkFinishDrawingQueryResult = [self runBookmarkFinishDrawingQueryWithRPGuid:theRpGuid];
            if (bookmarkFinishDrawingQueryResult)
                [theResults addObject:bookmarkFinishDrawingQueryResult];
            
            //--- add Bookmark Revisit query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkCheckWebsiteQueryResult = [self runBookmarkCheckWebsiteQueryWithRPGuid:theRpGuid];
            if (bookmarkCheckWebsiteQueryResult)
                [theResults addObject:bookmarkCheckWebsiteQueryResult];
            
            //--- add Bookmark General query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkSetAppointmentQueryResult = [self runBookmarkSetAppointmentQueryWithRPGuid:theRpGuid];
            if (bookmarkSetAppointmentQueryResult)
                [theResults addObject:bookmarkSetAppointmentQueryResult];
            
            //--- add Bookmark Revisit query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkIncompleteNewBuildingQueryResult = [self runBookmarkIncompleteNewBuildingQueryWithRPGuid:theRpGuid];
            if (bookmarkIncompleteNewBuildingQueryResult)
                [theResults addObject:bookmarkIncompleteNewBuildingQueryResult];
            
            //--- add Bookmark General query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkWaitForCallbackQueryResult = [self runBookmarkWaitForCallbackQueryWithRPGuid:theRpGuid];
            if (bookmarkWaitForCallbackQueryResult)
                [theResults addObject:bookmarkWaitForCallbackQueryResult];
            
            //--- add Bookmark Revisit query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkSeeNoteQueryResult = [self runBookmarkSeeNoteQueryWithRPGuid:theRpGuid];
            if (bookmarkSeeNoteQueryResult)
                [theResults addObject:bookmarkSeeNoteQueryResult];
            
            //--- add Bookmark General query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkDoNotSynchronizeQueryResult = [self runBookmarkDoNotSynchronizeQueryWithRPGuid:theRpGuid];
            if (bookmarkDoNotSynchronizeQueryResult)
                [theResults addObject:bookmarkDoNotSynchronizeQueryResult];
            
            //--- add Bookmark Revisit query result (if any) to items that will be displayed on dashboard
            NSString *bookmarkOtherQueryResult = [self runBookmarkOtherQueryWithRPGuid:theRpGuid];
            if (bookmarkOtherQueryResult)
                [theResults addObject:bookmarkOtherQueryResult];
            

            //--- add Permit Review query result (if any) to items that will be displayed on dashboard
            NSString *blankPermitReviewQueryResult = [self runPermitReviewQueryWithrpGuid:theRpGuid];
                if (blankPermitReviewQueryResult) 
                    [theResults addObject:blankPermitReviewQueryResult];
            
            //--- add Revisit Permit Review query result (if any) to items that will be displayed on dashboard
            //            NSString *revisitPermitReviewQueryResult = [self runRevisitPermitReviewQueryWithRealPropId:theRealPropId andPropType:thePropType];
            //                if (revisitPermitReviewQueryResult)
            //                    [theResults addObject:revisitPermitReviewQueryResult];
            //--- add SegMerge Event query result (if any) to items that will be displayed on dashboard
            NSString *segMergeEventQueryResult = [self runSegMergeQueryWithRpGuid:theRpGuid];
                if (segMergeEventQueryResult)
                    [theResults addObject:segMergeEventQueryResult];
            
            //--- add Unkill query result (if any) to items that will be displayed on dashboard
            NSString *unKillEventQueryResult = [self runUnKillQueryWithRpGuid:theRpGuid];
                if (unKillEventQueryResult)
                    [theResults addObject:unKillEventQueryResult];
            
            //--- add New Parcel query result (if any) to items that will be displayed on dashboard
            NSString *newParcelEventQueryResult = [self runNewParcelQueryWithRpGuid:theRpGuid];
                if (newParcelEventQueryResult)
                    [theResults addObject:newParcelEventQueryResult];
            
            //--- add Transfer query result (if any) to items that will be displayed on dashboard
            NSString *transferEventQueryResult = [self runTransferQueryWithRpGuid:theRpGuid];
                if(transferEventQueryResult)
                    [theResults addObject:transferEventQueryResult];
            
            //--- add Assessment Review query result (if any) to items that will be displayed on dashboard
            NSString *assmtReviewQueryResult = [self runAssmtReviewQueryWithRpGuid:theRpGuid];
                if (assmtReviewQueryResult)
                    [theResults addObject:assmtReviewQueryResult];
            
            //--- add Characteristics Review query result (if any) to items that will be displayed on dashboard
            NSString *characteristicsReviewQueryResult = [self runCharacteristicsReviewQueryWithRpGuid:theRpGuid];
                if (characteristicsReviewQueryResult)
                    [theResults addObject:characteristicsReviewQueryResult];
            
            //--- add Destruct Review query result (if any) to items that will be displayed on dashboard
            NSString *destructReviewQueryResult = [self runDestructReviewQueryWithRpGuid:theRpGuid];
                if (destructReviewQueryResult)
                    [theResults addObject:destructReviewQueryResult];

            //--- add Land Val query result (if any) to items that will be displayed on dashboard
            NSString *landValQueryResult = [self runLandValQueryWithLandGuid:theLndGuid andRpAssmtYr:theYear];
                if (landValQueryResult)
                    [theResults addObject:landValQueryResult];
            
            //--- add Total Val query result (if any) to items that will be displayed on dashboard
            //            NSString *totalValQueryResult = [self runTotalValQueryWithLandId:theLandId andRpAssmtYr:theYear];
            //                if (totalValQueryResult)
            //                    [theResults addObject:totalValQueryResult];
            
            
            _toDoItems = theResults;
        
            return theResults;
        }



    -(NSString*)runSaleVerificationQueryWithRPGuid:(NSString *)theRpGuid andAssmtYear:(int)theAssmtYr
        {
            if ((theRpGuid.length) == 0 || theAssmtYr == 0)
                return nil;
        
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
            int adjustedAssmtYear = theAssmtYr -3;
            NSMutableString *adjustedAssmtYearAsString = [NSMutableString stringWithFormat:@"%i-01-01",adjustedAssmtYear];
            NSDate *saleDate =  [dateFormatter dateFromString:adjustedAssmtYearAsString];
            NSDate *verifDate = [dateFormatter dateFromString:@"1900-01-01"];
    
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saleVerif.vYVerifDate=%@ AND saleDate>=%@ AND salePrice>0 AND ANY saleParcel.rpGuid=%@", verifDate, saleDate, theRpGuid];
    
            int theQueryResultCount = [self runQueryOnEntity:@"Sale" usingPredicate:predicate andContext:self.managedObjectContext];
            
            if (theQueryResultCount == 0)
                {
                    return nil;
                }
            else
                {
                    return @"Sales Verification is needed.";
                }

        }


    -(NSString*)runLandInspectionQueryWithRPGuid:(NSString *)theRpGuid
        {
        
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
            NSDate *completedDate = [dateFormatter dateFromString:@"1900-01-01"];
       
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completedDate > %@ AND rpGuid = %@ AND inspectionTypeItemId IN {1,3}", completedDate, theRpGuid];
        
            int theQueryResultCount = [self runQueryOnEntity:@"Inspection" usingPredicate:predicate andContext:self.managedObjectContext];
        
            if (theQueryResultCount == 0)
                {
                    // If there are no results, that indicates an inspection is needed.
                    return @"Land Inspection is needed.";
                }
            else
                {
                    return nil;
                }
        
        }


    -(NSString*)runImprovmInspectionQueryWithRPGuid:(NSString *)theRpGuid
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *completedDate = [dateFormatter dateFromString:@"1900-01-01"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completedDate > %@ AND rpGuid = %@ AND inspectionTypeItemId IN {2,3}", completedDate, theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"Inspection" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            // If there are no results, that indicates an inspection is needed.
            return @"Improvements Inspection is needed.";
        }
        else
        {
            return nil;
        }

    }


    // Per email from Don Saxby Tues May 13, 2014 1:48 pm, we aren't distinguishing Blank permits and Revisit permits, so this only needs
    // to say 'Permit Review is needed' rather than 'Blank Permit Review is needed' as it was previously.
    -(NSString*)runPermitReviewQueryWithrpGuid:(NSString *)theRpGuid
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid = %@ AND permitStatus = 1", theRpGuid];
        
            int theQueryResultCount = [self runQueryOnEntity:@"Permit" usingPredicate:predicate andContext:self.managedObjectContext];
        
            if (theQueryResultCount == 0)
                {
                    return nil;
                }
            else
                {
                    return @"Permit Review is needed.";
                }

        }


    /*
        // Per email from Don Saxby Tues May 13, 2014 1:48 pm, we aren't distinguishing Blank permits and Revisit permits, so this code isn't needed.
        -(NSString*)runRevisitPermitReviewQueryWithRealPropId:(int)theRealPropId andPropType:(NSString*)thePropType
        {
            if (theRealPropId == 0 || thePropType == nil)
                return nil;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId = %i AND (%@ != 'R' AND permitStatus = 4)", theRealPropId, thePropType];
            
            int theQueryResultCount = [self runQueryOnEntity:@"Permit" usingPredicate:predicate andContext:self.managedObjectContext];
            
            if (theQueryResultCount == 0)
            {
                //NSLog(@"No Blank Permit Reviews.");
                return nil;
            }
            else
            {
                //NSLog(@"Revisit Permit Review is needed.");
                return @"Revisit Permit Review is needed.";
            }
            
        }
    */


    -(NSString*)runSegMergeQueryWithRpGuid:(NSString *)theRpGuid
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid = %@ AND typeItemId = 4 AND propStatus IN {0,2}", theRpGuid];
        
            int theQueryResultCount = [self runQueryOnEntity:@"ChngHist" usingPredicate:predicate andContext:self.managedObjectContext];
        
            if (theQueryResultCount == 0)
                {
                    return nil;
                }
            else
                {
                    return @"Seg/Merge is needed.";
                }

        }

    -(NSString*)runUnKillQueryWithRpGuid:(NSString *)theRpGuid
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid = %@ AND propStatus IN {0,2} AND typeItemId IN {8,9}", theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"ChngHist" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"UnKill is needed.";
        }
        
    }


    -(NSString*)runNewParcelQueryWithRpGuid:(NSString *)theRpGuid
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid = %@ AND propStatus IN {0,2} AND typeItemId = 10", theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"ChngHist" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"New Parcel Event.";
        }
    }


    -(NSString*)runTransferQueryWithRpGuid:(NSString *)theRpGuid
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid = %@ AND propStatus IN {0,2} AND typeItemId = 11", theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"ChngHist" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Transfer Event.";
        }
    }


    -(NSString*)runAssmtReviewQueryWithRpGuid:(NSString *)theRpGuid
    {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reviewType == 4 AND rpGuid == %@ AND statusAssmtReview != 9", theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"Review" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Assessment Review is needed.";
        }
    }


    -(NSString*)runCharacteristicsReviewQueryWithRpGuid:(NSString *)theRpGuid
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reviewType == 5 AND rpGuid == %@ AND statusAssmtReview != 9", theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"Review" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Characteristics Review is needed.";
        }
    }


    -(NSString*)runDestructReviewQueryWithRpGuid:(NSString *)theRpGuid
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reviewType == 6 AND rpGuid == %@ AND statusAssmtReview != 9", theRpGuid];
        
        int theQueryResultCount = [self runQueryOnEntity:@"Review" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Destruct Review is needed.";
        }
    }


    -(NSString*)runLandValQueryWithLandGuid:(NSString *)theRpGuid andRpAssmtYr:(int)theRpAssmtYr
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid == %@ AND baseLandValTaxYr <> %i AND realPropInfo.propType <> 'R'", theRpGuid, theRpAssmtYr+1];
        
        int theQueryResultCount = [self runQueryOnEntity:@"Land" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Land Val is needed.";
        }
    }



    -(NSString*)runTotalValQueryWithLandId:(NSString *)theLandGuid andRpAssmtYr:(int)theRpAssmtYr
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lndGuid == %@ AND rollYr == %i", theLandGuid, theRpAssmtYr+1];
        
        int theQueryResultCount = [self runQueryOnEntity:@"ApplHist" usingPredicate:predicate andContext:self.managedObjectContext];
        
        if (theQueryResultCount == 0)
        {
            return @"Total Val is needed.";
        }
        else
        {
            return nil;
        }
    }


    -(NSString*)runBookmarkGeneralQueryWithRPGuid:(NSString *)theRpGuid
    {
        NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=0", theRpGuid];
        int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Bookmark General is needed.";
        }
    }


    -(NSString*)runBookmarkRevisitQueryWithRPGuid:(NSString *)theRpGuid
    {
        NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=1", theRpGuid];
        int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    
        if (theQueryResultCount == 0)
        {
            return nil;
        }
        else
        {
            return @"Bookmark Revisit is needed.";
        }
    }
-(NSString*)runBookmarkCallOwnerQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=7", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Call owner.";
    }
}


-(NSString*)runBookmarkGetPlansQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=8", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Get Plans.";
    }
}
-(NSString*)runBookmarkFinishDrawingQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=5", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Finish Drawing.";
    }
}


-(NSString*)runBookmarkCheckWebsiteQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=11", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Check Website.";
    }
}
-(NSString*)runBookmarkSetAppointmentQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=2", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Set Appointment.";
    }
}


-(NSString*)runBookmarkIncompleteNewBuildingQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=3", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Incomplete New Building.";
    }
}
-(NSString*)runBookmarkWaitForCallbackQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=4", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Wait for callback.";
    }
}


-(NSString*)runBookmarkSeeNoteQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=6", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark See Note.";
    }
}
-(NSString*)runBookmarkDoNotSynchronizeQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=9", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Do not synchronize.";
    }
}


-(NSString*)runBookmarkOtherQueryWithRPGuid:(NSString *)theRpGuid
{
    NSManagedObjectContext *personalNotesContext = [AxDataManager defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@ AND typeItemId=10", theRpGuid];
    int theQueryResultCount = [self runQueryOnEntity:@"Bookmark" usingPredicate:predicate andContext:personalNotesContext];
    
    if (theQueryResultCount == 0)
    {
        return nil;
    }
    else
    {
        return @"Bookmark Other.";
    }
}



    -(int)runQueryOnEntity:(NSString*)theEntityName usingPredicate:(NSPredicate*)thePredicate andContext:(NSManagedObjectContext*)theContext
    {
        NSFetchRequest *fetcher = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:theEntityName inManagedObjectContext:theContext];
        
        
        [fetcher setEntity:entity];
        [fetcher setPredicate:thePredicate];
        
        
        NSError *error = nil;
        NSArray *theResults = [theContext executeFetchRequest:fetcher error:&error];
        
        if (error)
        {
            NSLog(@"The error is %@, %@",error, error.userInfo);
            return 0;
        }
        
        return [theResults count];
    }



//
//
//    -(MKNumberBadgeView*)getBadgeFromToDoButton:(UIButton*)theButton
//    {
//        MKNumberBadgeView *theBadge = nil;
//        
//        if ([[theButton subviews] count]>0)
//        {
//            //Get reference to the subview, and if it's a badge, remove it from it's parent (the button)
//            
//            int initalValue = [[theButton subviews] count]-1;
//            
//            for (int i=initalValue; i>=0; i--) {
//                
//                //NSLog(@"Found a ToDo button subview of class %@",NSStringFromClass([[[theButton subviews] objectAtIndex:i] class]));
//                
//                if ([[[theButton subviews] objectAtIndex:i] isMemberOfClass:[MKNumberBadgeView class]])
//                {
//                    if (theBadge == nil) {
//                        theBadge = [[theButton subviews] objectAtIndex:i];
//                    }
//                    else {
//                        [[[theButton subviews] objectAtIndex:i] removeFromSuperview];
//                        [theButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
//                    }
//                }
//            }
//        }
//        
//        if (theBadge == nil) {
//            theBadge = [[MKNumberBadgeView alloc]initWithFrame:CGRectMake(32, -5, 18, 18)];
//        }
//        
//        return theBadge;
//    }
//
//
//
//-(void)removeToDoBadgeFromButton:(UIButton*)theButton
//{
//    if ([[theButton subviews] count]>0)
//    {
//        int initalValue = [[theButton subviews] count]-1;
//        //Get reference to the subview, and if it's a badge, remove it from it's parent (the button)
//        for (int i=initalValue; i>=0; i--) {
//            
//            if ([[[theButton subviews] objectAtIndex:i] isMemberOfClass:[MKNumberBadgeView class]])
//            {
//                [[[theButton subviews] objectAtIndex:i] removeFromSuperview];
//                [theButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
//            }
//        }
//    }
//    
//}
//
//
//-(void)displayDashboardPopoverOnButton:(id)theButton
//{
//    // Create the popover content view controller from the nib.
//    // Create a popover and initialize it with the tableview
//    // Size the popover... width MUST be between 320 and 600
//    // Present the popover
//    
//    int popoverHeight = 1;
//    
//    if ([self.toDoItems count]>0)
//    {
//        popoverHeight = [self.toDoItems count];
//        
//        DashboardToDoTableViewController *theTableViewController = [[DashboardToDoTableViewController alloc] init];
//        theTableViewController.dashboardToDoDelegate = self;
//        theTableViewController.listOfItems = self.toDoItems;
//        theToDoItemsPopover = [[UIPopoverController alloc] initWithContentViewController:theTableViewController];
//        theToDoItemsPopover.delegate = self;
//        
//        [theToDoItemsPopover setPopoverContentSize:CGSizeMake(320, popoverHeight*44) animated:YES];
//        [theToDoItemsPopover presentPopoverFromRect:[theButton bounds] inView:theButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:(YES)];
//    }
//    
//}
//


@end
















































