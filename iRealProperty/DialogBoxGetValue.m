#import "DialogBoxGetValue.h"
#import "Helper.h"


@implementation DialogBoxGetValue

    @synthesize delegate;
    @synthesize dropdownButton;
    @synthesize textArea;
    @synthesize textSubArea;
    @synthesize textApplGroup;

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
        }



    - (void)viewDidUnload
        {
            [self setTextApplGroup:nil];
            [self setTextSubArea:nil];
            [self setTextArea:nil];
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
                        315, 271);
            else
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                        315, 271);
        }
#pragma mark - Drop-down the button

    - (IBAction)dropdownAction:(id)sender
        {
            [self displayUniqueValues];
        }



    - (void)displayUniqueValues
        {
            if (values == nil)
                {

                }
            dropdownMenu = [[ComboBoxPopOver alloc] initWithArrayAndViewRect:values inView:self.view destRect:dropdownButton.frame selectedRow:0 withMaxItems:20];
            dropdownMenu.delegate = self;
        }



    - (void)popoverItemSelected:(id)object
        {

        }



    - (void)popoverItemSelected:(id)object
                          index:(int)index
        {

        }
@end
