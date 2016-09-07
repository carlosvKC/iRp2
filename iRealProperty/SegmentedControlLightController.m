#import "SegmentedControlLightController.h"
#import "MKNumberBadgeView.h"
#import "ScreenController.h"
#import "RealPropertyApp.h"
#import "ValidationController.h"

@implementation ErrorBadge : NSObject

@synthesize badgeView, target, index, targetIndex;

-(id)initWithView:(MKNumberBadgeView *)view index:(int)i
{
    self = [super init];

    badgeView = view;
    target = nil;
    index = i;
    targetIndex = 0;
    return self;
}
@end

@implementation SegmentedControlLightController

// Associate a specific controller to a badge index
-(void)linkBadgeToController:(int)index target:(id)target
{
    for(ErrorBadge *badge in badges)
    {
        if(badge.index==index)
        {
            badge.target = target;
            return;
        }
    }
    NSLog(@"Couldn't associate error badge");
}

-(id) initWithSegmentedControl:(UISegmentedControl *)segControl destView:(UIView *)destView
{
    self = [super init];
    if(self)
    {
        segmentedControl = segControl;
        lightArray = [[NSMutableArray alloc]initWithCapacity:segControl.numberOfSegments];
        // Get the dimension of the objects
        UIImage *img = [UIImage imageNamed:@"dotgreen.png"];
        _destView = destView;
        if(img==nil)
        {
            NSLog(@"can't open dotgreen.png");
            return self;
        }
        CGRect frame = segControl.frame;
        CGFloat segmentWidth = frame.size.width / segControl.numberOfSegments;
        badges = [[NSMutableArray alloc]init];
        
        // Create the list of subviews
        for(int i=0;i<segControl.numberOfSegments;i++)
        {
            CGRect rect = CGRectMake(segmentWidth*(i+1) - img.size.width - 3, 3, img.size.width, img.size.height);
            rect = [segControl convertRect:rect toView: destView];
            
            SegmentedControlLightView *view = [[SegmentedControlLightView alloc]initWithFrame:rect];
            view.segment = i;
            view.opaque = NO;
            view.userInteractionEnabled = NO;
            view.segLight = kSegLightGray;
            [lightArray addObject:view];
            [destView addSubview:view];
            [destView bringSubviewToFront:view];
            [destView setNeedsDisplay];
            
            // Create the badge
            MKNumberBadgeView *badgeView = [[MKNumberBadgeView alloc]init];
            badgeView.fillColor = [UIColor redColor];
            badgeView.value = 1;
            badgeView.shadow = NO;
            CGSize size = badgeView.badgeSize;
            
            rect = CGRectMake(segmentWidth * (i+1) - (size.width+2), 2, size.width, size.height);
            rect = [segmentedControl convertRect:rect toView: _destView];
            badgeView.frame = rect;
            
            [_destView addSubview:badgeView];
            [_destView bringSubviewToFront:badgeView];
            
            // Create a transparent button to collect feedback
            UIButton *btnMessage = [UIButton buttonWithType:UIButtonTypeCustom];
            btnMessage.frame = CGRectMake(0,0,rect.size.width, rect.size.height);
            btnMessage.backgroundColor = [UIColor clearColor];
            btnMessage.tag = i;
            
            [btnMessage addTarget:self action:@selector(displayError:) forControlEvents:UIControlEventTouchUpInside];
            [badgeView addSubview:btnMessage];
            
            badgeView.hidden = YES;

            // Create the error badges
            ErrorBadge *errorBadge = [[ErrorBadge alloc]initWithView:badgeView index:i];
            [badges addObject:errorBadge];
        }

    }
    return self;
}
-(void)calculatePositions
{
    CGRect frame = segmentedControl.frame;
    CGFloat segmentWidth = frame.size.width / segmentedControl.numberOfSegments;
    
    UIImage *img = [UIImage imageNamed:@"dotgreen.png"];
    // Create the list of subviews
    for(int i=0;i<segmentedControl.numberOfSegments;i++)
    {
        CGRect rect = CGRectMake(segmentWidth*(i+1) - img.size.width - 3, 3, img.size.width, img.size.height);
        rect = [segmentedControl convertRect:rect toView: _destView];
        UIView *view = [lightArray objectAtIndex:i];
        view.frame = rect;
        // Adjust the badges' position

        ErrorBadge *badge = [badges objectAtIndex:i];
        MKNumberBadgeView *badgeView = [badge badgeView];
        rect = CGRectMake(segmentWidth * (i+1) - (badgeView.frame.size.width+2), 2, badgeView.frame.size.width, badgeView.frame.size.height);
        rect = [segmentedControl convertRect:rect toView: _destView];
        badgeView.frame = rect;
    }
    
}
-(void)resetAll
{
    for(int i=0;i<[lightArray count];i++)
        [self changeLightStateOfSegment:i color:kSegLightGray];
}
-(void)refreshLights
{
    for(SegmentedControlLightView *view in lightArray)
    {
        [view setNeedsDisplay];
        [segmentedControl bringSubviewToFront:view];
    }
}
-(void) changeLightStateOfSegment:(int)segment color:(enum segLightConstant)color
{
    if(segment<0 || segment>=[lightArray count])
        return;
    SegmentedControlLightView *view = [lightArray objectAtIndex:segment];
    view.segLight = color;
    [self refreshLights];
}

-(enum segLightConstant) getLightStateOfSegment:(int)segment
{
    if(segment<0 || segment>=[lightArray count])
        return kSegLightNone;
    SegmentedControlLightView *view = [lightArray objectAtIndex:segment];
    return view.segLight;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
#pragma mark - Manage the warnings
- (void)addBadgeAtIndex:(int)index number:(int)count color:(UIColor *)color
{
    
    ErrorBadge *badge = [badges objectAtIndex:index];
    
    MKNumberBadgeView *badgeView = badge.badgeView;
    badgeView.fillColor = color;
    badgeView.value = count;
    badgeView.shadow = NO;
    CGSize size = badgeView.badgeSize;

    CGRect frame = segmentedControl.frame;
    CGFloat segmentWidth = frame.size.width / segmentedControl.numberOfSegments;
    CGRect rect = CGRectMake(segmentWidth * (index+1) - (size.width+2), 2, size.width, size.height);
    rect = [segmentedControl convertRect:rect toView: _destView];
    badgeView.frame = rect;
    badgeView.hidden = NO;
}
-(void)removeBadgeAtIndex:(int)index
{
    ErrorBadge *badge = [badges objectAtIndex:index];
    
    MKNumberBadgeView *badgeView = badge.badgeView;
    badgeView.hidden = YES;
}
-(void)removeAllBadges
{
    for(int i=0;i<segmentedControl.numberOfSegments;i++)
    {
        [self removeBadgeAtIndex:i];
    }
}
-(void)displayError:(UIButton *)btn
{
    ErrorBadge *badge = [badges objectAtIndex:btn.tag];
    NSArray *errorList;
    if([badge.target respondsToSelector:@selector(validationErrorList)])
        errorList = [badge.target validationErrorList];
    else
    {
        ValidationController *val = [ValidationController validation];
        errorList = [val errorList:badge.target];
    }
    NSMutableArray *messages = [[NSMutableArray alloc]init];
    // Prepare the line to be drawn in the view
    for(ValidationError *val in errorList)
    {
        NSString *msg;
        
        if(val.errorType==kValidationRequired)
        {
            msg = [NSString stringWithFormat:@"'%@' is required", val.item.labelName];
        }
        else if(val.errorType==kValidationError)
        {
            msg = [NSString stringWithFormat:@"Error: %@", val.errorDescription];
        }
        else if(val.errorType==kValidationWarning)
        {
            msg = [NSString stringWithFormat:@"Warning: %@", val.errorDescription];
        }
        [messages addObject:msg];
    }
    
    _messageController = [[UIViewController alloc]init];
    
    CGFloat width = 0 , height = 24;
    int count = 0;
    const CGFloat maxWidth = 500;
    const CGFloat border = 10;
    for(NSString *str in messages)
    {
        CGSize destSize = CGSizeMake(maxWidth, 10000.0);
        CGSize textSize = [str sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
        
        if(textSize.width > maxWidth)
            textSize.width = maxWidth;
        if(textSize.width>width)
            width = textSize.width;

        CGRect rect = CGRectMake(border, border + height*count, width, height);
        UILabel *labelView = [[UILabel alloc]initWithFrame:rect];
        labelView.numberOfLines = 1;
        labelView.text = str;
        labelView.textAlignment = NSTextAlignmentCenter;
        [_messageController.view addSubview:labelView];
        count++;
    }
    CGRect rect = CGRectMake(0, 0, width + 2*border , count*height + 2*border);
    _messageController.view.frame = rect;
    _messageController.view.backgroundColor = [UIColor whiteColor];
    _messageController.contentSizeForViewInPopover = rect.size;	
    
    _messagePopover = [[UIPopoverController alloc]initWithContentViewController:_messageController];
    [_messagePopover presentPopoverFromRect:btn.frame inView:btn  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _messagePopover.delegate = self;

}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[_messagePopover dismissPopoverAnimated:NO];
	_messagePopover = nil;
	_messageController.view = nil;
	_messageController = nil;
}
#pragma mark - Move badges around views
-(void)moveBadgesToView:(UIView *)destView target:(id)target
{
    ErrorBadge *badge = nil;
    for(ErrorBadge *errorBadge in badges)
    {
        if(errorBadge.target==target)
        {
            badge = errorBadge;
            break;
        }
    }
    //_lastFrame = badge.badgeView.frame;
    //NSLog(@"Existing frame=%@", NSStringFromCGRect(_lastFrame));
    //CGRect frame = [badge.badgeView convertRect:_lastFrame toView:destView];
    [badge.badgeView removeFromSuperview];
    [destView addSubview:badge.badgeView];
    // badge.badgeView.frame = frame;
    //NSLog(@"new frame=%@", NSStringFromCGRect(frame));
}
-(void)restoreBadges:(id)target
{
    ErrorBadge *badge = nil;
    for(ErrorBadge *errorBadge in badges)
    {
        if(errorBadge.target==target)
            badge = errorBadge;
    }
    [badge.badgeView removeFromSuperview];
    badge.badgeView.frame = _lastFrame;
    [_destView addSubview:badge.badgeView];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [lightArray removeAllObjects];
    lightArray = nil;
    [badges removeAllObjects];
    badges = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = segmentedControl.frame;
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        segmentedControl.frame = CGRectMake(frame.origin.x, frame.origin.y, 1024, frame.size.height);
    else
        segmentedControl.frame = CGRectMake(frame.origin.x, frame.origin.y, 768, frame.size.height);
    [self calculatePositions];
}
@end
