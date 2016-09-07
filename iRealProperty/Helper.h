#import <Foundation/Foundation.h>


@class NSManagedObject;
@class AzureBlob;



enum FilesSyncUpdateType {
    kFilesSyncCreateOrUpdate = 0,
    kFilesSyncUpdateOnly     = 1,
    kFilesSyncCreateOnly     = 2
};


@interface Helper : NSObject {
    }

// Debug mode
    + (void)dumpViews:(UIView *)view;

    + (void)dumpControllers:(UIViewController *)ctrl;

    + (void)displaySuperview:(UIView *)view;

// Draw a text and reduce its size
    + (CGRect)drawTextInRect:(NSString *)label
                    fontName:(NSString *)fontName
                    fontSize:(CGFloat)fontSize
             minimumFontSize:(CGFloat)minimumFontSize
                    destRect:(CGRect)rect
                   textAlign:(int)textAlign;

// Return the length of a string in the current system font
    + (int)getDefaultStringLength:(NSString *)label;

// Get a color from a 0...255 scale
    + (UIColor *)UIColorFromRGB255:(int)red
                             green:(int)green
                              blue:(int)blue;

// Top view of a current view
    + (UIView *)topViewFrom:(UIView *)view;

// Create a blue button of the appropriate size...
    + (UIButton *)createBlueButton:(CGRect)rect
                         withTitle:(NSString *)title;

    + (UIButton *)createRedButton:(CGRect)rect
                        withTitle:(NSString *)title;

// Display an error message
    + (UIAlertView *)alertWithOk:(NSString *)title
                         message:(NSString *)msg;

    + (UIAlertView *)alertWithOkCancel:(NSString *)title
                               message:(NSString *)msg
                              delegate:(id <UIAlertViewDelegate>)del;

// string formatter
    + (NSString *)convertFromHTML:(NSString *)string;

// Date formatting and all date functions...
    + (NSDate *)dateFromSqlString:(NSString *)string;

    + (NSDate *)dateFromString:(NSString *)string;

    + (NSString *)stringFromDate:(NSDate *)date;

    + (NSString *)fullStringFromDate:(NSDate *)date;

    + (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;

    + (NSDate *)localDate;

// Find first responder from a view
    + (UIResponder *)findFirstResponder:(UIResponder *)responder;

    + (UIResponder *)findFirstResponder;

    + (BOOL)findAndResignFirstResponder:(UIResponder *)responder;

// Return the size of the document folder
    + (unsigned long long)documentsFolderSize;

// Return the modification date of a document
    + (NSDate *)documentModificationDate:(NSString *)fileName;

// Return the screen bounds
    + (CGRect)getScreenBoundsForCurrentOrientation;

    + (CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)_orientation;

    + (BOOL)isDeviceInLandscape;

// Token checks
    + (BOOL)isTokenStillValid:(NSString *)token;

    + (NSDate *)expirationDate:(NSString *)token;

// Create a directory
    + (BOOL)createDirectory:(NSString *)dirName;

// delete directory
    + (BOOL)deleteDirectory:(NSString *)name;

// Generate a unique file name in doc
    + (NSString *)generateUniqueFileName;

// Access data
    + (NSArray *)findAllDirectories:(NSString *)suffix;

    + (NSString *)findFirstValidDirectory:(NSString *)name;

    + (BOOL)checkValidDirectory:(NSString *)name;

    + (NSArray *)findAllFiles:(NSString *)suffix
                    directory:(NSString *)directory;

    + (BOOL)moveFile:(NSString *)fileName
                  to:(NSString *)dirName;

    + (UIInterfaceOrientation)deviceOrientation;

    + (NSString *)generateGUID;

    + (void)addSetToArray:(NSSet *)set
                    array:(NSMutableArray *)array;

    + (BOOL)checkFileExist:(NSString *)name;

// Utility to convert to screen coordinates
    + (CGRect)convertToScreenCoordinate:(UIView *)view;

    + (NSTimeInterval)updateTimeForFile:(NSString *)fileName;

// CHange transparency of color
    + (UIColor *)adjustTransparency:(UIColor *)color
                       transparency:(CGFloat)transparency;

    + (NSString *)getEntryFromProperties:(NSString *)name;

    + (UIImage *)imageWithImage:(UIImage *)image
                   scaledToSize:(CGSize)newSize;

    + (void)extractAndPlaceCommonFileFromBundle:(NSString *)fileName
                                          force:(BOOL)forceInstall;


    + (void)ensureFilesSyncRecordsExistForAzureBlobs:(NSArray *)azureObtainedBlobs
                                        andContainer:(NSString *)containerName;

    + (void)addOrUpdateFilesSyncRecordUsingContainerName:(NSString *)containerName
                                            BlobFileName:(NSString *)fileName
                                                    ETag:(NSString *)etagValue
                                         FileSizeInBytes:(int64_t)fileSize
                                             WithContext:(NSManagedObjectContext *)personalNotesSqlite
                                            ShouldDoSave:(BOOL)shouldSaveChanges
                                              UpdateType:(enum FilesSyncUpdateType)updateType;

    + (NSMutableArray *)countChangedETagsForContainer:(NSString *)containerName
                                       withAzureBlobs:(NSArray *)azureObtainedBlobs;

    + (NSMutableArray *)getChangedBlobsFromAzureBlobs:(NSArray *)azureBlobList
                                  andFilesSyncRecords:(NSArray *)filesSyncRecords;

    + (void)addOrUpdateFilesSyncRecordsForContainer:(NSString *)containerName
                                     withAzureBlobs:(NSArray *)azureObtainedBlobs;


    + (void)deleteBlobsForContainer:(NSString *)containerName;

    + (NSDictionary *)filePropertiesForFile:(NSString *)fileName;


    +(NSString*)versionSpecificContainerName:(NSString*)containerName;

    +(NSString*)fileSystemContainerName:(NSString*)containerName;

//    +(BOOL)isThisATestVersion;

@end


/*
    + (void)ensureFilesSyncRecordWithContainerName:(NSString *)areaName
                                      andAzureBlob:(AzureBlob *)azureObtainedBlob
                                           andETag:(NSString *)etagValue;
*/

/*
    + (void)addOrUpdateFilesSyncRecordWithContainerName:(NSString *)containerName
                                           BlobFileName:(NSString *)fileName
                                                   ETag:(NSString *)etagValue
                                        FileSizeInBytes:(int64_t)fileSize
                                            WithContext:(NSManagedObjectContext *)personalNotesSqlite
                                           ShouldDoSave:(BOOL)shouldSaveChanges;
*/
