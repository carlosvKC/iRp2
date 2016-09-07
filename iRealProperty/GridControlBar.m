#import "GridControlBar.h"
#import "GridControlBarView.h"


@implementation GridControlBar

@synthesize delegate; //= _delegate;
    @synthesize btnAdd;
    @synthesize btnDelete;

    @synthesize btnLeft;
    @synthesize btnRight;
    @synthesize btnList;
    @synthesize labelNextPrevious;

    @synthesize btnCancel;
    @synthesize btnSave;

    @synthesize btnConfirmDel;

    @synthesize gridController;

    - (id)initWithNibName:(NSString *)nibNameOrNil
                  barMode:(int)barMode
        {
            self       = [super initWithNibName:nibNameOrNil bundle:nil];
            currentBar = barMode;
            return self;
        }



    - (void)setGridController:(GridController *)gridCtrl
        {
            gridController = gridCtrl;
            [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            // [super didReceiveMemoryWarning];
        }



// Update the look of the buttons
    - (void)updateButtonGraphic:(UIButton *)btn
                         useRed:(BOOL)useRed
        {
            if (btn == nil)
                return;

            UIImage *btnImage;

            if (!useRed)
                btnImage = [UIImage imageNamed:@"btnBlue38.png"];
            else
                btnImage = [UIImage imageNamed:@"btnRed38.png"];
            UIImage *strechable = [btnImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            [btn setBackgroundImage:strechable forState:UIControlStateNormal];
            btn.titleLabel.textColor = [UIColor whiteColor];
        }

#pragma mark - View lifecycle

    - (void)viewDidLoad
        {
            [super viewDidLoad];
            GridControlBarView *view = (GridControlBarView *) self.view;
            view.itsController = self;

            switch (currentBar)
                {
                    case kGridControlModeDeleteAdd:
                        btnAdd = (UIButton *) [view viewWithTag:1];
                        [btnAdd addTarget:self action:@selector(btnAddSelection:) forControlEvents:UIControlEventTouchUpInside];
                        
                        //cv  5/17/16
                        btnAdd.titleLabel.textColor = [UIColor whiteColor];

                        
                        
                        btnCancel = (UIButton *) [view viewWithTag:2];
                        [btnCancel addTarget:self action:@selector(btnDelSection:) forControlEvents:UIControlEventTouchUpInside];
                        //cv  5/17/16
                        btnCancel.titleLabel.textColor = [UIColor whiteColor];

                        
                        break;
                    case kGridControlModeNextPrevious:
                        btnLeft = (UIButton *) [view viewWithTag:1];
                        [btnLeft addTarget:self action:@selector(btnLeftSelection:) forControlEvents:UIControlEventTouchUpInside];
                        labelNextPrevious = (UILabel *) [view viewWithTag:2];
                        btnRight          = (UIButton *) [view viewWithTag:3];
                        [btnRight addTarget:self action:@selector(btnRightSelection:) forControlEvents:UIControlEventTouchUpInside];
                        break;
                    case kGridControlModeSaveCancel:
                        btnSave = (UIButton *) [view viewWithTag:1];
                        [btnSave addTarget:self action:@selector(btnSaveSelection:) forControlEvents:UIControlEventTouchUpInside];
                        btnCancel = (UIButton *) [view viewWithTag:2];
                        [btnCancel addTarget:self action:@selector(btnCancelSelection:) forControlEvents:UIControlEventTouchUpInside];
                        [self updateButtonGraphic:btnCancel useRed:YES];
                        [self updateButtonGraphic:btnSave useRed:NO];
                        break;
                    case kGridControlModeDeleteCancel:
                        btnCancel = (UIButton *) [view viewWithTag:2];
                        [btnCancel addTarget:self action:@selector(btnCancelSelection:) forControlEvents:UIControlEventTouchUpInside];
                        btnConfirmDel = (UIButton *) [view viewWithTag:1];
                        [btnConfirmDel addTarget:self action:@selector(btnConfirmDel:) forControlEvents:UIControlEventTouchUpInside];
                        [self updateButtonGraphic:btnCancel useRed:YES];
                        [self updateButtonGraphic:btnConfirmDel useRed:NO];

                        break;
                }

        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }

    // This is for the Add button on the grid control bar.  The delete button is not handled here.
    - (IBAction)btnAddSelection:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnAdd];
        }

	// DBaun 062914 (New Permit Form) Comment below
    // This doesn't care what grid control bar is in place, rather it simply hides or shows ALL buttons
    // that are on that particular grid control bar.
    - (void)setButtonVisible:(BOOL)mode
        {
            mode = !mode;

            btnAdd.hidden    = mode;
            btnDelete.hidden = mode;

            btnCancel.hidden     = mode;
            btnConfirmDel.hidden = mode;
            btnDelete.hidden     = mode;
            btnLeft.hidden       = mode;
            btnList.hidden       = mode;
            btnRight.hidden      = mode;
            btnSave.hidden       = mode;
        }



    - (IBAction)btnDelSection:(id)sender
        {
//            NSString *myString;
//            myString = [delegate description];
//            
//            if ([myString isEqualToString:@"TabPermits"])
//                  
//                  //"TabPermits"])
//            {
//            
//            }
//                else
//                {
            
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnDel];
                }
//        }


    - (IBAction)btnLeftSelection:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnLeft];
        }



    - (IBAction)btnRightSelection:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnRight];
        }



    - (IBAction)btnListSection:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnList];
        }



    - (IBAction)btnSaveSelection:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnSave];
        }



    - (IBAction)btnCancelSelection:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnCancel];
        }



    - (IBAction)btnConfirmDel:(id)sender
        {
            [delegate gridControlBarAction:(NSObject *) self.gridController action:kGridControlBarBtnConfirmDel];
        }

#pragma mark - Utilities functions

    - (UILabel *)getPrincipalLabel
        {
            return (UILabel *) [self.view viewWithTag:kGridControlLabel];
        }



    - (UILabel *)getSmallLabel
        {
            return (UILabel *) [self.view viewWithTag:kGridControlLabelNumbers];

        }



    - (void)setPrincipalLabelText:(NSString *)text
        {
            UILabel *label = [self getPrincipalLabel];
            label.text = text;
        }



    - (void)setSmallLabelText:(NSString *)text
        {
            UILabel *label = [self getSmallLabel];
            label.text     = text;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            if (gridController != nil)  //is nil why check again  self.btnList is nil
                return;

            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 1024, self.view.frame.size.height);
            else
                self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 768, self.view.frame.size.height);
            [self adjustFrame:self.view.frame];
        }



    - (void)setCounter:(int)current
                   max:(int)max
        {
            NSString *label = [NSString stringWithFormat:@"%d/%d", current, max];
            [self setSmallLabelText:label];

            if (current <= 1)
                btnLeft.hidden = YES;
            else
                btnLeft.hidden  = NO;
            if (current >= max)
                btnRight.hidden = YES;
            else
                btnLeft.hidden = NO;
        }



    - (UIButton *)getDeleteButton
        {
            return btnCancel;
        }



    - (void)adjustFrame:(CGRect)frame
        {
            self.view.frame = frame;
            switch (currentBar)
                {
                    case kGridControlModeDeleteAdd:
                        //do I need to reiterate the selector??
                        btnAdd.frame = CGRectMake(self.view.frame.size.width - 180, 0, btnAdd.frame.size.width, btnAdd.frame.size.height);
                        btnCancel.frame  = CGRectMake(btnAdd.frame.origin.x + btnAdd.frame.size.width + 20, 0, btnCancel.frame.size.width, btnCancel.frame.size.height);
                    break;
                    case kGridControlModeNextPrevious:
                        break;
                    case kGridControlModeSaveCancel:
                        break;
                    case kGridControlModeDeleteCancel:
                        break;
                }
        }
@end
