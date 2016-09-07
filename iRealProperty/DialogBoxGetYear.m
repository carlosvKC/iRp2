#import "DialogBoxGetYear.h"
#import "Helper.h"


@implementation DialogBoxGetYear

    @synthesize delegate;
    @synthesize dropdownButton;
    @synthesize dataField;

#pragma mark - ComboBox delegate
    - (void)comboxBoxClicked:(id)comboBox
                       value:(id)value
        {
            /*
            if(comboBox==cmbActions.view)
            {
                filterOptions.filterOperation = [value intValue];
            }
             */
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];
        }



// Done button clicked
    - (void)dismissView:(id)sender
        {
            [delegate didDismissModalView:self saveContent:YES];
        }



// Cancel button clicked
    - (void)cancelView:(id)sender
        {
            // Call the delegate to dismiss the modal view
            [delegate didDismissModalView:self saveContent:NO];
        }
#pragma mark - View lifecycle
    - (void)textFieldDidBeginEditing:(UITextField *)textField
        {
        }



    - (void)textFieldDidEndEditing:(UITextField *)textField
        {
            /// filterOptions.filterValue = textField.text;
        }



// Call back if the item has been selected
//
    - (BOOL)textFieldShouldReturn:(UITextField *)textField
        {
            return YES;
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];

            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
            self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];

            self.title = @"Calculate Value";

            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];

            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
            dataField.text = [NSString stringWithFormat:@"%d", [components year]];
        }



    - (void)viewDidUnload
        {
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;

        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            if (!UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                        354, 176);
            else
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                        354, 176);
        }
#pragma mark - Drop-down the button

    - (IBAction)dropdownAction:(id)sender
        {
            [self displayUniqueValues];
        }



    - (void)displayUniqueValues
        {
            if (yearValues == nil)
                {
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[Helper localDate]];
                    NSInteger year = [components year];

                    yearValues = [[NSMutableArray alloc] init];

                    for (int i = year - 4; i <= year + 2; i++)
                        {
                            [yearValues addObject:[NSString stringWithFormat:@"%d", i]];
                        }

                }
            dropdownMenu = [[ComboBoxPopOver alloc] initWithArrayAndViewRect:yearValues inView:self.view destRect:dropdownButton.frame selectedRow:0 withMaxItems:20];
            dropdownMenu.delegate = self;
        }



    - (void)popoverItemSelected:(id)object
        {
            dataField.text = object;
        }



    - (void)popoverItemSelected:(id)object
                          index:(int)index
        {
            dataField.text = object;
        }
@end
