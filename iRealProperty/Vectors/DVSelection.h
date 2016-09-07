#import <Foundation/Foundation.h>
#import "DVShape.h"

@protocol DVSelectionDelegate <NSObject>

// Duplicate from the keyboardOptionsLayer
-(void)dvKeyboardCopyLayer;
-(void)dvKeyboardPasteLayer;
-(int)dvKeyboardCountLayersToPaste;
-(void)selectAllShapes;
@end


@interface DVSelection : UIView
{
    UIMenuController    *menuController;
    DVShape             *_shape;
    UIView              *_view;
}

@property(nonatomic, weak) id<DVSelectionDelegate> delegate;

-(void)showMenu: (CGRect) menuRect inView:(UIView *)view shape:(DVShape *)shape;
@end


