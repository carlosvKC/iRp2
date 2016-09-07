#import "TabSearchItems.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "TabSearchController.h"
#import "TabSearchGrid.h"
#import "ComboBoxController.h"
#import "RealPropertyApp.h"

@implementation VisibleItem

@synthesize viewLabel;
@synthesize viewObject;
@synthesize viewObjectBtn;
@synthesize strValue;
@synthesize dateValue;
@synthesize numValue;
@synthesize btnHelp;
@synthesize itemHelp;
@synthesize refTitle, maxChars, filter, defaultValue, isRequired, refObjectName;
@synthesize choice;

-(id)initWithSearchItem:(SearchItem *)searchItem
{
	self = [super init];
	if(self)
	{
		itemHelp = searchItem.itemHelp;
		refTitle = searchItem.refTitle;
		maxChars = searchItem.maxChars;
		filter = searchItem.filter;
		defaultValue = searchItem.defaultValue;
		isRequired = searchItem.isRequired;
		refObjectName = searchItem.refObjectName;
		choice = searchItem.choice;
		viewObjectBtn = nil;
	}	
	return self;
}
@end


@implementation TabSearchItems
@synthesize itsController;
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
	[self.view addSubview:btnHelp];

	return btnHelp;
}
-(void)displayHelp:(id)sender
{
	for(VisibleItem *item in items)
	{
		if(item.btnHelp==sender)
		{
			CGSize destSize = CGSizeMake(240, 80);
			CGSize textSize = [item.itemHelp sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
			
			helpViewController = [[UIViewController alloc]init];
			CGRect helpRect = CGRectMake(0, 0, textSize.width + 30, textSize.height + 10);

			UILabel *labelView = [[UILabel alloc]initWithFrame:helpRect];
			labelView.numberOfLines = 0;
			labelView.text = item.itemHelp;
			labelView.textAlignment = NSTextAlignmentCenter;
			helpViewController.view = labelView;
			CGRect rect = helpViewController.view.frame;

			helpViewController.contentSizeForViewInPopover = rect.size;			
			helpPopover = [[UIPopoverController alloc]initWithContentViewController:helpViewController];
			[helpPopover presentPopoverFromRect:item.btnHelp.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
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
-(void)removeAllObjects
{
	// Release the different list of objects
	if(items!=nil)
	{
		for(VisibleItem *item in items)
		{
			[item.btnHelp removeFromSuperview];
			[item.viewLabel removeFromSuperview];
			if([item.viewObject isKindOfClass:[UITextField class]])
			{
				[item.viewObject removeFromSuperview];
			} 
			else if([item.viewObject isKindOfClass:[ComboBoxController class]])
			{
				ComboBoxController *ctrl = item.viewObject;
				[ctrl.view removeFromSuperview];
				[ctrl removeFromParentViewController];
				item.viewObject = nil;
			}
			[item.viewObjectBtn removeFromSuperview];
			item.dateValue = nil;
			item.strValue = nil;
		}
		[items removeAllObjects];
		items = nil;
	}
	if(btnSearch!=nil)
	{
		[btnSearch removeFromSuperview];
		btnSearch = nil;
	}
}
//
// Create the entities and all the different fields
-(void)setSearchDefinition:(SearchDefinition2 *)param
{

	items = [[NSMutableArray alloc]initWithCapacity:[param.items count]];
	for(SearchItem *searchItem in param.items)
	{
		VisibleItem *item = [[VisibleItem alloc]initWithSearchItem:searchItem];
		[items addObject:item];
	}

	UILabel *label = (UILabel *)[self.view viewWithTag:21];	// look for the top UI label
	
	label.text = param.searchDescription;
    label.textColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
	
	int topy = label.frame.size.height + 80;
	int center = self.view.frame.size.width/3;
	// Create the different objects
	int charWidth = 15;
	int inputSep = 46;	// delta between 2 input areas
	int dateWidth = 120;
	int btnWidth = 190;
	int btnHeight = 38;
	int margin = 5;
	int inputHeight = 31;
	for(int i=0;i<[items count];i++)
	{
		VisibleItem *searchItem = [items objectAtIndex:i];
		int width;
		// if there is a help, add it
		if([searchItem.itemHelp length]!=0)
		{
			searchItem.btnHelp = [self createHelpButton:topy];
			width = (center - searchItem.btnHelp.frame.size.width - 2 *margin);
		}
		else
		{
			width = (center - 2 *margin);
		}
        CGSize destSize = CGSizeMake(width, 10000.0);
        CGSize textSize = [searchItem.refTitle sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
		
		// Create the attached label
		CGRect rect = CGRectMake(center-margin-textSize.width, topy-(textSize.height/2.0),textSize.width, textSize.height );
		UILabel *label = [[UILabel alloc]initWithFrame:rect];
		label.text = searchItem.refTitle;
		label.textColor = [Helper UIColorFromRGB255:76 green:86 blue:108];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentRight;
		searchItem.viewLabel = label;
		[self.view addSubview:label];

		// Create the input area
		int max = searchItem.maxChars;
		if(max==0)
			max = 10;
		int w = charWidth * max;
		if(center+w>self.view.frame.size.width-2*margin)
			w = self.view.frame.size.width-(center + 2*margin);
		rect = CGRectMake(center, topy-inputHeight/2, w, inputHeight);
		
		if(searchItem.filter==kSearchDate)
		{
			rect = CGRectMake(center, topy-inputHeight/2, dateWidth, inputHeight);
			ComboBoxController *cmbDate = [[ComboBoxController alloc]initForDate:rect];
			searchItem.viewObject = cmbDate;
			[self.view addSubview:cmbDate.view];
			[(ComboBoxView *)cmbDate.view setEnabled:YES];
			[self addChildViewController:cmbDate];
			NSDate *date;
			if([searchItem.defaultValue length]==0)
				date = [Helper localDate];
			else
				date = [Helper dateFromString:searchItem.defaultValue];
			[cmbDate setSelectionDate:date];
		}
		else
		{
			// Create a text field
			UITextField *textField = [[UITextField alloc]initWithFrame:rect];
			textField.returnKeyType = UIReturnKeySearch;
			textField.placeholder = @"";
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			textField.adjustsFontSizeToFitWidth = NO;
			textField.borderStyle = UITextBorderStyleRoundedRect;
			textField.tag = i+1;
			textField.clearButtonMode = YES;

			textField.textColor = [UIColor blackColor]; //text color
			textField.font = [UIFont systemFontOfSize:17.0];  //font size
			textField.backgroundColor = [UIColor whiteColor]; //background color
			textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
			
			if(searchItem.filter == kSearchNumerical)
				textField.keyboardType = UIKeyboardTypeNumberPad;  // type of the keyboard
			else
				textField.keyboardType = UIKeyboardTypeDefault;

			[textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEnd];
			textField.delegate = self;
			[self.view addSubview:textField];
			searchItem.viewObject = textField;
			if([searchItem.defaultValue length]!=0)
				textField.text = searchItem.defaultValue;
			if(searchItem.isRequired && [textField.text length]==0)
				textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
			
			// Create a "choice" button (if it exists)
			if([searchItem.choice length]>0)
			{
				UIImage *btnImage = [UIImage imageNamed:@"ExpandArrow.png"];
				rect = CGRectMake(rect.origin.x + rect.size.width + 10,
								  rect.origin.y, 40 , 31);
				UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
				btn.frame = rect;

				[btn setBackgroundImage:btnImage forState:UIControlStateNormal];
				[btn setTitle:@"" forState:UIControlStateNormal];
				[self.view addSubview:btn];
				btn.tag = 1000+i;
				[btn addTarget:self action:@selector(multipleChoice:) forControlEvents:UIControlEventTouchUpInside];
				searchItem.viewObjectBtn = btn;

			}

		}
		
		
		// Go the next line
		topy += inputSep;

	}
	topy += 50;
	// Create the confirmation button
	topy += inputSep;
	UIImage *blueButtonImage = [UIImage imageNamed:@"btnBlue38.png"];
	CGRect rect = CGRectMake(self.view.frame.size.width/2 - btnWidth/2, topy, btnWidth, btnHeight);
	btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
	btnSearch.frame = rect;
	UIImage *strechable = [blueButtonImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
	[btnSearch setBackgroundImage:strechable forState:UIControlStateNormal];
	[btnSearch setTitle:@"Search Properties" forState:UIControlStateNormal];
	
	btnSearch.titleLabel.textColor = [UIColor whiteColor];
	
	[btnSearch addTarget:self action:@selector(performSearch:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnSearch];
}
//
// Prepare the search
//
-(void)performSearch:(id)sender
{
//#warning - believe that sometimes there is a memory issue here
	[Helper findAndResignFirstResponder:self.view];
	
	NSMutableDictionary *variables = [[NSMutableDictionary alloc]init];
	// Perform the search now
	for(VisibleItem *searchItem in items)
	{
		id object = searchItem.viewObject;
		if(object==nil)
			continue;
		
		id value;
		if([object isKindOfClass:[UITextField class]])
		{
			UITextField *tField = object;
			value = tField.text;
			if(searchItem.isRequired)
			{
				if([value length] == 0)
				{
					NSString *msg = [NSString stringWithFormat:@"The field '%@' cannot be empty!", searchItem.refTitle];
					[Helper alertWithOk:@"Field Required" message:msg];
					return;
				}
			}
			if([value length] == 0)
			{
				// Empty field
				if(searchItem.defaultValue!=nil)
					value = searchItem.defaultValue;
				else
					value = @"";
			}
			if(searchItem.filter==kSearchNumerical)
			{
				value = [[NSNumber alloc]initWithInt:[value intValue]];
			}
		}
		else if([object isKindOfClass:[ComboBoxController class]])
		{
			ComboBoxController *ctrl = object;
			value = [ctrl getSelectionDate];
		}
		else
			continue;
		NSString *var = [searchItem.refObjectName stringByReplacingOccurrencesOfString:@"$" withString:@""];
		[variables setObject:value forKey:var];
	}

	[variables setObject:[RealPropertyApp getUserName] forKey:@"User"];
	[variables setObject:[Helper localDate] forKey:@"Now"];
	[itsController searchWithArray:variables];
	
	
}
#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self performSearch:textField];
	return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	VisibleItem *item;
	
	for(VisibleItem *it in items)
	{
		if((UITextField *)it.viewObject==textField)
		{
			item = it;
			break;
		}
	}
	if(item==nil)
	{
		return YES;
	}
	if(item.filter == kSearchDate)
	{
		NSString *text = textField.text;
		NSDate *date = [Helper dateFromString:text];
		if(text.length==0)
			return YES;
		if(date==0)
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid value" message:@"A date must be entered in the following format: MM/DD/YYYY" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			alert = nil;
			return NO;
		} 
	}
	return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
	VisibleItem *item;
	for(VisibleItem *it in items)
	{
		if((UITextField *)it.viewObject==textField)
		{
			item = it;
			break;
		}
	}
	if(item==nil)
		return;
	NSDate *date;
	
	switch(item.filter)
	{
		case kSearchAlphabetical:
			item.strValue = textField.text;
			break;
		case kSearchDate:
			date = [Helper dateFromString:textField.text];
			item.dateValue = date;
			break;
		case kSearchNumerical:
			item.numValue = [textField.text intValue];
			break;
	}
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if(range.length==1)
        return YES;
	VisibleItem *item;
	for(VisibleItem *it in items)
	{
		if((UITextField *)it.viewObject==textField)
		{
			item = it;
			break;
		}
	}
	if(item==nil)
		return NO;
	
	if(item.isRequired && textField.text.length==0)
		textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
	else
		textField.backgroundColor = [UIColor whiteColor];
	
    NSString *allowedChars;
    
    switch(item.filter)
    {
		case kSearchNumerical:
            allowedChars = @"0123456789";
            break;
        case kSearchDate:
            allowedChars = @"0123456890/-";
            break;
        default:
            return YES;
    }
    // Now it is one of the field that we control...
    NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:allowedChars] invertedSet];
    return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
}
-(void)textFieldDone:(id)sender
{
	[sender resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[Helper UIColorFromRGB255:223 green:226 blue:231]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}

- (IBAction)clickInBackground:(id)sender 
{
    [Helper findAndResignFirstResponder:self.view];
}
-(void)multipleChoice:(UIButton *)btn
{
	visItem = [items objectAtIndex:btn.tag-1000];
	
    NSArray *strItems = [visItem.choice componentsSeparatedByString:@"."];
    if(strItems.count>2)
        return;
    // Now we should have only either one
    // element or maximum 2 elements
    NSString *root = nil;
    NSString *item = nil;
    
    if(strItems.count==1)
    {
        root = @"RealPropInfo";
        item = [strItems objectAtIndex:0];
    }
    else if(strItems.count==2)
    {
        root = [strItems objectAtIndex:0];
        item = [strItems objectAtIndex:1];
    }
    else
        return;
    
    // Read to do a select dictinct
    NSArray *results = [AxDataManager distinctSelect:root fieldName:item sortAscending:YES andPredicate:nil withContext:[AxDataManager defaultContext]];
        
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:results.count];
    
    for(id object in results)
    {
        if([object isKindOfClass:[NSDictionary class]])
        {
            id res = [object objectForKey:item];
            [array addObject:[NSString stringWithFormat:@"%@", res]];
        }
    }
    popOver = [[ComboBoxPopOver alloc]initWithArrayAndViewRect:array inView:self.view destRect:btn.frame selectedRow:0 withMaxItems:20];
    popOver.delegate = self;

}
- (void)popoverItemSelected: (id)object
{
    NSString *text = @"";
    if([object isKindOfClass:[NSString class]])
        text = object;
	else
		return;
	
	UITextField *textField = visItem.viewObject;
	
	textField.text = text;
	
}
-(void)popoverItemSelected:(id)object index:(int)index
{
    NSString *text = @"";
    if([object isKindOfClass:[NSString class]])
        text = object;
	else
		return;    
	UITextField *textField = visItem.viewObject;
	
	textField.text = text;
}

@end
