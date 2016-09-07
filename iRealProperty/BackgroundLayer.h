#import <UIKit/UIKit.h>


@interface BackgroundLayer : UIView
{
    enum backgroundType 
    {
        kBackgroundImage = 0,
        kBackgroundSmallSquare = 1,
        kBackgroundYellowLine = 2
    } backType;
    int constrainDelta;
}
@property enum  backgroundType backType;
@property int constrainDelta;
@property int offset;

@end
