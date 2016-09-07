#import "AxGridViewController.h"
#import "AxGridPictView.h"
#import "AxDelegates.h"

@interface AxGridPictController : AxGridViewController
{
    int tagId;
    double timeStamp;
}
-(id)initWithMediaArray:(NSArray *)medias destinationViewId:(int)tagId;

@property(nonatomic, weak) id<GridDelegate>delegate;

@property(nonatomic, strong) NSArray *mediaArray;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIFont *font;
@property CGFloat minFontSize;
@property CGRect pictureRect;
@property CGRect labelRect;
@property CGRect cellRect;

// Update the list of medias
-(void)updateMedias:(NSArray *)medias;

@end
