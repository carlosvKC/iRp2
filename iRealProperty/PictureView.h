#import <UIKit/UIKit.h>
#import "BaseView.h"

@class TabPicturesController;
@interface PictureView : BaseView
{
    id currentMedia;
    UIImage *currentImage;
}
-(void)setMedia:(id)media;
-(id)getCurrentMedia;

@property(nonatomic, strong) UIImage *currentImage;
@property(nonatomic, weak) TabPicturesController *itsController;
@end
