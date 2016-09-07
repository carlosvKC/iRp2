#import "GridSelection.h"
#import "GridController.h"

@implementation GridSelection

@synthesize gridController;
@synthesize columnIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
    }
    return self;
}
-(void)clearAction:(id)sender
{
    [gridController headerMenuSelection:gridSelectionClear :columnIndex];
}
-(void)clearAllAction:(id)sender
{
    [gridController headerMenuSelection:gridSelectionAllClear :columnIndex];
}
-(void)ascAction:(id)sender
{
    [gridController headerMenuSelection:gridSelectionAsc :columnIndex];
}
-(void)descAction:(id)sender
{
    [gridController headerMenuSelection:gridSelectionDesc :columnIndex];
}
-(void)filterAction:(id)sender
{
    [gridController headerMenuSelection:gridSelectionFilter :columnIndex];
}

-(void)showGridMenuInRect: (CGRect) menuRect inView:(UIView *)view withColumnIndex:(int)index withDefinition:(NSArray *)definitions
{
    [self becomeFirstResponder];
    
    menuController = [UIMenuController sharedMenuController];
    
    NSMutableArray *menus = [[NSMutableArray alloc]initWithCapacity:4];
    ItemDefinition *def = [definitions objectAtIndex:index];


    [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Asc." action:@selector(ascAction:)]];
    [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Desc." action:@selector(descAction:)]];

    if(gridController.showFilterOption)
        [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Filter..." action:@selector(filterAction:)]];
    
    if(def.filterOptions!=nil && def.filterOptions.filterValue!=nil)
        [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Clear" action:@selector(clearAction:)]];
    
    BOOL hasFilter = NO;
    for(ItemDefinition *def in definitions)
    {
        if(def.filterOptions!=nil && def.filterOptions.filterValue!=nil)
            hasFilter = YES;
        if(def.filterOptions!=nil && def.filterOptions.sortOption!=kFilterNone)
            hasFilter = YES;
    }
    if(hasFilter)
        [menus addObject:[[UIMenuItem alloc]initWithTitle:@"Clear All" action:@selector(clearAllAction:)]];

    menuController.menuItems = menus;

    CGRect destRect = CGRectMake(menuRect.origin.x + menuRect.size.width/2, menuRect.origin.y + menuRect.size.height,1, 1);
    
    [menuController setTargetRect:destRect inView:view];
    [menuController setMenuVisible:YES animated:YES];
   
}

- (BOOL) canPerformAction:(SEL)action withSender:(id) sender 
{
    if (action == @selector(clearAction:))
        return YES;
    else if(action==@selector(ascAction:))
        return YES;
    else if(action==@selector(descAction:))
        return YES;
    else if(action==@selector(filterAction:))
        return YES;
    else if(action==@selector(clearAllAction:))
        return YES;
    else
        return NO;
}

- (BOOL) canBecomeFirstResponder 
{
    return YES;
}
@end
