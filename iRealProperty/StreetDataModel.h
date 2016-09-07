
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface StreetModel : NSObject 
{
}
@property int sortId;
@property int streetId;
@property(nonatomic, retain) NSString *streetName;
@property(nonatomic, retain) NSString *streetType;
@property(nonatomic, retain) NSString *dirPrefix;
@property(nonatomic, retain) NSString *dirSuffix;
@end

@interface StreetDataModel : NSObject
{   
}
+(int)getStreetIdWithStreetName:(NSString *)streetName prefix:(NSString *)prefix streetType:(NSString *)streetType postfix:(NSString *)postfix;
+(NSMutableArray *)loadTable: (NSString *)table filter : (NSString *)filter;
+(NSString *)getStreetNameFromStreetId:(int)streetId;
+(void)getStreetDetails:(NSString *)streetName type:(NSMutableArray *)filterType prefix:(NSMutableArray *)filterPrefix suffix:(NSMutableArray *)filerSuffix;
@end
