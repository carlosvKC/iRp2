#import <Foundation/Foundation.h>
#import "BaseNote.h"

@class SurveyDefinition;

@interface SurveyNote : BaseNote <UIPopoverControllerDelegate, UITextFieldDelegate>
{
    SurveyDefinition *_surveyDefinition;
    // Help pop-over information
    UIPopoverController     *helpPopover;
    UIViewController        *helpViewController;
    int noteType;
}
@property(nonatomic, strong) SurveyDefinition *surveyDefinition;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *parcelNbr;
@end
