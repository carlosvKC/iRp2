//
//  BarChart.h
//
//  Modified Created by Dain on 7/23/10.
//  Copyright 2010 Dain Kaplan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"

@interface BarChartView : UIView 
{	
	NSMutableArray *_barItems;
	float _sum;
	ChartItemColor _noDataFillColor;
	ChartItemColor _gradientFillColor;
	
	float _gradientStart;
	float _gradientEnd;
    BOOL _valid;
    UIImage* cacheImage;
    UIImageView* chartRenderView;
}
@property (nonatomic, retain) UIImage* cacheImage;

- (void)clearItems;
- (void)addItemValue:(float)value withColor:(ChartItemColor)color;
- (void)setNoDataFillColorRed:(float)r green:(float)g blue:(float)b;
- (void)setNoDataFillColor:(ChartItemColor)color;
- (void)setGradientFillColorRed:(float)r green:(float)g blue:(float)b;
- (void)setGradientFillColor:(ChartItemColor)color;

// Values ranging from 0.0-1.0 specifying where to begin/end the fills. 
// E.g. A start of 0.0 starts at the top of the piechart, and 0.3 starts a third of the way from the top.
- (void)setGradientFillStart:(float)start andEnd:(float)end;

// draw the pie to a cache image (if cach is invalid) and return it
- (UIImage*)drawToImage: (CGRect)rect;

// invalidate cache pie image.
- (void) InvalidatedCache;
@end
