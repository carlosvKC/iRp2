#import "SyncEntityList.h"
#import "SyncEntityCell.h"

@implementation SyncEntityList

#pragma mark - View life cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil withEntities:(NSMutableArray *)syncEntityList
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) 
    {
        _syncEntityList = syncEntityList;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return [_syncEntityList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SyncEntityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[SyncEntityCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        /*
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionCellTabBar" owner:self options:nil];
        OptionCellTabBar *cell;
        for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
				cell = (OptionCellTabBar *) currentObject; //Get the cell with the custom UI cell information
				break;
			}
		}
        UISwitch *btnSwitch = ((OptionCellTabBar*)cell).btnToggle;
        [btnSwitch addTarget:self action:@selector(switchEffects:) forControlEvents:UIControlEventValueChanged];
        cell.label.text = option.label;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        Configuration *config = [RealPropertyApp getConfiguration];
        [btnSwitch setOn:config.useEffects];
        return cell;
         */
    } 
    return cell;
}

@end
