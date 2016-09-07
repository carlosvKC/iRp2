#import "BaseNote.h"
#import "Helper.h"
#import "ControlBar.h"
#import "IRNote.h"
#import "AxDataManager.h"
#import "TabNotesController.h"
#import "BackgroundLayer.h"
#import "OptionList.h"
// Marker Felt Thin, Size 19



@implementation BaseNote

    @synthesize currentNote;
    @synthesize backgroundView;
    @synthesize noteContent;
    @synthesize drawContent;
    @synthesize drawMode;
    @synthesize delegate;
    @synthesize voiceSearch, vuMeter;

    const unsigned char SpeechKitApplicationKey[] = {0x6b, 0x20, 0xb7, 0x08, 0x41, 0x80, 0x57, 0xae, 0x58, 0xa9, 0x48, 0x37, 0x6e, 0x96, 0xcc, 0xfb, 0xfa, 0xcd, 0x27, 0x51, 0x2a, 0x18, 0x13, 0xab, 0x1e, 0xe5, 0xb3, 0x77, 0x14, 0x7a, 0x2e, 0x80, 0x9a, 0xe5, 0x88, 0xdc, 0x66, 0xdf, 0x8a, 0xbe, 0x88, 0xd2, 0xf6, 0xf7, 0x68, 0xc2, 0xf2, 0x63, 0x8f, 0x19, 0xb4, 0xb9, 0x31, 0xc7, 0x64, 0x50, 0xac, 0x17, 0xc7, 0xc0, 0x91, 0xf5, 0x40, 0x2c};



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    // Custom initialization
                    _removeHome = NO;
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];

        }



    - (BOOL)containChar:(unichar)c
               inString:(NSString *)str
        {
            for (int i = 0; i < str.length; i++)
                if (c == [str characterAtIndex:i])
                    return YES;
            return NO;
        }



    - (NSString *)findParcelNbr
        {
            if (currentNote == nil || currentNote.major.length == 0 || currentNote.minor.length == 0)
                return @"";
            return [NSString stringWithFormat:@"%@-%@", currentNote.major, currentNote.minor];
        }



// Update the date and the parcelNbr
    - (void)updateInformation
        {
            UILabel *label = (UILabel *) [self.view viewWithTag:50];
            label.text = [self findParcelNbr];

            UILabel *dateLbl = (UILabel *) [self.view viewWithTag:51];
            dateLbl.text = @""; // [Helper stringFromGlobalDate:_currentNote.updateDate];
        }



// the current setter...
    - (void)setCurrentNote:(IRNote *)aNote
        {
            currentNote = aNote;
            if (currentNote == nil)
                {
                    noteContent.text = @"";
                }
            else
                noteContent.text = currentNote.note;
            if (drawContent != nil)
                {
                    [self updateInformation];
                    [drawContent loadLines:currentNote.iRLine];
                    drawContent.itsBaseNote = self;
                }
    if([currentNote.major length]==0 || [currentNote.minor length]==0)
                [self hideHome:YES];
            else
                [self hideHome:NO];
        }
#pragma mark - Actions

    - (IBAction)recordButtonAction:(id)sender
        {
            [Helper findAndResignFirstResponder:self.view];

            if (transactionState == TS_RECORDING)
                {
                    [voiceSearch stopRecording];
                }
            else if (transactionState == TS_IDLE)
                {
                    SKEndOfSpeechDetection detectionType;
                    NSString *recoType;
                    NSString *langType;

                    transactionState = TS_INITIAL;

                    detectionType = SKLongEndOfSpeechDetection; /* Dictations tend to be long utterances that may include short pauses. */
                    recoType      = SKDictationRecognizerType; /* Optimize recognition performance for dictation or message text. */
                    langType      = @"en_US";

                    if (voiceSearch)
                        voiceSearch = nil;

                    voiceSearch = [[SKRecognizer alloc] initWithType:recoType detection:detectionType language:langType delegate:self];
                }
        }



    - (void)closeSpeech
        {
            if (voiceSearch)
                {
                    [voiceSearch stopRecording];
                    [voiceSearch cancel];
                }
            voiceSearch = nil;
            isDestroyed = NO;
            [SpeechKit destroy];
            for (int i = 0; i < 5; i++)
                {
                    [NSThread sleepForTimeInterval:0.1];
                    if (isDestroyed)
                        break;
                }
        }

#pragma mark VU Meter

    - (void)setVUMeterWidth:(float)width
        {
            if (width < 0)
                width = 0;

            CGRect frame = vuMeter.frame;
            frame.size.width = width + 10;
            vuMeter.frame    = frame;
        }



    - (void)updateVUMeter
        {
            float width = (90 + voiceSearch.audioLevel) * 5 / 2;

            [self setVUMeterWidth:width];
            [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
        }

#pragma mark - Handle the UITextView
    - (void)scrollViewDidScroll:(UIScrollView *)scrollView
        {
            CGPoint offset = scrollView.contentOffset;
            // backgroundView.transform = CGAffineTransformMakeTranslation(0, -offset.y);
            backgroundView.offset = -offset.y;
            [backgroundView setNeedsDisplay];
        }
#pragma mark - Handling buttons...
// Create a new note or save the note
    - (void)closeForm:(id)sender
        {
            [self closeSpeech];
            [Helper findAndResignFirstResponder:self.view];
            if (currentNote == nil)
                {
                    currentNote = [AxDataManager getNewEntityObject:@"IRNote" andContext:[AxDataManager noteContext]];
                }
            // Update the content
            currentNote.note       = noteContent.text;
            currentNote.parcelNbr  = [self findParcelNbr];
            currentNote.updateDate = [[Helper localDate] timeIntervalSinceReferenceDate];

            // Add the handrawn text
            [drawContent saveLinesTo:currentNote];

            NSManagedObjectContext *context = [AxDataManager noteContext];
            NSError                *error;
            [context save:&error];
            // Last call
            [delegate noteMgrCloseNote:self];
        }



    - (void)menuBarBtnBackSelected
        {
            [Helper findAndResignFirstResponder:self.view];
            // Return to the main menu
            [self closeSpeech];
            [delegate noteMgrCloseNote:self];
        }



    - (void)menuBarBtnSelected:(int)tag
        {
            switch (tag)
                {
                    case kBtnNoteDone:
                        [self closeForm:nil];
                    break;
                    case kBtnRecord:
                        [self recordButtonAction:nil];
                    break;
                    case kBtnMicrophone:
                        if ([menuBar isItemSelected:kBtnMicrophone])
                            {
                                [menuBar setItemSelected:kBtnMicrophone isSelected:NO];
                                // Hide the Record button
                                [menuBar removeButton:kBtnRecordBtn];
                            }
                        else
                            {
                                [menuBar setItemSelected:kBtnMicrophone isSelected:YES];
                                // Show the Record button
                                [menuBar addButton:_recordButton atIndex:kBtnRecordBtn];
                                [self menuBarBtnSelected:kBtnKeyboard];
                            }
                    break;
                    case kBtnKeyboard:
                        if (![menuBar isItemSelected:kBtnKeyboard])
                            {
                                [self removeMenuBar];
                                [self addMenuBar:@"BaseNoteControlBarKeyboard"];
                                if (_removeHome)
                                    [menuBar removeButtonWithTag:kBtnHome];
                                [menuBar setItemSelected:kBtnPencil isSelected:NO];
                                [menuBar setItemSelected:kBtnKeyboard isSelected:YES];
                                drawContent.hidden = YES;
                            }
                    [self adjustControlBar];
                    break;
                    case kBtnPencil:
                        if (![menuBar isItemSelected:kBtnPencil])
                            {
                                [self removeMenuBar];
                                [self addMenuBar:@"BaseNoteControlBarPen"];
                                if (_removeHome)
                                    [menuBar removeButtonWithTag:kBtnHome];

                                [Helper findAndResignFirstResponder:self.view];
                                [menuBar setItemSelected:kBtnPencil isSelected:YES];
                                [menuBar setItemSelected:kBtnBluePen isSelected:YES];
                                [menuBar setItemSelected:kBtnRedPen isSelected:NO];
                                [menuBar setItemSelected:kBtnEraser isSelected:NO];
                                [menuBar setItemSelected:kBtnKeyboard isSelected:NO];
                                drawContent.hidden      = NO;
                                drawContent.itsBaseNote = self;
                                drawMode = kBtnBluePen;
                                [self adjustControlBar];
                            }
                    break;
                    case kBtnBluePen:
                        [menuBar setItemSelected:kBtnBluePen isSelected:YES];
                    [menuBar setItemSelected:kBtnRedPen isSelected:NO];
                    [menuBar setItemSelected:kBtnEraser isSelected:NO];
                    drawMode = kBtnBluePen;
                    break;
                    case kBtnRedPen:
                        [menuBar setItemSelected:kBtnBluePen isSelected:NO];
                    [menuBar setItemSelected:kBtnRedPen isSelected:YES];
                    [menuBar setItemSelected:kBtnEraser isSelected:NO];
                    drawMode = kBtnRedPen;
                    break;
                    case kBtnEraser:
                        [menuBar setItemSelected:kBtnBluePen isSelected:NO];
                    [menuBar setItemSelected:kBtnRedPen isSelected:NO];
                    [menuBar setItemSelected:kBtnEraser isSelected:YES];
                    drawMode = kBtnEraser;
                    break;
                    case kBtnHome:
                        // switch to the home (if it is possible...)
                        if ([delegate respondsToSelector:@selector(noteMgrSwitchToProperty:)])
                            [delegate noteMgrSwitchToProperty:self];
                    break;
                }
        }



    - (void)hideHome:(BOOL)hide
        {
            [menuBar setItemEnable:kBtnHome isEnable:!hide];
        }



    - (void)removeHome
        {
            _removeHome = YES;
            [menuBar removeButtonWithTag:kBtnHome];
        }
#pragma mark - Text handling
    - (void)textViewDidChange:(UITextView *)textView
        {
            // Update the 2 fields
            [self updateInformation];
        }

#pragma mark - SpeechKitDelegate methods
    - (void)selectOption:(NSString *)option
        {
            _optionList = nil;
            [self insertString:@" " intoTextView:noteContent];
            [self insertString:option intoTextView:noteContent];
        }



    - (void)destroyed
        {
            isDestroyed = YES;
        }

#pragma mark -
#pragma mark SKRecognizerDelegate methods
    - (void)insertString:(NSString *)insertingString
            intoTextView:(UITextView *)textView
        {
            NSRange range = textView.selectedRange;
            NSString *firstHalfString  = [textView.text substringToIndex:range.location];
            NSString *secondHalfString = [textView.text substringFromIndex:range.location];
            textView.scrollEnabled = NO;

            textView.text          = [NSString stringWithFormat:@"%@%@%@",
                                                                firstHalfString,
                                                                insertingString,
                                                                secondHalfString];
            range.location += [insertingString length];
            textView.selectedRange = range;
            textView.scrollEnabled = YES;  // turn scrolling back on.

        }



    - (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
        {
            transactionState = TS_RECORDING;
            [_recordButton setTitle:@"Recording..." forState:UIControlStateNormal];

            // [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
        }



    - (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
        {
            // [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
            //  [self setVUMeterWidth:0.];
            transactionState = TS_PROCESSING;
            [_recordButton setTitle:@"Processing..." forState:UIControlStateNormal];
        }



    - (void)recognizer:(SKRecognizer *)recognizer
  didFinishWithResults:(SKRecognition *)results
        {
            long numOfResults = [results.results count];

            transactionState = TS_IDLE;
            [_recordButton setTitle:@"Record" forState:UIControlStateNormal];

            if (numOfResults == 1)
                {
                    [self insertString:@" " intoTextView:noteContent];
                    [self insertString:[results firstResult] intoTextView:noteContent];
                }
            else if (numOfResults > 1)
                {
                    _optionList = [[OptionList alloc] initWithNibName:@"OptionList" bundle:nil];
                    _optionList.itsController = self;
                    _optionList.options       = results.results;
                    CGRect rect = CGRectMake(100, 300, 600, 300);
                    [_optionList showOptions:rect inView:self.view];
                }
            if (results.suggestion)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion" message:results.suggestion delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    alert = nil;
                }
            voiceSearch      = nil;
        }



    - (void)recognizer:(SKRecognizer *)recognizer
    didFinishWithError:(NSError *)error
            suggestion:(NSString *)suggestion
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

#pragma mark - View lifecycle
    - (void)addMenuBar:(NSString *)name
        {
            UIView *view = [self.view viewWithTag:1010];
            if (view == nil)
                {
                    NSLog(@"MenuBar: can't find the view with tag 1010");
                    return;
                }
            menuBar = [[ControlBar alloc] initWithNibName:name bundle:nil];
            menuBar.delegate = self;
            [view addSubview:menuBar.view];
            [self addChildViewController:menuBar];

            view = [self.view viewWithTag:5];
            //[view removeFromSuperview];
            view.hidden = YES;  // Hide this view
            UIButton *btnDone = [Helper createBlueButton:view.frame withTitle:@"Done"];
            btnDone.tag = kBtnNoteDone;
            [menuBar addButton:btnDone atIndex:100];

            [menuBar addBackButonWithTitle:@"Cancel"];

        }



    - (void)removeMenuBar
        {
            [menuBar.view removeFromSuperview];
            [menuBar removeFromParentViewController];
            menuBar.view = nil;
            menuBar = nil;
        }



    - (void)addMenuBar
        {
            [self addMenuBar:@"BaseNoteControlBarKeyboard"];
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];
            [self addMenuBar];
            ((UIScrollView *) noteContent).delegate = self;
            UIView *view = [self.view viewWithTag:6];
            [view removeFromSuperview];

            noteContent.delegate = self;
            drawContent.hidden   = YES;
            [menuBar setItemSelected:kBtnKeyboard isSelected:YES];

            _recordButton = [Helper createRedButton:view.frame withTitle:@"Record"];
            _recordButton.tag = kBtnRecord;
            // [menuBar addButton:_recordButton atIndex:2];

            // Speechkit enablement
            [SpeechKit setupWithID:@"NMDPPRODUCTION_King_County_iRealProperty_20120531131509"
                              host:@"oy.nmdp.nuancemobility.net"
                              port:443
                            useSSL:NO
                          delegate:self];

            // Set earcons to play
            SKEarcon *earconStart  = [SKEarcon earconWithName:@"earcon_listening.wav"];
            SKEarcon *earconStop   = [SKEarcon earconWithName:@"earcon_done_listening.wav"];
            SKEarcon *earconCancel = [SKEarcon earconWithName:@"earcon_cancel.wav"];

            [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
            [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
            [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];

            [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];

    		if([currentNote.major length]==0 || [currentNote.minor length]==0)
                [self hideHome:YES];
            else
                [self hideHome:NO];
            [menuBar setItemEnable:kBtnMicrophone isEnable:YES];
        }



    - (void)viewDidUnload
        {
            [self setDrawContent:nil];
            [super viewDidUnload];
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                    duration:(NSTimeInterval)duration
        {
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
                {
                    self.view.frame = CGRectMake(0, 0, 1024, 768);

                    menuBar.view.frame = CGRectMake(0, 0, 1024, menuBar.view.frame.size.height);

                }
            else
                {
                    self.view.frame    = CGRectMake(0, 0, 768, 1024);
                    menuBar.view.frame = CGRectMake(0, 0, 768, menuBar.view.frame.size.height);

                }
            UIView *view = [self.view viewWithTag:1010];
            view.frame = menuBar.view.frame;
        }



    - (void)adjustControlBar
        {
            if (UIInterfaceOrientationIsLandscape([Helper deviceOrientation]))
                {
                    menuBar.view.frame = CGRectMake(0, 0, 1024, menuBar.view.frame.size.height);

                }
            else
                {
                    menuBar.view.frame = CGRectMake(0, 0, 768, menuBar.view.frame.size.height);
                }

        }

@end
