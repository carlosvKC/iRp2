

#import <Foundation/Foundation.h>

@class CrashController;

@interface CrashController : NSObject 
+ (CrashController*)sharedInstance;

- (NSArray*)callstackAsArray;


@end

