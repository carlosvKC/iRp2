
#import <Foundation/Foundation.h>

@interface SyncInformation : NSObject

@property (nonatomic, strong) NSString *syncEntityName;
@property (nonatomic) int syncStatus;
@property (nonatomic) int numberOfEntitiesToSync;
@property (nonatomic) int position;
@property (nonatomic, strong) NSString *syncDescription;

@end
