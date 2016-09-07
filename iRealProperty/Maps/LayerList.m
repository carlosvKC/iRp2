#import "LayerList.h"
#import "ArcGisViewController.h"
#import "LayerCell.h"
#import "LayerInfo.h"
#import "LayerDisplayConfController.h"
#import "BaseShapeCustomLayer.h"
#import "AxDataManager.h"
#import "RealPropertyApp.h"
#import "MapLayerConfig.h"
#import "ItemDefinition.h"
#import "Helper.h"

@interface LayerList (private)
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation LayerList
@synthesize mapController;
@synthesize tvList;
@synthesize fileList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
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
    // data is from LayerCell.xib
    int count = [fileList count];
    int maxCount;
    if([Helper isDeviceInLandscape])
        maxCount = 10;
    else
        maxCount = 14;
    if(count>maxCount)
        count = maxCount;

    int height = 59*count;
    
    self.contentSizeForViewInPopover = CGSizeMake(350, height);
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
#pragma mark - table view
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileList count];
}
-(void)toggleLayerVisibility: (int)row
{
    LayerInfo* layer = [fileList objectAtIndex:row];
    if (!layer.isLoaded)
        [mapController openLayerFile:layer];
    else 
    {
        if (layer.isVisible)
            [mapController hideLayer:layer];
        else
            [mapController showLayer:layer];
    }
    [tvList reloadData];
    [mapController layerConfigDone];
}

-(void)visibleSwitchValueChanged:(id)sender
{
    [self toggleLayerVisibility:[(UISwitch*)sender tag]];
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LayerCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LayerCell-IPad" owner:self options:nil];
        for (id currentObject in topLevelObjects)
		{
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (UITableViewCell *) currentObject; //Get the cell with the custom UI cell information
				break;
			}
		}
        [((LayerCell*)cell).visibleSwitch addTarget:self action:@selector(visibleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];

    }
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LayerCell *layercell = (LayerCell*) cell;
    layercell.itsDelegate = self;
    LayerInfo *file = [fileList objectAtIndex:indexPath.row];
    
    // Get the configuration
    MapLayerConfig *config = [ArcGisViewController getConfigFromLayerInfo:file];
    if(config.minScale==0)
        layercell.layerFriendlyName.text = config.friendlyName;
    else
        layercell.layerFriendlyName.text = [NSString stringWithFormat:@"%@ (%@k)", config.friendlyName, [ItemDefinition formatNumber:config.minScale/1000]];
    if(config==nil)
        layercell.layerFriendlyName.text = [NSString stringWithFormat:@"%@ (undefined)", file.tableName];
    
    if(config.isSID)
        layercell.symbolView.image = [UIImage imageNamed:@"plane-2.png"];
    else
    {
        if(config.isPolygon)
            layercell.symbolView.image = [((BaseShapeCustomLayer*)file.mapLayer).renderSymbol swatchForGeometryType:AGSGeometryTypePolygon size:layercell.symbolView.frame.size];
        else
            layercell.symbolView.image = [((BaseShapeCustomLayer*)file.mapLayer).renderSymbol swatchForGeometryType:AGSGeometryTypePolyline size:layercell.symbolView.frame.size];
    }

    layercell.visibleSwitch.tag = [indexPath row];
    [layercell.visibleSwitch setOn:config.isVisible animated:NO];
    
    if(config.isVisible && !config.isSID)
        layercell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;   
    else
        layercell.accessoryType = UITableViewCellAccessoryNone;        

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // when indexPath is null, the user has actually changed the toggle value
    if(indexPath==nil)
    {
        return;
    }
    
    LayerInfo* file = [fileList objectAtIndex:indexPath.row];  

    if (!file.isLoaded) 
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Layer Config" message:@"The layer must be loaded before you can change the display settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
        LayerDisplayConfController* confScreen = [[LayerDisplayConfController alloc] initWithNibName:@"LayerDisplayConfController" bundle:[NSBundle mainBundle]];
        
        MapLayerConfig *config = [ArcGisViewController getConfigFromLayerInfo:file];
        confScreen.targetLayer = file.mapLayer;
        confScreen.layerInfo = file;
        confScreen.title = config.friendlyName;
        confScreen.mapController = mapController;
        confScreen.mapView = mapController.mapView;
        confScreen.layerListController = self;
        confScreen.layerConfig = config;
        [self.navigationController pushViewController:confScreen animated:YES];
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(IBAction) Cancel
{
    [mapController layerConfigDone];
}

@end
