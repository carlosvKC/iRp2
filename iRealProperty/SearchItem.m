#import "SearchItem.h"

@implementation SearchItem
@synthesize refObjectName;
@synthesize refTitle;
@synthesize isRequired;
@synthesize filter;
@synthesize maxChars;
@synthesize itemHelp;
@synthesize choice;

@synthesize defaultValue;
-(id)init
{
    self = [super init];
    if(self)
    {
        refObjectName = @"";
        refTitle = @"";
        isRequired = NO;
        filter = kSearchAlphabetical;
        maxChars = 8;       // Default size of characters
        itemHelp = @"";
        defaultValue = nil;
        choice = nil;
    }
    return self;
}
-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{ objectName=%@\nrefTitle='%@'\nisRequired=%d\nfilter=%d\nmaxChars=%d\nitemHelp='%@\ndefault='%@'",
                        refObjectName, refTitle, isRequired,filter,maxChars,itemHelp,defaultValue];
    return result;
}
@end
