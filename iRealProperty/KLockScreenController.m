
#import "KLockScreenController.h"
#import "UIColor+Hex.h"

@implementation KLockScreenController

@synthesize delegate;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) didTouchButtonWithIndex:(int) i
{
	if(i == 11 && currText)
	{
		currCode.bottomLabel.text = @"";
        if(currText.length>0)
            currText = [currText substringToIndex:[currText length] - 1] ;
	}
	else
	{
		i = i+1;
		if(i == 11) 
            i = 0;
		if(currText)
        {
            if(currText.length<4)
                currText = [NSString stringWithFormat:@"%@%d", currText, i];
		}
        else
            currText = [NSString stringWithFormat:@"%d", i];
	}
    
	[currCode setFull:currText.length];
    
	[self performSelector:@selector(testPass) withObject:nil afterDelay:1];
}

- (void) testPass
{
	if(currText.length == 4)
	{
		if(!showLock)
		{
			if(delegate && [delegate respondsToSelector:@selector(didSubmitPassCode:withClear:)])
			{
				BOOL success = [delegate didSubmitPassCode:currText withClear:clearLock];
				if(success) 
                    [self cancel];
				else 
                    currCode.bottomLabel.text = @"Passcode incorrect!";
			}
		}
		else if(!entered)
		{
			entered = currText;
			currText = @"";
			[currCode setFull:0];
			[self showNextCode];
		}
		else if([currText isEqualToString:entered])
		{
			if(delegate && [delegate respondsToSelector:@selector(didSubmitLock:)])
			{
				[delegate didSubmitLock:currText];
				[self cancel];
			}
		}
		else if(entered && ![currText isEqualToString:entered])
		{
			codeView1.bottomLabel.text = @"Passcodes did not match. Try again.";
			currText = @"";
			[currCode setFull:0];
			[self resetPasscodes];
		}
	}
}

- (id) initWithLock:(BOOL)shouldLock shouldClearLock:(BOOL)clear
{
	self = [super init];
    
	if(self)
	{
		showLock = shouldLock;
		clearLock = clear;
        currText = @"";
	}
    
	return self;
}

- (void) showUnlock
{
	navBar = [[UINavigationBar alloc] init];
	navBar.barStyle = UIBarStyleBlackOpaque;
	navBar.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:navBar];
    
	UINavigationItem *item = [[UINavigationItem alloc] init];
	item.title = clearLock ? @"Turn off Passcode" : @"Enter a passcode";
    
	if(clearLock)
	{
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
		item.rightBarButtonItem = rightButton;
	}
    
	[navBar setItems:[NSArray arrayWithObject:item]];
    
	item = nil;
    
	codeView1 = [[KCodeView alloc] init];
	codeView1.frame = CGRectMake(0, 44, 320, 200);
	codeView2 = [[KCodeView alloc] init];
	codeView2.frame = CGRectMake(-320, 44, 320, 200);
    
	[self.view addSubview:codeView1];
    
	currCode = codeView1;
    
	currCode.topLabel.text = @"Enter your passcode";
}

- (void) showLock
{
	navBar = [[UINavigationBar alloc] init];
	navBar.barStyle = UIBarStyleBlackOpaque;
	navBar.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:navBar];
    
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
	UINavigationItem *item = [[UINavigationItem alloc] init];
	item.title = @"Set Passcode";
    
	item.rightBarButtonItem = rightButton;
    
	[navBar setItems:[NSArray arrayWithObject:item]];
    
	item = nil;
	rightButton = nil;
    
	codeView1 = [[KCodeView alloc] init];
	codeView1.topLabel.text = @"Enter a passcode";
	codeView1.frame = CGRectMake(0, 44, 320, 200);
	codeView2 = [[KCodeView alloc] init];
	codeView2.topLabel.text = @"Re-enter your passcode";
	codeView2.frame = CGRectMake(-320, 44, 320, 200);
    
	[self.view addSubview:codeView1];
	[self.view addSubview:codeView2];
	currCode = codeView1;
}

- (void) cancel
{
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void) viewDidLoad
{
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
	numPad = [[KNumberPad alloc] initWithDelegate:self];
	numPad.frame = CGRectMake(0, (480 - 216) - 20, 320, 216);
	[self.view addSubview:numPad];
        
	if(showLock) [self showLock];
	else [self showUnlock];
}

- (void) resetPasscodes
{
	entered = nil;
    
	currCode = codeView1;
	codeView1.frame = CGRectMake(320, codeView1.frame.origin.y, codeView1.frame.size.width, codeView1.frame.size.height);
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
    
	codeView1.frame = CGRectMake(0, codeView1.frame.origin.y, codeView1.frame.size.width, codeView1.frame.size.height);
	codeView2.frame = CGRectMake(-codeView2.frame.size.width, codeView2.frame.origin.y, codeView2.frame.size.width, codeView2.frame.size.height);
    
	[UIView commitAnimations];
}

- (void) showNextCode
{
	currCode = codeView2;
	codeView2.bottomLabel.text = @"";
	codeView2.frame = CGRectMake(320, 44, 320, 200);
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
    
	codeView1.frame = CGRectMake(-codeView1.frame.size.width, codeView1.frame.origin.y, codeView1.frame.size.width, codeView1.frame.size.height);
	codeView2.frame = CGRectMake(0, codeView2.frame.origin.y, codeView2.frame.size.width, codeView2.frame.size.height);
    
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
	if(entered) entered = nil;
	if(codeView1) codeView1 = nil;
	if(codeView2) codeView2 = nil;
	navBar = nil;
}

@end

@implementation KCodeView

@synthesize topLabel, bottomLabel;

- (void) setFull:(int) full
{
	one.image = full >= 1 ? [UIImage imageNamed:@"secureFull.png"] : [UIImage imageNamed:@"secure.png"];
	two.image = full >= 2 ? [UIImage imageNamed:@"secureFull.png"] : [UIImage imageNamed:@"secure.png"];
	three.image = full >= 3 ? [UIImage imageNamed:@"secureFull.png"] : [UIImage imageNamed:@"secure.png"];
	four.image = full == 4 ? [UIImage imageNamed:@"secureFull.png"] : [UIImage imageNamed:@"secure.png"];
}

- (id) init
{
	self = [super init];
    
	if(self)
	{
		one = [[UIImageView alloc] init];
		one.frame = CGRectMake(25, 75, 61, 52);
		two = [[UIImageView alloc] init];
		two.frame = CGRectMake(one.frame.origin.x + one.frame.size.width + 10, one.frame.origin.y, 61, 52);
		three = [[UIImageView alloc] init];
		three.frame = CGRectMake(two.frame.origin.x + two.frame.size.width + 10, one.frame.origin.y, 61, 52);
		four = [[UIImageView alloc] init];
		four.frame = CGRectMake(three.frame.origin.x + three.frame.size.width + 10, one.frame.origin.y, 61, 52);
        
		one.image = [UIImage imageNamed:@"secure.png"];
		two.image = [UIImage imageNamed:@"secure.png"];
		three.image = [UIImage imageNamed:@"secure.png"];
		four.image = [UIImage imageNamed:@"secure.png"];
        
		[self addSubview:one];
		[self addSubview:two];
		[self addSubview:three];
		[self addSubview:four];
        
		float labelHeight = 30;
        
		topLabel = [[UILabel alloc] init];
		topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
		topLabel.textAlignment = NSTextAlignmentCenter;
		topLabel.backgroundColor = [UIColor clearColor];
		topLabel.textColor = [UIColor colorWithHex:0xff4c566c];
		topLabel.shadowColor = [UIColor colorWithHex:0xffffffff];
		topLabel.shadowOffset = CGSizeMake(0, -1.0);
		topLabel.frame = CGRectMake(0, four.frame.origin.y - (labelHeight+15), 320, labelHeight);
		[self addSubview:topLabel];
        
		bottomLabel = [[UILabel alloc] init];
		bottomLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
		bottomLabel.textAlignment = NSTextAlignmentCenter;
		bottomLabel.backgroundColor = [UIColor clearColor];
		bottomLabel.textColor = [UIColor colorWithHex:0xffff0000];    // 0xff4d576d
		bottomLabel.shadowColor = [UIColor colorWithHex:0xffffffff];
		bottomLabel.shadowOffset = CGSizeMake(0, -1.0);
		bottomLabel.frame = CGRectMake(0, four.frame.origin.y + four.frame.size.height + 15, 320, labelHeight);
		[self addSubview:bottomLabel];
	}
    
	return self;
}

- (void)dealloc
{
	topLabel = nil;
	bottomLabel = nil;
	one = nil;
	two  = nil;
	three = nil;
	four = nil;
}


@end

