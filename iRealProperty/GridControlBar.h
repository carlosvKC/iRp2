#import <UIKit/UIKit.h>
#import "AxDelegates.h"

enum GridControlBarConstant 
{
    kGridControlBarBtnAdd = 0,
    kGridControlBarBtnDel,
    kGridControlBarBtnConfirmDel,
    kGridControlBarBtnLeft,
    kGridControlBarBtnRight,
    kGridControlBarBtnList,
    kGridControlBarBtnCancel,
    kGridControlBarBtnSave,
    
    kGridControlModeDeleteAdd,
    kGridControlModeNextPrevious,
    kGridControlModeDeleteCancel,
    kGridControlModeSaveCancel,
    kGridControlModeEmpty,
    
    kGridControlLabel = 10,
    kGridControlLabelNumbers = 2
};
@class GridController;

@interface GridControlBar : UIViewController
{
    int currentBar;
}

@property(nonatomic, weak) id<GridDelegate> delegate;
@property(nonatomic, strong) IBOutlet UIButton *btnAdd;
@property(nonatomic, strong) IBOutlet UIButton *btnDelete;

@property(nonatomic, strong) IBOutlet UIButton *btnLeft;
@property(nonatomic, strong) IBOutlet UIButton *btnRight;
@property(nonatomic, strong) IBOutlet UIButton *btnList;
@property(nonatomic, strong) IBOutlet UILabel *labelNextPrevious;

@property(nonatomic, strong) IBOutlet UIButton *btnCancel;
@property(nonatomic, strong) IBOutlet UIButton *btnSave;

@property(nonatomic, strong) IBOutlet UIButton *btnConfirmDel;

@property(nonatomic, strong) GridController *gridController;

-(IBAction)btnAddSelection:(id)sender;
-(IBAction)btnDelSection:(id)sender;
-(IBAction)btnLeftSelection:(id)sender;
-(IBAction)btnRightSelection:(id)sender;
-(IBAction)btnListSection:(id)sender;
-(IBAction)btnSaveSelection:(id)sender;
-(IBAction)btnCancelSelection:(id)sender;
-(IBAction)btnConfirmDel:(id)sender;

-(UILabel *)getPrincipalLabel;
-(UILabel *)getSmallLabel;

-(void)setPrincipalLabelText:(NSString *)text;
-(void)setSmallLabelText:(NSString *)text;

-(void)setButtonVisible:(BOOL)mode;
-(id)initWithNibName:(NSString *)nibNameOrNil barMode:(int)barMode;
-(void)setCounter:(int)current max:(int)max;

-(UIButton *)getDeleteButton;
-(void)adjustFrame:(CGRect)frame;
@end
