#import <UIKit/UIKit.h>

@class ArcGisViewController;
@class RendererMenu;

typedef enum {
    classBreakRendererType,
    uniqueValueRendererType
} rendererTypesEnu;

@protocol RenderersPickerDelegate
- (void)rendererSelected:(id) renderer withName:(NSString*) name ofType: (rendererTypesEnu)type;
@end

@interface RenderersPicker : UITableViewController
{
    RendererMenu    *currentMenu;
    RendererMenu    *topMenu;
    id<RenderersPickerDelegate> __weak _delegate;
}
@property(nonatomic, retain) NSMutableArray *renderers;

@property (nonatomic, weak) id<RenderersPickerDelegate> delegate;
@property (nonatomic, weak) ArcGisViewController *arcgisMap;

@end
