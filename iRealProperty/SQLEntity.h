
#import <Foundation/Foundation.h>

enum sqlValuesConstant
{
    kSqlNull = 0,
    kSqlString,
    kSqlInt,
    kSqlFloat,
    kSqlDate
};





@interface SQLEntity : NSObject
    {
    }
    @property(nonatomic, retain) NSMutableString *valueString;
    @property int valueInt;
    @property float valueFloat;
    @property enum sqlValuesConstant sqlValue;
    @property(nonatomic, retain) NSMutableString *sqlName;
    @property(nonatomic, retain) NSDate *valueDate;

    // Return one entity from a row
    +(SQLEntity *)SQLEntityFromRow: (NSArray *)row withName:(NSString *)name;
    +(NSMutableArray *)SQLitemsFromTable:(NSString *)tableName withFilter:(NSString *)filter;
    +(NSMutableArray *)SQLItemsFromTable:(NSString *)tableName;

    +(void)prepareIndexes;

    -(NSMutableString *)getTypeName;
    -(void)cleanUp;
@end
