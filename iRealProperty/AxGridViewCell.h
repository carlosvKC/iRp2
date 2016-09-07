
#import <UIKit/UIKit.h>
#import "AXGridViewCellInfoProtocol.h"

@protocol AxGridViewCellDelegate;

#define LongTouchTimer  500 // in mms

@interface AxGridViewCell : UIView <AxGridViewCellInfoProtocol> 
{

	NSUInteger xPosition, yPosition;
	NSString *identifier;
	
	BOOL selected;
	BOOL highlighted;
	
	__weak id<AxGridViewCellDelegate> delegate;
	
    NSTimer *timerOnTouch;
    BOOL    _timerWasRun;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL highlighted;
- (id)initWithReuseIdentifier:(NSString *)identifier;
- (void)prepareForReuse;
@end

@protocol AxGridViewCellDelegate

- (void)gridViewCellWasTouched:(AxGridViewCell *)gridViewCell;
- (void)gridViewCellWasLongTouched:(AxGridViewCell *)gridViewCell;
@end
