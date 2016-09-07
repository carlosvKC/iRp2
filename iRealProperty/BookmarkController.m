#import "BookmarkController.h"
#import "Bookmark.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "MediaView.h"
#import "RealPropInfo.h"
#import "RealPropertyApp.h"
#import "TabMapDetail.h"
#import "TabBookmarkController.h"
#import "RealProperty.h"


@implementation BookmarkController

    @synthesize imageView;
    @synthesize label;
    @synthesize delegate;
    @synthesize bookmark;
    @synthesize btnDelete = _btnDelete;
    @synthesize propertyLabel = _propertyLabel;
    @synthesize btnNote = _btnNote;
    @synthesize btnGlobe = _btnGlobe;
    @synthesize realPropInfo;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    self.btnDelete.hidden = YES;
                }
            return self;
        }



    - (void)viewDidLoad
        {
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:self.bookmark.addedDate];

            _propertyLabel.text = [NSString stringWithFormat:@"%@", [Helper fullStringFromDate:date]];
            //label.text = [NSString stringWithFormat:@"%@-%@  %@", self.bookmark.major, self.bookmark.minor, self.bookmark.type];

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", self.bookmark.rpGuid];
            realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];
            label.text = [NSString stringWithFormat:@"%@-%@  %@", realPropInfo.major, realPropInfo.minor, self.bookmark.descr];

            if (realPropInfo == nil)
                return;

            @autoreleasepool
                {
                    NSSet *media = [RealProperty getPicture:realPropInfo];

                    imageView.image = [MediaView getImageFromMiniMedia:media];

                    // 2/21/13 HNN resize propertionally
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                }
        }



    - (void)viewDidUnload
        {
            [self setImageView:nil];
            [self setLabel:nil];
            [self setPropertyLabel:nil];
            [self setBtnNote:nil];
            [self setBtnGlobe:nil];
            [self setBtnDelete:nil];
            [super viewDidUnload];
            // Release any retained subviews of the main view.
            // e.g. self.myOutlet = nil;
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



    - (void)touchesBegan:(NSSet *)touches
               withEvent:(UIEvent *)event
        {
            _eventBegan = event;

            UITouch *aTouch = [touches anyObject];
            _startPoint = [aTouch locationInView:self.view];
            _eventBegan = nil;

        }



    - (void)touchesCancelled:(NSSet *)touches
                   withEvent:(UIEvent *)event
        {
            _eventBegan = nil;
        }



    - (void)touchesEnded:(NSSet *)touches
               withEvent:(UIEvent *)event
        {
            NSTimeInterval ti = 0;
            if (_eventBegan != nil)
                {
                    ti = event.timestamp - _eventBegan.timestamp;
                }
            if (ti < 0.5)
                {
                    // Short call
                    [self shortTouch];
                }
            else if (ti > 0.5)
                {
                    // Long call
                    [self longTouch];
                }
        }



// Long touch -- display the pop-up menu
    - (void)longTouch
        {
        }



// Short touch -- switch to the property
    - (void)shortTouch
        {
            [delegate bookmarkDetails:self];
        }



    - (IBAction)actionEditNote:(id)sender
        {
            [delegate bookmarkEditNote:self];
        }



    - (IBAction)actionDelete:(id)sender
        {
            [delegate bookmarkDelete:self];
        }



    - (IBAction)actionMap:(id)sender
        {
            [delegate bookmarkMap:self];
        }
@end
