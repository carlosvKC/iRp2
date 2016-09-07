#import "RenderersPicker.h"
#import "ArcGisViewController.h"
#import "RendererXmlMenu.h"
#import "RendererXmlBreaker.h"
#import "Helper.h"

@implementation RenderersPicker

@synthesize delegate = _delegate;
@synthesize arcgisMap;
@synthesize renderers;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)adjustMenuSize
{
    int max;
    if([Helper isDeviceInLandscape])
        max = 9;
    else
        max = 14;
    if([currentMenu.menus count]>max)
        max = max*44 + 20;  // show a little bit of extra menu
    else
        max = [currentMenu.menus count]*44; // exact number

    
    self.contentSizeForViewInPopover = CGSizeMake(350, max);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of menu in the current menu
    return [currentMenu.menus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell-Renderer";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.minimumScaleFactor = 8/[UIFont labelFontSize];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    RendererMenu *menu = [currentMenu.menus objectAtIndex:[indexPath row]];

    if(menu.click)
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    else if(menu.menus==nil || [menu.menus count]==0)
        cell.accessoryType = UITableViewCellAccessoryNone;
    else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = menu.menuCaption;
    return cell;
}


#pragma mark - Table view delegate
-(void)backButton:(id)sender
{
    currentMenu = currentMenu.parent;
    if(currentMenu.parent==nil)
    {
        self.navigationItem.leftBarButtonItem = nil;     
        self.navigationItem.title = @"Renderers";
    }
    else
    {
        self.navigationItem.title = currentMenu.menuCaption;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"                                                                                 style: UIBarButtonItemStyleBordered target:self action:@selector(backButton:)] ;
    }
    // Reload the list of menu
    NSIndexSet *index = [[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:index withRowAnimation:UITableViewRowAnimationRight];
    [self adjustMenuSize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Selection on the menu -- can either go done one level or select the menu
    RendererMenu *menu = [currentMenu.menus objectAtIndex:[indexPath row]];

    if(menu.click)
    {
        // Do something with the menu
        for(UniqueValueRenderer *render in renderers)
        {
            if([render.rendererName isEqualToString:menu.rendName])
            {
                // [render cleanUp];
                [_delegate rendererSelected:render withName:render.rendererName ofType:classBreakRendererType] ;
                return;
            }
        }
        NSLog(@"Couldn't find the menu");
        return;
    }
    
    else if([menu.menus count]>0)
    {
        self.navigationItem.title = menu.menuCaption;
        // Reload the list of menu
        NSIndexSet *index = [[NSIndexSet alloc]initWithIndex:0];
        currentMenu = menu;
        [tableView reloadSections:index withRowAnimation:UITableViewRowAnimationLeft];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"                                                                                 style: UIBarButtonItemStyleBordered target:self action:@selector(backButton:)] ;
        [self adjustMenuSize];
    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Renderers";
    // Get all the renderer menu
    topMenu = [arcgisMap rendererMenus];
    currentMenu = topMenu;
    [self adjustMenuSize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
@end
