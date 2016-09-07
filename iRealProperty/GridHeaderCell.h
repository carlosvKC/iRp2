#import "AxGridViewCell.h"
#import "GridInfoDesign.h"

@class GridHeaderController;

@interface GridHeaderCell : AxGridViewCell
{
    GridHeaderController *gridHeaderController;
}
@property int column;
@property(nonatomic, retain) GridHeaderController *gridHeaderController;

-(void) drawRect:(CGRect)rect;


@end
