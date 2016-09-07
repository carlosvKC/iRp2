#import "SurveyNote.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "XMLSurvey.h"
#import "ComboBoxController.h"
#import "CheckBoxView.h"
#import "MenuTable.h"
#import "IRNote.h"
#import "TabNotesController.h"

@implementation SurveyNote

@synthesize surveyDefinition = _surveyDefinition;
@synthesize scrollView;
@synthesize parcelNbr;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    noteType = kNotesSurvey;
    return self;
}
//
// Override the standard note
-(void)closeForm:(id)sender
{
    [Helper findAndResignFirstResponder:self.view];
    if(self.currentNote==nil)
    {
        return;
    }
    // Update the content
    self.currentNote.note = [self convertSurveyToString];
    self.currentNote.parcelNbr = parcelNbr.text;
    self.currentNote.updateDate = [[Helper localDate]timeIntervalSinceReferenceDate] ;
    self.currentNote.type = noteType;
    NSManagedObjectContext *context = [AxDataManager noteContext];
    NSError *error;
    [context save:&error];
    // Last call
    [self.delegate noteMgrCloseNote:self];
}
//
// Creates the help button - y is the center of the button
//
-(UIButton *)createHelpButton:(int)y
{
	UIImage *btnImage = [UIImage imageNamed:@"help2.png"];
	CGRect rect = CGRectMake(5, y-(btnImage.size.height/2), btnImage.size.width, btnImage.size.height);
	
	UIButton *btnHelp = [UIButton buttonWithType:UIButtonTypeCustom];
	btnHelp.frame = rect;
	[btnHelp setBackgroundImage:btnImage forState:UIControlStateNormal];
	
	[btnHelp addTarget:self action:@selector(displayHelp:) forControlEvents:UIControlEventTouchUpInside];
	[self.scrollView addSubview:btnHelp];
    
	return btnHelp;
}
-(void)displayHelp:(id)sender
{
	for(SurveyObject *item in _surveyDefinition.surveyObjects)
	{
		if(item.btnHelp==sender)
		{
			// NSLog(@"'%@'",item.itemHelp);
			
			CGSize destSize = CGSizeMake(240, 80);
			CGSize textSize = [item.help sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
			
			helpViewController = [[UIViewController alloc]init];
			CGRect helpRect = CGRectMake(0, 0, textSize.width + 30, textSize.height + 10);
            
			UILabel *labelView = [[UILabel alloc]initWithFrame:helpRect];
			labelView.numberOfLines = 0;
			labelView.text = item.help;
			labelView.textAlignment = NSTextAlignmentCenter;
			helpViewController.view = labelView;
			CGRect rect = helpViewController.view.frame;
            
			helpViewController.contentSizeForViewInPopover = rect.size;			
			helpPopover = [[UIPopoverController alloc]initWithContentViewController:helpViewController];
			[helpPopover presentPopoverFromRect:item.btnHelp.frame inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
			helpPopover.delegate = self;
		}
	}
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[helpPopover dismissPopoverAnimated:NO];
	helpPopover = nil;
	helpViewController.view = nil;
	helpViewController = nil;
}

//
// Create the entities and all the different fields
-(void)setSurveyDefinition:(SurveyDefinition *)param;
{
	// Release the different list of objects
	if(_surveyDefinition!=nil)
	{
        for(SurveyObject *item in _surveyDefinition.surveyObjects)
		{
            [item.btnHelp removeFromSuperview];
			[item.viewLabel removeFromSuperview];
            [item.viewObject removeFromSuperview];
			item.viewObject = nil;
			item.viewLabel = nil;
			item.btnHelp = nil;
		}
	}
    _surveyDefinition = param;
    
    // Look for the survey title and the survey definition
	UILabel *surveyTitle = (UILabel *)[self.scrollView viewWithTag:21];	// look for the top UI label
	surveyTitle.text = _surveyDefinition.title;
	
    // Survey definition
    UILabel *defLabel = (UILabel *)[self.scrollView viewWithTag:22];
    defLabel.text = _surveyDefinition.desc;
    
    
	int topy = defLabel.frame.origin.y +  defLabel.frame.size.height;
	// Create the different objects
	int charWidth = 15;
	int lineSep = 46;	// delta between 2 input areas
	int dateWidth = 120;
	int margin = 5;
	int inputHeight = 31;

    // --------------------------------------------------------------------- Loop through the objects
	for(int i=0;i<[_surveyDefinition.surveyObjects count];i++)
	{
        CGFloat center;

        SurveyObject *surveyItem = [_surveyDefinition.surveyObjects objectAtIndex:i];
		int width;
        
        // Create a separator
        if(surveyItem.itemType == kSurveyLine)
        {
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, topy, self.scrollView.frame.size.width, 2.0)];
            lineView.backgroundColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
            [self.scrollView addSubview:lineView];
            surveyItem.viewObject = lineView;
            topy += lineSep;
            continue;
        }
        // Create a text
        if(surveyItem.itemType == kSurveyText)
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, topy, self.scrollView.frame.size.width, 20.0)];
            label.text = surveyItem.title;
            label.textColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            surveyItem.viewLabel = label;
            [self.scrollView addSubview:label];
            topy += lineSep;
            continue;
        }
        // Center the text
        center = (self.scrollView.frame.size.width * surveyItem.position) / 100.0;
        
		// if there is a help, add it
		if([surveyItem.help length]!=0)
		{
			surveyItem.btnHelp = [self createHelpButton:topy];
			width = (center - surveyItem.btnHelp.frame.size.width - 2 *margin);
		}
		else
		{
			width = (center - 2 *margin);
		}

        
        // Create the attached label
        CGSize destSize = CGSizeMake(width, 10000.0);
        CGSize textSize = [surveyItem.title sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
		
		CGRect rect = CGRectMake(center-margin-textSize.width, topy-(textSize.height/2.0),textSize.width, textSize.height );
		UILabel *label = [[UILabel alloc]initWithFrame:rect];
		label.text = surveyItem.title;
		label.textColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentRight;
		surveyItem.viewLabel = label;
		[self.scrollView addSubview:label];
        
        if(surveyItem.itemType==kSurveyCheckbox)
        {
            int height = 28.0;
			CGRect rect = CGRectMake(center, topy-height/2.0, 60.0, height);
            CheckBoxView *checkBox = [[CheckBoxView alloc]initWithFrame:rect];
			[self.scrollView addSubview:checkBox];
            surveyItem.viewObject = checkBox;
            
            if([surveyItem.defaultValue caseInsensitiveCompare:@"on"]==NSOrderedSame ||
               [surveyItem.defaultValue caseInsensitiveCompare:@"yes"]==NSOrderedSame)
            {
                [checkBox setChecked:NO];
            }
            else 
            {
                [checkBox setChecked:YES];
            }
            // Go the next line
            topy += lineSep;
            continue;
        }
        else if(surveyItem.itemType==kSurveyChoices)
        {
            // Create the default label on the right
			CGRect rect = CGRectMake(center, topy-inputHeight/2, 250.0, inputHeight);
			ComboBoxController *cmbChoices = [[ComboBoxController alloc]initForStrings:surveyItem.choices inRect:rect];

			[self.scrollView addSubview:cmbChoices.view];
			[(ComboBoxView *)cmbChoices.view setEnabled:YES];
			[self addChildViewController:cmbChoices];
            
			surveyItem.viewObject = cmbChoices;
            // Go the next line
            topy += lineSep;
            continue;
            
        }
		else if(surveyItem.itemType==kSurveyDate)
		{
			CGRect rect = CGRectMake(center, topy-inputHeight/2, dateWidth, inputHeight);
			ComboBoxController *cmbDate = [[ComboBoxController alloc]initForDate:rect];
			[self.scrollView addSubview:cmbDate.view];
			[(ComboBoxView *)cmbDate.view setEnabled:YES];
			[self addChildViewController:cmbDate];
			NSDate *date = [Helper dateFromString:surveyItem.defaultValue];
			[cmbDate setSelectionDate:date];

			surveyItem.viewObject = cmbDate;
            // Go the next line
            topy += lineSep;
            continue;
		}
		else if(surveyItem.itemType==kSurveyInput)
		{
            // Create the input area
            if(surveyItem.maxChars==0)
                surveyItem.maxChars = 10;
            int w = charWidth * surveyItem.maxChars;
            if(center+w>self.scrollView.frame.size.width-2*margin)
                w = self.scrollView.frame.size.width-(center + 2*margin);
            CGRect rect = CGRectMake(center, topy-inputHeight/2, w, inputHeight);

			// Create a text field
			UITextField *textField = [[UITextField alloc]initWithFrame:rect];
			textField.returnKeyType = UIReturnKeySearch;
			textField.placeholder = @"";
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			textField.adjustsFontSizeToFitWidth = NO;
			textField.borderStyle = UITextBorderStyleRoundedRect;
			textField.tag = i+1;
            
			textField.textColor = [UIColor blackColor]; //text color
			textField.font = [UIFont systemFontOfSize:17.0];  //font size
			textField.backgroundColor = [UIColor whiteColor]; //background color
			textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
			
			[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEnd];
			textField.delegate = self;
			[self.scrollView addSubview:textField];
			
            surveyItem.viewObject = textField;
            // Go the next line
            topy += lineSep;
            continue;
		}
	}
    
    topy += lineSep;
    if(topy > self.scrollView.frame.size.height)
    {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, topy);
    }
}

-(NSString *)convertSurveyToString
{
    NSString *note = @"";
    note = [note stringByAppendingFormat:@"%@\n", parcelNbr.text];
    
    for(SurveyObject *item in _surveyDefinition.surveyObjects)
    {
        if([item.viewObject isKindOfClass:[ComboBoxController class]])
        {
            ComboBoxController *controller = item.viewObject;
            if(controller.comboBoxStyle == kComboBoxStyleDate)
            {
                note = [note stringByAppendingFormat:@"%@: %@\n", item.title, [Helper stringFromDate:controller.getSelectionDate]];
            }
            else if(controller.comboBoxStyle == kComboBoxStyleText)
            {
                int selection = [controller getSelection];
                note = [note stringByAppendingFormat:@"%@: %@\n", item.title, [item.choices objectAtIndex:selection]];
            }
        }
        else if([item.viewObject isKindOfClass:[UITextField class]])
        {
            UITextField *field = item.viewObject;
            note = [note stringByAppendingFormat:@"%@: %@\n", item.title, field.text];
        }
        else if([item.viewObject isKindOfClass:[CheckBoxView class]])
        {
            CheckBoxView *cmbView;
            note = [note stringByAppendingFormat:@"%@: %@\n", item.title, (cmbView.isChecked?@"yes":@"no")];
           
        }
    }
    return note;
}
#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.length==1)
        return YES;
	SurveyObject *item;
	for(SurveyObject *it in _surveyDefinition.surveyObjects)
	{
		if((UITextField *)it.viewObject==textField)
		{
			item = it;
			break;
		}
	}
	if(item==nil || [item.filter length]==0)
		return YES;
    
    // Now it is one of the field that we control...
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:item.filter] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
}
-(void)textFieldDone:(id)sender
{
	[sender resignFirstResponder];
}
//
// Hide the keyboard when finding the background view
//
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	int backgroundTag = 11;
    if(self.view.tag==backgroundTag)
    {
        [self.view endEditing:YES];
        return;
    }
    // Enumerate through all the touch objects.
    for (UITouch *touch in touches) 
    {
        for (UIView *aView in [self.view subviews]) 
        {
            if (CGRectContainsPoint([aView frame], [touch locationInView:self.view]) && aView.tag==backgroundTag)
            {
                [aView endEditing:YES];
                return;
            }
        }
    }	
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - View lifecycle
-(void) addMenuBar
{
    [self addMenuBar:@"SurveyNoteControlBar"];
}
- (void)viewDidLoad
{
    _skipSpeech = YES;
    [super viewDidLoad];
   
}
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setParcelNbr:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}

@end
