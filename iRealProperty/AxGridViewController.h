
#import <UIKit/UIKit.h>
#import "AxGridView.h"

@interface AxGridViewController : UIViewController <AxGridViewDataSource, AxGridViewDelegate> 
{
	AxGridView *gridView;
}

@property (nonatomic, retain) AxGridView *gridView;

@end

