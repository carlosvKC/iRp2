#import "DVSelection.h"

@implementation DVSelection
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
    }
    return self;
}
-(void)toggleLabelVisibility:(id)sender
{
    _shape.hideLabel = !_shape.hideLabel;
    [_view setNeedsDisplay];
}
-(void)copyLayer:(id)sender
{
    [delegate dvKeyboardCopyLayer];
}
-(void)pasteLayer:(id)sender
{
    [delegate dvKeyboardPasteLayer];
}
-(void)selectAllObjects:(id)sender
{
    [delegate selectAllShapes];
}
-(void)showMenu: (CGRect) menuRect inView:(UIView *)view shape:(DVShape *)shape
{
    [self becomeFirstResponder];
    
    _view = view;
    menuController = [UIMenuController sharedMenuController];
    NSMutableArray *menus = [[NSMutableArray alloc]init];
    
    if(shape!=nil)
    {
        // Menu for the shape label only
        NSString *text;
        if(shape.hideLabel)
            text = @"Show Label";
        else
            text = @"Hide Label";
        _shape = shape;
        
        [menus addObject:[[UIMenuItem alloc]initWithTitle:text action:@selector(toggleLabelVisibility:)]];
    }
    else
    {
        // Background 
        [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Copy Layer" action:@selector(copyLayer:)]];
        if([delegate dvKeyboardCountLayersToPaste]>0)
            [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Paste Layer" action:@selector(pasteLayer:)]];
        [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Select All" action:@selector(selectAllObjects:)]];        
    }
    
    
    menuController.menuItems = menus;
    
    CGRect destRect = CGRectMake(menuRect.origin.x + menuRect.size.width/2, menuRect.origin.y + menuRect.size.height,1, 1);
    
    [menuController setTargetRect:destRect inView:view];
    [menuController setMenuVisible:YES animated:YES];
    
}

- (BOOL) canPerformAction:(SEL)action withSender:(id) sender 
{
    if (action == @selector(toggleLabelVisibility:))
        return YES;
    else if (action == @selector(copyLayer:))
        return YES;
    else if (action == @selector(pasteLayer:))
        return YES;
    else if (action == @selector(selectAllObjects:))
        return YES;
    else
        return NO;
}

- (BOOL) canBecomeFirstResponder 
{
    return YES;
}
-(void)dealloc
{
    menuController = nil;
    _shape = nil;
    _view = nil;
    self.delegate = nil;
}
@end
