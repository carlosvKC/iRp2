#import <UIKit/UIKit.h>
#import "KeyboardController.h"
#import "Requester.h"
#import "ATActivityIndicator.h"

@interface LoginScreen : KeyboardController<UITextFieldDelegate, RequesterDelegate>
{
    UIActivityIndicatorView *activity;
    
 }
@property (weak, nonatomic) IBOutlet UITextField *loginName;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundPict;
@property (weak, nonatomic) IBOutlet UILabel *comments;
@property (strong, nonatomic) UIButton *btnLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnTestDrawing;
@end
