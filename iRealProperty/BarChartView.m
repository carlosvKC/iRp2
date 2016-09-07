//
//  BarChart.m
//
//  Modified from Created by Dain on 7/23/10.
//  Copyright 2010 Dain Kaplan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BarChartView.h"
#import "Helper.h"

@interface BarChartItem : NSObject
{
	ChartItemColor _color;
	float _value;
}

@property (nonatomic, assign) ChartItemColor color;
@property (nonatomic, assign) float value;

@end


@implementation BarChartItem

- (id)init
{	
    if ((self = [super init])) {
		_value = 0.0;
	}
	return self;
}

@synthesize color = _color;
@synthesize value = _value;

@end


@interface BarChartView()
// Private interface
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
- (UIImage *)createGradientImageUsingRect:(CGRect)rect;
@end

@implementation BarChartView

@synthesize cacheImage;

- (id)initWithFrame:(CGRect)aRect
{	
    if ((self = [super initWithFrame:aRect])) {
		_gradientFillColor = PieChartItemColorMake(0.0, 0.0, 0.0, 0.4);
		_gradientStart = 0.3;
		_gradientEnd = 1.0;
		self.backgroundColor = [UIColor clearColor];
        _valid = NO;
        cacheImage = nil;
        chartRenderView = [[UIImageView alloc] initWithFrame:aRect];
        [self addSubview:chartRenderView];
	}
	return self;
}

// XXX: In the case this view is being loaded from a NIB/XIB (and not programmatically)
// initWithCoder is called instead of initWithFrame:
- (id)initWithCoder:(NSCoder *)decoder
{	
    if ((self = [super initWithCoder:decoder])) {
		_gradientFillColor = PieChartItemColorMake(0.0, 0.0, 0.0, 0.4);
		_gradientStart = 0.3;
		_gradientEnd = 1.0;
		self.backgroundColor = [UIColor clearColor];
        _valid = NO;
        cacheImage = nil;
        chartRenderView = [[UIImageView alloc] initWithFrame:self.frame];
        chartRenderView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:chartRenderView];
	}
	return self;
}

- (void)clearItems 
{
	if( _barItems ) {
		[_barItems removeAllObjects];	
	}
	
	_sum = 0.0;
    [self InvalidatedCache];
}

- (void)addItemValue:(float)value withColor:(ChartItemColor)color
{
	BarChartItem *item = [[BarChartItem alloc] init];
	
	item.value = value;
	item.color = color;
	
	if( !_barItems ) {
		_barItems = [[NSMutableArray alloc] initWithCapacity:3];
	}
	
	[_barItems addObject:item];
	
	_sum += value;
    
    [self InvalidatedCache];
}

- (void)setNoDataFillColorRed:(float)r green:(float)g blue:(float)b
{
	_noDataFillColor = PieChartItemColorMake(r, g, b, 1.0);
}

- (void)setNoDataFillColor:(ChartItemColor)color
{
	_noDataFillColor = color;
}

- (void)setGradientFillColorRed:(float)r green:(float)g blue:(float)b
{
	_gradientFillColor = PieChartItemColorMake(r, g, b, 0.4);
}

- (void)setGradientFillColor:(ChartItemColor)color
{
	_gradientFillColor = color;
}

- (void)setGradientFillStart:(float)start andEnd:(float)end
{
	_gradientStart = start;
	_gradientEnd = end;
}

- (void)drawRect:(CGRect)rect {
	
    chartRenderView.frame = rect;
	[chartRenderView setImage:[self drawToImage:rect]];
    [super drawRect:rect];
}

- (void) InvalidatedCache
{
    if (cacheImage != nil)
    {
        cacheImage = nil;
       
    }
    _valid = NO;
}
- (UIImage*)drawToImage: (CGRect)rect
{
    if (!_valid)
    {
        if (cacheImage != nil)
        {
            cacheImage = nil;
        }
        _valid = YES;
        UIGraphicsBeginImageContext( rect.size );
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        float startDeg = 0;
        float endDeg = 0;
#define DELTA 10
        CGRect frame = CGRectMake(DELTA, DELTA, rect.size.width-2*DELTA, rect.size.height-2*DELTA);
        
        CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.4);
        CGContextSetLineWidth(ctx, 1.0);
        
        // Draw a thin line around the rectangle
        CGContextAddRect(ctx, frame);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        // Loop through all the values and draw the graph
        startDeg = 0;
        
        
        NSUInteger idx = 0;
        for( idx = 0; idx < [_barItems count]; idx++ ) 
        {
            
            BarChartItem *item = [_barItems objectAtIndex:idx];
            
            ChartItemColor color = item.color;
            float currentValue = item.value;
            
            float theta = (frame.size.width * (currentValue/_sum));
            
            if( theta > 0.0 ) 
            {
                endDeg += theta;
                
                if( startDeg != endDeg ) 
                {
                    CGContextSetRGBFillColor(ctx, color.red, color.green, color.blue, color.alpha );
                    CGRect drawRect = CGRectMake(frame.origin.x+ startDeg, 
                                                 frame.origin.y, 
                                                 endDeg - startDeg, frame.size.height);
                    CGContextAddRect(ctx, drawRect);
                    CGContextClosePath(ctx);
                    CGContextFillPath(ctx);
                    // Draw the text in the midle of the rectange
                    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0 );
                    int value = currentValue;
                    NSString *str = [NSString stringWithFormat:@"%d", value];

                    [Helper drawTextInRect:str fontName:@"Helvetica" fontSize:15.0 minimumFontSize:2.0 destRect:drawRect textAlign:NSTextAlignmentCenter];
                }
            }
            
            startDeg = endDeg;
        }
        
        // Now we want to create an overlay for the gradient to make it look *fancy*
        // We do this by:
        // (0) Create circle mask
        // (1) Creating a blanket gradient image the size of the piechart
        // (2) Masking the gradient image with a circle the same size as the piechart
        // (3) compositing the gradient onto the piechart
        // (0)
        UIImage *maskImage = [self createRectangleMaskUsingRect: frame];
        
        // (1)
        UIImage *gradientImage = [self createGradientImageUsingRect: frame];
        
        // (2)
        UIImage *fadeImage = [self maskImage:gradientImage withMask:maskImage];
        
        // (3)
        CGContextDrawImage(ctx, rect, fadeImage.CGImage);

        // Finally set shadows
        self.layer.shadowRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowOffset = CGSizeMake(0.0, 5.0);

        
        cacheImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsPopContext();
        
    }
    
    return cacheImage;
}
- (UIImage *)createRectangleMaskUsingRect:(CGRect)rect
{
	UIGraphicsBeginImageContext( self.bounds.size );
	CGContextRef ctx2 = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(ctx2, 1.0, 1.0, 1.0, 1.0 );
	CGContextFillRect(ctx2, self.bounds);
	CGContextSetRGBFillColor(ctx2, 0.0, 0.0, 0.0, 1.0 );
    CGContextAddRect(ctx2, rect);
	CGContextClosePath(ctx2);
	CGContextFillPath(ctx2);
	UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsPopContext();
	
	return maskImage;
}

// Shout out to: http://stackoverflow.com/questions/422066/gradients-on-uiview-and-uilabels-on-iphone
- (UIImage *)createGradientImageUsingRect:(CGRect)rect
{
	UIGraphicsBeginImageContext( rect.size );
	CGContextRef ctx3 = UIGraphicsGetCurrentContext();
	
	size_t locationsCount = 2;
    CGFloat locations[2] = { 1.0-_gradientStart, 1.0-_gradientEnd };
    CGFloat components[8] = { /* loc 2 */ 0.0, 0.0, 0.0, 0.0, /* loc 1 */ _gradientFillColor.red, _gradientFillColor.green, _gradientFillColor.blue, _gradientFillColor.alpha };
	
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, locationsCount);
	
    CGPoint topCenterPoint = CGPointMake(0,0);
    CGPoint bottomCenterPoint = CGPointMake(0,rect.size.height);
    CGContextDrawLinearGradient(ctx3, gradient, topCenterPoint, bottomCenterPoint, 0);
	
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace); 
	UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsPopContext();
	
	return gradientImage;
}

// Masks one image with another
// Shout out to: http://iphonedevelopertips.com/cocoa/how-to-mask-an-image.html
- (UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	
	CGImageRef maskRef = maskImage.CGImage; 
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	UIImage *ret = [UIImage imageWithCGImage:masked];
	CGImageRelease(masked);
	CGImageRelease(mask);
	return ret;
	
}


- (void)dealloc {
    [self InvalidatedCache];
}

@end
