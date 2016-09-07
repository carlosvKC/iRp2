
#import <UIKit/UIKit.h>
@protocol DVImagePickerDelegate <NSObject>
@optional
-(void)dvImagePickerSelected:(id) image;
@end
@interface DVImagePicker : UITableViewController<UITableViewDelegate>

@property(nonatomic, strong) NSArray *pictList; // list of MediaBldg
@property(nonatomic, weak) id<DVImagePickerDelegate> pickerDelegate;
@end
