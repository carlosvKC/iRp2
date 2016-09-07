#import "TableListController.h"
#import "StreetController.h"

@implementation TableSectionInfo

@synthesize firstEntry;
@synthesize count;
@synthesize label;

@end

@implementation TableListController

@synthesize dataList;
@synthesize streetController;
@synthesize useIndex;
@synthesize filter;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   // self.clearsSelectionOnViewWillAppear = NO;
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

#pragma mark - Table view data source
-(void)prepareIndex
{
    if(tableSections!=nil)
    {
        [tableSections removeAllObjects];
        tableSections = nil;
    }
    tableSections = [[NSMutableArray alloc]init];
    
    TableSectionInfo *sectionInfo = nil;
    NSString *letter = @"**";
    int startLine = 0;
    for(NSString *str in dataList)
    {
        if(startLine==0)
        {
            startLine = 1;
            continue;
        }
        const char *ptrLetter = [letter UTF8String];
        const char *ptrStr = [str UTF8String];
        startLine++;
        if(*ptrLetter == *ptrStr)
        {
            continue;
        }
        // Save previous entry
        if(sectionInfo!=nil)
        {
            sectionInfo.count = startLine - sectionInfo.firstEntry;
            [tableSections addObject:sectionInfo];
        }
        sectionInfo = [[TableSectionInfo alloc]init];
        letter = str;
        sectionInfo.label = str;
        sectionInfo.firstEntry = startLine;
        sectionInfo.count = 0;
    }
    if(sectionInfo!=0)
    {
        sectionInfo.count = startLine - sectionInfo.firstEntry;
        [tableSections addObject:sectionInfo];
    }

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(useIndex)
        return [tableSections count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(useIndex)
    {
        TableSectionInfo *info = [tableSections objectAtIndex:section];
        return info.count;
    }
    else
        return [dataList count];
}
-(BOOL)isTextFiltered:(NSString *)string
{
    if(filter==nil)
        return NO;
    for(NSString *str in filter)
    {
        NSRange range =[str rangeOfString:string];
        if(range.length >0)
            return YES;
    }
    return NO;
}
// Draw the cell
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    }
    // Configure the cell...
    if(useIndex)
    {
        TableSectionInfo *info = [tableSections objectAtIndex:[indexPath section]];
        int index = info.firstEntry + [indexPath row] -1;
        cell.textLabel.text = [dataList objectAtIndex:index];
    }
    else
        cell.textLabel.text = [dataList objectAtIndex:[indexPath row]];
    if([self isTextFiltered:cell.textLabel.text])
        cell.textLabel.textColor = [UIColor lightGrayColor];
    else
        cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(useIndex)
    {
        TableSectionInfo *info = [tableSections objectAtIndex:section];
        NSString *str = [info.label substringToIndex:1];
        return str;
    }
    else
        return nil;
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(useIndex)
    {
        NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:[tableSections count]];
        for(TableSectionInfo *info in tableSections)
        {
            NSString *str = [info.label substringToIndex:1];
            [array addObject:str];
        }
        return  array;
    }
    else
        return nil;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreetController *controller = (StreetController *)streetController;
    if(useIndex)
    {
        TableSectionInfo *info = [tableSections objectAtIndex:[indexPath section]];
        int index = info.firstEntry + [indexPath row] -1;
        [controller setTableSelection:tableView string:[dataList objectAtIndex:index]];
    }
    else
        [controller setTableSelection:tableView string:[dataList objectAtIndex:[indexPath row]]];
}

@end
