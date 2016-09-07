#import "TabMyDayController.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "ColorPicker.h"
#import "PieValues.h"

@implementation TabMyDayController
@synthesize pieSaleVerification;
@synthesize piePhysicalInspection;
@synthesize pieMaintIncomplete;
@synthesize pieMaintComplete;
@synthesize pieValues;
@synthesize labelUserName;

NSString *pVerifiedSaleCount = @"Verified Sales Count";
NSString *pUnverifiedSaleCount = @"Unverified Sales Count";
NSString *pNeedInspections = @"Need Inspections";

NSString *pCompletedLandInspections = @"Completed Land Inspection";
NSString *pCompletedBothInspections = @"Completed Both Inspection";
NSString *pCompletedImpInspections = @"Completed Imps Inspection";
NSString *pNeedsInspection = @"Needs Inspection";

NSString *pImcompleteHousePermits = @"Incomplete New House Permits";
NSString *pCompleteHousePermits = @"Complete New House Permits";

NSString *pImcompleteRemodelPermits = @"Incomplete Remodel Permits";
NSString *pCompleteRemodelPermits = @"Complete Remodel Permits";
NSString *pImcompleteSegregations = @"Incomplete Segregations/New Plats";
NSString *pImcompleteOther = @"Incomplete Other Maintenance";

NSString *pCompleteSegregation = @"Complete Segregations New Plats";
NSString *pCompleteOther = @"Complete Other Maintenance";
NSString *pTotalCount = @"User Total Count";

NSString *pIncomplete = @"Incomplete";
NSString *pComplete = @"Complete";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Status";
        self.tabBarItem.image = [UIImage imageNamed:@"ChartPie.png"];
        queue = [[NSOperationQueue alloc]init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)storePieValue:(NSString *)key
{
    for(PieValues *value in pieArray)
    {
        if([value.keyName caseInsensitiveCompare:key])
        {
            [pieValues setValue:[NSNumber numberWithInt:value.value] forKey:key];
            return;
        }
    }
    [pieValues setValue:[NSNumber numberWithInt:0] forKey:key];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area=%@", [RealPropertyApp getWorkingArea]];
    pieArray = [AxDataManager dataListEntity:@"PieValues" andPredicate:predicate andSortBy:@"area" sortAscending:YES withContext:[AxDataManager configContext]];
    
    // Setup default value to allow basic drawing
    
    if(pieValues == nil)
        pieValues = [[NSMutableDictionary alloc]init];
    
    [self storePieValue:pVerifiedSaleCount];
    [self storePieValue:pUnverifiedSaleCount];
    [self storePieValue:pNeedInspections];
    [self storePieValue:pCompletedLandInspections];
    [self storePieValue:pCompletedBothInspections];
    [self storePieValue:pCompletedImpInspections];
    [self storePieValue:pNeedInspections];
    
    [self storePieValue:pImcompleteRemodelPermits];
    [self storePieValue:pImcompleteSegregations];
    [self storePieValue:pImcompleteOther];
    [self storePieValue:pImcompleteHousePermits];

    [self storePieValue:pCompleteHousePermits];
    [self storePieValue:pCompleteRemodelPermits];
    [self storePieValue:pCompleteSegregation];
    [self storePieValue:pCompleteOther];
    
    [self storePieValue:pTotalCount];

    //    [pieValues setValue:[NSNumber numberWithInt:0] forKey:pComplete];
    //[pieValues setValue:[NSNumber numberWithInt:0] forKey:pIncomplete];
    
    [self didRotateFromInterfaceOrientation:[Helper deviceOrientation]];
    
    UIView *view = [self.view viewWithTag:1010];
    if(view==nil)
    {
        NSLog(@"MenuBar: can't find the view with tag 1010");
        return;
    }
    menuBar = [[ControlBar alloc]initWithNibName:@"TabMyDayControlBar" bundle:nil];
    [view addSubview:menuBar.view];
    [self addChildViewController:menuBar];

}

- (void)viewDidUnload
{
    [self setPieSaleVerification:nil];
    [self setPiePhysicalInspection:nil];
    [self setPieMaintIncomplete:nil];
    [self setPieMaintComplete:nil];
    [self setLabelUserName:nil];
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
-(void)drawPieChart:(BOOL)portrait
{
    labelUserName.text = @"Updating...";

    NSError *err;
    NSString *xib;
    if(portrait)
        xib = @"PieChartControlViewPortrait";
    else
        xib = @"PieChartControlViewLandscape";
    
    // Remove all existing one
    [pieView removeFromSuperview];
    [pieView2 removeFromSuperview];
    [pieView3 removeFromSuperview];
    [barView removeFromSuperview];
    
    pieView = [[[NSBundle mainBundle] loadNibNamed:xib owner:self options:nil] objectAtIndex:0];
    pieView.frame = CGRectMake(0, 0, pieSaleVerification.frame.size.width, pieSaleVerification.frame.size.height);
    [pieSaleVerification addSubview:pieView];
    NSMutableArray *paramArray = [[NSMutableArray alloc]init];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pVerifiedSaleCount Value:[[pieValues valueForKey:pVerifiedSaleCount]intValue] andColor:[UIColor greenColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pUnverifiedSaleCount Value:[[pieValues valueForKey:pUnverifiedSaleCount]intValue] andColor:[UIColor orangeColor]]];
    [pieView drawPieCharWithTitle:@"Sales Verification" andParameters:paramArray error:&err ] ;
    pieSaleVerification.backgroundColor = [UIColor clearColor];
    // Adjust position based on the orientation
    if(portrait)
        pieSaleVerification.frame = CGRectMake(0,156,pieView.frame.size.width,pieView.frame.size.height);
    else
        pieSaleVerification.frame = CGRectMake(20,123,pieView.frame.size.width,pieView.frame.size.height);
    
    
    pieView2 = [[[NSBundle mainBundle] loadNibNamed:xib owner:self options:nil] objectAtIndex:0];
    pieView2.frame = CGRectMake(0, 0, piePhysicalInspection.frame.size.width, piePhysicalInspection.frame.size.height);
    [piePhysicalInspection addSubview:pieView2];
    paramArray = [[NSMutableArray alloc]init];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pCompletedLandInspections 
                                                               Value:[[pieValues valueForKey:pCompletedLandInspections]intValue] andColor:[UIColor blueColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pCompletedImpInspections Value:[[pieValues valueForKey:pCompletedImpInspections]intValue] andColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.3 alpha:1.0]]];
     
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pCompletedBothInspections Value:[[pieValues valueForKey:pCompletedBothInspections]intValue] andColor:[UIColor greenColor]]];
    
    int needsInspection = [[pieValues valueForKey:pNeedInspections]intValue];
    
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pNeedsInspection Value:needsInspection andColor:[UIColor orangeColor]]];
    [pieView2 drawPieCharWithTitle:@"Physical Inspection" andParameters:paramArray error:&err ] ;
    
    
    piePhysicalInspection.backgroundColor = [UIColor clearColor];
    // Adjust position based on the orientation
    if(portrait)
        piePhysicalInspection.frame = CGRectMake(385,156,pieView2.frame.size.width,pieView2.frame.size.height);
    else
        piePhysicalInspection.frame = CGRectMake(518,123,pieView2.frame.size.width,pieView2.frame.size.height);

    
    // Manage the maintenances

    int totalComplete = [[pieValues valueForKey:pCompleteHousePermits]intValue] + [[pieValues valueForKey:pCompleteRemodelPermits]intValue] + [[pieValues valueForKey:pCompleteSegregation]intValue] + [[pieValues valueForKey:pCompleteOther]intValue];
    
    int totalIncomplete = [[pieValues valueForKey:pImcompleteHousePermits]intValue] + [[pieValues valueForKey:pImcompleteRemodelPermits]intValue] + [[pieValues valueForKey:pImcompleteSegregations]intValue] + [[pieValues valueForKey:pImcompleteOther]intValue];
    
    pieView3 = [[[NSBundle mainBundle] loadNibNamed:xib owner:self options:nil] objectAtIndex:0];
    pieView3.frame = CGRectMake(0, 0, pieMaintIncomplete.frame.size.width, pieMaintIncomplete.frame.size.height);
    [pieMaintIncomplete addSubview:pieView3];

    paramArray = [[NSMutableArray alloc]init];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pIncomplete Value:totalIncomplete andColor:[UIColor orangeColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pComplete Value:totalComplete andColor:[UIColor greenColor]]];

    [pieView3 drawPieCharWithTitle:@"Maintenance" andParameters:paramArray error:&err ] ;
    
    pieMaintIncomplete.backgroundColor = [UIColor clearColor];
    // Adjust position based on the orientation
    if(portrait)
        pieMaintIncomplete.frame = CGRectMake(0, 497,pieView3.frame.size.width,pieView3.frame.size.height);
    else
        pieMaintIncomplete.frame = CGRectMake(20, 411,pieView3.frame.size.width,pieView3.frame.size.height);
    
    // ------------- Bar display
    if(portrait)
        barView = [[[NSBundle mainBundle] loadNibNamed:@"BarChartControlViewPortrait" owner:self options:nil] objectAtIndex:0];
    else 
        barView = [[[NSBundle mainBundle] loadNibNamed:@"BarChartControlViewLandscape" owner:self options:nil] objectAtIndex:0];
        
    pieMaintComplete.frame = CGRectMake(0, 0, pieMaintComplete.frame.size.width, pieMaintComplete.frame.size.height);
    [pieMaintComplete addSubview:barView];

    paramArray = [[NSMutableArray alloc]init];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pIncomplete Value:[[pieValues valueForKey:pCompleteHousePermits]intValue] andColor:[UIColor greenColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pComplete Value:[[pieValues valueForKey:pImcompleteHousePermits]intValue] andColor:[UIColor orangeColor]]];
    [self drawBarView:@"New House Permits" tag:11 params:paramArray];
    
    paramArray = [[NSMutableArray alloc]init];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pIncomplete Value:[[pieValues valueForKey:pCompleteRemodelPermits]intValue] andColor:[UIColor greenColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pComplete Value:[[pieValues valueForKey:pImcompleteRemodelPermits]intValue] andColor:[UIColor orangeColor]]];
    [self drawBarView:@"Remodel Permits" tag:13 params:paramArray];

    paramArray = [[NSMutableArray alloc]init];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pIncomplete Value:[[pieValues valueForKey:pCompleteSegregation]intValue] andColor:[UIColor greenColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pComplete Value:[[pieValues valueForKey:pImcompleteSegregations]intValue] andColor:[UIColor orangeColor]]];
    [self drawBarView:@"Segregations & New Plats" tag:15 params:paramArray];

    int val1 = [[pieValues valueForKey:pCompleteOther]intValue];
    paramArray = [[NSMutableArray alloc]init];
    int val2 = [[pieValues valueForKey:pImcompleteOther]intValue] ;
    paramArray = [[NSMutableArray alloc]init];    [paramArray addObject:[self createNewPieChartParameterWithLegend:pIncomplete Value:val1 andColor:[UIColor greenColor]]];
    [paramArray addObject:[self createNewPieChartParameterWithLegend:pComplete Value:val2 andColor:[UIColor orangeColor]]];
    [self drawBarView:@"Other Maintenance" tag:17 params:paramArray];

    
    if(portrait)
        pieMaintComplete.frame = CGRectMake(385, 497, pieMaintComplete.frame.size.width, pieMaintComplete.frame.size.height);
    else
        pieMaintComplete.frame = CGRectMake(518, 411, pieMaintComplete.frame.size.width, pieMaintComplete.frame.size.height);
    pieMaintComplete.backgroundColor = [UIColor clearColor];

    labelUserName.text = [NSString stringWithFormat:@"You are logged as '%@' - %d total properties", [RealPropertyApp getUserName], [[pieValues valueForKey:pTotalCount] intValue]];
}

-(ChartParameter *)createNewPieChartParameterWithLegend:(NSString *) legend Value:(float)value andColor:(UIColor *)color
{
    ChartParameter *param = [[ChartParameter alloc]init];
    param.color = color;
    param.value = value;
    param.legendText = legend;
    return  param;
}
//
// Execute All the queries
//
-(void)executeAllQueries
{
    if([RealPropertyApp queryReady])
        return;
    [RealPropertyApp setQueryReady:YES];

    NSString *dbName = [self getDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbName];
    
    if (![db open]) 
    {
        NSLog(@"Could not open '%@'", dbName);
        return;
    }
    NSArray *keys = [pieValues allKeys];
    for(NSString *str in keys)
    {
        NSString *query = [self retrieveQuery:str];
        FMResultSet *rs = [db executeQuery:query];
        int res = 0;
        if(![db hadError])
        {
            [rs next];
            if(![rs columnIndexIsNull:0])
                res = [[rs objectForColumnIndex:0]intValue];
            [rs close];
        }
        [pieValues setValue:[NSNumber numberWithInt:res] forKey:str];
    }
    [db close];
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self drawPieChart:![Helper isDeviceInLandscape]];
    }];
    [RealPropertyApp setQueryReady:NO];
}
-(NSString *)getDatabaseName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    
    NSString *fileName = [docsDir stringByAppendingPathComponent:[AxDataManager permanentStoreName:@"default"]];
    
    return fileName;
}

//
// Return the queries pre-populated
//
-(NSString *)retrieveQuery:(NSString *)queryName
{
    NSString *query = [Helper getEntryFromProperties:queryName];
    
    if(query==nil)
    {
        NSLog(@"Can't find query '%@'", queryName);
        return nil;
    }
    // 3/1/13 HNN inspection is by assmtyr not taxyr
    NSString *startYear = [NSString stringWithFormat:@"%d",[RealPropertyApp taxYear]-1];
    NSString *userName =  [NSString stringWithFormat:@"'%@'", [RealPropertyApp getUserName]];
    NSString *saleDate = [NSString stringWithFormat:@"%lf",[[Helper dateFromString:[RealPropertyApp saleStartDate] ] timeIntervalSinceReferenceDate]];
    NSString *verifDate = [NSString stringWithFormat:@"%lf",[[Helper dateFromString:[RealPropertyApp cycleStartDate]] timeIntervalSinceReferenceDate]];
    NSString *startTime = [NSString stringWithFormat:@"%lf",[[Helper dateFromString:[RealPropertyApp cycleStartDate]] timeIntervalSinceReferenceDate]];
    

    query = [query stringByReplacingOccurrencesOfString:@"$YEAR" withString:startYear];
    query = [query stringByReplacingOccurrencesOfString:@"$SALEDATE" withString:saleDate];
    query = [query stringByReplacingOccurrencesOfString:@"$VERIFDATE" withString:verifDate];
    query = [query stringByReplacingOccurrencesOfString:@"$USER" withString:userName];
    query = [query stringByReplacingOccurrencesOfString:@"$STARTTIME" withString:startTime];
    return query;
}

#pragma mark - handle rotation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(![Helper isDeviceInLandscape])
    {
        labelUserName.frame = CGRectMake(0,62,768,33);
        UIView *view = [self.view viewWithTag:2000];
        view.frame = CGRectMake(0,0,768,view.frame.size.height);
        view = [self.view viewWithTag:1010];
        view.frame = CGRectMake(0,0,768,44);
        menuBar.view.frame = view.frame;
    }
    else
    {
        labelUserName.frame = CGRectMake(128,52,768,33);
        UIView *view = [self.view viewWithTag:2000];
        view.frame = CGRectMake(0,0,1024,view.frame.size.height);
        view = [self.view viewWithTag:1010];
        view.frame = CGRectMake(0,0,1024,44);
        menuBar.view.frame = view.frame;
    }
    [self drawPieChart:![Helper isDeviceInLandscape]];
}
-(void)activateController
{
    labelUserName.text = @"Updating...";

    [queue addOperationWithBlock:^{
        [self executeAllQueries];
    }];
    [self didRotateFromInterfaceOrientation:[Helper deviceOrientation]];
    
    [menuBar setItemTitle:100 title:[NSString stringWithFormat:@"Welcome to %@", [RealPropertyApp getWorkingArea]]];
}
#pragma mark - manage the bar items
-(ChartItemColor)getChartItemColorFromUIColor:(UIColor *)color
{
    ChartItemColor resultItemColor;
    
    const CGFloat *c = CGColorGetComponents(color.CGColor);
    resultItemColor.red = c[0];
    resultItemColor.green = c[1];
    resultItemColor.blue = c[2];
    resultItemColor.alpha = c[CGColorGetNumberOfComponents(color.CGColor)-1]; 
    return resultItemColor;
}
//[self drawBarView:@"Title" tag:11 parameters:paramArray];
-(void)drawBarView:(NSString *)title tag:(int)tag params:(NSArray *)array
{
    BarChartView *barChartRender = (BarChartView *)[barView viewWithTag:tag];
    
    UILabel *label = (UILabel *)[barView viewWithTag:tag+1];
    label.text = title;
    for(ChartParameter *param in array)
    {
        // NSLog(@"tag=%d value=%f c=%@", tag, param.value, [param.color stringFromColor]);

        ChartItemColor pieceColor = [self getChartItemColorFromUIColor:param.color ];
        [barChartRender addItemValue:param.value withColor:pieceColor];
    }
}


@end
