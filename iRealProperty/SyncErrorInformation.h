
#import <Foundation/Foundation.h>

@interface SyncErrorInformation : NSObject

@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSString *entityGuid;
@property(nonatomic, strong) NSString *entityKind;

-(id)init:(id)errorInformation;

@end
