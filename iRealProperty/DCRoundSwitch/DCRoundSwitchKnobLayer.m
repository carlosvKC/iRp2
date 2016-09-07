//
//  DCRoundSwitchKnobLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchKnobLayer.h"
CGGradientRef CreateGradientRefWithColors(CGColorSpaceRef colorSpace, UIColor *startColor, UIColor *endColor);

@implementation DCRoundSwitchKnobLayer
@synthesize gripped;

- (void)drawInContext:(CGContextRef)context
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGRect knobRect = CGRectInset(self.bounds, 2, 2);
	CGFloat knobRadius = self.bounds.size.height - 2;

	// knob outline (shadow is drawn in the toggle layer)
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.62 alpha:1.0].CGColor);
	CGContextSetLineWidth(context, 1.5);
	CGContextStrokeEllipseInRect(context, knobRect);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0, NULL);

	// knob inner gradient  // Value: 0.82, 894 and 996
	CGContextAddEllipseInRect(context, knobRect);
	CGContextClip(context);
	UIColor* knobStartColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.0];
	UIColor* knobEndColor =  (self.gripped) ? 
                                [UIColor colorWithRed:0.894 green:0.894 blue:0.894 alpha:1.0] :
                                [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
	CGPoint topPoint = CGPointMake(0, 0);
	CGPoint bottomPoint = CGPointMake(0, knobRadius + 2);
	CGGradientRef knobGradient = CreateGradientRefWithColors(colorSpace, knobStartColor, knobEndColor);
	CGContextDrawLinearGradient(context, knobGradient, topPoint, bottomPoint, kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(knobGradient);

	// knob inner highlight
	CGContextAddEllipseInRect(context, CGRectInset(knobRect, 0.5, 0.5));
	CGContextAddEllipseInRect(context, CGRectInset(knobRect, 1.5, 1.5));
	CGContextEOClip(context);
	CGGradientRef knobHighlightGradient = CreateGradientRefWithColors(colorSpace, [UIColor whiteColor], [UIColor colorWithWhite:1.0 alpha:0.5]);
	CGContextDrawLinearGradient(context, knobHighlightGradient, topPoint, bottomPoint, 0);
	CGGradientRelease(knobHighlightGradient);
	CGColorSpaceRelease(colorSpace);
}

CGGradientRef CreateGradientRefWithColors(CGColorSpaceRef colorSpace, UIColor* startColor, UIColor *endColor)
{
    CGFloat gradientColor[8];
    CGFloat red, green, blue, alpha;
    
    [startColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    gradientColor[0] = red;
    gradientColor[1] = green;
    gradientColor[2] = blue;
    gradientColor[3] = alpha;

    [endColor getRed:&red green:&green blue:&blue alpha:&alpha];
    gradientColor[4] = red;
    gradientColor[5] = green;
    gradientColor[6] = blue;
    gradientColor[7] = alpha;

    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColor, nil, 2);
    return gradient;
}

- (void)setGripped:(BOOL)newGripped
{
	gripped = newGripped;
	[self setNeedsDisplay];
}

@end
