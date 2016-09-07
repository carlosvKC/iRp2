#import "SearchGroup.h"

@implementation SearchGroup

@synthesize title;
@synthesize searchDefinitions;

-(id)init
{
    self = [super init];
    if(self)
    {
        title = @"";
        searchDefinitions = [[NSMutableArray alloc]init];
    }
    return self;
}
-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{ title='%@' }", title];
    for(SearchDefinition2 *def in searchDefinitions)
        result = [result stringByAppendingString:[def description]];
    return result;
}

@end
