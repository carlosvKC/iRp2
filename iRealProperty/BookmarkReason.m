#import "BookmarkReason.h"
#import "Helper.h"


@implementation BookmarkReason

    @synthesize details;
    @synthesize delegate;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    // Custom initialization
                }
            return self;
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];

            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
            self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];

            self.title = @"Bookmark";

            if ([Helper isDeviceInLandscape])
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
            else
                [self willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];

        }



    - (void)viewDidUnload
        {
            [self setDetails:nil];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;

        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            CGSize size = self.view.frame.size;
            self.contentSizeForViewInPopover = size;

            if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
                {
                    self.view.frame = CGRectMake((768 - size.width) / 2, (1024 - size.height) / 4,
                            size.width, size.height);
                }
            else
                {
                    self.view.frame = CGRectMake((1024 - size.width) / 2, (768 - size.height) / 4,
                            size.width, size.height);
                }
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


@end
