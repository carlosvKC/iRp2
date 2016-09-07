#import "AxGridViewCell.h"
#import "AxGridView.h"

#pragma mark Private Methods
@interface AxGridViewCell ()
- (AxGridView *)gridView;
@end



@implementation AxGridViewCell

@synthesize xPosition, yPosition, identifier, delegate, selected;
@synthesize highlighted;

@dynamic frame;

-(id):init
{
	if (![super init])
		return nil;

    return self;
}

- (id)initWithReuseIdentifier:(NSString *)anIdentifier
{
    self = [super initWithFrame:CGRectZero];
    if(self)
	identifier = [anIdentifier copy];
	
	return self;
}
- (void)dealloc 
{
}

- (void)awakeFromNib {
	identifier = nil;
}

- (void)prepareForReuse {
	self.selected = NO;
	self.highlighted = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{

	self.highlighted = YES;
    timerOnTouch = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerEnded:) userInfo:nil repeats:NO];
    _timerWasRun = NO;
    [self.delegate gridViewCellTouchesBegan:self:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
	self.highlighted = NO;
    [timerOnTouch invalidate];
    timerOnTouch = nil;
    [self.delegate gridViewCellTouchesCancelled:self:event];
	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [timerOnTouch invalidate];
    if(_timerWasRun)
        return;
    self.highlighted = NO;
    [self.delegate gridViewCellWasTouched:self];
    [super touchesEnded:touches withEvent:event];

    timerOnTouch = nil;
}
-(void)timerEnded:(NSTimer *)timer
{
    _timerWasRun = YES;
    timerOnTouch = nil;
    // Equivalent to cancel touch
	self.highlighted = NO;
    [self.delegate gridViewCellWasLongTouched:self];    
}
#pragma mark -
#pragma mark Private Methods

- (AxGridView *)gridView {	
	UIResponder *r = [self nextResponder];
	if (![r isKindOfClass:[AxGridView class]]) return nil;
	return (AxGridView *)r;
}

@end
