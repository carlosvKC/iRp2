#import "LUItems2.h"
#import "sqlite3.h"


@implementation LUItems2

    @synthesize LUTypeId;
    @synthesize LUItemId;
    @synthesize LUItemShortDesc;


    static NSMutableDictionary *itemCache;



//
// Return the name of the database to use for the different items (LUItems, streets, etc.)
    + (NSString *)getItemSQLName
        {
            NSArray  *paths             = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];

            NSString *fileName = [documentDirectory stringByAppendingPathComponent:@"common/LUItem2.sqlite3"];

            return fileName;
        }



    + (void)cleanUp
        {
            NSEnumerator *enumerator = [itemCache keyEnumerator];
            id key;
            while ((key = [enumerator nextObject]))
                {
                    NSMutableArray *array = [itemCache objectForKey:key];
                    [array removeAllObjects];
                }
            [itemCache removeAllObjects];
            itemCache = nil;
        }



    + (NSArray *)LUItemsFromLookup:(int)lookup
        {
            return [LUItems2 LUItemsFromLookup:lookup districtId:0];
        }



//
// Read the data from the LUItem2 if lookup is positive.
//
// if -3, read from the Park Table
    + (NSArray *)LUItemsFromLookup:(int)lookup
                        districtId:(int)districtId  //should be the one comming from db
        {
            if (itemCache == nil)
                itemCache = [[NSMutableDictionary alloc] init];

            NSNumber *number = [[NSNumber alloc] initWithInt:lookup];

            // Search for the existing area
            if (lookup > 0)
                {
                    NSArray *qresults = [itemCache objectForKey:number];
                    if (qresults != nil)
                        return qresults;
                }

            NSMutableArray *results = [[NSMutableArray alloc] init];
            //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //  NSString *documentDirectory = [paths objectAtIndex:0];

            NSString *fileName = [LUItems2 getItemSQLName]; // [documentDirectory stringByAppendingPathComponent:@"LUItem2.sqlite3"];

            sqlite3 *database;

            if (sqlite3_open([fileName UTF8String], &database) != SQLITE_OK)
                {
                    NSLog(@"Can't open the database");
                    return nil;
                }

            NSString *query;

            if (lookup > 0)
                query = [NSString stringWithFormat:@"SELECT [LUItemId] , [LUItemShortDesc] FROM LUItem2 WHERE [LUTypeId]=%d ORDER BY  LUItemId ASC", lookup];

            else if (lookup == -2)
                query = [NSString stringWithFormat:@"SELECT [ZoneId], [ZoneDesignation] FROM Zoning WHERE [DistrictId]=%d ORDER BY ZoneDesignation ASC", districtId];

            else if (lookup == -3)
                query = [NSString stringWithFormat:@"SELECT [ParkId], [ParkName] FROM ParkName ORDER BY ParkName"];

            sqlite3_stmt *statement;

            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW)
                        {
                            LUItems2 *item = [[LUItems2 alloc] init];
                            item.LUItemId            = sqlite3_column_int(statement, 0);
                            if (sqlite3_column_text(statement, 1) == nil)
                                item.LUItemShortDesc = @"";
                            else
                                item.LUItemShortDesc = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                            [results addObject:item];
                        }
                }
            sqlite3_finalize(statement);
            sqlite3_close(database);
            [itemCache setObject:results forKey:number];
            return results;
        }



    + (NSString *)LUItemFromTypeId:(int)typeId
                            itemId:(int)itemId
        {
            NSArray  *items  = [LUItems2 LUItemsFromLookup:typeId];
            NSString *result = @"";

            for (LUItems2 *item in items)
                {
                    if (item.LUItemId == itemId)
                        {
                            result = item.LUItemShortDesc;
                            break;
                        }
                }
            return result;
        }
@end
