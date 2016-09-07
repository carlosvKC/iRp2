#import <UIKit/UIKit.h>
#import "SearchBase.h"
#import <CoreData/CoreData.h>
#import "ComboBoxPopOver.h"

@class TabSearchController;

@interface VisibleItem : NSObject
@property(nonatomic, strong) UILabel     *viewLabel;
@property(nonatomic, strong) id     viewObject;
@property(nonatomic, strong) id     viewObjectBtn;
@property(nonatomic, strong) UIView     *btnHelp;
@property(nonatomic) int numValue;
@property(nonatomic, strong) NSDate *dateValue;
@property(nonatomic, strong) NSString *strValue;


@property(nonatomic, weak) NSString *itemHelp;
@property(nonatomic, weak) NSString *refTitle;
@property(nonatomic) int maxChars;
@property(nonatomic) int filter;
@property(nonatomic, weak) NSString *defaultValue;
@property(nonatomic) BOOL isRequired;
@property(nonatomic, weak) NSString *refObjectName;
@property(nonatomic, strong) NSString *choice;

@end

@interface TabSearchItems : UIViewController<UITextFieldDelegate, UIPopoverControllerDelegate, ComboBoxPopOverDelegate>
{
    // List of visible items
    NSMutableArray          *items;
    UIButton                *btnSearch;

    // Help pop-over information
    UIPopoverController     *helpPopover;
    UIViewController        *helpViewController;
    
    ComboBoxPopOver         *popOver;
    VisibleItem             *visItem;

}
// Call to change the search definition
-(void)setSearchDefinition:(SearchDefinition2 *)param;
-(void)performSearch:(id)sender;

// Void delete all the objects
-(void) removeAllObjects;

@property(nonatomic, weak) TabSearchController *itsController;
- (IBAction)clickInBackground:(id)sender;

@end
