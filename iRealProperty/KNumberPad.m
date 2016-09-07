#import "KNumberPad.h"
#import "UIColor+Hex.h"

#define TOTAL_BUTTONS 12

#define COL_TWO 105
#define COL_THREE 215

@implementation KNumberPad

@synthesize delegate;

- (id) initWithDelegate:(id) del
{
	self = [super init];
    
	if(self)
	{
		self.delegate = del;
        
        for(int i = 0; i < TOTAL_BUTTONS; i++)
		{
			int column = i % 3;
			int row = i / 3;
            
			BOOL isLong = column == 1;
			float buttonWidth = isLong ? 110 : 105;
			float buttonHeight = 54;
            
			KNumberPadButton *button = [[KNumberPadButton alloc] init];
            
			float colX = column == 2 ? COL_THREE : COL_TWO;
			if(column < 1) colX = 0;
            
			button.frame = CGRectMake(colX, row*buttonHeight, buttonWidth, buttonHeight);
			button.index = i;
			button.delegate = self.delegate;
            
			[self addSubview:button];
            
			switch (i)
			{
				case 0:
					[button setLabel:@"1" withSubLabel:@""];
					break;
				case 1:
					[button setLabel:@"2" withSubLabel:@"ABC"];
					break;
				case 2:
					[button setLabel:@"3" withSubLabel:@"DEF"];
					break;
				case 3:
					[button setLabel:@"4" withSubLabel:@"GHI"];
					break;
				case 4:
					[button setLabel:@"5" withSubLabel:@"JKL"];
					break;
				case 5:
					[button setLabel:@"6" withSubLabel:@"MNO"];
					break;
				case 6:
					[button setLabel:@"7" withSubLabel:@"PQRS"];
					break;
				case 7:
					[button setLabel:@"8" withSubLabel:@"TUV"];
					break;
				case 8:
					[button setLabel:@"9" withSubLabel:@"WXYZ"];
					break;
				case 9:
					button.inactive = YES;
					button.reversed = YES;
					break;
				case 10:
					[button setLabel:@"0" withSubLabel:@""];
					break;
				case 11:
					button.reversed = YES;
					[button setUpIcon:@"delete_white.png" andOverIcon:@"delete_delete.png"];
					break;
			}
            
            button = nil;
		}
	}
    
	return self;
}

- (void)dealloc
{
}

@end

@implementation KNumberPadButton

@synthesize inactive, reversed, numberLabel, delegate, index;

- (id) init
{
	self = [super init];
    
	if(self)
	{
		numberLabel = [[UILabel alloc] init];
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.textAlignment = NSTextAlignmentCenter;
		numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
		numberLabel.shadowOffset = CGSizeMake(0, -1.0);
		[self addSubview:numberLabel];
        
		subLabel = [[UILabel alloc] init];
		subLabel.backgroundColor = [UIColor clearColor];
		subLabel.textAlignment = NSTextAlignmentCenter;
		subLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
		subLabel.shadowOffset = CGSizeMake(0, -1.0);
		[self addSubview:subLabel];
	}
    
	return self;
}

- (void) setUpIcon:(NSString *) up andOverIcon:(NSString *) over
{
	iconView = [[UIImageView alloc] initWithFrame:self.bounds];
	upIcon = [UIImage imageNamed:up];
	overIcon = [UIImage imageNamed:over];
    
	iconView.image = upIcon;
    
	[self addSubview:iconView];
}

- (void) setLabel:(NSString *) label withSubLabel:(NSString *) slabel
{
	numberLabel.frame = CGRectMake(0, 2, self.frame.size.width, 35);
	numberLabel.text = label;
    
	subLabel.frame = CGRectMake(0, 25, self.frame.size.width, 35);
	subLabel.text = slabel;
    
	if(reversed)
	{
		numberLabel.textColor = [UIColor colorWithHex:0xff4d5462];
		subLabel.textColor = [UIColor colorWithHex:0xff4d5462];
        
		numberLabel.shadowColor = [UIColor colorWithHex:0xffe1e2e5];
		subLabel.shadowColor = [UIColor colorWithHex:0xffe1e2e5];
	}
	else
	{
		numberLabel.textColor = [UIColor whiteColor];
		subLabel.textColor = [UIColor whiteColor];
        
		numberLabel.shadowColor = [UIColor colorWithHex:0xff2e3138];
		subLabel.shadowColor = [UIColor colorWithHex:0xff2e3138];
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(inactive) return;
    
	if(reversed)
	{
		numberLabel.textColor = [UIColor whiteColor];
		subLabel.textColor = [UIColor whiteColor];
        
		numberLabel.shadowColor = [UIColor colorWithHex:0xff2e3138];
		subLabel.shadowColor = [UIColor colorWithHex:0xff2e3138];
	}
	else
	{
		numberLabel.textColor = [UIColor colorWithHex:0xff4d5462];
		subLabel.textColor = [UIColor colorWithHex:0xff4d5462];
        
		numberLabel.shadowColor = [UIColor colorWithHex:0xffe1e2e5];
		subLabel.shadowColor = [UIColor colorWithHex:0xffe1e2e5];
	}
    
	if(iconView) iconView.image = overIcon;
    
	selected = YES;
	[self setNeedsDisplay];
    
	if(delegate && [delegate respondsToSelector:@selector(didTouchButtonWithIndex:)])
		[delegate didTouchButtonWithIndex:self.index];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(inactive) return;
    
	if(reversed)
	{
		numberLabel.textColor = [UIColor colorWithHex:0xff4d5462];
		subLabel.textColor = [UIColor colorWithHex:0xff4d5462];
        
		numberLabel.shadowColor = [UIColor colorWithHex:0xffe1e2e5];
		subLabel.shadowColor = [UIColor colorWithHex:0xffe1e2e5];
	}
	else
	{
		numberLabel.textColor = [UIColor whiteColor];
		subLabel.textColor = [UIColor whiteColor];
        
		numberLabel.shadowColor = [UIColor colorWithHex:0xff2e3138];
		subLabel.shadowColor = [UIColor colorWithHex:0xff2e3138];
	}
    
	if(iconView) iconView.image = upIcon;
    
	selected = NO;
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
	CGFloat locations[2];
	locations[0] = 0.0;
	locations[1] = 1.0;
    
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    
	if((selected && !reversed) || (!selected && reversed))
	{
		[colors addObject:(id)[[UIColor colorWithHex:0xffdddee1] CGColor]];
		[colors addObject:(id)[[UIColor colorWithHex:0xffb3b7be] CGColor]];
	}
	else
	{
		[colors addObject:(id)[[UIColor colorWithHex:0xff6e7582] CGColor]];
		[colors addObject:(id)[[UIColor colorWithHex:0xff4d5462] CGColor]];
	}
    
	CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
	CGPoint end   = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
	CGContextClipToRect(context, rect);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    CGGradientRelease(gradient);
    
	CGContextSetLineWidth(context, 1.0);
    
	// Highlight
	CGColorRef highlightColor = [[UIColor colorWithHex:0xff9398a2] CGColor];
	CGContextSetStrokeColor(context, CGColorGetComponents(highlightColor));
    
	CGContextMoveToPoint(context, 0, 1);
	CGContextAddLineToPoint(context, rect.size.width, 1);
	CGContextStrokePath(context);
    
	// Dark Outline
	CGColorRef outlineColor = [[UIColor colorWithHex:0xff404040] CGColor];
	CGContextSetStrokeColor(context, CGColorGetComponents(outlineColor));
    
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, rect.size.width, 0);
    
	CGContextMoveToPoint(context, rect.size.width, 0);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
	CGContextStrokePath(context);
    
	CGColorSpaceRelease(space);
}

- (void)dealloc
{
	if(iconView)
	{
		iconView = nil;
		upIcon = nil;
		overIcon = nil;
	}
    
	subLabel = nil;
	numberLabel = nil;
}

@end