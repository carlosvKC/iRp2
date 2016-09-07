#import <UIKit/UIKit.h>
#import "KeyboardController.h"
#import "KeyboardController.h"

@class TabSearchController;
@class SearchDefinition2;  //cvSearchDef

@interface ParcelSearch : KeyboardController<UITextFieldDelegate>
{
    SearchDefinition2    *searchDefinition;
}
@property(nonatomic, weak) TabSearchController *itsController;

-(void)setSearchDefinition:(SearchDefinition2 *)definition;
@end