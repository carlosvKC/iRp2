
#import <UIKit/UIKit.h>
#import "AxDelegates.h"
#import "ScreenController.h"
#import "GridControlBar.h"
#import "NIBReader.h"
#import "DVModelController.h"
#import "TabPicturesController.h"

@class TabBaseDetail;
@class TabBaseGrid;
@class RealProperty;
@class PictureDetails;

@interface TabBase : ScreenController<GridDelegate, ModalViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DVModelControllerDelegate, TabPicturesDelegate>
{
    
    // Current set of information
    NSArray             *setEntities;
    // Current entity being consulted
    int                 currentIndex;
    // name of the default objects
    NSString            *defaultBaseEntity;
    NSString            *defaultMediaEntity;
    NSString            *defaultGridTitle;
    NSString            *defaultContentTitle;

    // Current base NIB name
    NSString            *baseNibName;

    // Private variables
    BOOL gridIsDisplay;
    int tabIndex;
    int currentBar;
    PictureDetails *mediaDialogBox;  
    
    BOOL dontUseDetailController;
    ScreenController *gridController;
    ScreenController *detailController;
    
    UIButton *btnDelete;
    MediaAccy *mediaAccy;
    AxGridPictController *_grid;
    
    // for the image picker

    UIButton *btnCancel, *btnPicture, *btnPictureInt;
    UILabel *imgLabel;
    UIImage *cameraImage;
    int cameraPictCount;
    CGAffineTransform *cameraViewTransform;
    
    // List of subcontrollers
    TabBase *activeSubController; 
    NIBReader   *nibReader;
    
    // Play with the animation
    BOOL    doingAnimation;

    BOOL animationOn;
    
    // Blocks the different selectors
    UIView  *topView, *bottomView;
    
    // Model controller
    DVModelController   *modelController;

}


@property(nonatomic) BOOL animationOn;
@property (nonatomic, strong) GridControlBar  *controlBar;
@property (nonatomic, strong) ScreenController *detailController;
@property (nonatomic, strong) ScreenController *gridController;
@property (nonatomic, strong) TabBase *activeSubController;
- (id)initWithNibName:(NSString *)portrait landscape:(NSString *)landscape;
- (id)initWithNibName:(NSString *)portrait portraitId:(int)pId landscape:(NSString *)landscape landscapeId:(int)lId;
-(void) displayGrid;
-(void) displayDetail;
-(void) updateDetailMedia;
-(void) switchControlBar:(enum GridControlBarConstant)bar;
-(void) gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex;
-(void) defaultMediaInformation:(id)media;
-(void) defaultMediaInformation:(id)media postToWeb:(BOOL)interiorPict;

-(BOOL) shouldSwitchView;
-(void) deleteMedia:(id)media;
-(void)didSwitchToSubController;

//@property(nonatomic) BOOL buildingToPlan;

@end
