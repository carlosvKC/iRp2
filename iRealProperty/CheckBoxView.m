#import "CheckBoxView.h"
#import "ScreenController.h"

@implementation CheckBoxView    

@synthesize delegate;
@synthesize checked, enabled;

-(void)switchToggled:(id)sender
{
    if(sender==self)
        [delegate checkBoxClicked:self isChecked:self.on];    
}
-(void)adjustFrame
{

    [self setOn:NO animated:NO ignoreControlEvents:YES];
    self.onText = @"Y";
    self.offText = @"N";
    self.onTintColor = [UIColor greenColor];
    [self addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    self.ignoreTap = NO;
    // [self setBackgroundColor:[UIColor clearColor]];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self adjustFrame];
    }

    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self adjustFrame];
    }

    return self;
}
-(void) setChecked:(BOOL)value
{
    checked = value;
    [self setOn:value animated:NO ignoreControlEvents:YES];
}
-(void) setEnabled:(BOOL)value
{
    enabled = value;
    self.ignoreTap = !value;
    if(enabled)
        self.onTintColor = [UIColor greenColor];
    else
        self.onTintColor = [UIColor lightGrayColor];
}
@end