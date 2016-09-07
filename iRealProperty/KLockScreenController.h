#import <UIKit/UIKit.h>
#import "KNumberPad.h"

@protocol KLockScreenControllerDelegate

- (BOOL) didSubmitPassCode:(NSString *) code withClear:(BOOL) clear;
- (void) didSubmitLock:(NSString *) code;

@end


@interface KCodeView : UIView
{
	UIImageView *one;
	UIImageView *two;
	UIImageView *three;
	UIImageView *four;
    
	UILabel *topLabel;
	UILabel *bottomLabel;
}

@property (nonatomic, retain) UILabel *topLabel;
@property (nonatomic, retain) UILabel *bottomLabel;

- (void) setFull:(int) full;

@end

@interface KLockScreenController : UIViewController <KNumberPadDelegate>
{
	UINavigationBar *navBar;
    
	KCodeView *codeView1;
	KCodeView *codeView2;
    
	KNumberPad *numPad;
    
	KCodeView *currCode;
    
	NSString *entered;
	NSString *currText;
    
	BOOL showLock;
	BOOL clearLock;
	BOOL ignoreClear;
	__weak id delegate;
}

@property (nonatomic, weak) id delegate;

- (id) initWithLock:(BOOL) shouldLock shouldClearLock:(BOOL) clear;

@end