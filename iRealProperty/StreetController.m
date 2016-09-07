#import "StreetController.h"
#import "TableListController.h"
#import "ComboBoxPopOver.h"


@implementation StreetController

@synthesize streetNameLabel;
@synthesize searchBar;
@synthesize btnStreetSelect;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (id)initWithdViewAndRect:(UIView *)cmbView destRect:(CGRect)rect;
{
    self = [super init];
    popoverController = [[UIPopoverController alloc]initWithContentViewController:self];
    [popoverController presentPopoverFromRect:rect inView:cmbView permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (TableListController *)createListController:(NSString *)tableName :(int)tagId
{
    TableListController *tableListController = [[TableListController alloc]initWithNibName:@"TableListController" bundle:nil];
    tableListController.dataList = [StreetDataModel loadTable:tableName filter:nil];
    UIView *view = [self.view viewWithTag:tagId];
    if(view==nil)
    {
        NSLog(@"Can't find UIView with tag %d", tagId);
        return nil;
    }
    //tableListController.tableView.frame = view.frame;
    [tableListController.tableView setRowHeight:POPOVER_LINE_HEIGHT];
    tableListController.streetController = self;
    [view addSubview:tableListController.tableView];
    [self addChildViewController:tableListController];
    
    return tableListController;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filterType = [[NSMutableArray alloc]init];
    filterSuffix = [[NSMutableArray alloc]init];
    filterPrefix = [[NSMutableArray alloc]init];
    
        
    CGSize size = self.view.frame.size;
    
    self.contentSizeForViewInPopover = CGSizeMake(size.width, size.height);
    // Add the street List controller
    streetListController = [self createListController:@"StreetName" :100];
    prefixListController = [self createListController:@"DirPrefix" :110];
    suffixListController = [self createListController:@"DirSuffix" :130];
    typeListController = [self createListController:@"StreetType" :120];
 
    streetListController.useIndex = YES;
    [streetListController prepareIndex];
    
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    searchBar.delegate = self;
    
    // Default selection value
    streetName = @"";
    streetType = [typeListController.dataList objectAtIndex:0];
    dirPrefix = [prefixListController.dataList objectAtIndex:0];
    dirSuffix = [suffixListController.dataList objectAtIndex:0];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    streetListController.dataList = [StreetDataModel loadTable:@"StreetName" filter:searchText];
    if([searchText length]>0)
        streetListController.useIndex = NO;
    else
    {
        streetListController.useIndex = YES;
        [streetListController prepareIndex];

    }
    [streetListController.tableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    streetListController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(IBAction)selectStreetAction:(id)sender
{
    // Now close it
    if(popoverController!=nil)
        [popoverController dismissPopoverAnimated:TRUE];
    popoverController = nil;
    int streetId = [StreetDataModel getStreetIdWithStreetName:streetName prefix:dirPrefix streetType:streetType postfix:dirSuffix];
    if(streetId!= -1)
    {
        NSNumber *number = [[NSNumber alloc]initWithInt:streetId];
        [delegate popoverItemSelected:number];
    }
    [filterSuffix removeAllObjects];
    [filterPrefix removeAllObjects];
    [filterType removeAllObjects];
}
//
// Update the StreetType, DirPrefix and DirSuffix based on the principal street being selected
//
-(void)updatePrefixes:(NSString *)name
{
    [StreetDataModel getStreetDetails:name type:filterType prefix:filterPrefix suffix:filterSuffix];
    
    prefixListController.filter = filterType;
    [prefixListController.tableView reloadData];
    
    suffixListController.filter = filterSuffix;
    [suffixListController.tableView reloadData];

    [prefixListController.tableView reloadData];
    prefixListController.filter = filterType;
    
}
-(void)setTableSelection:(UITableView *)tableView string:(NSString *)string
{
    // Search for the view...
    if(tableView==streetListController.tableView)
    {
        streetName = string;
        // Reload the 3 other columns filtered
        // Code not working properly [self updatePrefixes:streetName];
    }
    else if(tableView==prefixListController.tableView)
    {
        dirPrefix = string;
    }
    else if(tableView==suffixListController.tableView)
    {
        dirSuffix = string;
    }
    else if(tableView==typeListController.tableView)
    {
        streetType = string;
    }
    int streetId = [StreetDataModel getStreetIdWithStreetName:streetName prefix:dirPrefix streetType:streetType postfix:dirSuffix];
    if(streetId<0)
    {
        streetNameLabel.font = [UIFont italicSystemFontOfSize:16.0];
        streetNameLabel.textColor = [UIColor grayColor];
        streetNameLabel.text = @"selection not valid";
        UIBarButtonItem *btn = (UIBarButtonItem *)[self.view viewWithTag:75];
        btn.enabled = NO;
    }
    else
    {
        streetNameLabel.font = [UIFont systemFontOfSize:16.0];
        streetNameLabel.textColor = [UIColor blackColor];
        UIBarButtonItem *btn = (UIBarButtonItem *)[self.view viewWithTag:75];
        btn.enabled = NO;

        NSString *result = [NSString stringWithFormat:@"%@ %@ %@ %@",
                            [dirPrefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], 
                            [streetName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                            [streetType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                            [dirSuffix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        streetNameLabel.text = result;
    }
}
-(void)adjustHeight:(int)newHeight
{
    [self adjustHeight:streetListController newHeight:newHeight];
    [self adjustHeight:typeListController   newHeight:newHeight];
    [self adjustHeight:suffixListController newHeight:newHeight];
    [self adjustHeight:prefixListController newHeight:newHeight];
}
-(void)adjustHeight:(TableListController *)list newHeight:(int)newHeight
{
    list.view.frame = CGRectMake(list.view.frame.origin.x, list.view.frame.origin.y,
                                 list.view.frame.size.width, newHeight);
}
@end
