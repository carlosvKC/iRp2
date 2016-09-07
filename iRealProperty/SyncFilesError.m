

#import "SyncFilesError.h"
#import "AxDataManager.h"
#import "SyncValidationError.h"
#import "Helper.h"

@interface SyncFilesError ()
{
    NSMutableArray *errorList;
}


@end

@implementation SyncFilesError

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    errorList = [AxDataManager dataListEntity:@"SyncValidationError" andPredicate:nil andSortBy:@"entityKind" sortAscending:YES withContext:[AxDataManager configContext]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    errorList = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return errorList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellSyncValidationError";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    SyncValidationError *error = [errorList objectAtIndex:[indexPath row]];
    NSString *errorDate = [Helper stringFromTimeInterval:error.date];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", errorDate, error.errorMsg];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    
    if([error.entityKind length]>0 && [error.entityGuid length]>0)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    SyncValidationError *error = [errorList objectAtIndex:[indexPath row]];
    [delegate syncValidationOpenObject:error];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
@end
