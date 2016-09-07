
#import "DVLayerList.h"

@implementation DVDashView

@synthesize dvLayer = _dvLayer;

-(void)drawRect:(CGRect)rect
{
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    // Clean up background
    CGContextSetFillColor(gc, CGColorGetComponents([[UIColor clearColor] CGColor]));
    CGContextFillRect(gc, rect);
    
    CGContextSetStrokeColorWithColor(gc, [_dvLayer.color CGColor]);
    CGContextSetLineWidth(gc, _dvLayer.width);    
    
    CGContextSetLineDash(gc, 0, _dvLayer.dash, _dvLayer.dashCount);

    CGContextMoveToPoint(gc, 0, rect.size.height/2);
    CGContextAddLineToPoint(gc, rect.size.width, rect.size.height/2);
    CGContextStrokePath(gc);
    CGContextSetLineDash(gc, 0, 0, 0);
}
-(void)dealloc
{
    _dvLayer = nil;
    self.dvLayer = nil;
}
@end

@implementation DVLayerList


@synthesize layerList;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [layerList count]-1;
}
-(void)setLayerList:(NSArray *)list
{
    layerList = list;
    [self.tableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DVLayerListCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DVLayerCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
				cell = (UITableViewCell *) currentObject;
				break;
			}
		}
    }
    // Configure the cell.
    [self configureCell:(DVLayerCell *)cell row:[indexPath row]];
    return cell;
}
-(void)configureCell:(DVLayerCell *)cell row:(int)row
{
    if(row>=[layerList count])
        return;
    DVLayer *layer = [layerList objectAtIndex:row+1];
    [cell.visibleSwitch addTarget:self action:@selector(visibleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.visibleSwitch.tag = 100+row;   // to track which button is visible to not visible...
    [cell.visibleSwitch setOn:!layer.hidden animated:NO];
    cell.layerName.text = layer.name;
    
    // Need to draw if it is selected or not...
    cell.lineView.dvLayer = layer;
    if(layer.isDefault)
        cell.layerSelected.image = [UIImage imageNamed:@"check 40x40.png"];
    else
        cell.layerSelected.image = nil;
    cell.lineView.tag = 100+row;
    [cell.lineView addTarget:self action:@selector(selectRow:) forControlEvents:UIControlEventTouchDown];
}
-(void)visibleSwitchValueChanged:(UISwitch *)sender
{
    int row = sender.tag - 100;
    DVLayer *layer = [layerList objectAtIndex:row+1];
    layer.hidden = !sender.on;
    
    [delegate dvLayerListRefresh];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectLayerRow:indexPath.row];
}
-(void)selectRow:(id)sender
{
    DVDashView *view = sender;
    int row = view.tag-100;
    [self selectLayerRow:row];
}
-(void)selectLayerRow:(int)row
{
    DVLayer *layer = [layerList objectAtIndex:row+1];
    
    for(DVLayer *l in layerList)
        l.isDefault = NO;
    layer.isDefault = YES;
    
    [delegate dvLayerListDefault:layer];
}
-(void)dealloc
{
    self.layerList = nil;
    self.delegate = nil;
}
@end
