
#import "ValidationError.h"

@implementation ValidationError

@synthesize errorType = _errorType;
@synthesize errorDescription = _errorDescription;
@synthesize item = _item;
@synthesize view = _view;
@synthesize target = _target;
@synthesize itemIndex = _itemIndex;

-(id)initError:(id)t type:(enum ValidationErrorConstant)type description:(NSString *)desc item:(ItemDefinition *)itemDef index:(int)index
{
    self = [super init];
    if(self)
    {
        _errorType = type;
        _errorDescription = desc;
        _item = itemDef;
        _target = t;
        _itemIndex = index;
    }
    return self;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"'%@', index=%d, type=%d", _errorDescription, _itemIndex, _errorType];
}
@end
