#import <UIKit/UIKit.h>

@protocol StylePickerDelegate
- (void)styleSelected:(NSString*)styleName withID: (int) styleid;
@end

@interface StylePickerController : UITableViewController
{
    NSMutableArray *_styleList;
    id<StylePickerDelegate> __weak _delegate;
}

@property (nonatomic, strong) NSMutableArray *styleList;
@property (nonatomic, weak) id<StylePickerDelegate> delegate;


@end
