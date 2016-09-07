#import <UIKit/UIKit.h>

@interface ATActivityIndicator : UIView
{
	UILabel *centerMessageLabel;
	UILabel *subMessageLabel;
	
	UIActivityIndicatorView *spinner;
}

@property (nonatomic, strong) UILabel *centerMessageLabel;
@property (nonatomic, strong) UILabel *subMessageLabel;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;


+ (ATActivityIndicator *)currentIndicator;

- (void)show;
- (void)hideAfterDelay;
- (void)hide;
- (void)hidden;
- (void)displayActivity:(NSString *)m;
- (void)displayCompleted:(NSString *)m;
- (void)setCenterMessage:(NSString *)message;
- (void)setSubMessage:(NSString *)message;
- (void)showSpinner;
- (void)setProperRotation;
- (void)setProperRotation:(BOOL)animated;

@end
