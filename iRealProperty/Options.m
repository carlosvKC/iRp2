

#import "Options.h"

@implementation Options

@synthesize name, label, sectionArray;
-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{Options\nname = '%@'\nlabel = '%@'\nsection count = %d}\n",name, label, sectionArray.count];
    for(OptionSection *optionSection in sectionArray)
        result = [result stringByAppendingString:[optionSection description]];
    return result;
    
}
@end

@implementation OptionSection

@synthesize label, optionArray, footer;

-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{OptionSection\nlabel = '%@'\nfooter = '%@'\noption count = %d}\n",label, footer, optionArray.count];
    for(Option *option in optionArray)
        result = [result stringByAppendingString:[option description]];
    return result;
}

@end

@implementation Option

@synthesize label, param, choices, defaultStr;

-(NSString *)description
{
    return [NSString stringWithFormat:@"{Option\nlabel = '%@'\nparam = '%@' choices = '%@' defaultStr = '%@'}\n",
            label, param,choices,defaultStr];
}

@end