#import <UIKit/UIKit.h>
#import "CheckBoxView.h"
#import "DVLayerList.h"
#import "DVKeyboardOption.h"
enum 
{
    kToolLine = 0,
    kToolText = 1,
    kToolArc = 2,
    kToolClose = 3,
    kToolAlign = 4,
    kToolGrid = 5,
    kToolAdjustBackground,
    kToolMove
};
enum 
{
    kCbGrid = 1,
    kCbBackground = 2
};
@protocol DVKeykoardDelegate <NSObject>

// New data has been input
-(void)dvKeyboardInput:(CGFloat)value direction:(int)directin;
// Select a new angle
-(void)dvKeyboardAngle:(int)angleDegree;
// Click on an arrow
-(void)dvKeyboardArrow:(int)arrow;
// Select/Deselect the cross arrow
-(void)dvKeyboardCross:(BOOL)selection;
// Select a specific tool
-(void)dvKeyboardSelectTool:(int)tool;
// Undo
-(void)dvKeyboardPaste;
// Delete
-(void)dvKeyboardCut;
// Close area
-(void)dvKeyboardClose;
// Turn on or off the grid
-(void)dvKeyboardShowGrid:(BOOL)show;
// Align or not align on the grid
-(void)dvKeyboardAlign:(BOOL)align;

// Return the list of layers
-(NSArray *)dvKeyboardGetLayers;
// Activate a layer
-(void)dvKeyboardSelectLayer:(DVLayer *)layer;
// Force a refresh of the mode
-(void)dvKeyboardRefreshAll;
// Tell the controller to save the model and exit
-(void)dvKeyboardAction:(int)action;

// Manage the options
-(void)dvKeyboardAdjustBackground:(BOOL)on;
-(void)dvKeyboardBackground:(MediaBldg *)media;
-(void)dvKeyboardShowBackground:(BOOL)on;
-(void)dvKeyboardAdjustLegend:(BOOL)on;
-(void)dvKeyboardShowLegend:(BOOL)on;
-(void)dvKeyboardCopyLayer;
-(void)dvKeyboardPasteLayer;
-(void)dvKeyboardCopyDrawing;
-(void)dvKeyboardPasteDrawing;
-(void)dvFlipVertical:(BOOL)vertical;
@end

@interface DVKeyboard : UIViewController<UIPopoverControllerDelegate, DVLayerListDelegate,
    DVKeyboardOptionDelegate,
    UIAlertViewDelegate>
{
    BOOL        hasDot;
    NSString    *input;
    int         direction;
    BOOL        crossSelected;
    int         currentTool;
    int         digitsBeforeDot;
    int         digitsAfterDot;
    
    // Manage the layer menu
    DVLayerList *_layerList;
    UIPopoverController *popover;
    
    DVKeyboardOption *_option;
    
    BOOL        _showBackground,
                _adjustBackground,
                _showLegend,
                _adjustLegend;

}
// Options
@property(nonatomic) BOOL optionMetric;
@property(nonatomic) BOOL optionGridHidden;
@property(nonatomic) BOOL optionGridAlign;

@property (weak, nonatomic) IBOutlet UILabel *layerTitle;
@property (weak, nonatomic) IBOutlet DVDashView *layerLine;
- (IBAction)backgroundTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) id<DVKeykoardDelegate>delegate;
@property(nonatomic) int currentTool;
@property(nonatomic) int direction;
@property(nonatomic) BOOL crossSelected;
@property(nonatomic, strong) DVKeyboardOption *option;
@property(nonatomic) BOOL showLegend;
@property (weak, nonatomic) IBOutlet UILabel *labelAction;
- (IBAction)btnSelectLayers:(id)sender;

-(void)pasteLayerButtonActive:(BOOL)active;
-(void)updateLayer:(DVLayer *)layer;
@end
