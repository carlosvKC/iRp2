#import <UIKit/UIKit.h>
#import "SingleGrid.h"

@interface ReviewNotes : SingleGrid

@property(nonatomic, retain)Review *defaultReview;

// Load the new sale information into the grid
-(void)loadNotesForReview:(Review *)newReview;
@end
