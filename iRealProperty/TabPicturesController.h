#import <UIKit/UIKit.h>
#import "AxDelegates.h"
#import "MenuTable.h"
#import "ControlBar.h"
#import "ScreenController.h"
#import "NIBReader.h"
#import "DVModelController.h"

@class RealProperty;
@class PictureView;
@class PictureDetails;

enum  {
    kBtnDelete = 7,
    kBtnDetail = 12,
    kBtnOptions = 13,
    kBtnEditVectors = 20
};
// The different type of pictures
enum kPictureTypeConstant {
    kPictureAll = 1,
    kPictureLand = 2,
    kPictureBuilding = 3,
    kPictureAccy = 4,
    kPictureMobile = 5,
    kPictureNote = 6
};

@interface PictureInfo : NSObject 
{
    BOOL    isPrincipal;
    NSString *description;    
}
@end

@protocol TabPicturesDelegate <NSObject>

-(void)tabPicturesDelegateDismiss;
@optional
-(void)dvModelCompleted:(DVModelController *)model completion:(BOOL)cancel animate:(BOOL)animate;


@end

@interface TabPicturesController : ScreenController<UINavigationControllerDelegate, MenuBarDelegate, ModalViewControllerDelegate, DVModelControllerDelegate>
{
    UIPopoverController *imgPopover;
    
    MenuTable *menu;
    ControlBar *menuBar;
    
    int defaultFilter;
    
    PictureView *pictView;
    PictureDetails *itsDialogBox;
    
    int currentIndex;
    
    NIBReader *nibReader;
    
    DVModelController *modelController;
// 4/26/16 HNN preserve existing drawing by saving changes to a new media record
    //    BOOL    newObject;
}

@property(nonatomic, weak) IBOutlet UILabel *pictLabel;
// list of medias
@property(nonatomic, strong) NSMutableArray *medias;
// current media
@property(nonatomic, strong) id currentMedia;
@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) id<TabPicturesDelegate> delegate;

-(void)moveToPreviousPicture;
-(void)moveToNextPicture;
- (IBAction)clickInPicture:(id)sender;

@end
