#import "ReadPictures.h"
#import "RealPropertyApp.h"
#import "Helper.h"
#import "FMDatabase.h"
#import "MediaView.h"

#define OPEN_FLAG   SQLITE_OPEN_NOMUTEX


@implementation DirectoryEntry

    static ReadPictures *singlePictures   = nil;
    static NSLock       *readPicturesLock = nil;

    @synthesize name, fileCount, offset, length;



    - (NSString *)description
        {
            return [NSString stringWithFormat:@"'%@' fileCount=%d offset=%lld length=%lld", self.name, fileCount, offset, length];
        }
@end


@implementation ReadPictures

    @synthesize dataBasePath;


//    enum {
//        mtImages = 1,
//        mtMini = 2,
//        mtcadXml = 3,
//        mtVideo =4
//        } _mediaType;

    //cv Who uses  --> OfflineTileLayer
    //          -->OfflineTileOperation   zipFileName  ==> Area01.tiles
    + (ReadPictures *)getConnection:(NSString *)path
        {
            if (singlePictures == nil)
                singlePictures = [[ReadPictures alloc] initWithFile:path];

            return singlePictures;
        }



    - (id)initWithDataBase:(NSString *)path
        {
            self = [super init];
            if (self)
                {
                    dataBasePath     = path;
                    useFileStructure = NO;
                }
            return self;
        }


    //Who uses  --> self getConnection  , GetCDIFile
    - (id)initWithFile:(NSString *)fileName
        {
            self = [super init];
            if (self)
                {
                    dataBasePath = fileName;
                    _fileHandle  = [NSFileHandle fileHandleForReadingAtPath:dataBasePath];
                    if (_fileHandle == nil)
                        {
                            NSLog(@"Can't open the file %@", fileName);
                        }
                    useFileStructure = YES;
                }
            return self;
        }

-(UIImage *)findImageWithMediaType:(NSString *)imageName
                         mediaType:(int)mediaType;

{
    //imageName =@"4412Bldg.jpg";
    //imageName =@"291CD048-1E64-46CA-9ADA-58A3AB8A7129"
    NSData *data = [self getFileDataWithMediaType:imageName mediaType:mediaType];
    
    if (data == nil)
        return nil;
    
    NSLog(@"The image '%@' size is '%u' bytes", imageName, [data length])
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

-(UIImage *)findFirstImageWithMediaType:(int)mediaType;

{
    //imageName =@"4412Bldg.jpg";
    //imageName =@"291CD048-1E64-46CA-9ADA-58A3AB8A7129"
    
    NSData *data = [self getFirstFileDataWithMediaTypeFromDatabase:mediaType];
    
    if (data == nil)
        return nil;
    
    NSLog(@"The image size is '%u' bytes", [data length])
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

    //
    // Assume that the name of the image is Guid
    //
-(UIImage *)findImage:(NSString *)imageName;

{
            //imageName =@"4412Bldg.jpg";
            //imageName =@"291CD048-1E64-46CA-9ADA-58A3AB8A7129"
            NSData *data = [self getFileData:imageName];

            if (data == nil)
                return nil;

            NSLog(@"The image '%@' size is '%u' bytes", imageName, [data length])
            UIImage *image = [UIImage imageWithData:data];

            return image;
        }


-(NSData *)getFileDataWithMediaType:(NSString *)aFileName
                         mediaType:(int)mediaType;

{
    {
        NSData *imageBlob = nil;
        
        //   NSString *fileName = [aFileName stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
        // If [ReadPictures initWithDatabase] was called, then useFileStructure will be NO
        //NSString *extension = @"";
        
        if (useFileStructure)
        {
            return [self getFileDataFromFile:aFileName];
        }
        else
        {
            //3/15/15 cv Extension comes from Images db
            //extension = [self getExtensionWithGuid:aFileName];
            return [self getFileDataWithMediaTypeFromDatabase:aFileName mediaType:mediaType];
            //return [self getFileDataFromFile:aFileName];
            
        }
        
        // ??? Why create a database every time this method is entered?  Time consuming?
        // cv process just take fraction of a second...maybe getFileDataFromArray ehh sqlLite does not handle type of statement(x research)
        // 4/25/16 HNN commented code below because it would never get to here
//        FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
//        if (![db openWithFlags:OPEN_FLAG])
//        {
//            NSLog(@"Could not open db.");
//            return 0;
//        }
//        
//        NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE guid = '%@' AND mediaType= %d ", aFileName, mediaType];
//        FMResultSet *rs    = [db executeQuery:query];
//        if ([rs next])
//        {
//            imageBlob = [rs dataForColumn:@"Image"];
//        }
//        [rs close];
//        [db close];
        
    }
   
}


        // who uses -->TabPictureController  ok
        //          --> OfflineTileLayer -->getCDIFile -->@"Layers\\conf.cdi
        //                                             -->@"Layers\\conf.xml"  ok
    - (NSData *)getFileData:(NSString *)aFileName
        {
            NSData *imageBlob = nil;

            //   NSString *fileName = [aFileName stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
            // If [ReadPictures initWithDatabase] was called, then useFileStructure will be NO
            //NSString *extension = @"";
            
            if (useFileStructure)
                {
                    return [self getFileDataFromFile:aFileName];
                }

            return imageBlob;
// 4/25/16 HNN cleanup unused code
//            else
//                {
//                    //3/15/15 cv Extension comes from Images db
//                    //extension = [self getExtensionWithGuid:aFileName];
//                    return [self getFileDataFromDatabase:aFileName];
//                    //return [self getFileDataFromFile:aFileName];
//
//                }
            
            // ??? Why create a database every time this method is entered?  Time consuming?
            // cv process just take fraction of a second...maybe getFileDataFromArray ehh sqlLite does not handle type of statement(x research)
//             FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
//             if (![db openWithFlags:OPEN_FLAG])
//                {
//                    NSLog(@"Could not open db.");
//                    return 0;
//                }
//
//             NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE guid = '%@'", aFileName];
//             FMResultSet *rs    = [db executeQuery:query];
//             if ([rs next])
//              {
//               imageBlob = [rs dataForColumn:@"Image"];
//             }
//             [rs close];
//            [db close];

            // 8/1/13 HNN kludge sql2lite inserts drawings with a lower case extension (.cadxml) in realproperty.sqlite file but
            // inserts it with an upper case extension (.CADXML) in the production.sqlite file. I'm going to fix Sql2Lite to insert the lower file extension
            // but I need to keep backward compatibility so the appraisers don't have to reload their files.
            //if (imageBlob == nil)
            //    {
            // query = [NSString stringWithFormat:@"SELECT * FROM images WHERE path = '%@'", [fileName stringByReplacingOccurrencesOfString:@".cadxml"               withString:@".CADXML"]];
            //rs    = [db executeQuery:query];
            //          if ([rs next])
            //                  {
            //                  imageBlob = [rs dataForColumn:@"Image"];
            //              }
            //         [rs close];
            // return imageBlob;
        }

    // 3/1/15 cv change to xmlName
// 5/3/16 HNN not needed; just call getFileDataWithMediaTypeFromDatabase for kMediaFplan
//    - (NSData *)getXmlFileData:(NSString *)xmlName;
//        {
//        NSData     *imageBlob = nil;
//        if (useFileStructure)
//            //return [self getFileDataFromFile:xmlName];
//            return [self getCadDataFromDatabase:xmlName];
//            FMDatabase *db        = [FMDatabase databaseWithPath:dataBasePath];
//            if (![db openWithFlags:OPEN_FLAG])
//                {
//                    NSLog(@"Could not open db.");
//                    return 0;
//                }
//                //NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE guid = '%@' AND mediaType = 3", xmlName];
//                NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE guid = '%@' AND mediaType = %d LIMIT 1", xmlName, kMediaFplan];
//                //NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE guid = '%@' AND ext = 'PNG' LIMIT 1", xmlName];
//          
//            
//                FMResultSet *rs    = [db executeQuery:query];
//                if ([rs next])
//                    {
//                        imageBlob = [rs dataForColumn:@"Image"];
//                    }
//                [rs close];
//                [db close];
//                return imageBlob;
//        }


    //
    // Delete a file
    //
    //- (void)deleteFile:(NSString *)fileName
//    - (void)deleteFile:(NSString *)guid ext:(NSString *)ext;
//
//        {
//            FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
//            if (![db open])
//                {
//                    NSLog(@"Could not open db.");
//                    return;
//                }
//            if ([ext length] > 0)
//
//            //NSString *query = [NSString stringWithFormat:@"DELETE FROM images WHERE Path LIKE '%@'", fileName];
//            // 8/1/13 HNN kludge sql2lite inserts drawings with a lower case extension (.cadxml) in realproperty.sqlite file but
//            // inserts it with an upper case extension (.CADXML) in the production.sqlite file. I'm going to fix Sql2Lite to insert the lower file extension
//            // but I need to keep backward compatibility so the appraisers don't have to reload their files.
//            {
//                if ([ext rangeOfString:@".cadxml"].location != NSNotFound)
//                {
//                    NSString *query = [NSString stringWithFormat:@"DELETE FROM images WHERE Guid LIKE '%@' AND EXT ='%@' ", guid,[ext stringByReplacingOccurrencesOfString:@".cadxml" withString:@".CADXML"] ];
//                    [db executeUpdate:query];
//                }
//                else
//                {
//                    NSString *query = [NSString stringWithFormat:@"DELETE FROM images WHERE Guid LIKE '%@' AND EXT ='%@' ", guid,ext ];
//                    [db executeUpdate:query];
//                }
//            }
//            else
//            {
//                NSString *query = [NSString stringWithFormat:@"DELETE FROM images WHERE Guid LIKE '%@'", guid];
//                [db executeUpdate:query];
//
//            }
//            
//            [db close];
//
//        }



    - (void)deleteFileWithGUID:(NSString *)guid 
                           //src:(int)src
        {
            FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
            if (![db open])
                {
                    NSLog(@"Could not open db.");
                    return;
                }
            NSString *query = [NSString stringWithFormat:@"DELETE FROM images WHERE GUID = '%@' " ,guid];
            [db executeUpdate:query];
            [db close];

        }

    - (NSString *)getExtensionWithGuid:(NSString *)guidName;
        {
            NSString *returnExt =@"";
            if (dataBasePath == nil)
                return nil;
                FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
                if (![db openWithFlags:OPEN_FLAG])
                    {
                        NSLog(@"Could not open db.");
                        return 0;
                    }
                NSString    *query = [NSString stringWithFormat:@"SELECT ext FROM images WHERE Guid = '%@' AND mediaType=1 limit 1", guidName];
                FMResultSet *rs    = [db executeQuery:query];
                if ([rs next])
                    {
                        returnExt = [rs stringForColumn:@"Ext"];
                    }
                [rs close];
    
                [db close];
            return returnExt;
        }


    //
    // Gets the file from the database
    //
// 5/3/16 HNN not needed; just call getFileDataWithMediaTypeFromDatabase with kMediaFplan
//    - (NSData *)getCadDataFromDatabase:(NSString *)guid
//
//        {
//            NSData *imageBlob = nil;
//            // Change path to access data
//            //fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
//            if (dataBasePath == nil)
//                return nil;
//            FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
//            if (![db openWithFlags:OPEN_FLAG])
//                {
//                    NSLog(@"Could not open db.");
//                    return 0;
//                }
//            //NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE PATH = '%@'", fileName];
//            NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE Guid = '%@' AND MediaType = %d limit 1", guid,kMediaFplan];
//            FMResultSet *rs    = [db executeQuery:query];
//            if ([rs next])
//                {
//                    imageBlob = [rs dataForColumn:@"Image"];
//                    //if (guid)
//                    //    guid = [rs stringForColumn:@"Guid"];
//                    //if (ext)
//                      //  ext = [rs stringForColumn:@"Ext"];
//
//                }
//            [rs close];
//
//
//            [db close];
//            return imageBlob;
//                }

// 4/25/16 HNN cleanup code
//- (NSData *)getFileDataFromDatabase:(NSString *)guid;
//{
//    NSData *imageBlob = nil;
//    if (dataBasePath == nil)
//        return nil;
//    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
//    if (![db openWithFlags:OPEN_FLAG])
//    {
//        NSLog(@"Could not open db.");
//        return 0;
//    }
//    NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE Guid = '%@' limit 1", guid];
//    FMResultSet *rs    = [db executeQuery:query];
//    if ([rs next])
//    {
//        imageBlob = [rs dataForColumn:@"Image"];
//    }
//    [rs close];
//    [db close];
//    return imageBlob;
//
//}

- (NSData *)getFileDataWithMediaTypeFromDatabase:(NSString *)guid
                                       mediaType:(int)mediaType;

{
    NSData *imageBlob = nil;
    if (dataBasePath == nil)
        return nil;
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    if (![db openWithFlags:OPEN_FLAG])
    {
        NSLog(@"Could not open db.");
        return 0;
    }
    NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE Guid = '%@' AND mediaType= %d limit 1", guid,mediaType];
    FMResultSet *rs    = [db executeQuery:query];
    if ([rs next])
    {
        imageBlob = [rs dataForColumn:@"Image"];
    }
    [rs close];
    [db close];
    return imageBlob;
    
}

// 4/25/16 HNN used only in xcode to test camera
- (NSData *)getFirstFileDataWithMediaTypeFromDatabase:(int)mediaType;

{
    NSData *imageBlob = nil;
    if (dataBasePath == nil)
        return nil;
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    if (![db openWithFlags:OPEN_FLAG])
    {
        NSLog(@"Could not open db.");
        return 0;
    }
    NSString    *query = [NSString stringWithFormat:@"SELECT * FROM images WHERE mediaType= %d limit 1", mediaType];
    FMResultSet *rs    = [db executeQuery:query];
    if ([rs next])
    {
        imageBlob = [rs dataForColumn:@"Image"];
    }
    [rs close];
    [db close];
    return imageBlob;
    
}
    - (NSString *)saveNewData:(NSData *)data
                         guid:(NSString *)guid
                     mediaType:(NSInteger)mediaType
                          ext:(NSString *)ext
        {
            FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
            if (![db open])
                {
                    NSLog(@"Could not open db.");
                    return @"";
                }
             //3/1/15 cv validate mediatype
            if (mediaType <1)
                mediaType=kMediaPict;
            //NSNumber *srcNum = [NSNumber numberWithInt:src];
            NSNumber *numMediaType = [NSNumber numberWithInteger:mediaType];
            
            NSString *query  = @"insert into Images (Guid, MediaType, Image, Ext) values (?,?,?,?)";


    		//    bool result = [db executeUpdate:query, path, guid, 0, data, srcNum];
            
            // 5/21/15 HNN extension passed in needs to be correct
//            switch (mediaType) {
//                case mtImages:
//                    if ([ext length]==0)
//                        ext=@"JPG";
//                        break;
//                case mtcadXml:
//                    ///if ([ext length]==0)
//                        ext=@"CADXML";
//                        break;
//                default:
//                    break;
//            }

    		//bool result = [db executeUpdate:query, guid,mediaType,data, ext];
            bool result = [db executeUpdate:query, guid,numMediaType,data, ext];
    		if (!result)
        		NSLog(@"Fail to insert file '%@'", guid);
        		[db close];
        		db = nil;
    			return guid;
        }

- (void)saveNewImage:(UIImage *)image 
                 withMedia:(id)media
{
    MediaAccy *anyMedia = media;    //Yes we can use any media
    
#define MAX_IMAGE   1024
    // If a DB is available, save it directly into the DB for later sync
    // Adjust the picture size
    UIImage *_image;
    if (image.size.width > MAX_IMAGE || image.size.height > MAX_IMAGE)
    {
        CGFloat scale = 1.0;
        if (image.size.width > image.size.height)
        {
            if (image.size.width > MAX_IMAGE)
                scale = MAX_IMAGE / image.size.width;
        }
        else if (_image.size.height > MAX_IMAGE)
            scale = MAX_IMAGE / image.size.height;
        CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
        
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        _image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
        _image = image;
    //what do you need the filename for
    //NSString   *fileName = [NSString stringWithFormat:@"%@.jpg", mediaAccy.guid];
        
    //and ext
    NSString *ext =@"JPG";  //since only images are add it through device PNG the answer
    
    FMDatabase *db       = [FMDatabase databaseWithPath:dataBasePath];
    if (![db open])
    {
        NSLog(@"Could not open db.");
    }
    
    NSNumber *numMediaType = [NSNumber numberWithInteger:anyMedia.mediaType];
    NSData   *jpegData = UIImageJPEGRepresentation(_image, 9.0 / 12.0);
    NSString *query  = @"insert into Images (Guid, MediaType, Image, Ext) values (?,?,?,?)";

    bool result = [db executeUpdate:query, anyMedia.guid, numMediaType, jpegData, ext ];
    if (!result)
        NSLog(@"Fail to insert image '%@'", anyMedia.guid);
    [db close];
}

// 5/21/15 HNN undo Carlos' changes on saving images; go back to original logic
//    - (void )saveNewImg:(UIImage *)image
//                   guid:(NSString *)guid
//              mediaType:(NSInteger)mediaType ext:(NSString *)ext;
//        {
//            //MediaAccy *mediaAccy = media;    //Yes we can use any media
//            
//#define MAX_IMAGE   1024
//            // If a DB is available, save it directly into the DB for later sync
//            // Adjust the picture size
//            UIImage *_image;
//            if (image.size.width > MAX_IMAGE || image.size.height > MAX_IMAGE)
//            {
//                CGFloat scale = 1.0;
//                if (image.size.width > image.size.height)
//                {
//                    if (image.size.width > MAX_IMAGE)
//                        scale = MAX_IMAGE / image.size.width;
//                }
//                else if (_image.size.height > MAX_IMAGE)
//                    scale = MAX_IMAGE / image.size.height;
//                CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
//                
//                UIGraphicsBeginImageContext(size);
//                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//                _image = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//            }
//            else
//                _image = image;
//            
//            
//            
//            FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
//            if (![db open])
//            {
//                NSLog(@"Could not open db.");
//            }
//            //3/1/15 cv validate/enforce mediatype
//            if (mediaType <1)
//                mediaType=mtImages;
//    
//            NSNumber *numMediaType = [NSNumber numberWithInteger:mediaType];
//            NSData   *jpegData = UIImageJPEGRepresentation(_image, 9.0 / 12.0);
//
//            NSString *query  = @"insert into Images (Guid, MediaType, Image, Ext) values (?,?,?,?)";
//
//            switch (mediaType)
//            {
//                case mtImages:
//                    if ([ext length]==0)
//                        ext=@"JPG";
//                        break;
//                case mtcadXml:
//                    ext=@"CADXML";
//                    break;
//                default:
//                    break;
//            }
//
//            bool result = [db executeUpdate:query, guid,numMediaType,jpegData, ext];
//            if (!result)
//                NSLog(@"Fail to insert file '%@'", guid);
//                [db close];
//                db = nil;   
//        }


    //
    // Assume that the name of the image is production/dir0/dir1/filename
    // Not true any longer
    // getFileDataFromFile==>sample of file=> Layers\_alllayers\L00\R00000004\C00000005.jpg
    - (NSData *)getFileDataFromFile:(NSString *)fileName
        {
            if (readPicturesLock == nil)
                readPicturesLock = [[NSLock alloc] init];

            [readPicturesLock lock];

            DirectoryEntry *entry = nil, *subEntry = nil;
            @try
                {
                    [_fileHandle seekToFileOffset:0];
                    NSData *data = [_fileHandle readDataOfLength:sizeof(int64_t)];
                    [data getBytes:&directoryBegin length:sizeof(int64_t)];

                    // Split the file in different segments
                    NSArray *segments = [fileName componentsSeparatedByString:@"\\"];

                    entry = [self readDirectoryEntry:0];


                    for (int index = 1; index < segments.count; index++)
                        {
                            BOOL     found = NO;
                            for (int i     = 0; i < entry.fileCount; i++)
                                {
                                    subEntry = [self readDirectoryEntry:entry.offset + i * 52];
                                    if ([subEntry.name caseInsensitiveCompare:[segments objectAtIndex:index]] == NSOrderedSame)
                                        {
                                            found = YES;
                                            entry = subEntry;
                                            break;
                                        }
                                }
                            if (!found)
                                {
                                    entry = nil;
                                    break;
                                }
                        }
                    if (entry == nil)
                        {
                            [readPicturesLock unlock];

                            return nil;
                        }
                    else
                        {
                            [_fileHandle seekToFileOffset:entry.offset];
                            NSData *data = [_fileHandle readDataOfLength:entry.length];
                            [readPicturesLock unlock];

                            return data;
                        }
                }
            @catch (NSException *exception)
                {
                    NSLog(@"*** '%@' seek=%lld length=%lld exception=%@", fileName, entry.offset, entry.length, exception);
                }
            [readPicturesLock unlock];

            return nil;
        }



    //
    // Load a directory entry
    //
    - (DirectoryEntry *)readDirectoryEntry:(int64_t)position
        {
            DirectoryEntry *entry = [[DirectoryEntry alloc] init];

            [_fileHandle seekToFileOffset:position + directoryBegin];
            // Read the file name
            char buffer[64];
            NSData *data = [_fileHandle readDataOfLength:52];
            [data getBytes:buffer length:32];
            buffer[32] = 0;
            for (int i = 0; i < 32; i++)
                {
                    if (buffer[i] == ' ')
                        {
                            buffer[i] = 0;
                            break;
                        }
                }
            int      fileCount;
            [data getBytes:&fileCount range:NSMakeRange(32, 4)];
            int64_t offset, length;
            [data getBytes:&offset range:NSMakeRange(36, 8)];
            [data getBytes:&length range:NSMakeRange(44, 8)];

            // NSLog(@"offset=%lld length=%lld", offset, length);

            entry.name      = [NSString stringWithUTF8String:buffer];
            entry.length    = length;
            entry.offset    = offset;
            entry.fileCount = fileCount;

            return entry;
        }



@end
