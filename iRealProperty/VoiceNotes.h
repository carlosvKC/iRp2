#import <UIKit/UIKit.h>
#import "AxDelegates.h"
#import <SpeechKit/SpeechKit.h>
#import "BaseNote.h"

@class ControlBar;
@class IRNote;
@class TabNotesController;
#define kBtnRecord  66
@interface VoiceNotes : BaseNote<SpeechKitDelegate, SKRecognizerDelegate, UITextFieldDelegate>
{

    enum {
        TS_IDLE,
        TS_INITIAL,
        TS_RECORDING,
        TS_PROCESSING,
    } transactionState;
    
    UIButton *_recordButton;
}
@property(nonatomic, weak) TabNotesController *itsController;
@property(readonly, strong) SKRecognizer* voiceSearch;
@property(nonatomic, strong) IBOutlet UIView *vuMeter;
@property(nonatomic, strong) IBOutlet UITextView *resultView;

-(void)recordButtonAction:(id)sender;

-(void)closeSpeech;

@end

