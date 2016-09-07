#import "PictureView.h"
#import "MediaView.h"
#import "Helper.h"
#import "TabPicturesController.h"

@implementation PictureView
@synthesize currentImage;
@synthesize itsController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    UIColor *blackColor = [Helper UIColorFromRGB255:0 green:0 blue:0];
    if(currentMedia!=nil)
        [MediaView drawImageFromMediaInRect:currentMedia destRect:self.frame scale:YES withColor:blackColor];
    else
        [MediaView drawImageFromImageInRect:currentImage destRect:self.frame scale:YES];
}

-(void)setMedia:(id)media
{
    currentMedia = media;
    [self setNeedsDisplay];
}
-(id)getCurrentMedia
{
    return currentMedia;
}
-(void)swipeRight
{
    [itsController moveToPreviousPicture ];
}
-(void)swipeLeft
{
    [itsController moveToNextPicture];    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [itsController clickInPicture:self];
}
@end
