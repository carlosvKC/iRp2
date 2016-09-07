#import "MediaView.h"
#import "Helper.h"
#import "iRealProperty.h"
#import "RealPropertyApp.h"
#import "TrackChanges.h"
#import "ReadPictures.h"


#define DebugImage false


@implementation MediaView

///
/// resize image
/// got code from http://stackoverflow.com/questions/1215869/thumbnail-view-of-images
///
    + (UIImage *)imageScaledToSize:(CGSize)newSize
                       sourceImage:(UIImage *)image
        {
            UIGraphicsBeginImageContext(newSize);
            [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            return newImage;
        }



//
// Return an image from the current media object. Nil if the picture can't be found
// Try to use miniature media if they can be found
//
 /*   + (UIImage *)getImageFromMiniMedia:(NSManagedObject *)mediaLandRecord
        {
            @try
                {
                    // All medias have more or less the same format
                    MediaLand *media = (MediaLand *) mediaLandRecord;

                    // Image comes from  the production file
                    RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

                    if ([media.mediaLoc length] == 0)
                        return nil;

                    NSString *imageLocation = [media.mediaLoc stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
                    NSString *imageLocationAndFileName = [imageLocation stringByAppendingString:@".MINI"];
                    UIImage  *image = [appDelegate getImageFromZip:imageLocationAndFileName];

                    if (image == nil)
                        image = [appDelegate getImageFromZip:imageLocation];

                    CGFloat sizeRatio = 200 / image.size.width;
                    CGFloat newWidth  = image.size.width * sizeRatio;
                    CGFloat newHeight = image.size.height * sizeRatio;
                    CGSize  newSize   = {newWidth, newHeight};
                    return [MediaView imageScaledToSize:newSize sourceImage:image];

                }
            @catch (NSException *exception)
                {
                    NSLog("Exception in MediaView='%@'", exception.description);
                }

            return nil;
        }*/


// Media formats are MediaBldg, MediaLand, MediaNote, MediaAccy, MediaMobile.
// Talked with Hoang and he said that I should find this is used with Bookmarks, the map popover, and one other spot.
// He said that the mini pic can't be found though by using the guid off the mini record.  I have to instead grab the
// guid from the associated non-mini record and use that.  This is because of changes on the database side during sync.
// cv called by - BookmarkController
//              - DVImagePicker
//              - TabMapDetail.....
//    called after
//                - getImageFromZip
//                - findImage
 +(UIImage *)getImageFromMiniMedia:(NSObject *)object
    
     {
         @try {
             if (![object isKindOfClass:[NSManagedObject class]])
                 NSLog(@"Whoa nelly, Object is NOT of type NSManagedObject")
                 
                 //NSLog(@"The object passed to getImageFromMiniMedia is of type %@", NSStringFromClass([object class]))
             
                 MediaLand *media = (MediaLand *)object;  // All medias have more or less the same format
                //ReadPictures *picReader = [[ReadPictures alloc]initWithDataBase:imageDatabasePath];

                // Image comes from  the production file
                RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
             
                if([media.guid length]==0)
                 return nil;
             
                //cv   NSString *str = [media.mediaLoc stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
                NSString *str = media.guid;
                //int16_t imageType = media.imageType;
                //NSString *mini = [str stringByAppendingString:@".MINI"];
                //UIImage *image = [appDelegate getImageFromZip:mini];
            
             //3/15/15 cv Extension comes from Images db
             //NSString *extension = [picReader getExtensionWithGuid:str];

             //cv TODO --> need to add parameter where I check for mediaType 3 x mini
                        // else keep returning image
             
             /////////////
             //UIImage *image = [appDelegate getImageFromZip:str];
             /////////////
    UIImage *image = [appDelegate getImageFromZipWithMediaType:str
                                                     mediatype:kMediaMini];
             
             //cv This process only happens when the download happens on new images inserted from the server
             if(image==nil)
             {
                 UIImage *bigImage = [appDelegate getImageFromZipWithMediaType:str mediatype:kMediaPict];
                 CGFloat sizeRatio =200/bigImage.size.width;
                 CGFloat newWidth = bigImage.size.width * sizeRatio;
                 CGFloat newHeight = bigImage.size.height * sizeRatio;
                 CGSize newSize = {newWidth, newHeight};
                 return [MediaView imageScaledToSize:newSize sourceImage:bigImage];
             }
             else
             {
                 return image;
             }

//             // Image comes from  media file
//             //RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
//             
//             if ([object isKindOfClass:[MediaBldg class]])
//                 NSLog(@"The object passed to getImageFromMiniMedia is of type %@", NSStringFromClass([object class]))
//                 
//                 MediaBldg *mediaBldg = (MediaBldg *)object;  // All medias have more or less the same format
//             
//             // Image comes from  media file
//             //RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
//             //appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
//             RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
//
//             
//             
//            if([mediaBldg.guid length]==0)
//                return nil;
//
//             //just bring it back mediaType = 3
//             NSString *strBldg = mediaBldg.guid;
//             
//             
//             //NSString *mini = [str stringByAppendingString:@".MINI"];
//
//             // I don't know ext until Images get called ...asume for now
//             NSString  *fullName = [strBldg stringByAppendingString:@".JPG"];
//             //figure it out extensions
//             
//             
//             
//             //UIImage *image = [appDelegate getImageFromZip:mini];
//             UIImage *imageBldg = [appDelegate getImageFromZip:fullName];
//             
//             
//             // If mini image cannot be found, then use the full-size image scaled down to fit.
//             //Minis are never found
//             if(imageBldg==nil)
//             {
//                 UIImage *bigImage = [appDelegate getImageFromZip:fullName];
//                 CGFloat sizeRatio =200/bigImage.size.width;
//                 CGFloat newWidth = bigImage.size.width * sizeRatio;
//                 CGFloat newHeight = bigImage.size.height * sizeRatio;
//                 CGSize newSize = {newWidth, newHeight};
//                 return [MediaView imageScaledToSize:newSize sourceImage:bigImage];
//             }
//             else
//             {
//                 return imageBldg;
//             }
//
//
//                //if (![object isKindOfClass:[NSManagedObject class]])
////             if ([object isKindOfClass:[MediaLand class]])
////                    NSLog(@"Whoa nelly, Object is NOT of type NSManagedObject")
////                    //NSLog(@"The object passed to getImageFromMiniMedia is of type %@", NSStringFromClass([object class]))
////                                                     
////                    MediaLand *media = (MediaLand *)object;  // All medias have more or less the same format
////
////                    // Image comes from  media file
////                    //RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
////                    appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
////                    
////                    if([media.guid length]==0)
////                        return nil;
////
////                    //01/1/15 cv   NSString *str = [media.mediaLoc stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
////                    //NSString *str =media.lndGuid;
////                    NSString *str =[media.lndGuid stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
////             
////                    //NSString *mini = [str stringByAppendingString:@".MINI"];
////             
////                    //UIImage *image = [appDelegate getImageFromZip:mini];
////                    UIImage *image = [appDelegate getImageFromZip:str];
////                    // If mini image cannot be found, then use the full-size image scaled down to fit.
////                    if(image==nil)
////                        {
////                         UIImage *bigImage = [appDelegate getImageFromZip:str];
////                         CGFloat sizeRatio =200/bigImage.size.width;
////                         CGFloat newWidth = bigImage.size.width * sizeRatio;
////                         CGFloat newHeight = bigImage.size.height * sizeRatio;
////                         CGSize newSize = {newWidth, newHeight};
////                         return [MediaView imageScaledToSize:newSize sourceImage:bigImage];
////                        }
////                    else
////                        {
////                         return image;
////                        }
 

         
         
         }
         @catch (NSException *exception)
             {
                NSLog("Exception in MediaView='%@'", exception.description);
             }

         return nil;
     }




//
// Return an image from the current media object. Nil if the picture can't be found
//
// This method reads the temp directory for images that are stored locally,
// or make a request to get the file unzipped from the storage
//
    + (UIImage *)getImageFromMedia:(NSManagedObject *)object
        {
            MediaLand *media = (MediaLand *) object;  // All medias have more or less the same format

            // Image comes from  the production file
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            //   NSString  *str  = [media.guid stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
            NSString *str = media.guid;
        
            if ([str length] == 0)
                {
                    NSLog(@"2) getImageFromMedia: mediaGuid is nil");
                    return nil;
                }
            // 4/25/16 HNN retrieve pict
            return [appDelegate getImageFromZipWithMediaType:str mediatype:kMediaPict];
        }



//
// Draw the current image in the destination rectangle and erase the background with the color
//
    + (void)drawImageFromMediaInRect:(NSManagedObject *)media
                            destRect:(CGRect)destRect
                               scale:(BOOL)scale
                           withColor:(UIColor *)backgroundColor
        {
            CGContextRef gc = UIGraphicsGetCurrentContext();
            const CGFloat *f = CGColorGetComponents([backgroundColor CGColor]);

            CGContextSetFillColor(gc, f);
            CGRect frame = CGRectMake(0, 0, destRect.size.width, destRect.size.height);
            CGContextFillRect(gc, frame);
            [self drawImageFromMediaInRect:media destRect:destRect scale:scale];
        }



    + (void)drawImageFromImageInRect:(UIImage *)image
                            destRect:(CGRect)destRect
                               scale:(BOOL)scale
        {
            if (scale)
                {
                    CGFloat factor  = destRect.size.height / image.size.height;
                    CGSize  imgSize = image.size;
                    CGFloat width   = image.size.width * factor;
                    if (width > destRect.size.width)
                        factor = destRect.size.width / image.size.width;

                    CGSize destSize = CGSizeMake(imgSize.width * factor, imgSize.height * factor);

                    destRect = CGRectMake( /*destRect.origin.x + */(destRect.size.width - destSize.width) / 2,
                            /* destRect.origin.y + */ (destRect.size.height - destSize.height) / 2,
                            destSize.width, destSize.height);
                }
            [image drawInRect:destRect];
        }



//
// Draw the current image in the destination rectangle. If the image is not found, display the name of the picture
//
    + (void)drawImageFromMediaInRect:(NSManagedObject *)media
                            destRect:(CGRect)destRect
                               scale:(BOOL)scale
        {
            UIImage *image = [MediaView getImageFromMedia:media];
            destRect       = CGRectInset(destRect, 2.0, 0.0);
            if (image != nil)
                {
                    [MediaView drawImageFromImageInRect:image destRect:destRect scale:scale];
#if DebugImage
           //NSString *debugMsg = [NSString stringWithFormat:@"%d, %@ [%d]",[[media valueForKey:@"mediaId"] intValue],
           //                         [[media valueForKey:@"primary"] intValue]!=0?@"Prim":@"",
           //                         [[media valueForKey:@"order"] intValue]];
                    
        NSString *debugMsg = [NSString stringWithFormat:@"%d, [%@], %d",[[media valueForKey:@"guid"] intValue],
                                          [[media valueForKey:@"mediaType"] intValue]!=1?@"jpeg":@"other",
                                          [[media valueForKey:@"ext"]intValue]];
        
       [Helper drawTextInRect:debugMsg fontName:@"Helvetica" fontSize:12.0 minimumFontSize:10.0 destRect:destRect textAlign:NSTextAlignmentCenter];
        
#endif

                }
            else
                {
                    CGContextRef gc = UIGraphicsGetCurrentContext();

                    CGFloat white[4] = {0.8, 0.8, 0.8, 1.0};
                    CGContextSetFillColor(gc, white);
                    CGContextFillRect(gc, destRect);
                    destRect = CGRectInset(destRect, 12.0, 12.0);
                    [[UIColor blackColor] set];
                    //NSString *message = [NSString stringWithFormat:@"Media '%@.jpg' not found", [media valueForKey:@"mediaLoc"]];
                    NSString *message = @"Media not found";

                    [Helper drawTextInRect:message fontName:@"Helvetica" fontSize:17.0 minimumFontSize:12.0 destRect:destRect textAlign:NSTextAlignmentCenter];
                }
        }



//
// Draw the current image in the destination rectangle. Use the mini media if it is available
//
    + (void)drawImageFromMiniMediaInRect:(NSManagedObject *)media
                                destRect:(CGRect)destRect
                                   scale:(BOOL)scale
        {
            UIImage *image = [MediaView getImageFromMiniMedia:media];
            destRect = CGRectInset(destRect, 2.0, 0.0);
            if (image != nil)
                {
                    [MediaView drawImageFromImageInRect:image destRect:destRect scale:scale];
#if DebugImage
                        // NSString *debugMsg = [NSString stringWithFormat:@"%d, %@ [%d]", [[media valueForKey:@"mediaId"] intValue],
                        //NSString *debugMsg = [[media valueForKey:@"primary"] intValue]!=0?@"Prim":@"",
                          //    [[media valueForKey:@"order"] intValue]];
                    
                    NSString *debugMsg = [NSString stringWithFormat:@"%d, [%@], %d",[[media valueForKey:@"guid"] intValue],
                                          [[media valueForKey:@"mediaType"] intValue]!=1?@"jpeg":@"other",
                                          [[media valueForKey:@"ext"]intValue]];

        
        [Helper drawTextInRect:debugMsg fontName:@"Helvetica" fontSize:12.0 minimumFontSize:10.0 destRect:destRect textAlign:NSTextAlignmentCenter];
        
#endif
                }
            else
                {
                    CGContextRef gc = UIGraphicsGetCurrentContext();

                    CGFloat white[4] = {0.8, 0.8, 0.8, 1.0};
                    CGContextSetFillColor(gc, white);
                    CGContextFillRect(gc, destRect);
                    destRect = CGRectInset(destRect, 12.0, 12.0);
                    [[UIColor blackColor] set];
                    NSString *message = @"Media not found";

                    [Helper drawTextInRect:message fontName:@"Helvetica" fontSize:17.0 minimumFontSize:12.0 destRect:destRect textAlign:NSTextAlignmentCenter];
                }
        }


//
// Is used to create a new media (from a dialog box for example
//
    + (void)createNewMedia:(id)destination
                 fromMedia:(id)source
                 withImage:(UIImage *)image
        {
            // Cast to another class to make it easier to use
            MediaNote       *media       = destination;
            MediaNote       *org         = source;
            RealPropertyApp *appDelegate = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            NSString *mediaGuid = [Helper generateGUID];
    		media.guid = mediaGuid;
            media.active    = org.active;
            media.desc      = [org.desc copy];
            media.imageType = kMediaPict;   //1
            media.mediaDate = org.mediaDate;
            media.mediaType = kMediaImage;
            media.primary   = org.primary;
            media.order     = org.order;
            
            // 5/21/15 HNN undo Carlos' changes; go back to orginal logic
            //[[appDelegate pictureManager] saveNewImg:image guid:mediaGuid mediaType:kMediaImage ext:@"PNG"];
            [[appDelegate pictureManager] saveNewImage:image withMedia:media];

            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];

            media.year = [components year];
            [RealPropertyApp updateUserDate:media];
        }


//+(NSArray*) sortMedia:(NSSet*)media
//{
//    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc]initWithKey:@"primary" ascending:NO];
//    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc]initWithKey:@"imageType" ascending:YES];
//    NSSortDescriptor *descriptor3 = [[NSSortDescriptor alloc]initWithKey:@"mediaType" ascending:YES];
//    NSSortDescriptor *descriptor4 = [[NSSortDescriptor alloc]initWithKey:@"order" ascending:YES];
//    NSSortDescriptor *descriptor5 = [[NSSortDescriptor alloc]initWithKey:@"mediaDate" ascending:NO];
//    
//    NSArray *descriptors = [NSArray arrayWithObjects:descriptor1,descriptor2,descriptor3,descriptor4,descriptor5, nil];
//    NSArray *sortedArray = [media sortedArrayUsingDescriptors:descriptors];
//    descriptors = nil;
//    return sortedArray;
//}
@end
