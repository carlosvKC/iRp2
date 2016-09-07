#import <Foundation/Foundation.h>
#import "DVShape.h"

@interface DVLabel : NSObject<NSCopying>
{
    // Info for the labeling
    UIColor     *_labelColor;
    CGFloat     _labelFontSize;
    BOOL        _hidden;
    NSString    *_text;
    NSString    *_fontName;

    CGRect      _frame;
    CGPoint     _rotationCenter;
    
    CGFloat     _slope;
    
    CGFloat     _offset;

}
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic) CGFloat fontSize;
@property(nonatomic) BOOL hidden;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSString *fontName;
@property(nonatomic) BOOL autoPosition;

@property(nonatomic) CGFloat offset;
@property(nonatomic, weak) id<DVShapeDelegate>delegate;

-(void)drawLabel:(CGContextRef)gc;
-(void)positionLabel:(CGPoint)startPt endPoint:(CGPoint)endPt;
@end
