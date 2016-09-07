#import "TabBarController.h"


#define kContentView    2345
#define kContentBar     2346

@implementation TabBarController
@synthesize tabBarView;
@synthesize tabBar;
@synthesize selectedViewController = _selectedViewController;
@synthesize items = _items;
@synthesize delegate;
@synthesize debugViewBtn = _debugViewBtn;

static UIView *tabBarTopView;
#pragma mark - delegate

+(UIView *)topView
{
    return tabBarTopView;
}

-(void)tabBar:(UITabBar *)aTabBar didSelectItem:(UITabBarItem *)barItem
{
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    if(time-lastClick < 0.8)
    {
        aTabBar.selectedItem = lastItem;
        return;
    }
    else
    {
        lastItem = barItem;
        lastClick = time;
    }
    
    // Switch to a new controller
    UIViewController *tobeSelected = [_items objectAtIndex:barItem.tag];
    [self switchToNewController:tobeSelected];
}
-(void)switchToNewController:(UIViewController *)tobeSelected
{
    if(_selectedViewController==tobeSelected)
        return;
    
    if([delegate respondsToSelector:@selector(tabBarShoudSwitchController:)])
    {
        // if the delegate does not want to switch to a new controller
        if(![delegate tabBarShoudSwitchController:_selectedViewController])
            return;
    }
    if([delegate respondsToSelector:@selector(tabBarWillSwitchController:)])
    {
        // Let the current controller know that the switch will happen
        [delegate tabBarWillSwitchController:_selectedViewController];
    }    
    [self swapController:tobeSelected];
    
    if([delegate respondsToSelector:@selector(tabBardidSelectViewController:)])
    {
        [delegate tabBardidSelectViewController:tobeSelected];
    }
}
#pragma mark - Handle the view controller
// Swap the controller to a new one
-(void)swapController:(UIViewController *)newController
{
    if(_isTransitioning)
        return;
    _isTransitioning = YES;
    if(newController!=nil)
    {
        [self addChildViewController:newController];
        [tabBarView addSubview:newController.view];
        [newController didMoveToParentViewController:self];
    }

    [tabBarView bringSubviewToFront:newController.view];    

    [newController willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];    
    [UIView transitionFromView:_selectedViewController.view toView:newController.view duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished)
     {
         if(_selectedViewController!=nil)
         {
             [_selectedViewController willMoveToParentViewController:nil];
             [_selectedViewController.view removeFromSuperview];
             [_selectedViewController removeFromParentViewController];
         }
         _selectedViewController = newController;
         _isTransitioning = NO;
     }];

}
-(void)setSelectedViewController:(UIViewController *)selectedViewController
{
    // Change the current selected controller -- and execute a transition F/X
    [self switchToNewController:selectedViewController];
    for(int index=0;index<tabBar.items.count;index++)
    {
        UIViewController *viewCtrl = [_items objectAtIndex:index];
        if(selectedViewController == viewCtrl)
        {
            tabBar.selectedItem = [tabBar.items objectAtIndex:index];
            return;
        }
    }
}
-(void)setItems:(NSArray *)items
{
    _items = items;
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:items.count];
    for(int index=0;index<items.count;index++)
    {
        UIViewController *viewCtrl = [items objectAtIndex:index];
        UIBarItem *barItem;
        barItem = viewCtrl.tabBarItem;
        barItem.title = viewCtrl.title;
        barItem.tag = index;
        [array addObject:barItem];
    }
    tabBar.items = array;
}
-(void)setBarAtBottom:(BOOL)position
{
    if(!position)
    {
        tabBar.frame = CGRectMake(0,0, tabBar.frame.size.width, tabBar.frame.size.height);
        tabBarView.frame = CGRectMake(0,tabBar.frame.size.height, tabBarView.frame.size.width, tabBarView.frame.size.height);
    }
    else 
    {
        tabBarView.frame = CGRectMake(0,0, tabBarView.frame.size.width, tabBarView.frame.size.height);
        tabBar.frame = CGRectMake(0,tabBarView.frame.size.height, tabBar.frame.size.width, tabBar.frame.size.height);
    }
    _barAtBottom = position;

}
-(void)hide:(BOOL)animated
{
    
}
-(void)show:(BOOL)animated
{
}
#pragma mark - Rotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        tabBarView.frame = CGRectMake(tabBarView.frame.origin.x, tabBarView.frame.origin.y,
                                  1024,699);
    }
    else 
    {
        tabBarView.frame = CGRectMake(tabBarView.frame.origin.x, tabBarView.frame.origin.y,
                                      768,955);        
    }
    [self setBarAtBottom:_barAtBottom];
}

#pragma mark - LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _barAtBottom = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    tabBar.delegate = self;
    tabBarTopView = self.view;
    _debugViewBtn.hidden = YES;
#if TARGET_IPHONE_SIMULATOR
    _debugViewBtn.hidden = NO;
#endif
    tabBar.selectionIndicatorImage = [UIImage imageNamed:@"TabSelected"];
}

- (void)viewDidUnload
{
    [self setTabBarView:nil];
    [self setTabBar:nil];

    [self setDebugViewBtn:nil];
    [super viewDidUnload];

}

- (IBAction)debugView:(id)sender 
{
    // RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    
}
-(void)addBadgeToTab:(int)index value:(int)value
{
    NSArray *items = tabBar.items;
    if(index<0 || index>= items.count)
        return;
    UITabBarItem *item = [items objectAtIndex:index];
    
    item.badgeValue = [NSString stringWithFormat:@"%d", value];
}
-(void)removeBadgeFromTab:(int)index
{
    NSArray *items = tabBar.items;
    if(index<0 || index>= items.count)
        return;
    UITabBarItem *item = [items objectAtIndex:index];
    
    item.badgeValue = nil;

}
-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(BOOL)isBarAtBottom
{
    return _barAtBottom;
}
@end

