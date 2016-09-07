#import <UIKit/UIKit.h>
#import "DVShape.h"
#import "CheckBoxView.h"
#import "ControlBar.h"
#import "DVImagePicker.h"
#import "DVKeyboard.h"
#import "DVLayer.h"
#import "DVLayerList.h"
#import "MediaBldg.h"
#import "MediaAccy.h"
#import "KeyboardController.h"
#import "DVSelection.h"
@class DVModelView;
@class DVShape;
@class DVShapeText;
@class CheckBoxView;
@class RealPropInfo;

enum  {
    kTagBackground = 14,
    kTagSelectLayers =15
    };
enum {
    kCadNew = 1,
    kCadUpdate =2, // 4/26/16 HNN preserve existing drawing by creating new media
    kCadUpdateNew // 4/26/16 HNN new drawings only need to be created once, any updates to them should replace the existing new record
};

enum {
    mResBldg = 1,
    mCndoBldg =2,
    mCmlBldg =3,
    mAccy =4,
    mMobile=5,
    mMediaBldg
};

@class DVModelController;

@protocol DVModelControllerDelegate <NSObject>
@optional
-(void)dvModelCompleted:(DVModelController *)model completion:(BOOL)cancel animate:(BOOL)animate;

@end

@interface DVUndoObject : NSObject
@property(nonatomic, strong) DVLayer    *layer;
@property(nonatomic, strong) DVShape    *shape;
-(id)init:(DVLayer *)layer shape:(DVShape *)shape;
@end

@interface DVModelController : KeyboardController<UIScrollViewDelegate, UITextViewDelegate, UIPopoverControllerDelegate, DVImagePickerDelegate, DVKeykoardDelegate, UIAlertViewDelegate,DVSelectionDelegate>
{
    // Current information
    CGFloat _lastScale;
    CGFloat _currentScale;
    CGSize  _drawViewSize;
    CGPoint _beginLoc;
    CGPoint _currentLoc;
    
    CGPoint _currentTouch;
    CGPoint _lastTouch;
    NSTimeInterval  _time;
    CGPoint _intersectPoint;
    
    enum
    {
        kDrawNone,
        kDrawing,
        
        kRotateShape,
        kMoveShape,
        kResizeArc,
        kMoveScreen,
        kMoveBackground,
        kMoveLegend
    } _penMode;
    
    int     _previousPenMode;
    int     _currentTool;
    
    DVModelView *_model;
    DVShape *_selectedShape;
    int     _touchPoint;
    
    CGFloat _originalScale;
    
    UITextView  *_textView;
    DVShapeText *_shapeEdited;
    
    DVKeyboard *_keyboard;
    
    NSMutableArray *_undoObjects;
    
    UIAlertView     *_alert, *_alertArea;
    UIAlertView     *_pasteAlert;
    BOOL          _isDirty;

    UIButton    *_adjustButton;
    
    DVLayer     *copyLayer;
    
    int         _lastSelection;
    
    DVSelection *_popMenu;
    
    NSTimer     *_longTouchTimer;
    CGFloat     _currentArea;

}
@property (nonatomic) CGFloat minScale;
@property (nonatomic) CGFloat maxScale;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segDrawMove;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segTools;

@property (strong, nonatomic) RealPropInfo *realPropInfo;
@property (strong, nonatomic) id<DVModelControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnMoveScreen;
- (IBAction)moveScreenSelection:(UIButton *)sender;

@property(strong, nonatomic) MediaBldg *mediaBldg;
// 4/27/17 HNN not used
//@property(strong, nonatomic) MediaAccy *mediaAccy;
// 4/26/16 HNN provide guid of new media created on save
@property(strong, nonatomic) NSString *sketchGuid;

//@property(strong, nonatomic) MediaBldg *mediaBldgNew;


@property(nonatomic) int mediaMode;


-(void)loadModel:(NSString *)xmlName;

//cv
-(void)setPenMode:(int)mode;
-(void)openModel;

-(void)willRotateToLandscapeOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
