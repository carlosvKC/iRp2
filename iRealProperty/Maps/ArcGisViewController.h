#import <UIKit/UIKit.h>
#import <ARCGis/ArcGIS.h>
#import "MapLegend.h"
#import "MapRuler.h"
#import "MapKit/MapKit.h"
#import "TabMapDetail.h"

@class LayerInfo;
@class LayerList;
@class MapLayerConfig;
@class SpatiaLiteLayer;
@class ArcGisViewController;
@class AxSketchLayer;

@class RendererXmlBreaker;
@class RendererXmlMenu;
@class RendererXmlLabel;
@class RendererMenu;
@class ControlBar;
@class LayersXmlFileParser;

@class TabMapDetail;

typedef  void(^BlockAfterValidation)(void);

@protocol ArcGisViewControllerDelegate
- (void)arcGisViewController:(ArcGisViewController*)arcGisView didClickCalloutAccessoryButtonForParcel:(int)parcelId;
- (void)arcGisViewController:(ArcGisViewController*)arcGisView refreshZoomLevel:(NSString*)zoomText;

- (void)arcGisViewController:(ArcGisViewController*)arcGisView selectionHasChanged:(NSArray *)array;
@end

@interface ArcGisViewController : UIViewController<AGSInfoTemplateDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate, MapLegendDelegate, MapRulerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, TabMapDetailDelegate > 
{
    __weak AGSMapView      *_mapView;  // current map view
    NSMutableArray  *fileList; // List of LayerInfo -- contains a BOOL to say if the layer is loaded or not
    NSString        *publicDocumentsDir; // path to the documents folder of the app
    LayerList       *layerListViewController; // view controller of the table view that will show the list of available files to the user.

    // Inside class
    UIPopoverController *_layerListPopover;
    BOOL isPopoverOpen;
    
    UIAlertView *memoryAlert;
    
    //pointer to the tile base map first loaded.
    AGSTiledLayer* _baseMap;
    
    // Current Parcel Layer. This layer is special because will be used to display tematic maps and to highlight specific properties.
    LayerInfo* _parcels;
    
    id<ArcGisViewControllerDelegate> __weak _delegate; 
    
    NSDictionary* _parcelClassBreakRenderes;
    NSDictionary* _parcelUniqueValueRenderes;
    NSDictionary* _labelSetsByRender;
    
    MapLegend* _mapLegend;
    
    // sketching
    BOOL _isSketching;
    AxSketchLayer* _sketchLyr;
    AGSGeometry* _sketchGeometry;
    id _previewsTouchDelegate;
    
    // sketch messures
    double _sketchLenght;
    double _sketchArea;
    
    MapRuler* _mapRuler;
    
    // Push pins
    AGSGraphicsLayer * _pushPinLayer;
    
    // Internal class to track the ML renderers
    RendererXmlMenu *_xmlMenuRenderer;
    RendererXmlLabel *_xmlLabel;
    RendererXmlBreaker *_xmlBreaker;
    LayersXmlFileParser *xmlParcels;
    
    // Google data
    NSMutableArray  *googleMapAnnotations;
    BOOL _trackGps;
    
    BOOL _callOutWasHidden;
    
    // Compass information
    CLLocationManager *_locationManager;
    UIAlertView *_locationAlert;
    UIAlertView *_pushpinAlert;
    
    // Tabmap detail
    TabMapDetail *_mapDetail;
    int         _mapDetailId;
    NSString *  _mapDetailGuid;
    
    // Pop-up menu information
    enum {
        kPopupLayers,
        kPopupRenderers
    } _popupMenuMode;
    // additional point
    AGSGraphic *_selectedParcelIcon;
    
    NSArray *centers;
    
    // Block to be call after validation
    BlockAfterValidation _block;
}
@property(nonatomic, strong) TabMapDetail *mapDetail;
    
@property (nonatomic, strong) NSDictionary*  parcelClassBreakRenderes;
@property (nonatomic, strong) NSDictionary* parcelUniqueValueRenderes;

@property (nonatomic, strong) NSDictionary* labelSetsByRender;

@property (weak, nonatomic) IBOutlet MKMapView *GoogleMapView;

@property (nonatomic, weak) IBOutlet AGSMapView *mapView; // pointer to the map view
@property (weak, nonatomic) IBOutlet UIImageView *ArrowView;
@property (nonatomic, weak) id<ArcGisViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray * fileList; // pointer to the list of files
@property (nonatomic, strong) LayerList* layerListViewController; // pointer to the table view controller of the list of layers
@property (nonatomic, strong) UIPopoverController * layerListPopover;

// Says if the layer is in skech mode.
@property  (nonatomic, readonly ) BOOL isSketching;

@property (nonatomic, strong) RendererXmlMenu *xmlMenuRenderer;
@property (nonatomic, strong) RendererXmlLabel *xmlLabel;
@property (nonatomic, strong) RendererXmlBreaker *xmlBreaker;

@property(nonatomic) BOOL trackGps;
@property(nonatomic, weak) ControlBar *menuBar;

// The current ArcGisViewController
+(ArcGisViewController *)instance;

// Loads the list of valid files in the fileList array, to be used as datasource for the layerListViewController
- (void) checkForFiles; 

// Open a specific layer (file) and add it to the map. This function perform the operation asynchronous by calling the AsyncLayerLoader function.
- (void) openLayerFile:(LayerInfo*) layerInfo;

// Show the table view with the available layer list.
- (void) configLayer: (UIBarButtonItem *)btn;

// Zoom and pan the map the the full envelop of a selected layer.
- (void) zoomToLayer:(LayerInfo*) layerInfo;

// Hide the table view with the available layers
- (void) layerConfigDone;

// Hide the specific layer
- (void) hideLayer: (LayerInfo*) layerInf;

// Show a hided layer.
-(void) showLayer: (LayerInfo*) layerInf;

// Change alpha of specif layer. (For future use)
-(void) setLayer: (LayerInfo*) layerInf toAlpha: (CGFloat) alpha;

// Change the position of the layer in the list, this is to allow change what layer render over what layer. (For future use)
-(void) moveLayer: (LayerInfo*) layerInf to: (int) index;

// Event handler for testing. Is call when the map end a zoom in or a pan. This same logic is used by SpatialLiteLayer that is acctually reponding to this events.
- (void)respondToEnvChange: (NSNotification*) notification;

// Funtion to load a layer in a background thread.
-(void) asyncLayerLoader:(LayerInfo*) layerInfo withConfig: (MapLayerConfig*) layerconfig;

// Funtion to load a layer to load a layer in the current thread.
-(void) syncLayerLoader:(LayerInfo*) layerInfo withConfig: (MapLayerConfig*) layerconfig;

// hides the spinner indicator.
-(void) hideIndicator;

// store the current layer configuration.
-(void) saveLayerConfig: (LayerInfo*) layerinfo;

// Error message
- (void)fileNotFound:(NSString *)msg;

// Zoom the map to an appropriate level. Range should be [500 to 20,000]
-(void)adjustZoomLevel:(double)zoomLevel;

// hides the pushpin layer and unselect all the items.
-(void) removePushpins;

// Retrieve all the pushpins
-(NSArray *)retrievePushpins;

// Retrieve all the configFile based on layerInfo
+(MapLayerConfig *)getConfigFromLayerInfo:(LayerInfo *)layerInfo;
+(MapLayerConfig *)getConfigFromLayerName:(NSString *)layerName;

// Retrieve the list of menus for the parcel renderer
-(RendererMenu *)rendererMenus;

// start and stop GPS tracking
-(void)startGPS;
-(void)stopGPS;

// Show/hide the compass
-(void) toggleCompass;

-(void)hideConfigLayer;

#pragma mark - parcel management

-(void) highlightParcel: (id)pin;
-(void) highlightParcels: (NSArray*) parcelPins selectedParcels:(NSArray *)selectedParcels;
-(void) selectParcel: (NSNumber*)pin;
-(void) selectParcels:(NSArray*)parcelPins;
-(void) clearParcelFilter;
-(void) setParcelRenderer: (id) renderer withTitle: (NSString*)title;

#pragma mark - sketch management
- (void) startSketchPolyline;
- (void) startSketchPolygon;
- (void) endSketching;
- (void) undoLastSketch;
- (void) redoLastSketch;

#pragma mark - google Map
- (void) showGoogleMap;
- (void) hideGoogleMap;
- (void) toogleGoogleMap;

#pragma mark - dropCurrentPosition
- (void) dropCurrentPosition;

#pragma mark - Miscelleneous
-(void)resetLayersConfiguration;
-(void)resetRenderersConfiguration;

- (void) refreshParcelLayer;
-(void)cleanUpCaches;
// Zoom to all the selected
-(void)centerParcel;
-(void) closeVisibleLayers;
@end
