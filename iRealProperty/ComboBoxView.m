
#import "ComboBoxView.h"
#import "ComboBoxController.h"
#import "Helper.h"

@implementation ComboBoxView

@synthesize itsController;
@synthesize labelFont;
@synthesize labelFontColor;
@synthesize labelMinimumFontSize;
@synthesize labelFontSize;
@synthesize index;

// Automatically called from the NIB
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        labelTextRect = CGRectMake(comboBoxInsetLeft, 4, self.frame.size.width - (comboBoxInsetRight+4), 25);
        labelText = @"";
        labelFontSize = 17.0;
        labelMinimumFontSize = 12.0;
        labelFontColor = [UIColor blackColor];
        labelFont = [UIFont fontWithName:@"Helevetica" size:labelFontSize];
        
        itsItem = nil;
    }
    [self setBackgroundColor:[UIColor clearColor]];    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        labelTextRect = CGRectMake(comboBoxInsetLeft, 4, self.frame.size.width - (comboBoxInsetRight+4), 25);
        labelText = @"";
        labelFontSize = 17.0;
        labelMinimumFontSize = 12.0;
        labelFontColor = [UIColor blackColor];
        labelFont = [UIFont fontWithName:@"Helevetica" size:labelFontSize];
        
        itsItem = nil;
    }
    return self;
}
- (void)setComboItemWithString:(NSString *)string
{
    itsItem = nil;
    labelText = string;
    [self setNeedsDisplay];
}
- (void)setComboItem:(LUItems2 *)item
{
    // Update the label
    itsItem = item;
    labelText = item.LUItemShortDesc;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSString *pathName;
    
    if(enabled)
    {
        pathName = comboxBoxImageNormal;
        if(itsController.required && index==0)
            pathName = comboxBoxImageRequired;
    }
    else
        pathName = comboxBoxImageDisabled;
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(comboBoxInsetTop, comboBoxInsetLeft, comboBoxInsetBottom, comboBoxInsetRight);
    
    UIImage *img = [UIImage imageNamed:pathName];

    if(img==nil)
    {
        NSLog(@"can't open '%@'", pathName);
        return;
    }
    img = [img resizableImageWithCapInsets:imgInsets];
    [img drawInRect:rect];

    // Draw the label
    [labelFontColor set];
    [Helper drawTextInRect:labelText fontName:@"Helvetica" fontSize:labelFontSize minimumFontSize:labelMinimumFontSize destRect:labelTextRect textAlign:itsController.textAlign];
}

- (void)setEnabled:(BOOL)value
{
    enabled = value;
    [self setNeedsDisplay];
}
-(BOOL) isEnabled
{
    return enabled;
}
- (void)setSelection:(int)selection
{
    index = selection;
    [itsController setSelection:selection];
}
- (int)getSelection
{
    return [itsController getSelection];
}

// User clicks in the combo box.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!enabled)
        return;

    if(self.itsController==nil)
        return;
    ComboBoxController *controller = (ComboBoxController *)self.itsController;
    [controller clickInCombox];
}
-(void)setController:(ComboBoxController *)controller
{
    itsController = controller;
}
@end
