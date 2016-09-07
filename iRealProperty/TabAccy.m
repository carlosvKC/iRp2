#import "TabAccy.h"
#import "AxDataManager.h"
#import "MediaView.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation TabAccy


//
// Init the default values of the grid
- (void)initDefaultValues
{
    defaultSort = @"updateDate";
    defaultSortOrderAsc = YES;
    defaultBaseEntity = @"Accy";
    currentIndex = 0;
    tabIndex = kTabAccy;
}
//
// Return the list of rows -- setEntities is assigned the result as well
- (NSArray *)getDefaultOrderedList
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.accy;
    setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];
    
    return setEntities;
}
//
// Draw an image from the grid
-(void)drawImgEntity:(NSObject *)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex intoRect:(CGRect)rect
{
    GridController *gc = (GridController *)grid;
    NSArray *rows = gc.getGridContent;
    
    Accy *accy = (Accy *)[rows objectAtIndex:rowIndex];
    NSArray *medias =     [AxDataManager orderSet:accy.mediaAccy property:@"order" ascending:YES];
    if([medias count]>0)
        [MediaView drawImageFromMediaInRect:[medias objectAtIndex:0] destRect:rect scale:YES];
}
// this method is called when new data is updated
- (void)updateDetailMedia
{
    if(self.detailController.mediaController==nil)
    {
        // create the Media controller the first time
        [self.detailController addMedia:kTabAccyImage mediaArray:nil];
    }
    Accy *accy = (Accy *)[self.detailController workingBase];
    
    NSArray *medias = [AxDataManager orderSet:accy.mediaAccy property:@"MediaDate" ascending:NO];
    [self.detailController.mediaController updateMedias:[RealProperty sortMedia:medias]];
    
}
// Delete one object
-(BOOL)deleteSelection:(NSManagedObject *)object
{
    RealPropInfo *info = [RealProperty realPropInfo];
    NSSet *set = info.accy;
    
    for(Accy *accy in set)
    {
        if(accy==object)
        {
            if([accy.rowStatus isEqualToString:@"I"])
            {
                [info removeAccyObject:accy];
                [[AxDataManager defaultContext] deleteObject:accy];
                [[AxDataManager defaultContext]save:nil];
                return NO;
            }
            else
            {
                accy.rowStatus = @"D";
                accy.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                return YES;
            }
            break;
        }
    }
    [[AxDataManager defaultContext]save:nil];
    return NO;
}
//
// A new media is created
//
- (void)addNewMedia
{
//    RealPropInfo *info = [RealProperty realPropInfo];
    Accy *accy = (Accy *)[detailController workingBase];
    
    MediaAccy *media = [AxDataManager getNewEntityObject:@"MediaAccy"];

    [self defaultMediaInformation:media];
    
    if(detailController.mediaController==nil)
    {
        // create the Media controller the first time
        [detailController addMedia:kTabAccyImage mediaArray:nil];
    }

    media.accyGuid= accy.guid;
    media.rowStatus = @"I";
    [accy addMediaAccyObject:media];
    
    // Refresh the grid
    // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
    [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:accy.mediaAccy]]];
    //[self refreshMedias:[AxDataManager orderSet:accy.mediaAccy property:@"mediaDate" ascending:NO]];
}
-(void) deleteMedia:(id)media
{
    Accy *accy = (Accy *)[detailController workingBase];
    NSManagedObjectContext *context = [AxDataManager defaultContext];
    
    if([[media rowStatus] isEqualToString:@"I"])
    {
        [accy removeMediaAccyObject:media];
        [context deleteObject:media];
    }
    else
        [media setRowStatus:@"D"];
//undo        [media setUpdateDate:[[Helper localDate]timeIntervalSinceReferenceDate]];
        // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
        [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:accy.mediaAccy]]];
        //[self refreshMedias:[AxDataManager orderSet:accy.mediaAccy property:@"mediaDate" ascending:NO]];
        self.isDirty = YES;
        [self entityContentHasChanged:nil];
}
// Save the current form
-(void)addNewDetails
{
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    
    //NSSet *set = propInfo.accy;
     NSSet *bldgs = propInfo.resBldg;
    ResBldg *bldgRes = nil;
    for(ResBldg *bldg in bldgs)
    {
        if(bldg.bldgNbr== 1)
        {
            bldgRes = bldg;
            break;
        }
    }
    
    Accy *accy = (Accy *)[detailController workingBase];
    [propInfo addAccyObject:accy];
    // required items
    accy.rpGuid = propInfo.guid;
    
    if(bldgRes != nil)
    {
        //cv if association with bldgs exist
        accy.bldgGuid = bldgRes.guid;    
    }

    // update the media (if any)
    for(MediaAccy *media in accy.mediaAccy)
    {
        media.accyGuid = accy.guid;
    }
}

// Save the current details
-(void)saveCurrentDetails
{
}

-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    // If any content has changed, change indicate status
    [self.propertyController segmentUsed:kTabAccy];
    self.isDirty = YES;
    
    Accy *accy = (Accy *)[detailController workingBase];
    if(accy==nil)
        return;
    if([accy.rowStatus caseInsensitiveCompare:@"I"]!=NSOrderedSame && [accy.rowStatus caseInsensitiveCompare:@"D"]!=NSOrderedSame)
        accy.rowStatus = @"U";
}
// Custom code to handle the CAD model
//
// Create a new model
//

-(void)gridMediaAddCad:(id)grid
{
    RealPropInfo *info = [RealProperty realPropInfo];
    
    
    modelController  = [[DVModelController alloc]initWithNibName:@"DVModelController" bundle:nil]; 
    modelController.realPropInfo = info;
    modelController.delegate = self;
    
    // Create a new entity object
    id media = [self createEmptyMediaObject];

    //modelController.mediaAccy = (MediaAccy *)media;
    modelController.mediaBldg = media;
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

// Custom code to handle the CAD model with MediaType
// Create a new model
//

-(void)gridMediaAddCad:(id)grid mediaType:(int)mtype
{
    RealPropInfo *info = [RealProperty realPropInfo];
    
    
    modelController  = [[DVModelController alloc]initWithNibName:@"DVModelController" bundle:nil];
    modelController.realPropInfo = info;
    modelController.delegate = self;
    
    // Create a new entity object
    MediaBldg *media = [self createEmptyMediaObject];
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

-(id)createEmptyMediaObject
{
    // Create a new entity object
    MediaAccy *media = [AxDataManager getNewEntityObject:@"MediaAccy"];
    ///
    [media setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
    [media setValue:@"" forKey:@"desc"];
    [media setValue:[Helper localDate] forKey:@"mediaDate"];
    [media setValue:[NSNumber numberWithBool:NO] forKey:@"primary"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
    [media setValue:[NSNumber numberWithInt:[components year]] forKeyPath:@"year"];
    [media setValue:@"I" forKey:@"rowStatus"];
    [media setValue:[NSNumber numberWithInt:1] forKeyPath:@"order"];
    NSString *mediaGuid = [Requester createNewGuid];
    [media setValue:mediaGuid forKey:@"guid"];

    //[self defaultMediaInformation:media];
//    media.mediaType = kMediaPlan;   // special case with 2 attached files
    media.mediaType = kMediaImage;
    media.postToWeb = YES;    // default value
    media.primary = NO;
    media.imageType = 2;
    
    return media;
}

-(void)dvModelCompleted:(DVModelController *)model
             completion:(BOOL)cancel
                animate:(BOOL)animate
{
    if(!cancel)
    {
        // The file has been updated
        // 4/26/16 HNN need to link new media to accy record
//        if(model.mediaMode == kCadNew)
//
//            {
                // There is a new media to be added to the accessory
                if(self.detailController.mediaController==nil)
                    {
                        // create the Media controller the first time
                        [self.detailController addMedia:kTabAccyImage mediaArray:nil];
                    }
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        Accy *accessory = (Accy *)[self.detailController workingBase];
        id media = model.mediaBldg;
        // 4/26/16 HNN preserve existing drawing by create a new drawing record. kCadNew records are new media records already
        if (model.mediaMode==kCadUpdate)
        {
            media = [AxDataManager getNewEntityObject:@"MediaAccy"];
            model.mediaBldg=media; // 4/26/16 save media back to model so tabpictcontroller can reference and add it to the media array to be displayed.
        }
        [media setGuid:model.sketchGuid];
        [media setAccyGuid:accessory.guid];
        [media setImageType:kMediaFplan];
        [media setMediaType:kMediaImage];
        [media setActive:YES];
        [media setPrimary:NO];
        [media setOrder:1];
        [media setMediaDate:[[Helper localDate] timeIntervalSinceReferenceDate]];
        [media setPostToWeb:1];
        [media setRowStatus:@"I"];
        [media setValue:[NSNumber numberWithInt:[components year]] forKeyPath:@"year"];
        [RealPropertyApp updateUserDate:media];

        // 4/27/16 HNN new drawing and updates to existing drawing are new drawings that needs to be added to the resbldg.media collection. once a new drawing is added the resbldg.media collection, any updates to that drawing is on the same object so we don't need to add to the resbldg.media collection
        if (model.mediaMode==kCadUpdate || model.mediaMode==kCadNew)
            [accessory addMediaAccyObject:(MediaAccy*)media];
            //[self entityContentHasChanged:nil];
        
        [[AxDataManager defaultContext]save:nil];
        
            // Refresh the grid
            // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
        NSLog(@"Media GUId=%@", model.sketchGuid);
        
        // Refresh the grid
        // 4/26/16 HNN the following refresh the medias shown on the tabAccy
            [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:accessory.mediaAccy]]];
            //[self refreshMedias:[AxDataManager orderSet:accessory.mediaAccy property:@"mediaDate" ascending:NO]];
//        }
    }
    if(animate)
    {
        UIView *top = modelController.view;
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut 
                         animations:^{
                             top.frame =  CGRectOffset(top.frame,1024,0); 
                         } 
                         completion:^(BOOL finished)
                        {
                             [modelController.view removeFromSuperview];
                             [modelController removeFromParentViewController];
                            //[modelController viewDidUnload];
                             modelController = nil;
                         }];
    }
}


@end
