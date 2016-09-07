#import "KeyboardController.h"
#import "Helper.h"

@implementation KeyboardController
@synthesize firstResponder;

-(id)init
{
    self = [super init];
    if(self)
    {
        _currentOrientation = kOrientationPortrait;
        extraOffset = 0;
        keyboardController = nil;
    }
    return self;
}
#pragma mark - handle show/hide keyboard
-(void)registerForKeyboardNotifications
{
    [self registerForKeyboardNotifications:self withDelta:0];
}
-(void)registerForKeyboardNotifications:(UIViewController *)newController withDelta:(int)height
{
    keyboardController = newController; // principal controller that is going to move...
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    extraOffset = height;
}
-(void)deregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
// Called when the UIKeyboardDidShowNotification is sent.
-(void)keyboardWasShown:(NSNotification*)aNotification
{
    if(activeTextField==nil)
        return;
    
    keyboardControllerViewFrame = keyboardController.view.frame;
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    CGRect frame = [Helper convertToScreenCoordinate:(UIView *)activeTextField];
    int delta;
    CGFloat notCoveredHeight, keyboardHeight;
    
    CGFloat frameHeight;
    if(UIInterfaceOrientationIsPortrait(keyboardController.interfaceOrientation))
    {
        // Portrait mode
        keyboardHeight = keyboardFrame.size.height;
        
        notCoveredHeight = 1024 - keyboardHeight;
        frameHeight = frame.origin.y + frame.size.height;
        if(notCoveredHeight > frameHeight)
            return;   
    }
    else
    {
        // Landscape mode
        keyboardHeight = keyboardFrame.size.width;
        notCoveredHeight = 768 - keyboardHeight;
        frameHeight = frame.origin.y + frame.size.height+20;
        if(notCoveredHeight > frameHeight)
            return;

    }
    delta = frameHeight - notCoveredHeight + extraOffset;
    frame = CGRectMake(keyboardController.view.frame.origin.x, keyboardController.view.frame.origin.y -delta, keyboardController.view.frame.size.width, keyboardController.view.frame.size.height); 

    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [keyboardController.view setFrame:frame];
    [UIView commitAnimations];    
}

// Called when the UIKeyboardWillHideNotification is sent
-(void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(activeTextField==nil)
        return;
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [keyboardController.view setFrame:keyboardControllerViewFrame];
    [UIView commitAnimations];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField; 
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeTextField = nil;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    activeTextField = (UITextField *)textView;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    activeTextField = nil;
}
@end
