#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDatabase.h"
@interface ReadPictures : NSObject
{
    NSFileHandle *_fileHandle;
    int64_t     directoryBegin;
    BOOL        useFileStructure;
}


// Get an image based on the full name
-(UIImage *)findImage:(NSString *)imageName;
-(UIImage *)findImageWithMediaType:(NSString *)imageName
                         mediaType:(int)mediaType;
// 4/25/16 used only for xcode testing camera
-(UIImage *)findFirstImageWithMediaType:(int)mediaType;


// Get any file
-(NSData *)getFileData:(NSString *)afileName;
-(NSData *)getFileDataWithMediaType:(NSString *)afileName
                         mediaType:(int)mediaType;


// 5/3/16 HNN not needed; just call getFileDataWithMediaTypeFromDatabase for kMediaFplan
//-(NSData *)getXmlFileData:(NSString *)xmlName;
- (NSString *)getExtensionWithGuid:(NSString *)guidName;
// 5/3/16 HNN not needed; just call getFileDataWithMediaTypeFromDatabase for kMediaFplan
//- (NSData *)getCadDataFromDatabase:(NSString *)guid;
// 4/25/16 HNN cleanup code
//- (NSData *)getFileDataFromDatabase:(NSString *)guid;
- (NSData *)getFileDataWithMediaTypeFromDatabase:(NSString *)guid
                        mediaType:(int)mediaType;
// 4/25/16 HNN used only for testing xcode for camera functionality
- (NSData *)getFirstFileDataWithMediaTypeFromDatabase:(int)mediaType;


//-(NSData *)getFileDataFromDatabase:(NSString *)fileName guid:(NSString **)guid path:(NSString **)path;

//-(NSData *)getFileDataFromDbGuidAndExt:(NSString *)fileGuid fileExtension:(NSString **)fileExtension;

//-(NSData *)getFileDataFromDBGuidAndType:(NSString *)guid mediaType:(NSInteger)mediaType;

// Load a data file from a file structure
-(NSData *)getFileDataFromFile:(NSString *)fileName;




// Open the database
-(id)initWithDataBase:(NSString *)dataBasePath;
-(id)initWithFile:(NSString *)fileName;
// Add a new picture
-(void)saveNewImage:(UIImage *)image withMedia:(id)media;
// Save new data file
//- (NSString *)saveNewData:(NSData *)data path:(NSString *)path guid:(NSString *)guid src:(int)src;
- (NSString *)saveNewData:(NSData *)data guid:(NSString *)guid mediaType:(NSInteger)mediaType ext:(NSString *)ext;
// 5/21/15 HNN undo Carlos' changes on saving images
//- (void )saveNewImg:(UIImage *)image guid:(NSString *)guid mediaType:(NSInteger)mediaType ext:(NSString *)ext;

// Delete an entry
//-(void)deleteFile:(NSString *)fileName;
//- (void)deleteFile:(NSString *)guid ext:(NSString *)ext;

- (void)deleteFileWithGUID:(NSString *)guid; //mediaType:(int)mediaType; //src:(int)src;

@property(nonatomic, strong) NSString *dataBasePath;
+(ReadPictures *)getConnection:(NSString *)path;
//-(void)updatePath:(NSString *)oldPath to:(NSString *)newPath;
@end
////////////////////
@interface DirectoryEntry : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic) int fileCount;
@property(nonatomic) int64_t offset;
@property(nonatomic) int64_t length;

@end