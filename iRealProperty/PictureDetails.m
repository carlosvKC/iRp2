#import "PictureDetails.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "PictureView.h"
#import "CheckBoxView.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation PictureDetails

@synthesize delegate;
@synthesize selectedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isDirty = NO;
    }
    return self;
}

#pragma mark - Delegates
//
// Get description
-(NSString *)getDescription
{
    UITextView *textView = (UITextView *)[self.view viewWithTag:kPictureDetailInputTag];
    return textView.text;    
}
-(BOOL)getPrimary
{
    CheckBoxView *checkbox = (CheckBoxView *)[self.view viewWithTag:kPictureDetailPrimary];
    return checkbox.checked;
}
-(UIImage *)getImage
{
    return selectedImage;
}
-(BOOL)getPostToWeb
{
    CheckBoxView *btn = (CheckBoxView *)[self.view viewWithTag:kPictureDetailPostToWeb];
    return btn.checked;
}
- (void)dismissView:(id)sender 
{
    [self deregisterFromKeyboardNotifications];
    [Helper findAndResignFirstResponder:self.view];
    [delegate didDismissModalView:self saveContent:YES];
}
// Cancel button clicked
- (void)cancelView:(id)sender 
{
    [delegate didDismissModalView:self saveContent:NO];
}
#pragma mark - Manage the medias
-(void)configureDialogBox:(NSString *)title btnVisible:(BOOL)visible
{
    self.navigationItem.title = title;  
    UIButton *btn = (UIButton *)[self.view viewWithTag:kPictureDetailCameraTag];
    [btn setHidden:!visible];
    btn = (UIButton *)[self.view viewWithTag:kPictureDetailRollTag];
    [btn setHidden:!visible];
}
//
// Setup the different media components
-(void)setMedia:(id)media
{
    if(media!=nil)
    {
        // Existing media
        PictureView *pictView = (PictureView *)[self.view viewWithTag:kPictureDetailPictTag];
        [pictView setMedia:media];    
        // Hide the label tag
        UILabel *labelTag = (UILabel *)[self.view viewWithTag:kPictureDetailLabelTag];
        labelTag.hidden = YES;

        self.workingBase = media;
    }
    else
    {
        // New media -- update default values
        MediaAccy *media = [AxDataManager getNewEntityObject:@"MediaAccy"];
        [RealPropertyApp updateUserDate:media];
        media.active = YES;
        media.primary = YES;
        media.postToWeb = YES;
        media.order = 1;
        media.mediaDate = [[Helper localDate]timeIntervalSinceReferenceDate];
        self.workingBase = media;
    }
    MediaAccy *_media = media;
    [self setScreenEntities];
    // Override the post to web button
    CheckBoxView *btn = (CheckBoxView *)[self.view viewWithTag:kPictureDetailPostToWeb];
    btn.checked = _media.postToWeb;
}
//
// Return the media information -- only the caption and if it is a primary
-(id)getMedia
{
    return [self workingBase];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];
    self.navigationItem.title = @"Title";
    
    [self registerForKeyboardNotifications:self withDelta:10];
}

- (void)viewDidUnload
{
    [self deregisterFromKeyboardNotifications];
    [super viewDidUnload];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

