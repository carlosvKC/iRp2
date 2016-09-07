#import "ParcelSearch.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "TabSearchController.h"
#import "SearchDefinition2.h"
#import "RealPropertyApp.h"
#import "SelectedObject.h"
#import "RealProperty.h"

@implementation ParcelSearch

@synthesize itsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)setSearchDefinition:(SearchDefinition2 *)definition
{
    searchDefinition = definition;
}
#pragma mark - TextField delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.length==1)
        return YES;
    NSString *allowedChars = @"0123456789-";
    
    // Now it is one of the field that we control...
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:allowedChars] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
}

-(void)textFieldDone:(id)sender
{
	[sender resignFirstResponder];
}
//
// Hide the keyboard when finding the background view
//
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	int backgroundTag = 1000;
    if(self.view.tag==backgroundTag)
    {
        [self.view endEditing:YES];
        return;
    }
    // Enumerate through all the touch objects.
    for (UITouch *touch in touches) 
    {
        for (UIView *aView in [self.view subviews]) 
        {
            if (CGRectContainsPoint([aView frame], [touch locationInView:self.view]) && aView.tag==backgroundTag)
            {
                [aView endEditing:YES];
                return;
            }
        }
    }	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Update colors
    [self.view setBackgroundColor:[Helper UIColorFromRGB255:223 green:226 blue:231]];
    UILabel *label = (UILabel *)[self.view viewWithTag:98];
    label.textColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
    label = (UILabel *)[self.view viewWithTag:99];
    label.textColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
    
    
    // Update each button
    for(int i=10;;i++)
    {
        UIView *view = [self.view viewWithTag:i];
        if(view==nil)
            break;
        UITextField *textField = (UITextField *)view;
		//[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEnd];
		textField.delegate = self;
        textField.text = @"";
        textField.placeholder = @"major-minor";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    UIView *view = [self.view viewWithTag:5];
    [view removeFromSuperview];
    
	UIImage *blueButtonImage = [UIImage imageNamed:@"btnBlue38.png"];
	UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
	btnSearch.frame = view.frame;
	UIImage *strechable = [blueButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
	[btnSearch setBackgroundImage:strechable forState:UIControlStateNormal];
	[btnSearch setTitle:@"Search Parcel" forState:UIControlStateNormal];
	
	btnSearch.titleLabel.textColor = [UIColor whiteColor];
	
	[btnSearch addTarget:self action:@selector(performSearch:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnSearch];
    
    view = [self.view viewWithTag:6];
    [view removeFromSuperview];
    UIButton *btnSearches = [UIButton buttonWithType:UIButtonTypeCustom];
	btnSearches.frame = view.frame;
	[btnSearches setBackgroundImage:strechable forState:UIControlStateNormal];
	[btnSearches setTitle:@"Search Parcels" forState:UIControlStateNormal];
	
	btnSearches.titleLabel.textColor = [UIColor whiteColor];
	
	[btnSearches addTarget:self action:@selector(performSearches:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnSearches];

}
#pragma mark - Perform the search
-(NSString *)sanitize:(NSString *)parcel
{
    NSString *clean = [parcel stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if([clean length]!=10)
    {
        NSString *msg = [NSString stringWithFormat:@"The parcel number that you entered ('%@') does not have 10 digits", parcel];
        [Helper alertWithOk:@"Wrong Parcel" message:msg];
        return nil;
    }
    return clean;
}
//
// Perform a single search
//3
-(void)performSearch:(id)sender
{
    [Helper findAndResignFirstResponder:self.view];
    // Search for one item only
    UIView *view = [self.view viewWithTag:10];
    if(view==nil)
        return;
    UITextField *textField = (UITextField *)view;
    NSString *clean = [self sanitize:textField.text];
    if([clean length]==0)
        return;
    // Perform the search
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parcelNbr==%@",clean];
    RealPropInfo *propInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
    if(propInfo==nil)
    {
        NSString *msg = [NSString stringWithFormat:@"The parcel number that you entered ('%@') cannot be found.", textField.text];
        [Helper alertWithOk:@"Error" message:msg];
        return;
    }
    //    int realPropId = propInfo.realPropId;
    //    NSNumber *number = [[NSNumber alloc]initWithInt:realPropId];
    NSString *rpGuid = propInfo.guid;
    SelectedProperties *selectProperties = [[SelectedProperties alloc]initWithRealPropInfo:propInfo];
    [RealProperty setSelectedProperties:selectProperties];    
    //    [itsController switchToParcel:number];
    [itsController switchToParcel:rpGuid];
}
// Perform a multiple search
-(void)performSearches:(id)sender
{
    [Helper findAndResignFirstResponder:self.view];

    NSMutableArray *array = [[NSMutableArray alloc]init]; 
    for(int index=11;;index++)
    {
        // Look at all the textfields
        UIView *view = [self.view viewWithTag:index];
        if(view==nil)
            break;
        if(![view isKindOfClass:[UITextField class]])
        {
            NSLog(@"Wrong class!!!");
            continue;
        }
        UITextField *textField = (UITextField *)view;
        if([textField.text length]==0)
            continue;
        NSString *clean = [self sanitize:textField.text];
        if(clean==nil)  // Need to wait for the user to clean the staff
        {
            [array removeAllObjects];
            array = nil;
            return;
        }
        [array addObject:clean];
    }
    @try 
    {
        if([array count]==0)
        {
            [Helper alertWithOk:@"No data" message:@"You need at least one parcel number!"];
            return;
        }
        // Create a predicate
        QueryDefinition *query = searchDefinition.query;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[ItemDefinition replaceDateFilter:query.query], array];
        query.predicate = predicate;
        
        NSArray *array = [AxDataManager dataListEntity:query.entityName andSortBy:query.entitySortBy andPredicate:predicate];
        
        
        if([array count]==0)
        {
            [Helper alertWithOk:@"No parcel found!" message:@"Verify that you have entered valid parcel numbers"];
            return;
        }
        else if([array count]==1)
        {

            RealPropInfo *propInfo = (RealPropInfo *)[array objectAtIndex:0];
            SelectedProperties *selectProperties = [[SelectedProperties alloc]initWithRealPropInfo:propInfo];
            [RealProperty setSelectedProperties:selectProperties];
            [itsController switchToParcel:[NSNumber numberWithInt:propInfo.realPropId]];  
            itsController.autoSearch = NO;
            return;
        }
        // Case where there are a couple of parcels

        [itsController switchToGridWithArray];
        itsController.autoSearch = NO;

    }
    @catch (NSException *exception) 
    {
        NSLog(@"%@", exception);
        [Helper alertWithOk:@"1) Query Error" message:[exception description]];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deregisterFromKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)setItsController:(TabSearchController *)ctrl
{
    itsController = ctrl;
    [self registerForKeyboardNotifications:ctrl withDelta:0];
}
@end
