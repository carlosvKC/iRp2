
#import "TabSearchTable.h"
#import "TabSearchController.h"

@implementation TabSearchTable

@synthesize itsController;

-(id)initWithNibNameAndSearch:(NSString *)nibNameOrNil searchBase:(SearchBase *)searchBaseParam
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if(self)
    {
        searchBase = searchBaseParam;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [searchBase.searchGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    SearchGroup *searchGroup = [searchBase.searchGroups objectAtIndex:section];
    
    return [searchGroup.searchDefinitions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    SearchGroup *searchGroup = [searchBase.searchGroups objectAtIndex:[indexPath section]];
    SearchDefinition2 *searchDefinition= [searchGroup.searchDefinitions objectAtIndex:[indexPath row]];
    cell.textLabel.text = searchDefinition.title;
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SearchGroup *searchGroup = [searchBase.searchGroups objectAtIndex:section];
    return searchGroup.title;
}

#pragma mark - Table view delegate
// A selection occured
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchGroup *searchGroup = [searchBase.searchGroups objectAtIndex:[indexPath section]];
    SearchDefinition2 *searchDefinition= [searchGroup.searchDefinitions objectAtIndex:[indexPath row]];
    
    [itsController tableSelection:searchDefinition];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
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
