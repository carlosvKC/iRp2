#import <UIKit/UIKit.h>
#import "MenuItem.h"
#import "AxDelegates.h"


@interface MenuRange : NSObject

    @property int   section;        // index to location of section (-1 if non existant)
    @property int   location;       // index to first item in the list
    @property int   length;         // how many items

    -(id)initRangeWithSection:(int)sec location:(int)loc length:(int)len;
@end


@interface MenuTable : UITableViewController<UIPopoverControllerDelegate, UITableViewDelegate>
    {
        NSArray     *menuRanges;      // array of menuRanges pointing on each section of the menu
        NSString    *menuTitle;       // if there is a menu title
        UIPopoverController *popoverController;
        UIView      *destView;
    }
    @property(nonatomic, retain) NSArray *items;
    @property(nonatomic, retain) NSString *menuSrc;
@property(nonatomic, retain) NSString *parcelNbr;

    @property(nonatomic, retain) id<MenuTableDelegate>delegate;


    // Create a menu with a list of menus
    -(id)initWithMenuItems:(NSArray *)listofItems;

    // Create a menu from the resource file
    -(id)initFromResource:(NSString *)name;

    // Present the menu
    -(void)presentMenu:(UIBarButtonItem *)btn withDelegate:(id)aDelegate;
    -(void)presentMenu:(CGRect)inRect withView:(UIView *)view withDelegate:(id)aDelegate;

    //  cv 4/1/2015 Store parcelNbr for web link
    -(void)storeParcelNbr:(NSString *)parcelNumber;


    // Check and uncheck a menu item
    -(void)setMenuCheck:(int)tag checked:(BOOL)val;

    -(NSString *)getMenuName:(id)param;
    -(int16_t)getTypeItem:(id)param;

    -(int)getTypeItemInt:(id)param;
    -(int16_t)getMenuItemFromDesc : (NSString *)desc;

    -(int)getMenuItemFromDescInt : (NSString *)desc;

    -(void)cancelMenu;
    // -------------------------------------- Internal functions
    -(NSArray *)getMenuItems:(NSString *)name;

@end
