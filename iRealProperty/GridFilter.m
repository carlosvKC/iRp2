#import "GridFilter.h"
#import "Helper.h"
#import "ItemDefinition.h"
#import "ComboBoxController.h"

@implementation GridFilterOptions


@synthesize filterValue = _filterValue;
@synthesize filterOperation = _filterOperation;
@synthesize sortOption = _sortOption;
@synthesize columnType = _columnType;
@synthesize columnName = _columnName;
@synthesize columnIndex = _columnIndex;

-(NSString *)description
{
    return [NSString stringWithFormat:@"{ %@\ncolumnName=%@ }", _filterValue, _columnName];
}
@end

//--------------------------------- Grid Filter
@implementation GridFilter

@synthesize uniqueValues;
@synthesize delegate;
@synthesize filterOptions;
@synthesize dropdownButton;
@synthesize gridDelegate;
@synthesize dataField;

#pragma mark - ComboBox delegate
-(void) comboxBoxClicked:(id)comboBox value:(id)value
{
    if(comboBox==cmbActions.view)
    {
        filterOptions.filterOperation = [value intValue];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    filterOptions.filterValue = textField.text;
}
// Call back if the item has been selected
//
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}
// Done button clicked
- (void)dismissView:(id)sender 
{
    // Save the value
    if(filterOptions.columnType==ftText || filterOptions.columnType==ftBool || filterOptions.columnType==ftLookup)
    {
        filterOptions.filterValue = dataField.text;
    }
    else if(filterOptions.columnType==ftDate)
    {
        filterOptions.filterValue = [cmbDate getSelectionDate];
    }
    else
    {
        NSNumber *number = [[NSNumber alloc]initWithInt:[dataField.text intValue]];
        filterOptions.filterValue = number;
    }
    uniqueValues = nil;
    [delegate didDismissModalView:filterOptions saveContent:YES];
}
// Cancel button clicked
- (void)cancelView:(id)sender 
{
    // Call the delegate to dismiss the modal view
    [delegate didDismissModalView:nil saveContent:NO];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];
    self.navigationItem.title = filterOptions.columnName;

    
    if(filterOptions.columnType==ftText || filterOptions.columnType==ftTextL)
        _actionsArray = [[NSArray alloc]initWithObjects:@"IS EQUAL", @"IS NOT EQUAL", @"CONTAINS", @"DOES NOT CONTAIN" ,  nil];
    else
        _actionsArray = [[NSArray alloc]initWithObjects:@"=", @"<>", @">", @">=", @"<", @"<=", nil];
    
    // Create the option combo-box
    UIView *view = [self.view viewWithTag:4];

    cmbActions = [[ComboBoxController alloc]initForStrings:_actionsArray inRect:view.frame];
    cmbActions.delegate = self;
    [view removeFromSuperview];
    [self.view addSubview:cmbActions.view];
    [self addChildViewController:cmbActions];
    cmbActions.enabled = YES;
    [cmbActions setSelection:0];
    
    // Create the date combo
    view = [self.view viewWithTag:6];
    cmbDate = [[ComboBoxController alloc]initForDate:view.frame];
    [view removeFromSuperview];
    [self.view addSubview:cmbDate.view];
    [self addChildViewController:cmbDate];
    NSDate *date = [Helper localDate];
    [cmbDate setSelectionDate:date]; 
    cmbDate.enabled = YES;

    if(filterOptions.columnType==ftDate)
    {
        dataField.hidden = YES;
        cmbDate.view.hidden = NO;
    }
    else 
    {
        dataField.hidden = NO;
        cmbDate.view.hidden = YES;
    }
    if([Helper isDeviceInLandscape])
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
    else
        [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
    
    if([gridDelegate respondsToSelector:@selector(gridFilterRetrieveUniqueEntries:columnIndex:completion:)])
        dropdownButton.hidden = YES;
}

- (void)viewDidUnload
{
    [self setDataField:nil];
    [self setUniqueValues:nil];
    [self setDropdownButton:nil];
    [super viewDidUnload];
    _actionsArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(!UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 
                                     120, 500);
    else
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 
                                 500,120);
}
#pragma mark - Drop-down the button

- (IBAction)dropdownAction:(id)sender 
{
    [self displayUniqueValues];
}
-(void)displayUniqueValues
{
    if(uniqueValues==nil && [gridDelegate respondsToSelector:@selector(gridFilterRetrieveUniqueEntries:columnIndex:completion:)])
    {
        [gridDelegate gridFilterRetrieveUniqueEntries:delegate columnIndex:filterOptions.columnIndex completion:^(NSArray *items) {
            dropdownMenu = [[ComboBoxPopOver alloc]initWithArrayAndViewRect:items inView:self.view destRect:dropdownButton.frame selectedRow:0 withMaxItems:20];
            dropdownMenu.delegate = self;
        } ];
    }

}
- (void)popoverItemSelected: (id)object
{
    NSString *text = @"";
    if([object isKindOfClass:[NSString class]])
        text = object;
    if(filterOptions.columnType==ftDate)
    {
        NSDate *date = [Helper dateFromString:text];
        [cmbDate setSelectionDate:date];
    }
    else
        dataField.text = text;
}
-(void)popoverItemSelected:(id)object index:(int)index
{
    NSString *text = @"";
    if([object isKindOfClass:[NSString class]])
        text = object;
    if(filterOptions.columnType==ftDate)
    {
        NSDate *date = [Helper dateFromString:text];
        [cmbDate setSelectionDate:date];
    }
    else
        dataField.text = text;
    
}
@end
