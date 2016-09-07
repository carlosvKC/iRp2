#import "MenuItem.h"

@implementation MenuItem

@synthesize menuChecked;
@synthesize menuTag;
@synthesize menuLabel;
@synthesize menuParam;
@synthesize menuParam2;


-(id)initWithInfo:(NSString *)label tag:(int)tag 
{
    self = [super init];
    if(self)
    {
        menuChecked = NO;
        menuLabel = label;
        menuTag = tag;
    }
    return self;
}

-(id)initWithInfo:(NSString *)label tag:(int)tag param:(id)param
{
    self = [super init];
    if(self)
    {
        menuParam = param;
        menuLabel = label;
        menuTag = tag;        
    }
    return self;
}

-(id)initWithInfo:(NSString *)label tag:(int)tag param:(id)param param2:(id)param2
{
    self = [super init];
    if(self)
    {
        menuParam2 = param2;
        menuParam = param;
        menuLabel = label;
        menuTag = tag;
    }
    return self;
}

@end
