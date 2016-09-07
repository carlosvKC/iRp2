
#import "VoiceNotes.h"
#import "Helper.h"
#import "ControlBar.h"
#import "IRNote.h"
#import "AxDataManager.h"
#import "TabNotesController.h"

const unsigned char SpeechKitApplicationKey[] = {0x9e, 0x07, 0x11, 0x6e, 0x90, 0x3a, 0x06, 0x90, 0x77, 0x5b, 0x1d, 0x7c, 0xae, 0xff, 0x6f, 0x93, 0xb5, 0x9e, 0x0b, 0xf4, 0x8a, 0x4b, 0x9e, 0xdf, 0x28, 0x05, 0x23, 0xfb, 0x9a, 0x8a, 0xfc, 0x39, 0x91, 0x0d, 0xa7, 0x22, 0x47, 0xae, 0xb2, 0xbf, 0x09, 0xd0, 0x3b, 0xb8, 0xcf, 0xab, 0x4b, 0x84, 0x49, 0x56, 0x78, 0xd3, 0xa1, 0x16, 0xb2, 0xca, 0x1b, 0xd5, 0xc5, 0xb5, 0x60, 0xc1, 0xee, 0xf1};


@implementation VoiceNotes

@synthesize voiceSearch, vuMeter;
@synthesize itsController;
@synthesize resultView;

#pragma mark VU Meter

- (void)setVUMeterWidth:(float)width 
{
    if (width < 0)
        width = 0;
    
    CGRect frame = vuMeter.frame;
    frame.size.width = width+10;
    vuMeter.frame = frame;
}

- (void)updateVUMeter 
{
    float width = (90+voiceSearch.audioLevel)*5/2;
    
    [self setVUMeterWidth:width];    
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

#pragma mark - Handling buttons...
// Create a new note or save the note
-(void)closeForm:(id)sender
{
    [self closeSpeech];
    [super closeForm:sender];
    _currentNote.updateDate = [[Helper globalTime]timeIntervalSinceReferenceDate] ;
    _currentNote.type = kNotesVoice;
    NSManagedObjectContext *context = [AxDataManager noteContext];
    NSError *error;
    [context save:&error];
    [itsController closeNote:self];
}
-(void)menuBarBtnSelected:(int)tag
{
    if(tag==kBtnRecord)
        [self recordButtonAction:nil];
}

#pragma mark - handle show/hide keyboard
- (void) insertString: (NSString *) insertingString intoTextView: (UITextView *) textView  
{  
    NSRange range = textView.selectedRange;  
    NSString * firstHalfString = [textView.text substringToIndex:range.location];  
    NSString * secondHalfString = [textView.text substringFromIndex: range.location];  
    textView.scrollEnabled = NO; 
    
    textView.text = [NSString stringWithFormat: @"%@%@%@",  
                     firstHalfString,  
                     insertingString,  
                     secondHalfString];  
    range.location += [insertingString length];  
    textView.selectedRange = range;  
    textView.scrollEnabled = YES;  // turn scrolling back on.  
    
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    UITextView *textView = (UITextView *)[self.view viewWithTag:10];
    
    textView.contentInset = contentInsets;
    textView.scrollIndicatorInsets = contentInsets;
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UITextView *textView = (UITextView *)[self.view viewWithTag:10];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    textView.contentInset = contentInsets;
    textView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Actions

- (IBAction)recordButtonAction: (id)sender 
{
    [Helper findAndResignFirstResponder:self.view];
    
    if (transactionState == TS_RECORDING) 
    {
        [voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE) 
    {
        SKEndOfSpeechDetection detectionType;
        NSString* recoType;
        NSString* langType;
        
        transactionState = TS_INITIAL;
        
        detectionType = SKLongEndOfSpeechDetection; /* Dictations tend to be long utterances that may include short pauses. */
        recoType = SKDictationRecognizerType; /* Optimize recognition performance for dictation or message text. */
		langType = @"en_US";
        
        if (voiceSearch)
            voiceSearch = nil;
		
        voiceSearch = [[SKRecognizer alloc] initWithType:recoType                                               detection:detectionType language:langType delegate:self];
    }
}

- (void)closeSpeech
{
    if (voiceSearch) 
        [voiceSearch cancel];
    
    [SpeechKit destroy];
}
#pragma mark -
#pragma mark - SpeechKitDelegate methods

- (void) destroyed {
    // Debug - Uncomment this code and fill in your app ID below, and set
    // the Main Window nib to MainWindow_Debug (in DMRecognizer-Info.plist)
    // if you need the ability to change servers in DMRecognizer
    //
    //[SpeechKit setupWithID:INSERT_YOUR_APPLICATION_ID_HERE
    //                  host:INSERT_YOUR_HOST_ADDRESS_HERE
    //                  port:INSERT_YOUR_HOST_PORT_HERE[[portBox text] intValue]
    //                useSSL:NO
    //              delegate:self];
    //
	// Set earcons to play
	//SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	//SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	//SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
	//
	//[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	//[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	//[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];    
}

#pragma mark -
#pragma mark SKRecognizerDelegate methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    transactionState = TS_RECORDING;
    [_recordButton setTitle:@"Recording..." forState:UIControlStateNormal];
    
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
    [self setVUMeterWidth:0.];
    transactionState = TS_PROCESSING;
    [_recordButton setTitle:@"Processing..." forState:UIControlStateNormal];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    if (numOfResults > 0)
    {
        [self insertString:@" " intoTextView:resultView];
        [self insertString:[results firstResult] intoTextView:resultView];
    }
    /***
	if (numOfResults > 1) 
		alternativesDisplay.text = [[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"];
    ***/
    if (results.suggestion) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion" message:results.suggestion delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];        
        [alert show];
        alert = nil;
    }
	voiceSearch = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id 
    
    transactionState = TS_IDLE;
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];        
    [alert show];
    alert = nil;
    
    if (suggestion) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion" message:suggestion delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];        
        [alert show];
        alert = nil;
        
    }
	voiceSearch = nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [super addMenuBar:@"VoiceNotesControlBar"];

    UIView *view = [self.view viewWithTag:6];
    [view removeFromSuperview];
    _recordButton = [Helper createRedButton:view.frame withTitle:@"Record"];
    _recordButton.tag = kBtnRecord;
    [menuBar addButton:_recordButton atIndex:2]; 
    
    // Speechkit enablement
    [SpeechKit setupWithID: @"NMDPTRIAL_axelerate20120223171235"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:self];
    
	// Set earcons to play
	SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
	
	[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
}


@end
