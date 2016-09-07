#import "MapLegend.h"
#import "RendererXmlBreaker.h"
#import "Helper.h"

// private object to store legend items info
@interface LegendItem : NSObject 
{
@public
    NSString* label;
    UIImage* image;
}
@end

@implementation LegendItem
@end

// implements map legend
@implementation MapLegend

@synthesize closeButton;
@synthesize legendTitle;
@synthesize tv;
@synthesize renderer = _renderer;
@synthesize tobBar;
@synthesize delegate = _delegate;


-(void) loadLegendItems
{
    [_legendItems removeAllObjects];
    
    if([_renderer isKindOfClass:[UniqueValueRenderer class]])
    {
        UniqueValueRenderer *renderer = (UniqueValueRenderer*)self.renderer;
        for(Renderer *classBreak in renderer.renderers)
        {
            LegendItem* item = [[LegendItem alloc] init];
            item->label = classBreak.label;
            item->image = [classBreak.fillSymbol swatchForGeometryType:AGSGeometryTypePolygon size:CGSizeMake(20, 20)];
            [_legendItems addObject:item];            
        }
    }
    [tv reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _legendItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andRenderer: (AGSRenderer*)layerRenderer
{
    self = [self initWithNibName:nibNameOrNil bundle:nil];
    if (self)
    {
        self.renderer = layerRenderer;
        [self loadLegendItems];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tobBar.dragableDelegate = self;
    [self.tv setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
    [self setRenderer:nil];
    [self setLegendTitle: nil];
    [self setTv:nil];
    [self setCloseButton:nil];
    [self setTobBar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint center = [self.view center];
    
    CGRect frame;
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        frame = CGRectMake(0, 0, 768, 1004);
    else
        frame = CGRectMake(0, 0, 1024, 748);
    
    if(center.x < frame.origin.x )
        center.x = frame.origin.x;
    if(center.x > frame.origin.x + frame.size.width)
        center.x = frame.origin.x + frame.size.width;
    
    if(center.y < frame.origin.y )
        center.y = frame.origin.y;
    if(center.y > frame.origin.y + frame.size.height)
        center.y = frame.origin.y + frame.size.height;
    
    [self.view setCenter:center];
}

#pragma mark - UIDragableToolbar
-(void)draggedBy:(CGPoint)delta
{
    [self.view setCenter:CGPointMake(self.view.center.x + delta.x, self.view.center.y + delta.y)];
}

#pragma mark - table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_legendItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.minimumScaleFactor = 14.0/[UIFont labelFontSize];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    // configure cell
    LegendItem* item = [_legendItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item->label;
    cell.imageView.image = item->image;
    cell.imageView.hidden = false;
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - actions

- (IBAction)onClose:(id)sender 
{
    [_delegate mapLegendCloseButtonClick];
}

- (IBAction)onEdit:(id)sender 
{
}
@end
