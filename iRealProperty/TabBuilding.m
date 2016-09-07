#import "TabBuilding.h"
#import "TabBuildingDetail.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "MediaView.h"
#import "TrackChanges.h"
#import "RealPropertyApp.h"

#import "TabBase.h"


@implementation TabBuilding

static BOOL interiorPicture = YES;
static BOOL fromBldgToPlan  = NO;

+(void)interiorPicture:(BOOL)click
{
    interiorPicture = click;
}


//
// Init the default values of the grid
    - (void)initDefaultValues
        {
            defaultSort         = @"bldgNbr";
            defaultSortOrderAsc = YES;
            defaultBaseEntity   = @"ResBldg";
            currentIndex        = 0;
            tabIndex            = kTabBuilding;
            defaultGridTitle    = @"List of Buildings (%d)";
        }



//
// Return the list of rows -- setEntities is assigned the result as well
    - (NSArray *)getDefaultOrderedList
        {
            RealPropInfo *info = [RealProperty realPropInfo];
            NSSet        *set  = info.resBldg;
            setEntities = [AxDataManager orderSet:set property:defaultSort ascending:defaultSortOrderAsc];

            return setEntities;
        }

//
// Draw an image from the grid
    - (void)drawImgEntity:(NSObject *)grid
                 rowIndex:(int)rowIndex
              columnIndex:(int)columnIndex
                 intoRect:(CGRect)rect
        {
            GridController *gc = (GridController *) grid;

            NSArray *rows = gc.getGridContent;

            ResBldg *resBldg = (ResBldg *) [rows objectAtIndex:rowIndex];
            NSArray *medias  = [AxDataManager orderSet:resBldg.mediaBldg property:@"order" ascending:YES];
            if ([medias count] > 0)
                [MediaView drawImageFromMediaInRect:[medias objectAtIndex:0] destRect:rect scale:YES];
        }

// this method is called when new data is updated
    - (void)updateDetailMedia
        {
            if (self.detailController.mediaController == nil)
                {
                    // create the Media controller the first time
                    [self.detailController addMedia:kTabBuildingImage mediaArray:nil];
                }
            ResBldg *resBldg = (ResBldg *) [self.detailController workingBase];

            // 2/20/13 HNN no need to sort since sorting is done by sortMedia
            NSArray *medias = [AxDataManager setToArray:resBldg.mediaBldg];
            //NSArray *medias = [AxDataManager orderSet:resBldg.mediaBldg property:@"MediaDate" ascending:NO];

            [self.detailController.mediaController updateMedias:[RealProperty sortMedia:medias]];

        }



// Delete one object
    - (BOOL)deleteSelection:(NSManagedObject *)object
        {
            RealPropInfo *info = [RealProperty realPropInfo];
            NSSet        *set  = info.resBldg;

            for (ResBldg *bldg in set)
                {
                    if (bldg == object)
                        {
                            if ([bldg.rowStatus isEqualToString:@"I"])
                                {
                                    [[AxDataManager defaultContext] deleteObject:bldg];
                                    [[AxDataManager defaultContext] save:nil];
                                    return NO;
                                }
                            else
                                {
                                    bldg.rowStatus = @"D";
                                    bldg.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate];
                                    return YES;
                                }
                        }
                }
            return NO;
        }



// Save the current form
    - (void)addNewDetails
        {
            RealPropInfo *propInfo = [RealProperty realPropInfo];
            ResBldg *bldg = (ResBldg *) [self.detailController workingBase];
            [propInfo addResBldgObject:bldg];

            // update media information
            for (MediaBldg *mediaBldg in bldg.mediaBldg)
                {
                    mediaBldg.bldgGuid = bldg.guid;
                }

        }



//
// A new media is created
//
    - (void)addNewMedia
        {
            MediaBldg *media = [AxDataManager getNewEntityObject:@"MediaBldg"];
            
            if (interiorPicture == YES)
                [self defaultMediaInformation:media postToWeb:interiorPicture];
            else
                [self defaultMediaInformation:media];
            

            if (self.detailController.mediaController == nil)
                {
                    // create the Media controller the first time
                    [self.detailController addMedia:kTabBuildingImage mediaArray:nil];
                }
            ResBldg *resBldg = (ResBldg *) [self.detailController workingBase];
            media.bldgGuid = resBldg.guid;
            [resBldg addMediaBldgObject:media];

            // Refresh the grid
            // 2/20/13 HNN no need to sort since sorting is done by sortMedia
            NSArray *area = [AxDataManager setToArray:resBldg.mediaBldg];
            //    NSArray *area = [AxDataManager orderSet:resBldg.mediaBldg property:@"mediaDate" ascending:NO];
            area = [RealProperty sortMedia:area];
            [self refreshMedias:area];
        }



    - (void)deleteMedia:(id)media
        {
            ResBldg                *resBldg = (ResBldg *) [detailController workingBase];
            NSManagedObjectContext *context = [AxDataManager defaultContext];

            if ([[media rowStatus] isEqualToString:@"I"])
                {// media has been inserted locally, then we can delete
                    [resBldg removeMediaBldgObject:media];
                    [context deleteObject:media];
                }
            else
                [media setRowStatus:@"D"];  // mark as deleted
//undo                [media setUpdateDate:[[Helper localDate]timeIntervalSinceReferenceDate]];

            // 2/20/13 HNN no need to sort since sorting is done by sortMedia
            NSArray *area = [AxDataManager setToArray:resBldg.mediaBldg];
            //NSArray *area = [AxDataManager orderSet:resBldg.mediaBldg property:@"mediaDate" ascending:NO];
            //area = [RealProperty sortMedia:area];
            area = [RealProperty sortMedia:area];

            [self refreshMedias:area];
            self.isDirty = YES;
            [self entityContentHasChanged:nil];
        }



// Save the the current details
    - (void)saveCurrentDetails
        {
#if 0
    GridController *gController = [gridController getFirstGridController];
    NSArray *rows = [gController getGridContent];
    NSManagedObject *row = [rows objectAtIndex:currentIndex];
    
    RealPropInfo *propInfo = [RealProperty realPropInfo];
    Land *land = propInfo.land;
    
    
    //for(ResBldg *bldg in land.resBldg)
    for(ResBldg *bldg in propInfo.ResBldg)
    {
        if(bldg==row)
        {
            // Cloning    [AxDataManager copyManagedObject:[detailController workingBase] destination:bldg withSets:YES withLinks:YES];
            break;
        }
    }
#endif
        }



    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
            // If any content has changed, change indicate status
            [self.propertyController segmentUsed:kTabBuilding];
            self.isDirty = YES;
            // Calculate the total living area
            ResBldg *resBldg = (ResBldg *) [detailController workingBase];

            int total = (resBldg.sqFt1stFloor + resBldg.sqFtHalfFloor + resBldg.sqFt2ndFloor + resBldg.sqFtUpperFloor +
                    resBldg.sqFtFinBasement) - (resBldg.sqFtUnFinHalf + resBldg.sqFtUnFinFull);
            resBldg.sqFtTotLiving = total;
            // Hard coded number to find the area
            UITextField *text = (UITextField *) [detailController.view viewWithTag:20];
            text.text             = [NSString stringWithFormat:@"%d", total];
            if ([resBldg.rowStatus caseInsensitiveCompare:@"I"] != NSOrderedSame &&
                    [resBldg.rowStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
                resBldg.rowStatus = @"U";
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
            [modelController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

        }
// Custom code to handle the CAD model
//
// Create a new model
//

    - (void)gridMediaAddCad:(id)grid
        {            
            
            RealPropInfo *info = [RealProperty realPropInfo];
//            //[TabBase buildingToPlan] = TRUE];
//            //TabBase *base = base.buildingToPlan
//            TabBase *base;
//            base.buildingToPlan = TRUE;
            
            fromBldgToPlan = YES;

            modelController = [[DVModelController alloc] initWithNibName:@"DVModelController" bundle:nil];
            modelController.realPropInfo = info;
            modelController.delegate     = self;

            MediaBldg *media = [self createEmptyMediaObject];   ///imageType = 2 mediaType =1

            modelController.mediaBldg = media;
            modelController.mediaMode = kCadNew;

            RealPropertyApp  *app        = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            UIViewController *controller = app.tabBarController;
            [controller.view addSubview:modelController.view];
            [controller.view bringSubviewToFront:modelController.view];

            UIView *top = modelController.view;


            top.frame = CGRectOffset(top.frame, 1024, 0);
            //[self deregisterFromKeyboardNotifications];


            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
                {
                    top.frame = CGRectOffset(top.frame, -1024, 0);
                }            completion:^(BOOL done)
                {
                }];
        }

    - (id)createEmptyMediaObject
        {
            // Create a new entity object
            MediaBldg *media = [AxDataManager getNewEntityObject:@"MediaBldg"];
            [media setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
            [media setValue:@"" forKey:@"desc"];
            [media setValue:[Helper localDate] forKey:@"mediaDate"];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
            [media setValue:[NSNumber numberWithInt:[components year]] forKeyPath:@"year"];
            [media setValue:@"I" forKey:@"rowStatus"];
            [media setValue:[NSNumber numberWithInt:1] forKeyPath:@"order"];
            NSString *mediaGuid = [Requester createNewGuid];
            [media setValue:mediaGuid forKey:@"guid"];

            //////////////[self defaultMediaInformation:media];
//            media.mediaType  = kMediaPlan;   // special case with 2 attached files
            media.mediaType  = kMediaImage;
            media.postToWeb  = YES;    // default value //used as a constraint for wmf files
            media.primary    = NO;
            media.imageType  = 2;

            return media;
        }



    - (void)dvModelCompleted:(DVModelController *)model
                  completion:(BOOL)cancel
                     animate:(BOOL)animate
        {
            if (!cancel)
                {
                    // 4/26/16 HNN need to link new media to resbldg record
//                    if (model.mediaMode == kCadUpdate)
//                        {

                            // There is a new media to be added to the building
                            if (self.detailController.mediaController == nil)
                                {
                                    // create the Media controller the first time
                                    [self.detailController addMedia:kTabBuildingImage mediaArray:nil];
                                }
                    
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
                            ResBldg   *resBldg = (ResBldg *) [self.detailController workingBase];
                            MediaBldg *media   = model.mediaBldg;
                            // 4/26/16 HNN preserve existing drawing by create a new drawing record. kCadNew records are new media records already
                            if (model.mediaMode==kCadUpdate)
                            {
                                media = [AxDataManager getNewEntityObject:@"MediaBldg"];
                                model.mediaBldg=media; // 4/26/16 save media back to model so tabpictcontroller can reference and add it to the media array to be displayed.
                            }
                            media.guid = model.sketchGuid;
                            media.bldgGuid = resBldg.guid;
                            media.imageType = kMediaFplan;
                            media.mediaType = kMediaImage;
                            media.active     = YES;
                            media.primary    = NO;
                            media.order      = 1;
                            media.mediaDate  = [[Helper localDate] timeIntervalSinceReferenceDate];
                            media.postToWeb = 1;
                            media.rowStatus=@"I";
                            media.year = [components year];
                            [RealPropertyApp updateUserDate:media];
                    
                            // 4/27/16 HNN new drawing and updates to existing drawing are new drawings that needs to be added to the resbldg.media collection. once a new drawing is added the resbldg.media collection, any updates to that drawing is on the same object so we don't need to add to the resbldg.media collection
                            if (model.mediaMode==kCadUpdate || model.mediaMode==kCadNew)
                                [resBldg addMediaBldgObject:media];
                            //[self entityContentHasChanged:nil];
                            [[AxDataManager defaultContext] save:nil];
                            ///////////////////////////////////////
                            NSLog(@"Media GUId=%@", model.sketchGuid);                            

                            // Refresh the grid
                    // 4/26/16 HNN the following call updates the pictures on the tabbuilding
                            [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:resBldg.mediaBldg]]];
//                        }
                }
            if (animate)
                {
                    UIView *top = model.view;

                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                                     animations:^
                                         {
                                             top.frame = CGRectOffset(top.frame, 1024, 0);
                                         }
                                     completion:^(BOOL finished)
                                         {
                                             [model.view removeFromSuperview];
                                             [model removeFromParentViewController];
                                             //    model = nil;
                                         }];
                }
            //5/18/16 cv
            model = nil;
            fromBldgToPlan = NO;


        }

@end
