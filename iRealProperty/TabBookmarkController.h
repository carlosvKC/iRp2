#import <UIKit/UIKit.h>
#import "BookmarkController.h"
#import "ControlBar.h"
#import "BaseNote.h"
#import "GridBookmark.h"

#define kBookmarkBorder     30.0  // border on each side
#define kBookmarkSep        20.0  // between each cell of bookmark

#define kBmBtnDelete  6

// cv 9/1/2014 reserve 0 to 16 for rpBookmark types
#define kBookmarkErrorRegular   (1<<4)  // 16
#define kBookmarkErrorLand      (1<<5)
#define kBookmarkErrorBuilding  (1<<6)
#define kBookmarkErrorMobile    (1<<7)
#define kBookmarkErrorAccessory (1<<8)
#define kBookmarkErrorHistory   (1<<9)
#define kBookmarkErrorHIE       (1<<10)
#define kBookmarkErrorInterest  (1<<11)
#define kBookmarkErrorNote      (1<<12)
#define kBookmarkErrorValue     (1<<13)
#define kBookmarkErrorDetails   (1<<14)
#define kBookmarkErrorSync      (1<<15)
//#define kBookmarkErrorSync       (9)

enum {
    kBtnBookmarkMap = 24,
    kBtnBookmarkGrid = 25,
    kBookmarkTrash = 7
    
};
typedef signed char		BOOL;
// cv BOOL is explicitly signed so @encode(BOOL) == "c" rather than "C"
// even if -unsigned-char is used.

#if __has_feature(objc_bool)
#define BLANK             __objc_yes
#define COMPLETED              __objc_no
#else
#define COMPLETED             ((BOOL)1)
#define BLANK              ((BOOL)0)
#endif

@class TabMapDetail;
@class BaseNote;

@interface TabBookmarkController : ScreenController<BookmarkDelegate, MenuBarDelegate, UIPopoverControllerDelegate,
    NoteMgrDelegate, GridDelegate>
{
    NSMutableArray  *bookmarkViews;
    ControlBar      *menuBar;
    UIPopoverController *_popOver;
    BOOL editMode;
    BaseNote        *baseNote;
    ScreenController *gridController;
    BOOL            gridVisible;
    //cv
    RealPropInfo *realPropInfo;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *noBookmarkDefined;

@property (strong, nonatomic) TabMapDetail *mapDetail;

- (void) addBookmarksToView;
-(void)displayDetail:(BookmarkController *)bookmark;
- (void)deleteBookmark:(BookmarkController *)bookmarkView;

+(void)updateBookmarkErrors;
+(void)updateBookmarkErrors:(int)filter withInfo:(RealPropInfo *)info;

+(void)createBookmark:(NSString *)reason
             withInfo:(RealPropInfo *)info
             typeItem:(int)bookmarkType
           typeItemId:(int)bookmarkTypeItem;

+(void)createBookmark:(NSString *)reason
             withInfo:(RealPropInfo *)info
             typeItem:(int)bookmarkType
          withContext:(NSManagedObjectContext*)context;

+(void)createBookmarkfromRPInfo:(NSString *)reason
                       withInfo:(RealPropInfo *)info
                       typeItem:(int)bookmarkType
                     typeItemId:(int)boomarkTypeItem
                    withContext:(NSManagedObjectContext*)context;

+ (void)createBookmarkWithReason:(NSString *)reason
                        withInfo:(RealPropInfo *)info;

@end
