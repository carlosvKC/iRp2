#import <UIKit/UIKit.h>
#import "DialogGrid.h"
#import "AxDelegates.h"

enum {
    kPictureDetailLabelTag = 1,
    kPictureDetailPictTag = 2,
    kPictureDetailInputTag = 3,
    kPictureDetailPrimary = 4,
    kPictureDetailPostToWeb = 5,
    kPictureDetailMediaDate = 6,
    kPictureDetailOrder = 7,
    kPictureDetailUpdatedBy = 8,
    kPictureDetailUpdateDate = 9,
    kPictureDetailCameraTag = 50,
    kPictureDetailRollTag = 60
};
@interface PictureDetails : DialogGrid< UINavigationControllerDelegate>


-(void)configureDialogBox:(NSString *)title btnVisible:(BOOL)visible;
// Call to setup the current media
-(void)setMedia:(id)media;
// Return the media with all the appropriate info
-(id)getMedia;
// Return the UIImage that was selected
-(UIImage *)getImage;

-(NSString *)getDescription;
-(BOOL)getPrimary;
-(BOOL)getPostToWeb;

// Current selected image (remain in memory)
@property(nonatomic, strong) UIImage *selectedImage;
// delegate
@property(nonatomic, weak) id<ModalViewControllerDelegate>delegate;

@end
