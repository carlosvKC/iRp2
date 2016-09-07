#import <UIKit/UIKit.h>
#import "SingleGrid.h"

@interface ReviewTracking : SingleGrid

@property(nonatomic, strong)Review *defaultReview;

// Load the new sale information into the grid
-(void)loadTracking:(Review *)newReview;
@end
