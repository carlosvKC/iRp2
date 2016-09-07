#import "DVShape.h"

@interface DVShapeText : DVShape<NSCopying>
{
    NSString    *_text;
    CGRect      _frame;
    CGFloat     _fontSize;
    UIColor     *_fontColor;
    NSString    *_fontName;
    UIColor     *_backColor;
}
@property(nonatomic) CGPoint startCorner;
@property(nonatomic) CGPoint endCorner;
@property(nonatomic) CGRect frame;
@property(nonatomic, strong)  NSString *text;
@property(nonatomic, strong) UIColor *backColor;
@property(nonatomic) BOOL isLength;
@property(nonatomic) BOOL isAutoText;

-(void)adjustRect:(CGPoint)pt atCorner:(int)corner;
-(id)initWithFrame:(CGRect)frame;
-(UIFont *)getFontForScale:(CGFloat)scale;
-(id)initWithText:(NSString *)text origin:(CGPoint)origin;
-(void)flipVertical:(BOOL)vertical aroundPoint:(CGPoint)center;

@end
