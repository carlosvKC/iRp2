#import "Helper.h"
#import "Crittercism.h"
#import "AxDataManager.h"
#import "FilesSync.h"
#import "AzureBlob.h"
#import "RealPropertyApp.h"


@implementation Helper

    + (void)displaySubviews:(UIView *)view
            :(int)level
        {
            NSString *leading = @"";
            for (int i = 0; i < level; i++)
                leading = [leading stringByAppendingString:@"---"];

            NSString *name = NSStringFromClass([view class]);

            NSLog(@"%@ 0x%08x - %@ %@ tag=%d", leading, (unsigned int) view, name, NSStringFromCGRect(view.frame), view.tag );

            if (view.subviews == nil)
                return;
            int      count = [view.subviews count];
            for (int i     = 0; i < count; i++)
                {
                    UIView *aView = [view.subviews objectAtIndex:i];
                    [Helper displaySubviews:aView :level + 1];
                }
        }



    + (void)dumpViews:(UIView *)view
        {
            if (view == nil)
                return;
            [self displaySubviews:view :0];
        }



    + (void)displaySuperview:(UIView *)view
                       level:(int)level
        {
            NSString *whiteSpace = @"";
            for (int x = 0; x < level; x++)
                whiteSpace = [whiteSpace stringByAppendingString:@"  "];

            NSLog(@"%@%@ tag=%d frame=%@", whiteSpace, NSStringFromClass([view class]), view.tag, NSStringFromCGRect(view.frame));
            if (view.superview != nil)
                [self displaySuperview:view.superview level:level++];
        }



    + (void)displaySuperview:(UIView *)view
        {
            [self displaySuperview:view level:0];
        }



    + (UIColor *)UIColorFromRGB255:(int)red
                             green:(int)green
                              blue:(int)blue
        {
            UIColor *color = [[UIColor alloc] initWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
            return color;
        }


#pragma mark - File utilities

//      cv 3/7/2016  No longer in use
//    // If this copy of the app has a 3 on the end (iRealProperty3) then it's considered to be a testing app.
//    +(BOOL)isThisATestVersion
//    {
//        return [[[[NSBundle mainBundle] executableURL] lastPathComponent] hasSuffix:@"3"];
//    }

    +(NSString*)correctCommonNameForAppVersion
    {
        if ([RealPropertyApp isUserLoggedInTestMode])
            return @"testcommon";
        else
            return @"common";
    }


    // Considers whether this app version is iRp or iRp2 and returns the appropriate container
    // name given a container name.  So for example, if this is the test version of the app (iRp2)
    // then submitting Area01 will return TestArea01, and submitting Common will return TestCommon.
    +(NSString*)versionSpecificContainerName:(NSString*)containerName
    {
        if (containerName == nil)
            return @"";
        
        if ([containerName rangeOfString:@"common" options:NSCaseInsensitiveSearch].location!=NSNotFound)
            return [Helper correctCommonNameForAppVersion];
        
        //---------------------------------------------------------------------------------------------------------------
        
        NSString *rawAreaName;
        NSRange areaRange = [containerName rangeOfString:@"Area" options:NSCaseInsensitiveSearch];
        
        if (areaRange.location != NSNotFound)
        {
            rawAreaName = [containerName substringFromIndex:areaRange.location];
            
           // if ([self isThisATestVersion])
            if ([RealPropertyApp isUserLoggedInTestMode])
                return [@"Test" stringByAppendingString:rawAreaName];
            else
                return rawAreaName;
        }
        else
            return @"";
    }


    // The container name as it should be used in the file system.
    // This will always be Area or Common, regardless of whether the version
    // of the app is iRp or iRp2
    +(NSString*)fileSystemContainerName:(NSString*)containerName
    {
        if (containerName == nil)
            return @"";
        
        //    NSRange commonRange = [containerName rangeOfString:@"common" options:NSCaseInsensitiveSearch];
        
        if ([containerName rangeOfString:@"common" options:NSCaseInsensitiveSearch].location!=NSNotFound)
            return @"Common";
        
        //---------------------------------------------------------------------------------------------------------------
        
        NSString *rawAreaName;
        NSRange areaRange = [containerName rangeOfString:@"Area" options:NSCaseInsensitiveSearch];
        
        if (areaRange.location != NSNotFound)
        {
            rawAreaName = [containerName substringFromIndex:areaRange.location];
            return rawAreaName;
        }
        else
            return @"";
    }


    + (void)deleteFile:(NSString *)fileName
        {
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];

            NSString *finalName = [documentDirectory stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] delete:finalName];
        }



    + (NSTimeInterval)updateTimeForFile:(NSString *)fileName
        {
            NSFileManager *fileManager       = [NSFileManager defaultManager];
            NSArray       *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString      *documentDirectory = [paths objectAtIndex:0];

            NSString *finalName = [documentDirectory stringByAppendingPathComponent:fileName];

            NSDictionary *info = [fileManager attributesOfItemAtPath:finalName error:nil];
            NSDate       *date = [info objectForKey:NSFileModificationDate];

            return [date timeIntervalSinceReferenceDate];
        }


#pragma - Buttons


    + (UIButton *)createButton:(CGRect)rect
                     withTitle:(NSString *)title
                     withImage:(UIImage *)image
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = rect;
            UIImage *strechable = [image stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            [btn setBackgroundImage:strechable forState:UIControlStateNormal];
            [btn setTitle:title forState:UIControlStateNormal];

            btn.titleLabel.textColor = [UIColor whiteColor];

            return btn;
        }



    + (UIButton *)createRedButton:(CGRect)rect
                        withTitle:(NSString *)title
        {
            UIImage *image = [UIImage imageNamed:@"btnRed38.png"];
            return [Helper createButton:rect withTitle:title withImage:image];
        }



    + (UIButton *)createBlueButton:(CGRect)rect
                         withTitle:(NSString *)title
        {
            UIImage *image = [UIImage imageNamed:@"btnBlue38.png"];
            return [Helper createButton:rect withTitle:title withImage:image];
        }



    + (void)dumpControllers:(UIViewController *)ctrl
        {
            [Helper dumpControllers:ctrl space:0];
        }



    + (void)dumpControllers:(UIViewController *)ctrl
                      space:(int)space
        {
            NSString *white = @"";
            for (int i = 0; i < space; i++)
                white = [white stringByAppendingString:@" "];
            NSString *className = NSStringFromClass([ctrl class]);
            NSLog(@"%@ Controller %@: 0x%x (view=0x%08x) ", white, className, (unsigned int) ctrl, (int) ctrl.view);
            for (UIViewController *ctrler in ctrl.childViewControllers)
                [Helper dumpControllers:ctrler space:space + 2];
        }



    + (CGRect)drawTextInRect:(NSString *)label
                    fontName:(NSString *)fontName
                    fontSize:(CGFloat)fontSize
             minimumFontSize:(CGFloat)minimumFontSize
                    destRect:(CGRect)rect
                   textAlign:(int)textAlign
        {
            UIFont *tempFont = [UIFont fontWithName:fontName size:fontSize];
            CGFloat pointSize = fontSize;
            CGRect  textRect;

            while (true)
                {
                    CGSize destSize = CGSizeMake(rect.size.width, 10000.0);
                    CGSize textSize = [label sizeWithFont:tempFont constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];

                    if (textSize.height < rect.size.height || pointSize <= minimumFontSize)
                        {
                            destSize.height = rect.size.height;
                            textSize = [label sizeWithFont:tempFont constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];

                            textRect = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - textSize.height) / 2, rect.size.width, textSize.height);
                            [label drawInRect:textRect withFont:tempFont lineBreakMode:NSLineBreakByCharWrapping alignment:textAlign];

                            break;
                        }
                    else
                        {
                            pointSize -= 0.5;
                            tempFont = [UIFont fontWithName:fontName size:pointSize];
                        }
                }
            tempFont          = nil;
            return textRect;
        }



//
// Return the length of a string
    + (int)getDefaultStringLength:(NSString *)label
        {
            CGSize destSize = CGSizeMake(10000.0, 10000.0);
            CGSize textSize = [label sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
            return (int) textSize.width;
        }



//
// Find top view
    + (UIView *)topViewFrom:(UIView *)view
        {
            if (view.superview == nil)
                return view;
            else return [self topViewFrom:view.superview];
        }



//
// Find first responder
    + (UIResponder *)findFirstResponder:(UIResponder *)responder
        {

            return [Helper findFirstResponderInViews:responder];
        }



    + (UIResponder *)findFirstResponder
        {

            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

            return [Helper findFirstResponderInViews:keyWindow];
        }



    + (UIResponder *)findFirstResponderInViews:(UIResponder *)responder
        {
            if (responder.isFirstResponder)
                {
                    return responder;
                }

            UIView *view = (UIView *) responder;

            for (UIView *subView in view.subviews)
                {
                    UIResponder *nextResponder = [Helper findFirstResponderInViews:subView];
                    if (nextResponder != nil)
                        return nextResponder;
                }
            return nil;
        }



// Return the screen coordinates of the current view
    + (CGRect)convertToScreenCoordinate:(UIView *)view
        {
            return [Helper convertToScreenCoordinate:view rect:view.frame];
        }



    + (CGRect)convertToScreenCoordinate:(UIView *)view
                                   rect:(CGRect)rect
        {
            if (view.superview == nil)
                return rect;
            view = view.superview;
            rect = CGRectMake(view.frame.origin.x + rect.origin.x,
                    view.frame.origin.y + rect.origin.y,
                    rect.size.width, rect.size.height);
            return [Helper convertToScreenCoordinate:view rect:rect];
        }



    + (BOOL)findAndResignFirstResponder:(UIResponder *)responder
        {
            UIView *view = (UIView *) [Helper findFirstResponder:responder];
            if (view == nil)
                return YES;
            if ([view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UITextField class]])
                return [view resignFirstResponder];
            return YES;
        }


#pragma mark - Alert dialog box


    + (UIAlertView *)alertWithOk:(NSString *)title
                         message:(NSString *)msg
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return alert;
        }



    + (UIAlertView *)alertWithOkCancel:(NSString *)title
                               message:(NSString *)msg
                              delegate:(id <UIAlertViewDelegate>)del
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:del cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];
            return alert;
        }


#pragma mark - convert the HTML code


    + (NSString *)convertFromHTML:(NSString *)string
        {
            string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            return string;
        }


#pragma mark - Date functions


// Date functions
    + (NSTimeZone *)getLocalTimeZone
        {
            return [NSTimeZone localTimeZone];
        }



//
// Return the absolute date/time from SQL string. This method should be used only
// when dealing with the original database
//
    + (NSDate *)dateFromSqlString:(NSString *)string
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
            // we need to have an absolute time
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSDate *date = [dateFormat dateFromString:string];
            return date;
        }



//
// Return an absolute date/time from a local date. The expected string is in MM/dd/yyyy.
// the date is expressed in the local time zone
//
    + (NSDate *)dateFromString:(NSString *)string
        {

            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            //[dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormat setTimeZone:[Helper getLocalTimeZone]];
            NSDate *date = [dateFormat dateFromString:string];
            return date;
        }



//
// Reverse operation
//
    + (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
        {
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
            return [Helper stringFromDate:date];
        }



    + (NSDate *)localDate
        {
            NSDate *date = [NSDate date];
            return date;
        }



    + (NSDate *)localDate:(NSDate *)date
        {
            return date;
        }



    + (NSString *)stringFromDate:(NSDate *)date
        {
            if (date == nil)
                {
                    return @"";
                }
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            [dateFormat setTimeZone:[Helper getLocalTimeZone]];
            NSString *res = [dateFormat stringFromDate:date];
            return res;
        }



    + (NSString *)fullStringFromDate:(NSDate *)date
        {
            if (date == nil)
                {
                    return @"";
                }
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm"];
            [dateFormat setTimeZone:[Helper getLocalTimeZone]];
            // [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            NSString *res = [dateFormat stringFromDate:date];
            return res;
        }



    + (unsigned long long)documentsFolderSize
        {
            NSFileManager *manager            = [NSFileManager defaultManager];
            NSArray       *documentPaths      = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString      *documentsDirectory = [documentPaths objectAtIndex:0];
            NSArray       *documentsFileList;
            NSEnumerator  *documentsEnumerator;
            NSString      *documentFilePath;
            unsigned long long documentsFolderSize = 0;

            documentsFileList       = [manager subpathsAtPath:documentsDirectory];
            documentsEnumerator     = [documentsFileList objectEnumerator];
            while (documentFilePath = [documentsEnumerator nextObject])
                {
                    NSDictionary *documentFileAttributes = [manager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:documentFilePath] error:nil];
                    documentsFolderSize += [documentFileAttributes fileSize];
                }
            return documentsFolderSize;
        }



    + (BOOL)deleteDirectory:(NSString *)name
        {
            if ([name length] == 0)
                return NO;
            NSFileManager *manager            = [NSFileManager defaultManager];
            NSArray       *documentPaths      = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString      *documentsDirectory = [documentPaths objectAtIndex:0];

            NSString *pathToFolder = [documentsDirectory stringByAppendingPathComponent:name];
            NSError  *error;
            BOOL success = [manager removeItemAtPath:pathToFolder error:&error];
            return success;
        }



    + (NSDate *)documentModificationDate:(NSString *)fileName
        {
            NSError  *error;
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];

            NSString *filePath = [documentDirectory stringByAppendingFormat:@"/%@", fileName];


            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                    NSDate       *fileDate   = [dictionary objectForKey:NSFileModificationDate];
                    return fileDate;
                }
            return nil;
        }



//
// Some screen methods
//
    + (CGRect)getScreenBoundsForCurrentOrientation
        {
            return [Helper getScreenBoundsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        }



    + (CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)_orientation
        {
            UIScreen *screen = [UIScreen mainScreen];
            CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.

            if (UIInterfaceOrientationIsLandscape(_orientation))
                {
                    CGRect temp;
                    temp.size.width  = fullScreenRect.size.height;
                    temp.size.height = fullScreenRect.size.width;
                    fullScreenRect = temp;
                }

            return fullScreenRect;
        }



    + (BOOL)isDeviceInLandscape
        {
            return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
        }



    + (UIInterfaceOrientation)deviceOrientation
        {
            return [[UIApplication sharedApplication] statusBarOrientation];
        }



// return the expiration date of the token
    + (NSDate *)expirationDate:(NSString *)token
        {
            NSArray       *items = [token componentsSeparatedByString:@"&"];
            for (NSString *str in items)
                {
                    NSRange range = [str rangeOfString:@"ExpiresOn="];
                    if (range.length > 0)
                        {
                            NSString *time = [str substringFromIndex:range.length];
                            double dtime = [time doubleValue];

                            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dtime];
                            return [Helper localDate:date];
                        }
                }
            return nil;
        }



// Validate the date of simple token
    + (BOOL)isTokenStillValid:(NSString *)token
        {
            NSDate *date = [Helper expirationDate:token];

            if (date == nil)
                return NO;
            NSDate *now = [Helper localDate];

            NSString *result = [NSString stringWithFormat:@"now=%@ expiration=%@", now, date];

            [Crittercism leaveBreadcrumb:result];
            if ([date compare:now] == NSOrderedAscending)
                return NO;
            return YES;
        }



//
// Return an entry from the default properties file
//
    + (NSString *)getEntryFromProperties:(NSString *)name
        {
            NSString     *path      = [[NSBundle mainBundle] pathForResource:@"Properties" ofType:@"plist"];
            NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];

            return [plistData valueForKey:name];
        }



//
// Return a list of directories that starts with the current prefix
//
    + (NSArray *)findAllDirectories:(NSString *)suffix
        {
            // Create a local file manager instance
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];


            NSURL *directoryToScan = [NSURL fileURLWithPath:documentDirectory];

            NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryToScan
                                                                        includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey, nil]
                                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants
                                                                                      errorHandler:nil];
            NSMutableArray        *results       = [[NSMutableArray alloc] init];

            // Enumerate the dirEnumerator results, each value is stored in allURLs
            for (NSURL *theURL in dirEnumerator)
                {
                    // Retrieve whether a directory.
                    NSNumber *isDirectory;
                    [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

                    if ([isDirectory boolValue])
                        {
                            NSString *path = [theURL lastPathComponent];

                            NSRange range = [path rangeOfString:suffix options:NSCaseInsensitiveSearch];
                            if (range.location == 0 && range.length > 0)
                                [results addObject:path];
                        }
                }
            NSArray *sortedArray = [results sortedArrayUsingComparator:^(NSString *m1,
                                                                         NSString *m2)
                {
                    return [m1 caseInsensitiveCompare:m2];
                }];
            return sortedArray;
        }



//
// Find all the files in the top directory -- files must start with a current prefix
//
    + (NSArray *)findAllFiles:(NSString *)suffix
                    directory:(NSString *)directory
        {
            // Create a local file manager instance
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];

            if ([directory length] > 0)
                documentDirectory = [documentDirectory stringByAppendingPathComponent:directory];

            NSURL *directoryToScan = [NSURL fileURLWithPath:documentDirectory];

            NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryToScan
                                                                        includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey, nil]
                                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants
                                                                                      errorHandler:nil];
            NSMutableArray        *results       = [[NSMutableArray alloc] init];

            // Enumerate the dirEnumerator results, each value is stored in allURLs
            for (NSURL *theURL in dirEnumerator)
                {
                    NSNumber *isDirectory;
                    [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

                    if ([isDirectory boolValue])
                        continue;
                    NSString *path = [theURL lastPathComponent];

                    NSRange range = [path rangeOfString:suffix options:NSCaseInsensitiveSearch];
                    if (range.location == 0 && range.length > 0)
                        [results addObject:path];
                }
            NSArray *sortedArray = [results sortedArrayUsingComparator:^(NSString *m1,
                                                                         NSString *m2)
                {
                    return [m1 caseInsensitiveCompare:m2];
                }];
            return sortedArray;
        }



//
// Find first entry
//
    + (NSString *)findFirstValidDirectory:(NSString *)name
        {
            NSArray *array = [Helper findAllDirectories:name];
            if ([array count] == 0)
                return @"";
            else
                return [array objectAtIndex:0];
        }



    + (BOOL)checkValidDirectory:(NSString *)name
        {
            NSArray *array = [Helper findAllDirectories:name];
            if ([array count] == 0)
                return NO;
            else
                return YES;

        }



    // This only searches the /Documents directory, so if you want a deeper level, you need to append that path to the file
    // so that this method will look there, for example... @"/common/someFile.txt"
    // This method is case-insensitive on both directory name and file name, and it's smart enough to recognize and check
    // either of these and return the correct answer...
    //  @"/common/someFile.txt"
    //  @"common/someFile.txt"
    + (BOOL)checkFileExist:(NSString *)name
        {
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *fileName          = [documentDirectory stringByAppendingPathComponent:name];
            return [[NSFileManager defaultManager] fileExistsAtPath:fileName];
        }


    + (BOOL)createDirectory:(NSString *)dirName
        {
            NSArray       *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString      *documentDirectory = [paths objectAtIndex:0];
            NSString      *newDir            = [documentDirectory stringByAppendingPathComponent:dirName];
            NSFileManager *filemgr           = [NSFileManager defaultManager];

            return [filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:NULL];
        }



//
// Move a file to another location. If file exists, it is deleted
//
    + (BOOL)moveFile:(NSString *)fileName
                  to:(NSString *)destName
        {
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *destination       = [documentDirectory stringByAppendingPathComponent:destName];

            NSString      *source  = [documentDirectory stringByAppendingPathComponent:fileName];
            NSFileManager *filemgr = [NSFileManager defaultManager];

            [filemgr removeItemAtPath:destination error:nil];
            return [filemgr moveItemAtPath:source toPath:destination error:nil];
        }



// return a new autoreleased UUID string
    + (NSString *)generateGUID
        {
            // create a new UUID which you own
            CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);

            // create a new CFStringRef (toll-free bridged to NSString)
            // that you own
            NSString *uuidString = (__bridge_transfer NSString *) CFUUIDCreateString(kCFAllocatorDefault, uuid);

            // release the UUID
            CFRelease(uuid);

            return uuidString;
        }



    + (NSString *)generateUniqueFileName
        {
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];

            return [documentDirectory stringByAppendingPathComponent:[Helper generateGUID]];
        }



    + (void)addSetToArray:(NSSet *)set
                    array:(NSMutableArray *)array
        {
            NSEnumerator *enumerator = [set objectEnumerator];
            id object;

            while (object = [enumerator nextObject])
                [array addObject:object];
        }



//
// Change the trasnparency of a color
//
    + (UIColor *)adjustTransparency:(UIColor *)color
                       transparency:(CGFloat)transparency
        {
            CGFloat red, green, blue, t;

            [color getRed:&red green:&green blue:&blue alpha:&t];

            UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:transparency];
            return newColor;
        }



    + (UIImage *)imageWithImage:(UIImage *)image
                   scaledToSize:(CGSize)newSize
        {
            //UIGraphicsBeginImageContext(newSize);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (newImage == nil)
                return image;   // handle the case when not enough memory is available
            return newImage;
        }



    //
    // Runs when the application is starting up, and if necessary extracts the common files from the
    // application resource bundle and puts them in the /Directory/common folder.
    //
    // HNN 2/5/13 only install file if it doesn't exists because if the user has previously obtained the latest files from azure,
    // we don't want to overwrite the azure files with an older file that came from this codes resource bundle.
    //    if([fileManager fileExistsAtPath:destPath])
    //        return;
    //
    // DBaun 10/16/13 01:24 PM
    // Need to force install in cases where the app is a new version because the files included in the bundle, or the code that
    // works against those files may have changed in such a way that it won't work with the existing files.  And working properly,
    // this code will very quickly detect that files pulled from the bundle need to be updated from azure, which the user can then
    // do via the Options Tab Page.
    //
    + (void)extractAndPlaceCommonFileFromBundle:(NSString *)fileName
                                          force:(BOOL)forceInstall
        {
            NSString      *commonDirectory;
            NSString      *documentDirectory;
            NSString      *destPath;
            NSArray       *paths;
            NSFileManager *fileManager;
            BOOL fileAlreadyExists;


            commonDirectory   = @"common";
            fileAlreadyExists = NO;
            paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            documentDirectory = [paths objectAtIndex:0];
            destPath          = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", commonDirectory, fileName]];
            fileManager       = [NSFileManager defaultManager];
            fileAlreadyExists = [fileManager fileExistsAtPath:destPath];

            if (fileAlreadyExists && !forceInstall)
                return;

            // Here because the file does not exist OR it's a new installation (forceInstall = YES)

            [Helper createDirectory:commonDirectory];

            // the file is not copied, so let's get it
            NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];

            NSError *err = nil;
            [fileManager removeItemAtPath:destPath error:nil];
            [fileManager copyItemAtPath:srcPath toPath:destPath error:&err];

            if (err != nil)
                {
                    NSLog(@"Err desc-%@", [err localizedDescription]);
                    NSLog(@"Err reason-%@", [err localizedFailureReason]);
                }
            else
                {
                    if (!fileAlreadyExists)
                        {
                            // Update the FilesSync table record with 'bundle' since the file was installed here and now from the bundle to /common
                            // Because the file didn't previously exist, and this is not a forced install (because it's not a new version) we definitely
                            // want to download this file from azure because pulling this from the bundle at this point means it could be outdated.
                            unsigned long long theFileLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:destPath error:nil] fileSize];
                            [Helper addOrUpdateFilesSyncRecordUsingContainerName:@"common" BlobFileName:fileName ETag:@"from bundle" FileSizeInBytes:theFileLength WithContext:nil ShouldDoSave:YES UpdateType:kFilesSyncCreateOrUpdate];
                        }
                }
        }



    // ..........SAMPLE OF *filesSyncRecords after a query of testArea01..........
    //
    //  <FilesSync: 0xd864d20> (entity: FilesSync; id: 0xdc21670 <x-coredata://80D38905-0CB0-4E5D-8683-FEF2470574F7/FilesSync/p11> ; data: {
    //      area    = testArea01;
    //      eTag    = "New Record";
    //      length  = 831;
    //      name    = "Area01.LabelSets.xml";
    //      updateDate = nil;
    //  }),
    //  <FilesSync: 0xcfbe4f0> (entity: FilesSync; id: 0xdc200b0 <x-coredata://80D38905-0CB0-4E5D-8683-FEF2470574F7/FilesSync/p10> ; data: {
    //      area    = testArea01;
    //      eTag    = "New Record";
    //      length  = 24254;
    //      name    = "Area01.Renderers.xml";
    //      updateDate = nil;
    //  }),
    //  <FilesSync: 0xcfbe330> (entity: FilesSync; id: 0xdc21190 <x-coredata://80D38905-0CB0-4E5D-8683-FEF2470574F7/FilesSync/p8> ; data: {
    //      area    = testArea01;
    //      eTag    = "New Record";
    //      length  = 5174;
    //      name    = "Area01.layers.xml";
    //      updateDate = nil;
    //  }),
    //  <FilesSync: 0xcfbe840> (entity: FilesSync; id: 0xdc6dd20 <x-coredata://80D38905-0CB0-4E5D-8683-FEF2470574F7/FilesSync/p9> ; data: {
    //      area    = testArea01;
    //      eTag    = "New Record";
    //      length  = 3605;
    //      name    = "Area01.menuStructure.xml";
    //      updateDate = nil;
    //  })
    + (void)ensureFilesSyncRecordsExistForAzureBlobs:(NSArray *)azureObtainedBlobs
                                        andContainer:(NSString *)containerName
        {
            NSManagedObjectContext *personalNotesSqlite;
            NSArray                *filesSyncRecords;

            personalNotesSqlite = [AxDataManager noteContext];
            filesSyncRecords    = [AxDataManager dataListEntity:@"FilesSync" andSortBy:@"name" andPredicate:nil withContext:personalNotesSqlite];

            if ([azureObtainedBlobs count] > 0)
                {
                    for (AzureBlob *currentBlob in azureObtainedBlobs)
                        {
                            [Helper addOrUpdateFilesSyncRecordUsingContainerName:containerName BlobFileName:currentBlob.name ETag:@"New Record" FileSizeInBytes:currentBlob.length WithContext:personalNotesSqlite ShouldDoSave:NO UpdateType:kFilesSyncCreateOnly];
                        }


                    NSError *error = nil;

                    [personalNotesSqlite save:&error];

                    if (error)
                        {
                            NSLog(@"Err desc-%@", [error localizedDescription]);
                            NSLog(@"Err reason-%@", [error localizedFailureReason]);
                        }
                }
        }


    //
    // AreaName, ContainerName, and FolderName are all pretty much synonymous.
    //
    + (void)addOrUpdateFilesSyncRecordUsingContainerName:(NSString *)containerName
                                            BlobFileName:(NSString *)fileName
                                                    ETag:(NSString *)etagValue
                                         FileSizeInBytes:(int64_t)fileSize
                                             WithContext:(NSManagedObjectContext *)personalNotesSqlite
                                            ShouldDoSave:(BOOL)shouldSaveChanges
                                              UpdateType:(enum FilesSyncUpdateType)updateType
        {

            NSPredicate *databaseQueryDefinition;
            FilesSync   *filesSyncRecordForBlob;

            if (!personalNotesSqlite)
                personalNotesSqlite = [AxDataManager noteContext];


            databaseQueryDefinition = [NSPredicate predicateWithFormat:@"area LIKE[c] %@ AND name LIKE[c] %@", containerName, fileName];

            filesSyncRecordForBlob = [AxDataManager getEntityObject:@"FilesSync" andPredicate:databaseQueryDefinition andContext:personalNotesSqlite];

            if (filesSyncRecordForBlob && updateType == kFilesSyncCreateOnly)
                return; // because the file already exists and the option is create only (which means DO NOT update an existing record)

            if (filesSyncRecordForBlob == nil && updateType == kFilesSyncUpdateOnly)
                return;

            if (!filesSyncRecordForBlob)
                filesSyncRecordForBlob = [AxDataManager getNewEntityObject:@"FilesSync" andContext:personalNotesSqlite];

            filesSyncRecordForBlob.name   = fileName;
            filesSyncRecordForBlob.length = fileSize;
            filesSyncRecordForBlob.eTag   = etagValue;
            filesSyncRecordForBlob.area   = containerName;

            if (shouldSaveChanges)
                {
                    NSError *error = nil;

                    [personalNotesSqlite save:&error];

                    if (error != nil)
                        {
                            NSLog(@"Err desc-%@", [error localizedDescription]);
                            NSLog(@"Err reason-%@", [error localizedFailureReason]);
                        }
                }
        }



    // DBaun 2013-10-14...
    // When a brand new PersonalNotes.sqlite database is created, the FilesSync table has zero records in it, and this has been a problem
    // for the badge operation, so I'm going to alter this method so that if there are zero records in FilesSync for the given AxDataManager query
    // then I'm going to add default FilesSync records for those items on the spot so that the badge will work properly.
    + (NSMutableArray *)countChangedETagsForContainer:(NSString *)containerName
                                       withAzureBlobs:(NSArray *)azureObtainedBlobs
        {
            NSMutableArray         *changedBlobs;
            NSManagedObjectContext *personalNotesSqlite;
            NSPredicate            *predicate;
            NSArray                *filesSyncRecords;


            personalNotesSqlite = [AxDataManager noteContext];
            predicate           = [NSPredicate predicateWithFormat:@"area LIKE[c] %@", containerName];

            [Helper ensureFilesSyncRecordsExistForAzureBlobs:azureObtainedBlobs andContainer:containerName];

            filesSyncRecords = [AxDataManager dataListEntity:@"FilesSync" andSortBy:@"name" andPredicate:predicate withContext:personalNotesSqlite];

            changedBlobs = [Helper getChangedBlobsFromAzureBlobs:azureObtainedBlobs andFilesSyncRecords:filesSyncRecords];

            return changedBlobs;
        }



    // Compares the ETag values between the list of AzureBlob obtained from a web request and the list of FilesSync records
    // in the database, and returns a list of AzureBlob's that have a different ETag than it's corresponding FilesSync record.
    + (NSMutableArray *)getChangedBlobsFromAzureBlobs:(NSArray *)azureBlobList
                                  andFilesSyncRecords:(NSArray *)filesSyncRecords
        {

            NSMutableArray *changedBlobs = [[NSMutableArray alloc] init];


            for (AzureBlob *currentAzureBlob in azureBlobList)
                {
                    for (FilesSync *filesSyncDatabaseRecord in filesSyncRecords)
                        {
                            if ([filesSyncDatabaseRecord.name caseInsensitiveCompare:currentAzureBlob.name] == NSOrderedSame)
                                {
                                    // Check if the ETag value has changed
                                    if ([filesSyncDatabaseRecord.eTag caseInsensitiveCompare:currentAzureBlob.eTag] != NSOrderedSame)
                                        {
                                            NSLog(@"Blob has changed.  Old ETag=%@      New ETag=%@", filesSyncDatabaseRecord.eTag, currentAzureBlob.eTag);
                                            [changedBlobs addObject:currentAzureBlob];
                                        }
                                    else
                                            NSLog(@"Blob has not changed.  Old ETag=%@      New ETag=%@", filesSyncDatabaseRecord.eTag, currentAzureBlob.eTag);
                                }
                        }
                }

            return changedBlobs;
        }



    // DBaun 2013-09-29: Per recent discussion with Hoang, not going to delete records from FilesSync table, only add/update
    //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area LIKE[c] %@", r.containerRequested];
    //            NSArray *list = [AxDataManager dataListEntity:@"FilesSync" andSortBy:@"name" andPredicate:predicate withContext:personalNotesSqlite];
    //                for (NSManagedObject *object in list)
    //                   [personalNotesSqlite deleteObject:object];
    //
    // All this does is takes a list of blobs from an Azure query, and uses those to update the FilesSync records.
    //
    + (void)addOrUpdateFilesSyncRecordsForContainer:(NSString *)containerName
                                     withAzureBlobs:(NSArray *)azureObtainedBlobs
        {
            NSManagedObjectContext *personalNotesSqlite;

            personalNotesSqlite = [AxDataManager noteContext];

            for (AzureBlob *azureBlob in azureObtainedBlobs)
                {
                    [Helper addOrUpdateFilesSyncRecordUsingContainerName:containerName BlobFileName:azureBlob.name ETag:azureBlob.eTag FileSizeInBytes:azureBlob.length WithContext:personalNotesSqlite ShouldDoSave:NO UpdateType:kFilesSyncCreateOrUpdate];
                }

            NSError *error = nil;

            [personalNotesSqlite save:&error];

            if (error != nil)
                {
                    NSLog(@"Err desc-%@", [error localizedDescription]);
                    NSLog(@"Err reason-%@", [error localizedFailureReason]);
                }
        }



    + (void)deleteBlobsForContainer:(NSString *)containerName
        {
            NSManagedObjectContext *personalNotesSqlite;
            NSPredicate            *predicate;
            NSArray                *filesSyncRecords;


            if ([containerName length]==0)
                return;

            personalNotesSqlite = [AxDataManager noteContext];

            if ([containerName isEqualToString:@"common"])
                predicate = [NSPredicate predicateWithFormat:@"name IN %@", [Helper theCommonFileNames]];
            else
                {
                    NSString *wildCardContainerName = [NSString stringWithFormat:@"%@*",containerName];
                    predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@", wildCardContainerName];
                }


            filesSyncRecords = [AxDataManager dataListEntity:@"Blob" andSortBy:@"name" andPredicate:predicate withContext:personalNotesSqlite];

            if ([filesSyncRecords count] > 0)
                {
                    for (FilesSync *blobRecord in filesSyncRecords)
                        {
                            NSLog(@"Deleting blob %@ from FilesSync Blob table",blobRecord);
                            [personalNotesSqlite deleteObject:blobRecord];
                        }

                    NSError *error = nil;

                    [personalNotesSqlite save:&error];

                    if (error != nil)
                        {
                            NSLog(@"Err desc-%@", [error localizedDescription]);
                            NSLog(@"Err reason-%@", [error localizedFailureReason]);
                        }
                }
        }



    + (NSArray *)theCommonFileNames
        {
            NSArray *theNamesOfTheCommonFiles = [NSArray arrayWithObjects:@"iRealProperty2.xml", @"LUItem2.sqlite3", @"SearchDefinition2.xml", nil];
            return theNamesOfTheCommonFiles;
        }



    //
    // DBaun 2013-10-06 New method added.
    // If the file exists, then the file properties will be returned, otherwise nil
    //
    + (NSDictionary *)filePropertiesForFile:(NSString *)fileName
        {
            if (![fileName length])
                return nil;

            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *theFileName       = [documentDirectory stringByAppendingPathComponent:fileName];
            return [[NSFileManager defaultManager] attributesOfItemAtPath:theFileName error:nil];
        }


@end

