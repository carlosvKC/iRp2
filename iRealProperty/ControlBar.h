#import <UIKit/UIKit.h>
#import "AxDelegates.h"

enum ToolbarButtonConstant
{
    kBtnBack = 512,
    kBtnLabel = 100
};

@interface ControlBar : UIViewController
{
    UIBarButtonItem *feedbackButton;
}
@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property(nonatomic, weak) id<MenuBarDelegate>delegate;

// Update the bar title
-(void)setupBarLabel:(NSString *)text;
-(void)setItemTitle:(int)tag title:(NSString *)title;


// Back buton function
-(void)addBackButonWithTitle:(NSString *)title;
-(void)addBackButon;
-(void)removeBackButton;
-(void)removeButton:(int)index;
-(void)removeButtonWithTag:(int)tag;
-(void)addButton:(UIButton *)btn atIndex:(int)index;
-(int )getBarButtonItemIndex:(int)tag;
-(UIButton*)getDashboardToDoButton;  // DBaun 2014-04-27
-(UIBarButtonItem*)getDashboardToDoParentButton;  // DBaun 2014-04-27

// Return an item from the bar based on its tag
-(UIBarButtonItem *)getBarButtonItem:(int)tag;
-(UIBarItem *)getBarItem:(int)tag;
-(void)replaceItemWith:(UIBarButtonItem *)item withTag:(int)tag;

// Set the visibility of an button
-(void)setItemEnable:(int)tag isEnable:(BOOL)en;

// Set a button if it selected or not
-(void)setItemSelected:(int) tag isSelected:(BOOL)selected;
-(BOOL)isItemSelected:(int)tag;

// Refresh links
-(void)refreshLinks;

@end
