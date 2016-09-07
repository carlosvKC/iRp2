#import "SyncInformation.h"

@implementation SyncInformation

@synthesize syncEntityName;
@synthesize syncStatus;
@synthesize numberOfEntitiesToSync;
@synthesize position;
@synthesize syncDescription;

-(NSString *)description
{
    return [NSString stringWithFormat:@"name=%@ status=%d #=%d", syncEntityName, syncStatus, numberOfEntitiesToSync];
}
@end
