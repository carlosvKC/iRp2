#import "EntityStructure.h"


@implementation PropertyDef

    @synthesize name, type, lookup, alphaSorted, link, isSet, isUniqueId, isBackLink;

    -(void)print
    {
        NSLog(@"Name='%@', type=%d lookup=%d alphaSorted=%d, link='%@', isSet=%d, isBackLink=%d", name,type,lookup,alphaSorted,link,isSet,isBackLink);
    }

@end



@implementation EntityDef

    @synthesize name, root, properties;

    -(id)init
    {
        self = [super init];
        if(self)
        {
            properties = [[NSMutableArray alloc]init];
        }
        return self;
    }

    -(void)print
    {
        NSLog(@"=============> definition '%@' isRoot=%@",name, root?@"YES":@"NO"); 
        for(PropertyDef *def in properties)
            [def print];
    }
@end



// ----------- Screen Definition
@implementation ScreenDefinition

    @synthesize name, items, defaultEntity, validations, repeatHeader, cellHeight;

    -(id)initWithName:(NSString *)label
    {
        self = [super init];
        if(self)
        {
            self.name = [label copy];
            items = [[NSMutableArray alloc]init];
        }
        return self;
    }
    -(NSString *)description
    {
        NSString *res = [NSString stringWithFormat:@"{ screen='%@'\n", self.name];
        for(int i=0;i<[items count];i++)
        {
            res = [res stringByAppendingString:[[items objectAtIndex:i]description]]; 
        }
        res = [res stringByAppendingString:@"\n}"];
        return res;
    }
@end


// ----------- Validation
@implementation Validation

@synthesize evaluate, message, warning;

-(NSString *)description
{
    return [NSString stringWithFormat:@"{ '%@', '%@' }", evaluate, message];
}

@end    

// ----------- Grid Definition
@implementation GridDefinition

@synthesize name, columns, tag, rowHeight, autoColumn, editLevel;
@synthesize sortDescending, sortOption, defaultObject;
-(id)initWithName:(NSString *)label
{
    self = [super init];
    if(self)
    {
        self.name = [label copy];
        columns = [[NSMutableArray alloc]init];
    }
    return self;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"{ name=%@\ntag=%d\rowHeight=%d\nautoColumn=%d\n# of columns=%d\n}", name, tag, rowHeight, autoColumn, columns==nil?-1:[columns count]];
}
@end
// ----------- Menu Definition
@implementation MenuDefinition

@synthesize name, menus;
-(id)initWithName:(NSString *)label
{
    self = [super init];
    if(self)
    {
        self.name = [label copy];
        menus = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
//---------- Multiple screens
@implementation MultiScreenDefinition
@synthesize name, screens;
-(id)initWithName:(NSString *)label
{
    self = [super init];
    if(self)
    {
        self.name = [label copy];
        screens = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
//---------- MultiScreenItem
@implementation MultiScreenItem
@synthesize label, screenName, path, repeatHeader, cellHeight, sortAscending, sortField;

@end
