#import <UIKit/UIKit.h>
#import "StylePickerController.h"
#import "AttributePicker.h"
#import "AxColorPicker.h"

@class AGSMapView;
@class AGSLayer;
@class LayerInfo;
@class ArcGisViewController;
@class LayerList;
@class AxColorPicker;
@class MapLayerConfig;

// This is the view controller of the screen used to configure an layer. Show the properties and just set the values over the layers.
@interface LayerDisplayConfController : UIViewController<StylePickerDelegate, AttributePickerDelegate, AxColorPickerDelegate, UINavigationControllerDelegate>
{
    UILabel* layerType;
    UILabel* numRecords;
    UILabel* fileSize;
    UILabel* projection;
    
    __weak UIButton* styleSelector;
    __weak UIButton* mainColor;
    __weak  UIButton* borderColor;
    
    UIButton* selectTitleColumn;
    UIButton* selectDescriptionColumn;
    
    UISlider* minSetZoom;
    UISlider* maxSetZoom;
    
    UILabel* minSetZoomLabel;
    
    AGSLayer* __weak targetLayer;
    LayerInfo* layerInfo;
    AGSMapView* __weak mapView;
    
    UIButton* selectLabelColumn;
    UIButton* labelColor;
    UITextField * fontSize;
    UISwitch * showLabels;
    UISwitch * showShapes;
    UISwitch * scaleLabels;
    UISwitch * showAnnotationPolygons;
    UISwitch * clipping;
    UISwitch * removeLabelDuplicates;
    
    // Inside class
    StylePickerController *_stylePicker;
    UIPopoverController *_stylePickerPopover;
    
    AttributePicker *_attrPicker;
    UIPopoverController *_attrPickerPopover;
    
    AxColorPicker *_colorPicker;
    UIPopoverController *_colorPickerPopover;
    
    AxColorPicker *_axColorPicker;
    
    UIScrollView* scrollViewContainer;
    
    ArcGisViewController* __weak mapController;
    LayerList* layerListController;
    
    UISlider __weak *slider;
    UISlider __weak *fontSlider;
    
    UIColor *backColor;
    
    MapLayerConfig *_layerConfig;
    
}
@property (nonatomic, strong) MapLayerConfig *layerConfig;
@property (nonatomic,weak) IBOutlet UIButton* styleSelector;
@property (nonatomic,weak) IBOutlet UIButton* mainColor;
@property (nonatomic,weak) IBOutlet UIButton* borderColor;

@property(nonatomic,weak) IBOutlet UILabel* labelFontSize;
@property(nonatomic,weak) IBOutlet UILabel* labelBorderColor;

@property (nonatomic, strong) StylePickerController * stylePicker;
@property (nonatomic, strong) UIPopoverController * stylePickerPopover;

@property (nonatomic, strong) AttributePicker * attrPicker;
@property (nonatomic, strong) UIPopoverController * attrPickerPopover;

@property (nonatomic, strong) UIPopoverController * colorPickerPopover;

@property (nonatomic, strong) AxColorPicker *axColorPicker;

@property (nonatomic,weak) AGSMapView* mapView;
@property (nonatomic,weak) AGSLayer* targetLayer;
@property (nonatomic,strong) LayerInfo* layerInfo;
@property (nonatomic, weak) ArcGisViewController* mapController;
@property (nonatomic, strong) LayerList* layerListController;

@property(nonatomic, weak) IBOutlet UISlider *slider;
@property(nonatomic, weak) IBOutlet UISlider *fontSlider;

-(IBAction)SetLayerStyle:(id)sender;
-(IBAction)SetLayerMainColor:(id)sender;
-(IBAction)SetLayerBorderColor:(id)sender;

-(IBAction)changeSliderValue:(id)sender;
-(IBAction)changeFontSliderValue:(id)sender;

-(void)updateStyle:(id)sender;
@end
