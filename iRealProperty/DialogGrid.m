#import "DialogGrid.h"
#import "Helper.h"

@implementation DialogGrid

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    dontUseDetailController = YES;
    // Create the "done" and "cancel" button
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}
#pragma mark - Dialog box methods
-(void)setDialogTitle:(NSString *)title
{
    self.navigationItem.title = title;
}
- (void)dismissView:(id)sender 
{
    // Make sure to collect all the pieces
    UIViewController *dialogSender = sender;

    [Helper findAndResignFirstResponder:dialogSender.view];
    // Make sure that nothing is blocking
 //   if([self checkTextfieldsAreValid]==NO)
 //       return;
    // Now, verifies that the content follows the business logic
    
    if([self validateBusinessRules]==NO)
        return;
    
    [delegate didDismissModalView:self saveContent:YES];
}
// Cancel button clicked
- (void)cancelView:(id)sender 
{
    isCanceling = YES;
    // Call the delegate to dismiss the modal view
    
    [delegate didDismissModalView:self saveContent:NO];
}


@end
