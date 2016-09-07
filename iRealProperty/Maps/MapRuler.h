
#import <UIKit/UIKit.h>
#import "UIDragableToolbar.h"

@protocol MapRulerDelegate 

-(void) mapRulerDoneButtonClick;

@end

@interface MapRuler : UIViewController <UIDragableToolbarDelegate>
{
     __weak id<MapRulerDelegate> _delegate; 
}

@property (weak, nonatomic) IBOutlet UIDragableToolbar *toolBar;
@property (nonatomic, weak) id<MapRulerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *rulerTitle;

@property (weak, nonatomic) IBOutlet UILabel *lenghtLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
- (IBAction)onDone:(id)sender;

@end
