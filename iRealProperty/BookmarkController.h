
#import <UIKit/UIKit.h>

@class Bookmark;
@class BookmarkController;
@class TabBookmarkController;
@class RealPropInfo;

@protocol BookmarkDelegate <NSObject>

-(void)bookmarkDelete:(BookmarkController *)bmk;
-(void)bookmarkEditNote:(BookmarkController *)bmk;
-(void)bookmarkMap:(BookmarkController *)bmk;
-(void)bookmarkDetails:(BookmarkController *)bmk;
@end

@interface BookmarkController : UIViewController
{
    BOOL _isDragging;
    CGPoint _startPoint;
    UITouch* _startTouch;
    UIEvent *_eventBegan;

}
@property (nonatomic, weak) id<BookmarkDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) Bookmark *bookmark;
@property (strong, nonatomic) RealPropInfo *realPropInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnNote;
- (IBAction)actionEditNote:(id)sender;
- (IBAction)actionDelete:(id)sender;
- (IBAction)actionMap:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *btnGlobe;
@end
