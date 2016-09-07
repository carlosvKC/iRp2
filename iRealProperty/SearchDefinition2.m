
#import "SearchDefinition2.h"

@implementation QueryDefinition
@synthesize query;
@synthesize entityName;
@synthesize entitySortBy;
@synthesize entityLink;
@synthesize ascending;
@synthesize predicate;
@synthesize unique;

-(id)init
{
    self = [super init];

    return self;
}
-(NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"{ QueryDefinition\n name=%@\n sortBy=%@\n link=%@\n predicate=%@ \nquery=%@\n}\n", entityName, entitySortBy, entityLink, predicate, query];
    return desc;
}
@end

@implementation SearchDefinition2
@synthesize title;
@synthesize items;
@synthesize errorMsg;
@synthesize searchDescription;

@synthesize resultRef;
@synthesize searchType;

@synthesize query;
@synthesize joinQueries;
@synthesize isDefaultMap;

-(id)init
{
    self = [super init];
    if(self)
    {
        title = @"";
        items = [[NSMutableArray alloc]init];
        errorMsg = @"";
        searchDescription = @"";

        resultRef = @"";
        searchType = kSearchByItems;
    }
    return self;
}

-(NSString *)description
{
    NSString *res = [NSString stringWithFormat:@"{ SearchDefinition\ntitle='%@'\nerrorMsg='%@'\ndescription='%@'\nquery='%@'\n\nresult=%@\nsearchtype=%d }\n", title, errorMsg, searchDescription, [query description], resultRef, searchType];
    
    return res;

}

@end
