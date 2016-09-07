
#import "SyncErrorInformation.h"

@implementation SyncErrorInformation

@synthesize errorMessage;
@synthesize entityGuid;
@synthesize entityKind;


//
// Constructor of the class
//
-(id)init:(id)errorInformation
{
    self= [super init];
    if (self)
    {
        @try
        {
            if ([errorInformation isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dic = errorInformation;
                self.errorMessage = [dic objectForKey:@"ErrorMessage"];
                self.entityGuid = [dic objectForKey:@"EntityGuid"];
                self.entityKind = [dic objectForKey:@"EntityKind"];
            }
        }
        @catch (NSException *ex)
        {
            NSLog(@"SyncErrorInformation Init exception: %@", ex);
        }
    }
    
    return self;
}

@end
