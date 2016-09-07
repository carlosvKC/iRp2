
#import <Foundation/Foundation.h>
#import "ItemDefinition.h"
enum ValidationErrorConstant
{
    kValidationRequired,
    kValidationError,
    kValidationWarning
};

@interface ValidationError : NSObject
{
    enum ValidationErrorConstant _errorType;
    NSString    *_errorDescription;
    ItemDefinition *_item;
    UIView *_view;
    
    int _itemIndex;
    __weak id _target;
}
@property(nonatomic) enum ValidationErrorConstant errorType;
@property(nonatomic, strong) NSString *errorDescription;
@property(nonatomic, strong) ItemDefinition *item;
@property(nonatomic, strong) UIView *view;
@property(nonatomic, weak) id target;
@property(nonatomic) int itemIndex;

-(id)initError:(id)t type:(enum ValidationErrorConstant)type description:(NSString *)desc item:(ItemDefinition *)itemDef index:(int)index;
@end
