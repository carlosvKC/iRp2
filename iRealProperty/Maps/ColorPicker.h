#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate
- (void)colorSelected:(UIColor*)color forTarget: (id) target;
@end

@interface ColorPicker : UIViewController
{
    id<ColorPickerDelegate> __weak _delegate;
    UIButton* _target;
    UISlider* __weak _opacitySlider;
    UILabel * __weak _opacityPercentageLabel;
    UIColor* _selectedColor;
}

@property (nonatomic, strong) UIColor* selectedColor;
@property (nonatomic, strong) UIButton* target;
@property (nonatomic, weak) id<ColorPickerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UISlider* opacitySlider;
@property (nonatomic, weak) IBOutlet UILabel * opacityPercentageLabel;

-(IBAction)colorButtonClicked:(id)sender;
-(IBAction)seOpacityPercentage:(UISlider *)sender;
@end

@interface UIColor (expanded)
- (CGColorSpaceModel) colorSpaceModel;
- (NSString *) colorSpaceString;
- (BOOL) canProvideRGBComponents;
- (CGFloat) red;
- (CGFloat) green;
- (CGFloat) blue;
- (CGFloat) alpha;
- (NSString *) stringFromColor;  
- (NSString *) hexStringFromColor;  
+ (UIColor *) colorWithString: (NSString *) stringToConvert; 
+ (UIColor *) colorWithByteString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert; 
@end