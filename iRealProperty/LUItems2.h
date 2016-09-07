
#import <Foundation/Foundation.h>

@interface LUItems2 : NSObject
{

}
@property   int LUTypeId;
@property   int LUItemId;
@property(nonatomic, retain) NSString *LUItemShortDesc;
+(NSArray *)LUItemsFromLookup:(int)lookup;
+(NSArray *)LUItemsFromLookup:(int)lookup districtId:(int)districtId;
+(NSString *)LUItemFromTypeId:(int)typeId itemId:(int)itemId;
+(void)cleanUp;
+(NSString *)getItemSQLName;
@end
