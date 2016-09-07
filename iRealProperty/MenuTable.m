
#import "MenuTable.h"
#import "Helper.h"
#import "EntityBase.h"

@implementation MenuRange
@synthesize location;
@synthesize length;
@synthesize section;

#pragma mark - Identify the different menus
-(id)initRangeWithSection:(int)sec location:(int)loc length:(int)len
{
    self = [super init];
    if(self)
    {
        section = sec;
        location = loc;
        length = len;
    }
    return self;
}
@end

@implementation MenuTable

@synthesize items;
@synthesize menuSrc;
@synthesize delegate;
@synthesize parcelNbr;

//
// Create the different sections
-(void)createSections
{
    NSMutableArray *ranges = [[NSMutableArray alloc]init];
    int firstIndex=0, firstSection= -1;
    
    for(int index=0;index<[self.items count];index++)
    {
        MenuItem *item = [self.items objectAtIndex:index];
        NSRange range = [item.menuLabel rangeOfString:@"-"];

        if(range.location==0 && range.length==1)
        {
            // Find a new section
            if(index!=0)
                [ranges addObject:[[MenuRange alloc]initRangeWithSection:firstSection location:firstIndex length:index-firstIndex]];
            firstSection = index;
            firstIndex = index+1;
        }
        range = [item.menuLabel rangeOfString:@"+"];
        
        if(range.location==0 && range.length==1)
        {
            menuTitle = [item.menuLabel stringByReplacingOccurrencesOfString:@"+" withString:@""];
            firstIndex++;
        }
    }
    // Last entries
    [ranges addObject:[[MenuRange alloc]initRangeWithSection:firstSection location:firstIndex length:[self.items count]-firstIndex]];
    menuRanges = ranges;
}
-(void)calculateMenu:(id)aDelegate
{
    UITableView *tableView = (UITableView *)self.view;
    delegate = aDelegate;
    if([delegate respondsToSelector:@selector(menuTableBeforeDisplay:withItems:)])
        [delegate menuTableBeforeDisplay:menuSrc withItems:items];
    
    // Recalculate the height of the table
    [tableView layoutIfNeeded];
    int height = [tableView contentSize].height;
    
    // Recalculate the width of the table
    int width = 10;
    for(MenuItem *item in self.items)
    {
        int w = [Helper getDefaultStringLength:item.menuLabel];
        if(w>width)
            width = w;
    }
    //width += 60;
    width += 80;
    if([menuTitle length]!=0)
    {
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self];
        nav.title = menuTitle;
        
        self.contentSizeForViewInPopover = CGSizeMake(width, height);
        popoverController = [[UIPopoverController alloc]initWithContentViewController:nav];
        
        self.navigationItem.title = menuTitle;
    }
    else
    {
        self.contentSizeForViewInPopover = CGSizeMake(width, height);
        popoverController = [[UIPopoverController alloc]initWithContentViewController:self];
    }
    popoverController.delegate = self;
}

//
// Display the pop-over menu from a button
//
-(void)presentMenu:(UIBarButtonItem *)btn withDelegate:(id)aDelegate
{
    [self calculateMenu:aDelegate];
    [popoverController presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
//  Store parcelNbr for web link
-(void)storeParcelNbr:(NSString *)parcelNumber
{
    self.parcelNbr = parcelNumber;
}
//
// Display the pop-over menu from a button
//
-(void)presentMenu:(CGRect)inRect withView:(UIView *)view withDelegate:(id)aDelegate
{
    [self calculateMenu:aDelegate];
    [popoverController presentPopoverFromRect:inRect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//
// Check a menu (based on the tag(
-(void)setMenuCheck:(int)tag checked:(BOOL)val
{
    for(MenuItem *item in self.items)
    {
        if(item.menuTag==tag)
            item.menuChecked = val;
    }
}
#pragma mark - Init
-(id)initFromResource:(NSString *)name
{
    self = [super initWithNibName:@"MenuTable" bundle:nil];
    if(self)
    {
        self.items = [self getMenuItems:name];
        [self createSections];
        menuSrc = name;
    }
    return self;
}
//
// List of MenuItems
-(id)initWithMenuItems:(NSArray *)listofItems
{
    self = [super initWithNibName:@"MenuTable" bundle:nil];
    if(self)
    {
        self.items = listofItems;
        [self createSections];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [menuRanges count];  // return the # of sections
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MenuRange *range = [menuRanges objectAtIndex:section];

    return range.length;
}
//
// Return a cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    }
    MenuRange *range = [menuRanges objectAtIndex:[indexPath section]];
    MenuItem *item = [self.items objectAtIndex:range.location + [indexPath row]];

    cell.textLabel.text = item.menuLabel;
    /// add image
    //UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(3,2, 20, 25)];
     //imv.image=[UIImage imageNamed:@"icon144.png"];
    //cell.imageView.image = imv.image;
    //
    if(item.menuChecked)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
    
}
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    if (![self.menuSrc isEqualToString:@"MenuZoomLevel"])
    {
    if(indexPath.row  == 0)     //Call Owner
    {
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"finance32.png"];   //finance
        }
        else
             {
             image=[UIImage imageNamed: @"callOwnr64.png"];
             }
        cell.imageView.image = image;
    }
    if(indexPath.row  == 1)     //Get Plans
    {
        UIImage *image = nil;
        cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"record32.png"];   //recorders
        }
        else
            image=[UIImage imageNamed: @"getPlan64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 2)     //Finish Drawing
    {
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"view32.png"];       //parcelViewer
        }
        else
        image=[UIImage imageNamed: @"present64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 3)     //Check website
    {
        UIImage *image = nil;
        cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"eRp32.png"];       //eRealproperty
        }
        else

        image=[UIImage imageNamed: @"earth_location64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 4)     //Set appointment
    {
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"esales32.png"];       //eSales
        }
        else

        image=[UIImage imageNamed: @"appt64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 5)     //Incomplete New Building
    {
        cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"emap32.png"];       //eMap
        }
        else
        image=[UIImage imageNamed: @"IncBldgDraw64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 6)     //Wait for callback
    {
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"area_rpt32.png"];       //Area Report
        }
        else

        image=[UIImage imageNamed: @"callBack64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 7)     //See Note
    {
        UIImage *image = nil;
        cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            image=[UIImage imageNamed: @"imap32.png"];       //iMap
        }
        else

        image=[UIImage imageNamed: @"note_text64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 8)     //Do not synchronize   //
    {
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            //image=[UIImage imageNamed: @"bug32A.png"];        //Bug Report
            image=[UIImage imageNamed: @"crowd32B.png"];     //res Division
        }
        else
        
        image=[UIImage imageNamed: @"doNotSynch64.png"];
        cell.imageView.image = image;
        
    }
    if(indexPath.row  == 9)     //Other
    {
        UIImage *image = nil;
        cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            //image=[UIImage imageNamed: @"crowd32B.png"];     //res Division
            image=[UIImage imageNamed: @"first_aid32B.png"];   //User Support
            
        }
        else
        
        image=[UIImage imageNamed: @"other64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 10)   //General
    {
        UIImage *image = nil;
        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            //image=[UIImage imageNamed: @"first_aid32B.png"];   //User Support
            image=[UIImage imageNamed: @"moneybag_32B.png"];      //HR
         
        }
        else
            
        image=[UIImage imageNamed: @"gral64.png"];
        cell.imageView.image = image;
    }
    if(indexPath.row  == 11)    
    {
        UIImage *image = nil;
        cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];

        if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
            //image=[UIImage imageNamed: @"moneybag_32B.png"];      //HR
            
        }
        else
        
        image=[UIImage imageNamed: @"revisit64.png"];       //Revisit
        cell.imageView.image = image;
    }

        if(indexPath.row  == 12)
        {
            UIImage *image = nil;
            //cell.backgroundColor = [UIColor colorWithRed:238 green:233 blue:233 alpha:1];
            
            if ([self.menuSrc isEqualToString:@"MenuWeb"]) {
               //image=[UIImage imageNamed: @"hammer64.png"];      //Pictometry

            }
//            else
//                
//                image=[UIImage imageNamed: @"revisit64.png"];       //Revisit
            cell.imageView.image = image;
        }
 
        
    }
    
}
-(void)cancelMenu
{
    [popoverController dismissPopoverAnimated:NO];
    popoverController = nil;
}
#pragma mark - Popover delegate
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popover
{
    popoverController = nil;
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuRange *range = [menuRanges objectAtIndex:[indexPath section]];
    MenuItem *item = [self.items objectAtIndex:range.location + [indexPath row]];
    
    [popoverController dismissPopoverAnimated:YES];
    popoverController = nil;
    
    if([delegate respondsToSelector:@selector(menuTableMenuSelected:withTag:withParam:)])
    {
        NSArray * sepParamArray = [item.menuParam componentsSeparatedByString:@"+"];
        NSString * paramWebNbr = [sepParamArray objectAtIndex:0]; //123
        
        if ([paramWebNbr isEqualToString:@"w1"]) //Finance
            
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            paramUrl = [paramUrl stringByAppendingString:parcelNbr];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w2"]) //Recorders
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            paramUrl = [paramUrl stringByAppendingString:parcelNbr];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w3"]) //ParcelViewer
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            paramUrl = [paramUrl stringByAppendingString:parcelNbr];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w4"])    //eRealProperty
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w5"])    //eSales
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w6"])    //eMap
        {
            paramWebNbr = [paramWebNbr stringByAppendingString:parcelNbr];
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w7"])    //AreaReport
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w8"])    //iMap
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"w9"])    //Bug Track
        {
            //NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"r1"])    //Res Division
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"a1"])    //User Support
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"a2"])    //HR
        {
            NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        else if ([paramWebNbr isEqualToString:@"x1"])    //Permit Info
        {
            //NSString * paramUrl = [sepParamArray objectAtIndex:1]; //456
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:paramUrl]];
        }
        
        else
        {
            //cv  all menu items from bookmark
            [delegate menuTableMenuSelected:menuSrc withTag:item.menuTag withParam:item.menuParam];
        }
        
    }
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *view = (UITableView *)self.view;
    view.delegate = self;
    
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
#pragma mark - Menu items functions

-(NSArray *)getMenuItems : (NSString *)name 
{
    MenuDefinition *menu = [EntityBase getMenuWithName:name];
    return menu.menus;
}
-(NSString *)getMenuName:(id)param
{
    for(MenuItem *item in self.items)
    {
        if(item.menuParam==param)
            return item.menuLabel;
    }
    return @"";
}

-(int16_t)getTypeItem:(id)param
{
    return [[param substringFromIndex:1] integerValue];
}
-(int)getTypeItemInt:(id)param
{
    return [[param substringFromIndex:1] integerValue];
}

-(int16_t)getMenuItemFromDesc : (NSString *)desc
{
    for(MenuItem *item in self.items)
    {
        if( [item.menuLabel isEqualToString: desc])
            return [[item.menuParam substringFromIndex:1] integerValue];
    }
    return 100;
}

-( int)getMenuItemFromDescInt : (NSString *)desc
{
    for(MenuItem *item in self.items)
    {
        if( [item.menuLabel isEqualToString: desc])            
            return [[item.menuParam substringFromIndex:1] integerValue];
    }
 
    return 100;
}


@end
