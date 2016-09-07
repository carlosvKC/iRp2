#import <UIKit/UIKit.h>

@interface TabFeedbackController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *feedback;
- (IBAction)submitFeedback:(id)sender;

@end
