#import <UIKit/UIKit.h>
#import "AxDelegates.h"
#import <SpeechKit/SpeechKit.h>
#import "DrawContent.h"

@class ControlBar;
@class IRNote;
@class TabNotesController;
@class BackgroundLayer;
@class OptionList;

#define kBtnNoteDone 1000
#define kBtnRecord  1001
#define kBtnMicrophone 3
#define kBtnKeyboard 4
#define kBtnPencil 5
#define kBtnBluePen 25
#define kBtnRedPen 26
#define kBtnEraser 27
#define kBtnRecordBtn 2
#define kBtnHome 13

@protocol NoteMgrDelegate <NSObject>

-(void)noteMgrCloseNote:(id)note;

@optional
-(void)noteMgrSwitchToProperty:(id)note;

@end

@interface BaseNote : UIViewController<MenuBarDelegate, UIScrollViewDelegate, SpeechKitDelegate, SKRecognizerDelegate, UITextViewDelegate>
{
    
    enum 
    {
        TS_IDLE,
        TS_INITIAL,
        TS_RECORDING,
        TS_PROCESSING,
    } transactionState;
    
    UIButton *_recordButton;
    ControlBar *menuBar;
    OptionList *_optionList;
    BOOL        _skipSpeech;
    CGPoint     _currentPoint;
    BOOL        isDestroyed;
    BOOL        _removeHome;
}
@property(nonatomic, strong) IRNote *currentNote;

@property(nonatomic, weak) IBOutlet BackgroundLayer *backgroundView;
@property(nonatomic, weak) IBOutlet UITextView *noteContent;
@property (weak, nonatomic) IBOutlet DrawContent *drawContent;
@property(readonly, strong) SKRecognizer* voiceSearch;
@property(nonatomic, strong) UIView *vuMeter;
@property(nonatomic) int drawMode;
@property(nonatomic, strong) id<NoteMgrDelegate> delegate;

-(void)addMenuBar:(NSString *)name;
-(void)closeForm:(id)sender;
-(void)selectOption:(NSString *)option;


- (void) insertString: (NSString *) insertingString intoTextView: (UITextView *) textView  ;
-(void)hideHome:(BOOL)hide;
-(void)removeHome;
@end
