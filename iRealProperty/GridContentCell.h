
#import "AxGridViewCell.h"
#import "GridContentController.h"

@class GridContentController;

@interface GridContentCell : AxGridViewCell
{
}
@property int row, column;
@property(nonatomic,retain) NSString *label;

@property(nonatomic, retain) GridContentController *gridContentController;
-(void) drawRect:(CGRect)rect;
@end
