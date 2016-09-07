#import <Foundation/Foundation.h>

@interface EntityStartStatus : NSObject

@property (nonatomic, strong) NSString* entityKind;
@property (nonatomic) int actualEntityIndex;
@property (nonatomic) int totalEntities;

@end
