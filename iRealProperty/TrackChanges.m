#import "TrackChanges.h"
#import "FMDatabase.h"
#import "RealPropertyApp.h"


#define MAX_OFFSET   1000000     // offset added to the top


@implementation Change

    @synthesize className, uniqueId, operation, date;

@end


@implementation TrackChanges

// Name of the class, name of the Z table and the Z column that is unique
static char *classesAndGuid[]=
                        {
							    "ResBldg",  "ZRESBLDG", "ZGUID",
							    "Chnghist", "ZCHNGHIST", "ZGUID",
							    "EnvRes",   "ZENVRES",  "ZGUID",
							    "Inspection", "ZINSPECTION", "ZGUID",
							    "Land",         "ZLAND",    "ZGUID",
							    "LandFootage",  "ZLANDFOOTAGE", "ZGUID",
							    "MediaAccy",    "ZMEDIACCY",    "ZGUID",
							    "MediaBldg",    "ZMEDIABLDG",   "ZGUID",
							    "MediaLand",    "ZMEDIALAND",   "ZGUID",
							    "MediaMobile",  "ZMEDIAMOBILE", "ZGUID",
							    "MediaNote",    "ZMEDIANOTE",   "ZGUID",
							    "MHAccount",    "ZMHACCOUNT",   "ZGUID",
							    "NoteInstance", "ZNOTEINSTANCE", "ZGUID"
                        };
    static int  lastMaxRequest[128];
    static BOOL isInitialized   = NO;



    + (int)getNewId:(id)object
        {
            // NoteHIExmpt, NoteInstance, NoteRealPropInfo, NoteReview, NoteSale;
            NSString *className = NSStringFromClass([object class]);

            if ([className caseInsensitiveCompare:@"NoteHIExmpt"] == NSOrderedSame ||
                    [className caseInsensitiveCompare:@"NoteRealPropInfo"] == NSOrderedSame ||
                    [className caseInsensitiveCompare:@"NoteReview"] == NSOrderedSame ||
                    [className caseInsensitiveCompare:@"NoteSale"] == NSOrderedSame)
                className = @"NoteInstance";

            if (!isInitialized)
                {
                    for (int i = 0; i < sizeof(lastMaxRequest) / sizeof(lastMaxRequest[0]); i++)
                        lastMaxRequest[i] = 0;
                    isInitialized = YES;
                }

            // The only issue is that there is no consistency on what is considered unique in the
            // original database. Each table has its own object...
            for (int i = 0; i < sizeof(classesAndGuid) / sizeof(classesAndGuid[0]); i += 3)
                {
                    NSString *name = [NSString stringWithCString:classesAndGuid[i] encoding:NSStringEncodingConversionAllowLossy];
                    if ([name caseInsensitiveCompare:className] == NSOrderedSame)
                        {
                            // We have the class name...
                            NSString   *tableName  = [NSString stringWithCString:classesAndGuid[i + 1] encoding:NSStringEncodingConversionAllowLossy];
                            NSString   *columnName = [NSString stringWithCString:classesAndGuid[i + 2] encoding:NSStringEncodingConversionAllowLossy];
                            // Get the highest component
                            FMDatabase *db         = [FMDatabase databaseWithPath:[TrackChanges getDatabaseName]];

                            if (![db open])
                                {
                                    NSLog(@"Couldn't open the current DB");
                                    return 0;
                                }
                            NSString    *query = [NSString stringWithFormat:@"SELECT MAX(%@) FROM %@", columnName, tableName];
                            FMResultSet *rs    = [db executeQuery:query];

                            if (![db hadError])
                                {
                                    [rs next];
                                    int res = 0;
                                    if (![rs columnIndexIsNull:0])
                                        res = [[rs objectForColumnIndex:0] intValue];
                                    [rs close];
                                    [db close];
                                    if (res < MAX_OFFSET)
                                        res = MAX_OFFSET;
                                    // Check if this value is less than the last one requested. This is to keep incrementing the values
                                    // even if the user cancel the operation
                                    res++;  // to avoid collision
                                    i = i / 3;    // to get the current index
                                    if (res <= lastMaxRequest[i])
                                        {
                                            res = lastMaxRequest[i] + 1;
                                        }
                                    lastMaxRequest[i] = res;
                                    return res;
                                }
                            else
                                {
                                    return 0;
                                }

                        }
                }
            return 0;
        }



    + (NSString *)getDatabaseName
        {
            NSArray  *paths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [paths objectAtIndex:0];

            NSString *fileName = [docsDir stringByAppendingPathComponent:[AxDataManager permanentStoreName:@"default"]];

            return fileName;
        }

@end
