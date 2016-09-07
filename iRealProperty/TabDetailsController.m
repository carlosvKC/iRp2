#import "TabDetailsController.h"


@implementation TabDetailsController

    @synthesize uiTextField;



    - (void)menuTableMenuSelected:(NSString *)menuName
                          withTag:(int)tag
                        withParam:(id)param
        {
        }



    - (void)menuTableBeforeDisplay:(NSString *)menuName
                         withItems:(NSArray *)array
        {
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];

            // Release any cached data, images, etc that aren't in use.
        }



    - (void)viewDidLoad
        {
            dontUseDetailController = YES;

            [super viewDidLoad];
            RealPropInfo *propinfo = [RealProperty realPropInfo];

            // Prepare the business rules (if any)
            [self setupBusinessRules:propinfo];

            // Setup the working base (here RealPropInfo)
            self.workingBase = propinfo;

            // Setup the screen content
            [self setScreenEntities];

            // Setup the parcel number
            UITextView *textView = (UITextView *) [self.view viewWithTag:1];

            textView.text = [NSString stringWithFormat:@"%@-%@", propinfo.major, propinfo.minor];

            NSArray *sortedArray = [RealProperty findAllMedias:propinfo];

            [self addMedia:kTabPropertyImage mediaArray:sortedArray];
        }



    - (void)didSwitchToSubController
        {
            RealPropInfo *propinfo = [RealProperty realPropInfo];
            [super didSwitchToSubController];
            NSArray *sortedArray = [RealProperty findAllMedias:propinfo];
            [self refreshMedias:sortedArray];
        }



//
// Track the chages
//
    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
            // If any content has changed, change indicate status
            [self.propertyController segmentUsed:kTabDetails];
            self.isDirty           = YES;
            RealPropInfo *propInfo = [RealProperty realPropInfo];

            propInfo.rowStatus = @"U";
        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
        }
@end
