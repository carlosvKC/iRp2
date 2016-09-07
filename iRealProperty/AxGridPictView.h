
#import "AxGridViewCell.h"
#import "AxGridPictController.h"



@class AxGridPictController;

@interface AxGridPictView : AxGridViewCell
{
}
@property int colNum;            // current column number
@property(nonatomic, retain) AxGridPictController *gridPictController;

//

@end
