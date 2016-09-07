#import "StreetDataModel.h"
#import "LUItems2.h"

@implementation StreetModel

@synthesize sortId;
@synthesize streetId;
@synthesize streetName;
@synthesize streetType;
@synthesize dirPrefix;
@synthesize dirSuffix;

@end

@implementation StreetDataModel

//
// Return a table of streets or prefeix or suffix
//
+(NSMutableArray *)loadTable: (NSString *)table filter : (NSString *)filter
{
    sqlite3 *database;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
    if(sqlite3_open([[LUItems2 getItemSQLName]  UTF8String], &database)!=SQLITE_OK)
    {
        NSLog(@"Can't open the database");
        return nil;
    }
    
    NSString *query;
    
    if(filter==nil)
        query = [NSString stringWithFormat:@"SELECT * FROM %@",table];
    else
        query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ like '%@%%'",table,table,filter];
    
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        
        while(sqlite3_step(statement)==SQLITE_ROW)
        {
            NSString *result;
            if(sqlite3_column_text(statement,0)==nil)
                result = @"";
            else
                result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            [dataArray addObject:result];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    return dataArray;
}
//
// Return an array with only the streetType, DirPrefix and DirSuffix
//
+(void)getStreetDetails:(NSString *)streetName type:(NSMutableArray *)filterType prefix:(NSMutableArray *)filterPrefix suffix:(NSMutableArray *)filerSuffix
{
    sqlite3 *database;
    
    // Remove everything from the arrays
    [filterType removeAllObjects];
    [filterPrefix removeAllObjects];
    [filerSuffix removeAllObjects];
    
    
    if(sqlite3_open([[LUItems2 getItemSQLName]  UTF8String], &database)!=SQLITE_OK)
    {
        NSLog(@"Can't open the database");
        return;
    }
    NSString *query = [NSString stringWithFormat:@"SELECT StreetType, DirPrefix, DirSuffix FROM Street WHERE StreetName='%@'",streetName]; 
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        
        while(sqlite3_step(statement)==SQLITE_ROW)
        {
            NSString *streetType, *dirPrefix, *dirSuffix;

            streetType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            dirPrefix = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            dirSuffix = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            
            if(![filterType containsObject:streetType])
                [filterType addObject:streetType];
            if(![filterPrefix containsObject:dirPrefix])
                [filterPrefix addObject:dirPrefix];
            if(![filerSuffix containsObject:streetType])
                [filerSuffix addObject:dirSuffix];

        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}
//
// Return a full detailed with postfix and suffix
//
+(int)getStreetIdWithStreetName:(NSString *)streetName prefix:(NSString *)prefix streetType:(NSString *)streetType postfix:(NSString *)postfix
{
    sqlite3 *database;
     
    if(sqlite3_open([[LUItems2 getItemSQLName]  UTF8String], &database)!=SQLITE_OK)
    {
        NSLog(@"Can't open the database");
        return -1;
    }
    
    // 3/7/13 HNN need to trim street fields and search input in order to find matching records because it looks like
    // the street table sometimes contain padding
    NSString *query = [NSString stringWithFormat:@"SELECT StreetId FROM Street WHERE ltrim(rtrim(StreetType))='%@' AND ltrim(rtrim(DirPrefix))='%@' AND ltrim(rtrim(DirSuffix))='%@' AND ltrim(rtrim(StreetName))='%@'",
                       [streetType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ,[prefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],[postfix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],[streetName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]; 
    
    sqlite3_stmt *statement;
    int count= -1;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        
        while(sqlite3_step(statement)==SQLITE_ROW)
        {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);

    return count;
}
//
// Return a street name based on a streetId
//
+(NSString *)getStreetNameFromStreetId:(int)streetId
{
    sqlite3 *database;
    
    if(sqlite3_open([[LUItems2 getItemSQLName]  UTF8String], &database)!=SQLITE_OK)
    {
        NSLog(@"Can't open the database");
        return nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT StreetName, StreetType, DirSuffix, DirPrefix FROM Street WHERE StreetId=%d", streetId];
    
    sqlite3_stmt *statement;
    NSString *result = nil;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
    {
        
        if(sqlite3_step(statement)==SQLITE_ROW)
        {
            NSString *streetName = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *streetType = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];  
            NSString *dirSuffix = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
            NSString *dirPrefix = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
            
            result = [NSString stringWithFormat:@"%@ %@ %@ %@", dirPrefix, streetName, streetType, dirSuffix];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    return result;
}

@end
