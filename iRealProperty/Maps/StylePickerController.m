#import "StylePickerController.h"
#import <ArcGIS/ArcGIS.h>

@implementation StylePickerController
// Under @implementation
@synthesize styleList = _styleList;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)dealloc
{
    self.delegate = nil;
    
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.styleList = [NSMutableArray array];
    [_styleList addObject:@"BackwardDiagonal"];
    [_styleList addObject:@"ForwardDiagonal"];
    [_styleList addObject:@"Cross"];
    [_styleList addObject:@"DiagonalCross"];
    [_styleList addObject:@"Solid"];
    [_styleList addObject:@"None"];
    
    self.contentSizeForViewInPopover = CGSizeMake(220, 200.0);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_styleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *style = [_styleList objectAtIndex:indexPath.row];
    cell.textLabel.text = style;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (_delegate != nil) {
         NSString *style = [_styleList objectAtIndex:indexPath.row];
        if ([style compare:@"BackwardDiagonal" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            [_delegate styleSelected:style withID:AGSSimpleFillSymbolStyleBackwardDiagonal];
        }
        else if ([style compare:@"ForwardDiagonal" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            [_delegate styleSelected:style withID:AGSSimpleFillSymbolStyleForwardDiagonal];
        }
        else if ([style compare:@"Cross" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            [_delegate styleSelected:style withID:AGSSimpleFillSymbolStyleCross];
        }
        else if ([style compare:@"DiagonalCross" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            [_delegate styleSelected:style withID:AGSSimpleFillSymbolStyleDiagonalCross];
        }
        else if ([style compare:@"Solid" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            [_delegate styleSelected:style withID:AGSSimpleFillSymbolStyleSolid];
        }
        else {
             [_delegate styleSelected:style withID:AGSSimpleFillSymbolStyleNull];
        }
        
    }
}

@end
