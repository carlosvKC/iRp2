
#import "ValidationController.h"
#import "TabBase.h"

// there is only one activate validation controller per session
static ValidationController *validationController = nil;
@implementation ValidationController
@synthesize validations;

+(ValidationController *)validation
{
    if(validationController==nil)
        validationController = [[ValidationController alloc]init];
    return validationController;
}
+(void)clearAll
{
    if(validationController==nil)
        return;
    [validationController.validations removeAllObjects];
}
-(id)init
{
    self = [super init];
    
    validations = [[NSMutableArray alloc]init];
    return self;
}
// Add error
-(void)addError:(id)object type:(int)type description:(NSString *)message item:(ItemDefinition *)item index:(int)index
{
    ValidationError *error = [[ValidationError alloc]initError:object type:type description:message item:item index:index];
    [validations addObject:error];
}
// Return the number of errors for a particular controller + index
-(int)countErrors:(id)object
{
    int count = 0;
    for(ValidationError *valError in validations)
    {
        if(valError.target==object && valError.errorType!=kValidationWarning)
            count++;
    }
    if([object isKindOfClass:[TabBase class]])
    {
        if(((TabBase *)object).detailController!=nil)
        {
            object = ((TabBase *)object).detailController;
            for(ValidationError *valError in validations)
            {
                if(valError.target==object && valError.errorType!=kValidationWarning)
                    count++;
            }
        }
    }
    return count;
}
// Return the number of warnings for a particular controller + index
-(int)countWarnings:(id)object
{
    int count = 0;
    for(ValidationError *valError in validations)
    {
        if(valError.target==object && valError.errorType==kValidationWarning)
            count++;
    }
    if([object isKindOfClass:[TabBase class]])
    {
        if(((TabBase *)object).detailController!=nil)
        {
            object = ((TabBase *)object).detailController;
            for(ValidationError *valError in validations)
            {
                if(valError.target==object && valError.errorType!=kValidationWarning)
                    count++;
            }
        }
    }
    return count;
}
// Return the validation errors
-(NSArray *)errorList:(id)object
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    [self addErrorToArray:object array:array];
     
    if([object isKindOfClass:[TabBase class]] && ((TabBase *)object).detailController!=nil)
        [self addErrorToArray:((TabBase *)object).detailController array:array];
    
    return array;
}
-(void)addErrorToArray:(id)object array:(NSMutableArray *)array
{
    for(ValidationError *valError in validations)
    {
        if(valError.target==object)
            [array addObject:valError];
    }
    
}
-(void)clearError:(id)target index:(int)index
{

    NSMutableArray *deleted = [[NSMutableArray alloc]init];
    for(ValidationError *valError in validations)
    {
        if(valError.target==target)
            [deleted addObject:valError];
    }
    if([target isKindOfClass:[TabBase class]] && ((TabBase *)target).detailController!=nil)
    {
        target = ((TabBase *)target).detailController;
        for(ValidationError *valError in validations)
        {
            if(valError.target==target)
                [deleted addObject:valError];
        }
    }
    // Remove the errors
    for(id object in deleted)
        [validations removeObject:object];
    
}
@end
