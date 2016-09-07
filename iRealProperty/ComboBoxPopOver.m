#import "ComboBoxPopOver.h"
#import "ComboBoxController.h"

@implementation ComboBoxPopOver

@synthesize comboItems;
@synthesize delegate;
@synthesize popoverController;
@synthesize maxItems, popoverWidth, popoverHeight;

- (id)initWithArrayAndViewRect:(NSArray *)elementList inView:(UIView *)cmbView   destRect:(CGRect)rect selectedRow:(int)row
{
    self = [super init];
    maxItems = 12;
    popoverWidth = POPOVER_WIDTH;
    popoverHeight = POPOVER_LINE_HEIGHT;
    
    comboItems = elementList;
    [self selectRow:row];
    popoverController = [[UIPopoverController alloc]initWithContentViewController:self];
    [popoverController presentPopoverFromRect:rect inView:cmbView permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
       
    return self;
}


- (id)initWithArrayAndViewRect:(NSArray *)elementList inView:(UIView *)cmbView destRect:(CGRect)rect selectedRow:(int)row withMaxItems:(int)nbItems
{
    self = [super init];
    maxItems = nbItems;
    popoverWidth = POPOVER_WIDTH;
    popoverHeight = POPOVER_LINE_HEIGHT;
    
    comboItems = elementList;
    [self selectRow:row];
    popoverController = [[UIPopoverController alloc]initWithContentViewController:self];
    [popoverController presentPopoverFromRect:rect inView:cmbView permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int count = [self.comboItems count];
    if(count>maxItems)
        count = maxItems;
    
    [self adjustPopoverWidth];

    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, count*popoverHeight);
    
    UITableView *tableView = (UITableView *)self.view;
    
    [tableView setRowHeight:popoverHeight];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.comboItems = nil;
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

#pragma mark - Table view data source

-(void)selectRow:(int)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection: 0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.comboItems count];
}
-(UIFont *)getCellFont
{
    UIFont *font = [UIFont systemFontOfSize:17.0];
    
    return font;
}
//
// Update the text for the cell
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LookupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [self getCellFont];
    }
    
    NSObject *obj = [comboItems objectAtIndex: [indexPath row]];
    
    // Support the different types of list
    if([obj isKindOfClass:[LUItems2 class]])
    {
        LUItems2 *luItems2 = (LUItems2 *)obj;
        cell.textLabel.text = luItems2.LUItemShortDesc;
    }
    else if([obj isKindOfClass:[NSString class]])
    {
        cell.textLabel.text = (NSString *)obj;
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 10);
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *item = [comboItems objectAtIndex:[indexPath row]];
    
    // Now close it
    if(self.popoverController!=nil)
        [self.popoverController dismissPopoverAnimated:TRUE];
    self.popoverController = nil;

    [self.delegate popoverItemSelected:item index:[indexPath row]];
}


-(void) adjustPopoverWidth
{
    // Calculate the expected size based on the font and linebreak mode of your label
    
    popoverWidth = 10;
    
    UIFont *font = [self getCellFont];
    CGSize maximumLabelSize = CGSizeMake(POPOVER_WIDTH-24,10000);  
    CGSize expectedLabelSize;
    
    for(NSObject *obj in comboItems)
    {
        NSString *str;
        if([obj isKindOfClass:[LUItems2 class]])
        {
            LUItems2 *luItems2 = (LUItems2 *)obj;
            str = luItems2.LUItemShortDesc;
        }
        else if([obj isKindOfClass:[NSString class]])
        {
            str = (NSString *)obj;
        }
        expectedLabelSize = [str sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:0];
        if(expectedLabelSize.width > popoverWidth)
            popoverWidth = expectedLabelSize.width;
    }
    if(popoverWidth > 500)
        popoverWidth = 500;
    popoverWidth += 22;     // Border from the popover

}



@end
