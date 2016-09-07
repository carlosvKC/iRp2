
#import <UIKit/UIKit.h>
#import "DVImagePicker.h"
#import "RealPropInfo.h"
#import "MediaBldg.h"
enum  {
    
    kOptionSave = 1,
    kOptionCancel
};

@protocol DVKeyboardOptionDelegate <NSObject>

-(void)dvKeyboardOptionBackground:(MediaBldg *)image;
-(void)dvKeyboardOptionShowBackground:(BOOL)on;
-(void)dvKeyboardOptionShowLegend:(BOOL)on;
-(void)dvKeyboardOptionClose;
-(void)dvKeyboardOptionAdjustBackground:(BOOL)on;
-(void)dvKeyboardOptionAdjustLegend:(BOOL)on;
-(void)dvKeyboardOptionsCopyLayer;
-(void)dvKeyboardOptionsPasteLayer;
-(void)dvKeyboardOptionsCopyDrawing;
-(void)dvKeyboardOptionsPasteDrawing;
@end

@interface DVKeyboardOption : UIViewController<DVImagePickerDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController *popover;
    DVImagePicker *picker;
    
}
@property(nonatomic, weak) id<DVKeyboardOptionDelegate> delegate;

@property(nonatomic, weak) RealPropInfo *realPropInfo;
@property(nonatomic) BOOL showBackground;
@property(nonatomic) BOOL showLegend;


@property (weak, nonatomic) IBOutlet UIButton *btnAdjustBackground;
@property (weak, nonatomic) IBOutlet UIButton *btnAdjustLegend;
@property (weak, nonatomic) IBOutlet UIButton *btnCopyLayer;
@property (weak, nonatomic) IBOutlet UIButton *btnPasteLayer;
@property (weak, nonatomic) IBOutlet UIButton *btnCopyDrawing;
@property (weak, nonatomic) IBOutlet UIButton *btnPasteDrawing;
- (IBAction)actionAdjustBackground:(UIButton *)sender;
- (IBAction)actionAdjustLegend:(id)sender;
- (IBAction)actionCopyLayer:(id)sender;
- (IBAction)actionPasteLayer:(id)sender;
- (IBAction)actionCopyDrawing:(id)sender;
- (IBAction)actionPasteDrawing:(id)sender;


@end
