
#import <Foundation/Foundation.h>

@interface ChartParameter : NSObject

// text for the legend
@property (nonatomic, strong) NSString *legendText;

// value of this parameter
@property (nonatomic) float value;

// color to draw this parameter, this color has to be RGB compatible
@property (nonatomic, strong) UIColor *color;

@end
