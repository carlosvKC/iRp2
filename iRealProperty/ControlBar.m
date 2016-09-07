
#import "ControlBar.h"


@implementation ControlBar
@synthesize toolbar;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//
// the back button has been selected
-(void)toolbarBackSelected
{
    [delegate menuBarBtnBackSelected];
}
//
// Call to the delegate
-(void)toolbarSelection:(id)btn
{
    UIBarButtonItem *button = btn;
    [delegate menuBarBtnSelected:button.tag];
    
}
//
// Setup the label
-(void)setupBarLabel:(NSString *)text
{

    for(UIBarButtonItem *btn in toolbar.items)
    {
        if(btn.tag==kBtnLabel)
        {
            btn.title = text;
            
            // DBaun - painful amount of work to set text size on button item.
            UIFont * font = [UIFont boldSystemFontOfSize:14];
            NSDictionary * attributes = @{UITextAttributeFont: font};
            [btn setTitleTextAttributes:attributes forState:UIControlStateNormal];
            
            break;
        }
    }
}



-(UIButton*)getDashboardToDoButton
{
    for (UIBarButtonItem *item in toolbar.items)
    {
        if ([item customView] && [[item customView] isMemberOfClass:[UIButton class]])
        {
            UIButton *theButton = (UIButton*)[item customView];
            if ([theButton.titleLabel.text isEqual: @"ToDo"])
                return theButton;
        }
            
    }
    return nil;
}


-(UIBarButtonItem*)getDashboardToDoParentButton
{
    for (UIBarButtonItem *item in toolbar.items)
    {
        if ([item customView] && [[item customView] isMemberOfClass:[UIButton class]])
        {
            UIButton *theButton = (UIButton*)[item customView];
            if ([theButton.titleLabel.text isEqual: @"ToDo"])
                return item;
        }
        
    }
    return nil;
}


//
// Return an item from the bar based on its tag
-(UIBarButtonItem *)getBarButtonItem:(int)tag
{
    for(UIBarButtonItem *item in toolbar.items)
    {
        //NSLog(@"Bar button item:Tag = %ld /// Title = %@ /// Class = %@ /// Has custom view = %i",(long)[item tag], [item title], NSStringFromClass([item class]), item.customView != nil);
        if(item.tag == tag)
            return item;
    }
    return nil;
}
// Return a index from the bar based on its tag
-(int )getBarButtonItemIndex:(int)tag
{
    for(int index=0;index<toolbar.items.count;index++)
    {
        UIBarButtonItem *item = [toolbar.items objectAtIndex:index];
        if(item.tag == tag)
            return index;
    }
    return -1;
}

// Return an item from the bar based on its tag
-(UIBarItem *)getBarItem:(int)tag
{
    for(UIBarItem *item in toolbar.items)
    {
        if(item.tag == tag)
            return item;
    }
    return nil;
}
-(void)setItemEnable:(int)tag isEnable:(BOOL)en
{
    UIBarButtonItem *item = [self getBarButtonItem:tag];
    item.enabled = en;
}
-(void)setItemTitle:(int)tag title:(NSString *)title
{
    UIBarButtonItem *item = [self getBarButtonItem:tag];
    item.title = title;
}
-(void)setItemSelected:(int)tag isSelected:(BOOL)en
{
    UIBarButtonItem *item = [self getBarButtonItem:tag];
    if(en)
        item.style = UIBarButtonItemStyleDone;
    else 
        item.style = UIBarButtonItemStylePlain;
}
-(BOOL)isItemSelected:(int)tag
{
    UIBarButtonItem *item = [self getBarButtonItem:tag];

    return item.style == UIBarButtonItemStyleDone ? YES : NO;
}
-(void)addBackButonWithTitle:(NSString *)title
{  
    // create button
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    backButton.tag = kBtnBack;  // well. hopefully nobody will use so many buttons!
    [backButton addTarget:self action:@selector(toolbarBackSelected) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:title forState:UIControlStateNormal];
    
    // create button item -- possible because UIButton subclasses UIView!
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    backItem.tag = kBtnBack;
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:toolbar.items];
    [array insertObject:backItem atIndex:0];
    
    toolbar.items = array;
}
-(void)addButton:(UIButton *)btn atIndex:(int)index
{
    [btn addTarget:self action:@selector(toolbarSelection:) forControlEvents:UIControlEventTouchUpInside];
    // create button item -- possible because UIButton subclasses UIView!
    UIBarButtonItem* btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:toolbar.items];
    if(index<0)
        [array insertObject:btnItem atIndex:0];
    else if(index>[array count])
        [array addObject:btnItem];
    else
        [array insertObject:btnItem atIndex:index];
    toolbar.items = array;
}


-(void)replaceItemWith:(UIBarButtonItem *)item withTag:(int)tag
{
    UIBarButtonItem *current = [self getBarButtonItem:tag];
    if(current==nil)
        return;
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:toolbar.items];
    int index = 0;
    for(id value in array)
    {
        if(value==current)
        {
            [array replaceObjectAtIndex:index withObject:item];
            toolbar.items = array;
            return;
        }
        index++;
    }
}


-(void)removeButton:(int)index
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:toolbar.items];
    [array removeObjectAtIndex:index];
    toolbar.items = array;
}


-(void)removeButtonWithTag:(int)tag
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:toolbar.items];
    UIBarButtonItem *removeItem = nil;
    for(UIBarButtonItem *item in array)
    {
        if(item.tag==tag)
        {
            removeItem = item;
            break;
        }
    }
    if(removeItem)
        [array removeObject:removeItem];
    toolbar.items = array;
}


-(void)addBackButon
{
    [self addBackButonWithTitle:@"Back"];
}


-(void)removeBackButton
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:toolbar.items];
    UIBarButtonItem *back;
    for(UIBarButtonItem *btn in array)
    {
        if(btn.tag==kBtnBack)
        {
            back = btn;
            break;
        }
    }
    if(back!=nil)
        [array removeObject:back];
    toolbar.items = array;
}


-(void)refreshLinks
{
    if(toolbar==nil)
    {
        NSLog(@"Top Bar: Verify that the toolbar is setup in the NIB");
        return;
    }
    for(UIBarButtonItem *btn in toolbar.items)
    {
        if(btn.tag)
        {
            btn.action = @selector(toolbarSelection:); 
            btn.target = self;
        }
    }
}

#pragma mark - View lifecycle
- (void) viewDidLoad
{
    [self refreshLinks];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = self.view.frame;
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        self.view.frame = CGRectMake(frame.origin.x, frame.origin.y, 1024, frame.size.height);
    else
        self.view.frame = CGRectMake(frame.origin.x, frame.origin.y, 768, frame.size.height);
}




@end
