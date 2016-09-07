/*
    Verify that the tag care correct for the 3 components (i.e. 2050, 2051, etc.)
    if not, the message "viewController" is wrong comes from wrongly associating the tags #
*/
#import "TabMobile.h"
#import "TabMobileGrid.h"
#import "TabMobileDetail.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "iRealProperty.h"
#import "MediaView.h"
#import "PictureDetails.h"
#import "TrackChanges.h"
#import "RealPropertyApp.h"

@implementation TabMobile

-(void)setupBusinessRules:(id)baseEntity
{

    if([detailController isNewContent])
    {        
        MHAccount *mhAccount = [AxDataManager getNewEntityObject:@"MHAccount"];
        MHCharacteristic *mhChar = [AxDataManager getNewEntityObject:@"MHCharacteristic"];
        MHLocation *mhLoc = [AxDataManager getNewEntityObject:@"MHLocation"];
        
        mhAccount.mHCharacteristic = mhChar;
        mhAccount.mHLocation = mhLoc;
        RealPropInfo *propInfo = [RealProperty realPropInfo];
        
        mhAccount.rowStatus = @"I";
        mhAccount.rpGuid = propInfo.guid;       
        
        mhChar.rowStatus = @"I";
        mhChar.mhGuid = mhAccount.guid;
        // per Hoang 9/8/2015
        mhChar.guid = mhAccount.guid;
        
        // in Mobile characteristics, the 0 is not defined in LUItems2
        mhChar.class_ = 1;
        mhChar.condition = 1;
        mhChar.size = 1;
        
        mhLoc.rowStatus = @"I";
        mhLoc.mhGuid = mhAccount.guid;
        mhLoc.guid = mhAccount.guid;
        
        
        
        mhAccount.txExempt = NO;

        self.detailController.workingBase = mhAccount;  // to allow the delete when canceling
        
        ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
        screen.workingBase = mhAccount;
        [screen setScreenEntities];

        screen = [detailController.controllerList valueForKey:@"MobileCharacteristic"];
        screen.workingBase = mhChar;
        [screen setScreenEntities];
        
        screen = [detailController.controllerList valueForKey:@"MobileLocation"];
        screen.workingBase = mhLoc;
        [screen setScreenEntities];

    }

}
// Save the current form
-(void)addNewDetails
{
    RealPropInfo *info = [RealProperty realPropInfo];
    [info addMHAccountObject:(MHAccount *)( self.detailController.workingBase)];
    MHAccount *mhAccount = (MHAccount *)( self.detailController.workingBase);
    
    for(MediaMobile *media in mhAccount.mediaMobile)
    {
        media.mhGuid = mhAccount.guid;
    }
}
// Save the the current details
-(void)saveCurrentDetails
{
    
    
}
//
// A new media is created
//
- (void)addNewMedia
{
    MediaMobile *media = [AxDataManager getNewEntityObject:@"MediaMobile"];
    [self defaultMediaInformation:media];
    
    if(detailController.mediaController==nil)
    {
        // create the Media controller the first time
        [detailController addMedia:kTabMobileImage mediaArray:nil];
    }
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    MHAccount *mhAccount = (MHAccount *)[screen workingBase];
    
    media.mhGuid = mhAccount.guid;
    [mhAccount addMediaMobileObject:media];
    
    // Refresh the grid
    // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
    [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:mhAccount.mediaMobile]]];
    //[self refreshMedias:[AxDataManager orderSet:mhAccount.mediaMobile property:@"mediaDate" ascending:NO]];
}
-(void) deleteMedia:(id)media
{
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    MHAccount *mhAccount = (MHAccount *)[screen workingBase];
    
    NSManagedObjectContext *context = [AxDataManager defaultContext];

    if([[media rowStatus] isEqualToString:@"I"])
    {
        [mhAccount removeMediaMobileObject:media];
        [context deleteObject:media];
    }
    else
        [media setRowStatus:@"D"];
//undo        [media setUpdateDate:[[Helper localDate]timeIntervalSinceReferenceDate]];
    // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
    [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:mhAccount.mediaMobile]]];
    //[self refreshMedias:[AxDataManager orderSet:mhAccount.mediaMobile property:@"mediaDate" ascending:NO]];
    self.isDirty = YES;
    [self entityContentHasChanged:nil];
}
//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultSort = @"bldgNbr";
    defaultSortOrderAsc = YES;
    defaultBaseEntity = @"MHAccount";
    currentIndex = 0;
    tabIndex = kTabMobile;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.mHAccount;
    
    setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
    
    return setEntities;
}
//
// Draw an image from the grid
-(void)drawImgEntity:(NSObject *)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex intoRect:(CGRect)rect
{
    GridController *gc = (GridController *)grid;
    
    NSArray *rows = gc.getGridContent;
    
    MHAccount *mhAccount = (MHAccount *)[rows objectAtIndex:rowIndex];
    NSArray *medias = [AxDataManager orderSet:mhAccount.mediaMobile property:@"order" ascending:YES];
    if([medias count]>0)
        [MediaView drawImageFromMediaInRect:[medias objectAtIndex:0] destRect:rect scale:YES];
}
// this method is called when new data is updated
- (void)updateDetailMedia
{
    if(detailController.mediaController==nil)
    {
        // create the Media controller the first time
        [detailController addMedia:kTabMobileImage mediaArray:nil];
    }
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    MHAccount *mhAccount = (MHAccount *)[screen workingBase];
    
    NSArray *medias = [AxDataManager orderSet:mhAccount.mediaMobile property:@"MediaDate" ascending:NO];
    [detailController.mediaController updateMedias:medias];
    
}
// Delete one object
- (BOOL) deleteSelection:(NSManagedObject *)object
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.mHAccount;
    
    for(MHAccount *mhAccount in set)
    {
        if(mhAccount==object)
        {
            if([mhAccount.rowStatus isEqualToString:@"I"])
            {
                [info removeMHAccountObject:mhAccount];
                [[AxDataManager defaultContext]deleteObject:mhAccount];
                [[AxDataManager defaultContext]save:nil];
                return NO;
            }
            else
            {
                mhAccount.rowStatus = @"D";
                mhAccount.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                mhAccount.mHCharacteristic.rowStatus = @"D";
                mhAccount.mHCharacteristic.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                mhAccount.mHLocation.rowStatus = @"D";
                mhAccount.mHLocation.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                return YES;
            }
        }
    }
    return NO;
}
-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
    currentIndex = rowIndex;
    animationOn = NO;
    GridController *gController = (GridController *)grid;
    NSArray *rows = [gController getGridContent];
    MHAccount *mhAccount = [rows objectAtIndex:rowIndex];

    detailController.isNewContent = NO;
    detailController.isDirty = NO;
    [detailController setScreenEntities];
    [self displayDetail];
      
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    screen.workingBase = mhAccount;
    [screen setScreenEntities];

    screen = [detailController.controllerList valueForKey:@"MobileCharacteristic"];
    screen.workingBase = mhAccount.mHCharacteristic;
    [screen setScreenEntities];
    
    screen = [detailController.controllerList valueForKey:@"MobileLocation"];
    screen.workingBase = mhAccount.mHLocation;
    [screen setScreenEntities];

    [self updateDetailMedia];
    // Update the grid
    [self switchControlBar:kGridControlModeNextPrevious];
    // Update the current position vs. the entire number of entries
    [self.controlBar setSmallLabelText:[NSString stringWithFormat:@"%d/%d",rowIndex+1,[rows count]]];
}
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    // If any content has changed, change indicate status
    [self.propertyController segmentUsed:kTabMobile];
    self.isDirty = YES;
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    [screen willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
    screen = [detailController.controllerList valueForKey:@"MobileCharacteristic"];
    [screen willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
    screen = [detailController.controllerList valueForKey:@"MobileLocation"];
    [screen willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
}
-(void)gridMediaAddCad:(id)grid
{
    RealPropInfo *info = [RealProperty realPropInfo];
    
    
    modelController  = [[DVModelController alloc]initWithNibName:@"DVModelController" bundle:nil]; 
    modelController.realPropInfo = info;
    modelController.delegate = self;
    
    // Create a new entity object
    MediaMobile *media = [self createEmptMediaObject];
    modelController.mediaBldg = (MediaBldg *)media;
    modelController.mediaMode = kCadNew;
    
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    UIViewController *controller = app.tabBarController;
    [controller.view addSubview:modelController.view];
    [controller.view bringSubviewToFront:modelController.view];
    
    UIView *top = modelController.view;
    
    
    top.frame = CGRectOffset(top.frame, 1024, 0);
    //[self deregisterFromKeyboardNotifications];
    
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        top.frame =  CGRectOffset(top.frame,-1024,0); 
    } completion:^(BOOL done)
     {
     }];
}
-(id)createEmptMediaObject
{
    MediaMobile *media = [AxDataManager getNewEntityObject:@"MediaMobile"];
    [self defaultMediaInformation:media];
//    media.mediaType = kMediaPlan;   // special case with 2 attached files
    media.mediaType = kMediaImage;
    media.postToWeb = YES;    // default value
    media.primary = NO;
    media.imageType = 2;

    return media;
}
-(void)dvModelCompleted:(DVModelController *)model completion:(BOOL)cancel animate:(BOOL)animate
{
    if(!cancel)
    {
        // The file has been updated
        if(modelController.mediaMode == kCadNew)
        {
            ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
            MHAccount *mhAccount = (MHAccount *)[screen workingBase];
            MediaMobile *media = (MediaMobile *) modelController.mediaBldg;
            media.active = YES;
            media.primary = NO;
            media.order = 1;
            media.mediaDate = [[Helper localDate]timeIntervalSinceReferenceDate];
            media.mhGuid = mhAccount.guid;
            
            [mhAccount addMediaMobileObject:media];
            //[self entityContentHasChanged:nil];
            [[AxDataManager defaultContext]save:nil];
        }
    }
    if(animate)
    {
    UIView *top = modelController.view;
    [self updateDetailMedia];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
                         top.frame =  CGRectOffset(top.frame,1024,0); 
                     } 
                     completion:^(BOOL finished){
                         [modelController.view removeFromSuperview];
                         [modelController removeFromParentViewController];
                         //[modelController viewDidUnload];
                         modelController = nil;
                     }];
    }
}
#pragma mark - Update
-(BOOL)shouldSwitchView
{    
    int res=0;
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    res += ![screen shouldSwitchView:screen.workingBase];
    
    screen = [detailController.controllerList valueForKey:@"MobileCharacteristic"];
    res += ![screen shouldSwitchView:screen.workingBase ];
    
    screen = [detailController.controllerList valueForKey:@"MobileLocation"];
    res += ![screen shouldSwitchView:screen.workingBase ];
    
    if(res==0)
        return YES;
    return NO;
}
-(int)validationError:(int)errorType
{
    int count = 0;
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    count += [screen validationError:errorType];
    
    screen = [detailController.controllerList valueForKey:@"MobileCharacteristic"];
    count += [screen validationError:errorType];
    
    screen = [detailController.controllerList valueForKey:@"MobileLocation"];
    count += [screen validationError:errorType];
    return count;
}
-(NSArray *)validationErrorList
{
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    ScreenController *screen = [detailController.controllerList valueForKey:@"MobileAccount"];
    [results addObjectsFromArray:[screen validationErrorList]];
    
    screen = [detailController.controllerList valueForKey:@"MobileCharacteristic"];
    [results addObjectsFromArray:[screen validationErrorList]];
    
    screen = [detailController.controllerList valueForKey:@"MobileLocation"];
    [results addObjectsFromArray:[screen validationErrorList]];
    return results;
}


@end
