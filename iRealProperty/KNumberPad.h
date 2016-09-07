#import <UIKit/UIKit.h>

@protocol KNumberPadDelegate

- (void) didTouchButtonWithIndex:(int) i;

@end

@interface KNumberPadButton : UIView
{
	UILabel *numberLabel;
	UILabel *subLabel;
	BOOL selected;
    
	BOOL inactive;
	BOOL reversed;
    
	UIImageView *iconView;
	UIImage *upIcon;
	UIImage *overIcon;
    
	int index;
    
	__weak id delegate;
}

@property (readwrite) BOOL inactive;
@property (readwrite) BOOL reversed;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, weak) id delegate;

@property (readwrite) int index;

- (void) setLabel:(NSString *) label withSubLabel:(NSString *) slabel;
- (void) setUpIcon:(NSString *) up andOverIcon:(NSString *) over;

@end


@interface KNumberPad : UIView
{
	__weak id delegate;
}

@property (nonatomic, weak) id<KNumberPadDelegate> delegate;

- (id) initWithDelegate:(id) del;

@end