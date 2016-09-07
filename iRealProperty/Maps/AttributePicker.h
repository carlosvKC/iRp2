#import <UIKit/UIKit.h>

@protocol AttributePickerDelegate
- (void)attributeSelected:(NSString*)attributeName forTarget: (id) target;
@end

@interface AttributePicker : UITableViewController
{
    NSArray *_attrList;
    id<AttributePickerDelegate> __weak _delegate;
    id _target;
}

@property (nonatomic, strong) id target;
@property (nonatomic, strong) NSArray * attrList;
@property (nonatomic, weak) id<AttributePickerDelegate> delegate;


@end
