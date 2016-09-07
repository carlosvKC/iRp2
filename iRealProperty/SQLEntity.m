#import "SQLEntity.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import <sqlite3.h>


@implementation SQLEntity
@synthesize valueString;
@synthesize valueInt;
@synthesize valueFloat;
@synthesize sqlValue;
@synthesize sqlName;
@synthesize valueDate;
static char *createIndex[] = 
{
    "CREATE INDEX idx_Accounts ON Accounts (_RealPropId);",
    "CREATE INDEX idx_RealPropInfo ON RealPropInfo (_RealPropId);",
    "CREATE UNIQUE INDEX idx_xland ON XLand (_landId);",
    "CREATE UNIQUE INDEX idx_land ON Land (_landId);",
    "CREATE UNIQUE INDEX idx_header ON Header (_RealPropId);",
    "CREATE UNIQUE INDEX idx_building ON ResBldg (_RealPropId, _BldgId);",
    "CREATE  INDEX idx_accy ON Accy (_LandId);",
    "CREATE  INDEX idx_note ON Note (_RealPropId);",
    "CREATE  INDEX idx_noteInstance ON NoteInstance (_NoteId);",
    "CREATE  INDEX idx_mediaNote ON MediaNote (_InstanceId);",
    "CREATE  INDEX idx_mobile ON Mobile (_RealPropId);",
    "CREATE  INDEX idx_mediaACyy ON MediaAccy (_RealPropId);",
    "CREATE  INDEX idx_mediaBuilding ON MediaBldg (_RealPropId);",
    "CREATE  INDEX idx_mediaLand ON MediaLand (_RealPropId);",
    "CREATE  INDEX idx_sale ON Sale (_RealPropId);",
    "CREATE  INDEX idx_saleParcels ON SaleParcel (_SaleId);",
    "CREATE  INDEX idx_saleWarning ON SaleWarning (_SaleId);",
    "CREATE  INDEX idx_review ON Review (_RealPropId);",
    "CREATE  INDEX idx_reviewJrnl ON ReviewJrnl (_AssmtReviewId);",
    "CREATE  INDEX idx_valHist ON ValHist (_RealPropId);",
    "CREATE  INDEX idx_chngHist ON ChngHist (_RealPropId);",
    "CREATE  INDEX idx_chngHistDtl ON ChngHistDtl (_EventId, _RealPropId);",
    "CREATE  INDEX idx_hiexmpt ON HIExmpt (_RealPropId);",
    "CREATE  INDEX idx_undividedInt ON UndInt (_RealPropId);",
    "CREATE  INDEX idx_taxRoll ON TaxRoll (_RealPropId);",
    "CREATE  INDEX idx_valEst ON ValEst (_RealPropId);",
    "CREATE  INDEX idx_applHist ON ApplHist (_RealPropId);",
    "CREATE  INDEX idx_currentZoning ON CurrentZoning ( _LandId);",
    "CREATE  INDEX idx_envRes ON ENVRES ( _LandId);",
    "CREATE  INDEX idx_permitDtl ON PermitDtl ( _RealPropId);",
    "CREATE  INDEX idx_permit ON Permit ( _RealPropId);",
    "CREATE  INDEX idx_medMobile ON MediaMobile (_RealPropId);",
    "CREATE  INDEX idx_accParcel ON MobileAccount (_RealPropId,_MobileHomeId);",
    "CREATE  INDEX idx_locParcel ON MobileLocAddr (_RealPropId,_MobileHomeId);",
    "CREATE  INDEX idx_addParcel ON MobileChar (_MobileHomeId);"
};

//
// This method is called for new databases to make sure that it has indexes
+(void)prepareIndexes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *sqlFile = [[RealPropertyApp getWorkingPath]stringByAppendingString:@".original.sqlite"];
    
    NSString *fileName = [docsDir stringByAppendingPathComponent:sqlFile];
    const char *dbpath = [fileName UTF8String];
    
    sqlite3 *database = nil;
    
    if(sqlite3_open(dbpath, &database)!=SQLITE_OK)
    {
        NSLog(@"Can't open the database");
        return;
    }
    
    for(int i=0;i<sizeof(createIndex)/sizeof(char *);i++)
    {
        sqlite3_stmt *statement;
        int result = sqlite3_prepare_v2(database,createIndex[i] , -1, &statement, nil);
        if(result!=SQLITE_OK)
        {
            NSLog(@"wrong prepare");
            continue;
        }
        result = sqlite3_step(statement);
        if(result!=SQLITE_DONE)
        {
            NSLog(@"wrong execute %d", result);
        }
        
        sqlite3_finalize(statement);
    }
}
//
// Return the SQLEntity from a SQL table
//
+(NSMutableArray *)SQLitemsFromTable:(NSString *)tableName withFilter:(NSString *)filter
{
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    
    NSString *sqlFile = [[RealPropertyApp getWorkingPath]stringByAppendingString:@".original.sqlite"];
    
    NSString *fileName = [docsDir stringByAppendingPathComponent:sqlFile];
    const char *dbpath = [fileName UTF8String];
    
    sqlite3 *database = nil;
    
    if(sqlite3_open(dbpath, &database)!=SQLITE_OK)
    {
        NSLog(@"Can't open the database");
        return nil;
    }
    NSMutableString *query;
    
    if([filter length]>0)
        query = [[NSMutableString alloc]initWithFormat:@"SELECT * FROM %@ WHERE %@ ", tableName, filter];
    else
        query = [[NSMutableString alloc]initWithFormat:@"SELECT * FROM %@", tableName];
    
    sqlite3_stmt *statement;

    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if(result==SQLITE_OK)
    {
        while(sqlite3_step(statement)==SQLITE_ROW)
        {
            // Creating a row
            NSMutableArray *array = [[NSMutableArray alloc]init];
            
            for(int i=0;i<sqlite3_column_count(statement);i++)
            {
                SQLEntity *sqlEntity = [[SQLEntity alloc]init];
                sqlEntity.sqlName = [[NSMutableString alloc]initWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                NSMutableString *dateStr;
                NSDate *dateRes;

                [sqlEntity.sqlName replaceOccurrencesOfString:@"_" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 1)];
                
                switch(sqlite3_column_type(statement,i))
                {
                    case SQLITE_INTEGER:
                        sqlEntity.valueInt = sqlite3_column_int(statement, i);
                        sqlEntity.sqlValue = kSqlInt;
                        break;
                    case SQLITE_FLOAT:
                        sqlEntity.valueFloat = sqlite3_column_double(statement, i);
                        sqlEntity.sqlValue = kSqlFloat;
                        break;
                    case SQLITE_TEXT:
                        dateRes = 0;
                        dateStr = [[NSMutableString alloc]initWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                        
                        NSRange range = [sqlEntity.sqlName rangeOfString:@"Date" options:NSCaseInsensitiveSearch];
                        if(range.length>0)
                        {
                            // We might have a date
                            dateRes = [Helper dateFromSqlString:dateStr];
                            if(dateRes==nil)
                            {
                                sqlEntity.valueString = dateStr;
                                sqlEntity.sqlValue = kSqlString;
                            }
                            else
                            {
                                sqlEntity.valueDate = dateRes;
                                sqlEntity.sqlValue = kSqlDate;
                            }
                        }
                        else
                        {
                            sqlEntity.valueString = dateStr;
                            sqlEntity.sqlValue = kSqlString;
                        }
                        dateStr = nil;
                        break;
                        
                    case SQLITE_NULL:
                        sqlEntity.sqlValue = kSqlNull;
                        break;
                }
                [array addObject:sqlEntity];
            }
            
            // Add the result to the rows
            [rows addObject:array];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    return rows;
}
-(void)cleanUp
{
    valueString = nil;
    sqlName = nil;
    valueDate = nil;

}
//
// Return a table of rows
// Each row is a table that contain key information about the data
//
+(NSArray *)SQLItemsFromTable:(NSString *)tableName
{
    return [SQLEntity SQLitemsFromTable:tableName withFilter:@""];
}
+(SQLEntity *)SQLEntityFromRow: (NSArray *)row withName:(NSString *)name
{
    for(SQLEntity *entity in row)
    {
        if([entity.sqlName compare:name]==NSOrderedSame)
        {
            return entity;
        }
    }
    return nil;
}
-(NSString *)getTypeName
{
    switch (sqlValue) {
        case kSqlDate:
            return @"date";
        case kSqlFloat:
            return @"float";
        case kSqlInt:
            return @"int";
        case kSqlNull:
            return @"null";
        case kSqlString:
            return @"string";
        default:
            break;
    }
}

@end
