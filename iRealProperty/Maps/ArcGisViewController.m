#import "ArcGisViewController.h"
#import "NSData_Additions.h"
#import "LayerInfo.h"
#import "LayerList.h"
#import "SHPFileLayer.h"
#import "ATActivityIndicator.h"

#include "shapefil.h"
#include "proj_api.h"
#include "shpgeo.h"
#include "prjopen.h"
#include "SQLite3.h"
#include "Spatialite.h"
#include "gaiageo.h"
#include "SpatiaLiteLayer.h"
#include "OfflineTiledLayer.h"
#include "SidTiledLayer.hpp"
#include "LayerList.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "AxDataManager.h"
#import "MapLayerConfig.h"
#import "ColorPicker.h"
#import "RenderersXmlFileParserDelegate.h"
#import "MapLegend.h"
#import "AxSketchLayer.h"

#import "RealPropertyApp.h"
#import "Helper.h"
#import "LayersXmlFileParser.h"
#import "RendererXmlMenu.h"
#import "RendererXmlLabel.h"
#import "RendererXmlBreaker.h"

#import "parcelAnnotation.h"
#import "TabMapDetail.h"
#import "ControlBar.h"
#import "TabMapController.h"
#import "Configuration.h"
#import "BreakerConfig.h"
#import "RendererConfig.h"

#import "TabMapDetail.h"

#import "Configuration.h"
#import "MapLayerConfig.h"


@implementation ArcGisViewController

@synthesize mapView=_mapView;
@synthesize ArrowView = _ArrowView;
@synthesize delegate=_delegate;
@synthesize parcelClassBreakRenderes = _parcelClassBreakRenderes;
@synthesize parcelUniqueValueRenderes = _parcelUniqueValueRenderes;
@synthesize labelSetsByRender = _labelSetsByRender;
@synthesize GoogleMapView = _GoogleMapView;

@synthesize fileList;
@synthesize layerListViewController;
@synthesize layerListPopover = _layerListPopover;

@synthesize xmlLabel = _xmlLabel;
@synthesize xmlMenuRenderer = _xmlMenuRenderer;
@synthesize xmlBreaker = _xmlBreaker;
@synthesize trackGps = _trackGps;

@synthesize mapDetail = _mapDetail;

@synthesize menuBar;
static ArcGisViewController *activeInstance = nil;

static BOOL zoomToEnvelop = YES;

+(void)zoomToEnvelop:(BOOL)zoom
{
    zoomToEnvelop = zoom;
}

// @synthesize itsController;
#pragma mark - special getter
-(BOOL) isSketching
{
    return _isSketching;
}

#pragma mark - pushpin layer

// adds the pushpin layer
- (void) addPushpinLayer
{
    if (_pushPinLayer == NULL)
    {
        _pushPinLayer = [[AGSGraphicsLayer alloc] init];
        // AGSSimpleMarkerSymbol * marker = [[AGSSimpleMarkerSymbol alloc]  initWithColor:[UIColor redColor]];
        AGSSimpleMarkerSymbol * marker = [[AGSSimpleMarkerSymbol alloc]  initWithColor:[UIColor blueColor]];
        AGSSimpleRenderer * renderer = [[AGSSimpleRenderer alloc]  initWithSymbol:marker];
        _pushPinLayer.renderer = renderer;
    }
    if (![self.mapView.mapLayers containsObject:_pushPinLayer]) 
    {
        [self.mapView addMapLayer:_pushPinLayer withName:@"Pushpin Layer @dr"];
        if (_isSketching)
        {
            [self endSketching];
        }
        self.mapView.touchDelegate = self;
    }
    else
    {
        int currentIndex = [self.mapView.mapLayers indexOfObject:_pushPinLayer];
        int toIndex = [self.mapView.mapLayers count] - 1;
        [self.mapView exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:toIndex];
    }
}

// hides the pushpin layer and unselect all the items.
-(void) removePushpins
{
    if (_pushPinLayer != NULL)
    {
        _pushpinAlert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:@"Are you sure to deselect all the parcels?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [_pushpinAlert show];
        
    }
}
// Deselect the layers
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView==_pushpinAlert)
    {
        if(buttonIndex==0)
            return;
        [_pushPinLayer removeAllGraphics];
        [self.mapView removeMapLayerWithName:_pushPinLayer.name];
        [((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes removeAllObjects];
        if(_delegate)
            [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];
    }
    else if(alertView == _locationAlert)
    {
        if(buttonIndex==0)
            return;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];        
    }
    else if(alertView==memoryAlert)
    {
        [self closeVisibleLayers];
    }
    

}
#pragma mark - Refresh the parcel layer if it is on
- (void) refreshParcelLayer
{
    if(_parcels.isLoaded && _parcels.isVisible && _mapLegend.view!=nil )
    {
        UniqueValueRenderer *renderer = (UniqueValueRenderer *) ((SpatiaLiteLayer*)_parcels.mapLayer).renderer;
        [self cleanUpCaches];

        [(SpatiaLiteLayer*)_parcels.mapLayer setRenderer:nil];
        [(SpatiaLiteLayer*)_parcels.mapLayer dataChanged];

        [(SpatiaLiteLayer*)_parcels.mapLayer setRenderer:renderer];
        [(SpatiaLiteLayer*)_parcels.mapLayer performLabeling];
        [(SpatiaLiteLayer*)_parcels.mapLayer dataChanged];  

    }
    // Refresh the detail view if it is activated //got in the first time
    if(_mapDetail!=nil)
    {
        // [self tabMapDetailIsDone];
        [_mapDetail.view removeFromSuperview];
        [_mapDetail removeFromParentViewController];
        _mapDetail = nil;
        
        NSNumber *number = [NSNumber numberWithInt:_mapDetailId];
        [self createTabMapDetail:CGPointMake(0, 0) realPropId:number];
        //cv  in
        //[self checkSelection:_mapDetailId];
        
        // add current icon
        [self addSelectedIcon];
    }
}

#pragma mark - utility and memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    /***
    memoryAlert = [[UIAlertView alloc] initWithTitle:@"Low Memory" message:@"There are too many layers open at once. The application will close some or most of the layers." delegate:self cancelButtonTitle:@"Close Layers" otherButtonTitles:nil];
    [memoryAlert show];
     ****/
    [self closeVisibleLayers];
}

static int callback(void *NotUsed, int argc, char **argv, char **azColName)
{
    int i;
    for(i =0; i < argc; i++)
    {
        //NSLog(@"")
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return  0;
}

- (void)fileNotFound:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:NULL cancelButtonTitle:@"Quit" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - map events
//
// Refresh the current zoom level
//
-(void) refreshZoomLevel
{
    NSString *zoomText;
    if (self.mapView.mapScale != NAN)
        zoomText = [NSString stringWithFormat:@"1:%.0f", self.mapView.mapScale];
    else
        zoomText = [NSString stringWithFormat:@"Resolution %f", self.mapView.resolution];
    // Pass it back to the TabController tab
    if (_delegate != NULL)
    {
        [_delegate arcGisViewController:self refreshZoomLevel:zoomText];
    }
}
//
// The method that should be called when the notification arises
//
- (void)respondToEnvChange: (NSNotification*) notification 
{
    if ([[notification name] compare:@"MapDidEndZooming"] == NSOrderedSame) 
    {
        [self refreshZoomLevel];
    }
}
#define _CLICK_CUTOFF_  4000.0
-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    BOOL selectionChanged = false;
    if (graphics != NULL)
    {
        // Don't select anything if too far
        if(self.mapView.mapScale > _CLICK_CUTOFF_)
            return;

        if(_callOutWasHidden)
        {
            _callOutWasHidden = NO;
            return;
        }
        
        [self addPushpinLayer];
        // detect selected vertex. (i.e. click directly inside the dot)
        NSArray* thisLayerGraphics = [graphics valueForKey:_pushPinLayer.name];
        if (thisLayerGraphics != NULL && [thisLayerGraphics count] > 0)
        {
            for (AGSGraphic* gr in thisLayerGraphics) 
            {
                if ([_pushPinLayer.graphics containsObject:gr])
                {
                    selectionChanged = true;
                    NSNumber* pkuid = [gr.attributes valueForKey:@"RealPropId"];
                    
                    // check if the selection was added manually
                    if([self checkSelection:[pkuid intValue]])
                    {
                        if(gr.symbol==nil)
                        {
                            // Remove it
                            [_pushPinLayer removeGraphic:gr];
                            [self removeSelection:pkuid.intValue];
                        }
                        else
                        {
                            gr.symbol = nil;    // make it blue
                            [self changeSelection:pkuid.intValue selected:NO];
                        }
                    }
                    else
                    {
                        if(gr.symbol==nil)
                        {
                            gr.symbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
                            [self changeSelection:pkuid.intValue selected:YES];
                        }
                        else
                        {
                            gr.symbol = nil;    // default is BLUE, put it back to default value
                            [self changeSelection:pkuid.intValue selected:NO];
                        }
                    }


                    break;
                }
            }
        }
        if (selectionChanged)
        {
            if(_delegate)
                [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];
            [_pushPinLayer dataChanged];
        }
        else 
        {
            thisLayerGraphics = [graphics valueForKey:_parcels.mapLayer.name];
            if (thisLayerGraphics != NULL && [thisLayerGraphics count] > 0)
            {
                AGSSymbol* redSymbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
                for (AGSGraphic* gr in thisLayerGraphics) 
                {
                    
                    if ([((SpatiaLiteLayer*)_parcels.mapLayer).graphics containsObject:gr])
                    {
                       
                        NSNumber* pkuid = [gr.attributes valueForKey:@"RealPropId"];
                        NSMutableArray *selectedShapes = ((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes;
                        if (![selectedShapes containsObject:pkuid])
                        {
                            [self addDot:gr symbol:redSymbol pkuid:pkuid];
                            selectionChanged = YES;
                        }
                        else 
                        {
                            // Looking for the dot, and deselect it.
                            for (AGSGraphic* pushpin in _pushPinLayer.graphics) 
                            {
                                if ([[pushpin.attributes valueForKey:@"RealPropId"] compare:pkuid] == NSOrderedSame)
                                {
                                    selectionChanged = true;
                                    // Check if object was manually added
                                    if([self checkSelection:[pkuid intValue]])
                                    {
                                        // is the object blue?
                                        if(pushpin.symbol==nil)
                                        {
                                            // Remove it
                                            [((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes removeObject:pkuid];
                                            [_pushPinLayer removeGraphic:pushpin];
                                            [self removeSelection:pkuid.intValue];
                                        }
                                        else
                                        {
                                            // Make it blue
                                            pushpin.symbol = nil; 
                                            [self changeSelection:pkuid.intValue selected:NO];
                                        }
                                    }
                                    else 
                                    {
                                        // Deselect it
                                        if(pushpin.symbol==nil)
                                        {
                                            pushpin.symbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
                                            [self changeSelection:pkuid.intValue selected:YES];
                                        }
                                        else
                                        {
                                            pushpin.symbol = nil;    // default is BLUE, put it back to default value
                                            [self changeSelection:pkuid.intValue selected:NO];
                                        }
                                    }
                                    break;

                                }
                            }
                            // special case -- we might have lost the dot, reselect it
                            if(!selectionChanged)
                            {
                                [self addDot:gr symbol:redSymbol pkuid:pkuid];
                                selectionChanged = YES;
                            }
                        }
                        break;
                    }
                }
            }
            if (selectionChanged)
            {
                if(_delegate)
                    [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];
                [_pushPinLayer dataChanged];
            }
        }
    }
}
// add a dot
-(void)addDot:(AGSGraphic *)gr symbol:(AGSSymbol *)symbol pkuid:(NSNumber *)pkuid
{
    // Not selected -- add the dot
    NSMutableDictionary* pushpinAtt = gr.attributes;
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint *center = [engine labelPointForPolygon:(AGSPolygon *)gr.geometry];
    AGSGraphic* newPushPin = [[AGSGraphic alloc] initWithGeometry:center symbol:symbol attributes:pushpinAtt infoTemplateDelegate:((SpatiaLiteLayer*)_parcels.mapLayer)];
    [_pushPinLayer addGraphic:newPushPin];
    [((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes addObject:pkuid];
    [self addSelection:[pkuid intValue]]; // Add a selected (red)
}
// Toggle the selection -- selection can be of 3 mode
-(void)changeSelection:(int)pkuid selected:(BOOL)sel
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    [app changeSelection:pkuid selection:sel];
}
// Add selection
-(void)addSelection:(int)pkuid
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    [app addSelection:pkuid];
}
// Return true if the selection is part of the initial search 
-(BOOL)checkSelection:(int)pkuid
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    return [app isParcelFromMap:pkuid];    
}
// Remove the selection
-(void)removeSelection:(int)pkuid
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    return [app removeSelection:pkuid];    
}
//
// Retrieve all the pushpins
//
-(NSArray *)retrievePushpins
{
    return ((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes;
}
-(void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    if(_isSketching)
        return;
    BOOL selectionChanged = false;
    if (graphics != NULL)
    {
        // detect selected vertex.
        NSArray* thisLayerGraphics = [graphics valueForKey:_pushPinLayer.name];
        if (thisLayerGraphics != NULL && [thisLayerGraphics count] > 0)
        {
            for (AGSGraphic* gr in thisLayerGraphics) 
            {
                if ([_pushPinLayer.graphics containsObject:gr])
                {
                    // get the parcel ID
                    NSNumber *parcelId = [gr.attributes valueForKey:@"RealPropId"];
                    
                    for(AGSGraphic *graphic in ((SpatiaLiteLayer *) (_parcels.mapLayer)).graphics)
                    {
                        NSNumber *num = [graphic.attributes valueForKey:@"RealPropId"];
                        if([num intValue]==[parcelId intValue])
                        {
                            // AGSPoint *point = [AGSPoint pointWithX:graphic.geometry.envelope.xmin y:graphic.geometry.envelope.ymin + graphic.geometry.envelope.height/2 spatialReference:graphic.geometry.spatialReference];
                            NSNumber *num = [gr.attributes valueForKey:@"RealPropId"];
                            [self createTabMapDetail:screen realPropId:num];
                            [self addIcon:(AGSPoint *)(gr.geometry)];
                            break;
                        }
                    }
                    // [self.mapView showCalloutAtPoint:(AGSPoint*)gr.geometry forGraphic:gr animated:YES];

                    selectionChanged = true;
                    break;
                }
            }
        }
        if (selectionChanged)
        {
            if(_delegate)
                [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];
            [_pushPinLayer dataChanged];
        }
        else 
        {
            thisLayerGraphics = [graphics valueForKey:_parcels.mapLayer.name];
            if (thisLayerGraphics != NULL && [thisLayerGraphics count] > 0)
            {
                for (AGSGraphic* gr in thisLayerGraphics) {
                    if ([((SpatiaLiteLayer*)_parcels.mapLayer).graphics containsObject:gr])
                    {
                        AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
                        AGSPoint *center = [engine labelPointForPolygon:(AGSPolygon *)gr.geometry];

                        // AGSPoint *point = [AGSPoint pointWithX:gr.geometry.envelope.xmin y:gr.geometry.envelope.ymin + gr.geometry.envelope.height/2 spatialReference:gr.geometry.spatialReference];
                        NSNumber *num = [gr.attributes valueForKey:@"RealPropId"];
                        // Validate the realpropid
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", [num intValue]];
                        RealPropInfo *realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate];

                        if(realPropInfo==nil)
                        {
                            [Helper alertWithOk:@"No data" message:@"This parcel does not have data and can't be opened."];
                            return;
                        }
                        
                        [self createTabMapDetail:screen realPropId:num];
                        [self addIcon:center];

                        // [self.mapView showCalloutAtPoint:point forGraphic:gr animated:YES];
                        // [self.mapView showCalloutAtPoint:mappoint forGraphic:gr animated:YES];
                        selectionChanged = true;
                        break;
                    }
                }
            }
            if (selectionChanged)
            {
                if(_delegate)
                    [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];
                [_pushPinLayer dataChanged];
            }
        }
    }
}
// Add a new icon
-(void)addIcon:(AGSPoint *)point
{
    if(_selectedParcelIcon!=nil)
        [_pushPinLayer removeGraphic:_selectedParcelIcon];
    UIImage *pictSymbol = [UIImage imageNamed:@"signal_flag_blue.png"];
    if(pictSymbol==nil)
    {
        NSLog(@"pictSymbol is null");
        return;
    }
     AGSPictureMarkerSymbol *symbol = [[AGSPictureMarkerSymbol alloc]initWithImage:pictSymbol];
        
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:99999999], @"RealPropId", nil];
    _selectedParcelIcon = [[AGSGraphic alloc]initWithGeometry:point symbol:symbol attributes:attributes infoTemplateDelegate:nil];

    [_pushPinLayer addGraphic:_selectedParcelIcon];

}
-(void)removeIcon
{
    if(_selectedParcelIcon!=nil)
        [_pushPinLayer removeGraphic:_selectedParcelIcon];
    _selectedParcelIcon = nil;
    [_pushPinLayer dataChanged];
    
}
-(void)addSelectedIcon
{
    if(_selectedParcelIcon==nil)
        return;
    [_pushPinLayer addGraphic:_selectedParcelIcon];
    [_pushPinLayer dataChanged];
    
}
-(void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic
{
    if ([graphic.layer isKindOfClass:[SpatiaLiteLayer class]])
    {
        SpatiaLiteLayer* layer = (SpatiaLiteLayer*)graphic.layer;
        if (layer == (SpatiaLiteLayer*)_parcels)
        {
            // parcel layer was clicked.
            if (_delegate != NULL)
            {
                int pin = [[graphic.attributes valueForKey:@"RealPropId"]intValue];
                [_delegate arcGisViewController:self didClickCalloutAccessoryButtonForParcel:pin];
            }
        }
    }
}

- (BOOL) mapView: (AGSMapView *) mapView shouldShowCalloutForGraphic: (AGSGraphic *) graphic
{
    if (!mapView.callout.isHidden)
    {
        _callOutWasHidden = YES;
        return false;
    }
    if (_isSketching)
    {
        return false;
    }
    else if ((graphic.layer != _pushPinLayer) && (graphic.layer != _parcels.mapLayer) && ( [graphic.layer isKindOfClass:[SpatiaLiteLayer class]] && ([(SpatiaLiteLayer*)graphic.layer titleColumnName] != NULL)))
    {
        return true;
    }
    return false;
}

#pragma mark - life cycle
+(ArcGisViewController *)instance
{
    return activeInstance;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    activeInstance = self;
    @try 
    {
        [super viewDidLoad];
        isPopoverOpen = false;
        
        // Init the magnifier glass
        [self.mapView setShowMagnifierOnTapAndHold:NO];
        
        spatialite_init(1);
        
        self.mapView.calloutDelegate = self;
        
        [self checkForFiles];
        
        // register for "MapDidEndPanning" notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) name:@"MapDidEndPanning" object:nil];
        
        // register for "MapDidEndZooming" notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)  name:@"MapDidEndZooming" object:nil];
        
        //register self for receiving notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:@"GeometryChanged" object:nil];
        
        // set current zoom level
        [self refreshZoomLevel];
        [self addPushpinLayer];
        
        [self.mapView.callout setLeaderPositionFlags:AGSCalloutLeaderPositionRight];
    }
    @catch (NSException *ex) 
    {
        NSLog(@"ArcGis View: %@",ex);
    }
}
//
// unload view
//
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapDidEndPanning" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapDidEndZooming" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
    [self setGoogleMapView:nil];
    [self setArrowView:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
#pragma mark - Handles the renderers
-(RendererMenu *)rendererMenus
{
    return _xmlMenuRenderer.rootMenu;
}
#pragma mark - layer configuration
+(MapLayerConfig *)getConfigFromLayerInfo:(LayerInfo *)layerInfo
{
    NSPredicate *predicate;
    NSManagedObjectContext *context = [AxDataManager configContext];
    

    predicate = [NSPredicate predicateWithFormat:@"tableName ==[uc]%@ AND area==[uc]%@", layerInfo.tableName, [RealPropertyApp getWorkingArea]]; 
    return [AxDataManager getEntityObject:@"MapLayerConfig" andPredicate:predicate andContext:context];
}
+(MapLayerConfig *)getConfigFromLayerName:(NSString *)layerName
{
    NSPredicate *predicate;
    NSManagedObjectContext *context = [AxDataManager configContext];
    
    
    predicate = [NSPredicate predicateWithFormat:@"tableName CONTAINS[uc] %@ AND area==[uc]%@", layerName, [RealPropertyApp getWorkingArea]]; 
    return [AxDataManager getEntityObject:@"MapLayerConfig" andPredicate:predicate andContext:context];
}
-(void)applyConfiguration: (LayerInfo *) layerInfo
{
    
    MapLayerConfig *layerConfig = [ArcGisViewController getConfigFromLayerInfo:layerInfo];
    
    if(layerConfig.isVisible)
    {
        [self syncLayerLoader:layerInfo withConfig:layerConfig];
    }
    
    if (_baseMap == NULL && layerInfo.fileType == CACHEFILETYPE)
    {
        _baseMap = (AGSTiledLayer*)layerInfo.mapLayer;
    }
    else if (layerConfig.isParcel) 
    {
        if (!layerInfo.isLoaded)
        {
             [self syncLayerLoader:layerInfo withConfig:layerConfig];
        }
        _parcels = layerInfo;
    }
}

-(void) saveLayerConfig: (LayerInfo*) layerinfo
{
    if (layerinfo != NULL)
    {
        NSManagedObjectContext * context = [AxDataManager configContext];
        
        MapLayerConfig* layerconfig = [ArcGisViewController getConfigFromLayerInfo:layerinfo];
        
        if (layerconfig != NULL) 
        {
            layerconfig.isVisible = layerinfo.isVisible;
            if (layerinfo.fileType == SQLITEFILETYPE && layerinfo.mapLayer!=NULL)
            {
                BaseShapeCustomLayer* shapeLayer = (BaseShapeCustomLayer*)layerinfo.mapLayer;
                layerconfig.minScale = [shapeLayer minScale];
                layerconfig.titleColumn = shapeLayer.titleColumnName;
                layerconfig.descriptionColumn = shapeLayer.descriptionColumName;
                
                if ([layerinfo.shapeTypeName compare:(NSString*)SHAPETYPEMULTILINESTRING] == NSOrderedSame)
                {
                    layerconfig.lineColor = [shapeLayer.renderSymbol.color stringFromColor];
                    layerconfig.fillStyle = [LayerInfo StringFromAGSSimpleLineSymbolStyle:((AGSSimpleLineSymbol*)shapeLayer.renderSymbol).style];
                    
                }
                else if ([layerinfo.shapeTypeName compare:(NSString*)SHAPETYPEMULTIPOINT] == NSOrderedSame)
                {
                    layerconfig.fillColor = [shapeLayer.renderSymbol.color stringFromColor];
                    layerconfig.fillStyle = [LayerInfo StringFromAGSSimpleMarkerSymbolStyle:((AGSSimpleMarkerSymbol*)shapeLayer.renderSymbol).style];
                }
                else if ([layerinfo.shapeTypeName compare:(NSString*)SHAPETYPEMULTIPOLYGON] == NSOrderedSame ||
                         [layerinfo.shapeTypeName compare:(NSString*)SHAPETYPEPOLYGON] == NSOrderedSame)
                {
                    layerconfig.fillColor = [shapeLayer.renderSymbol.color stringFromColor];
                    layerconfig.lineColor = [((AGSSimpleFillSymbol*)shapeLayer.renderSymbol).outline.color stringFromColor];
                    layerconfig.fillStyle = [LayerInfo StringFromAGSSimpleFillSymbolStyle:((AGSSimpleFillSymbol*)shapeLayer.renderSymbol).style];
                }
                else if ([layerinfo.shapeTypeName compare:(NSString*)SHAPETYPELINESTRING] == NSOrderedSame)
                {
                    SpatiaLiteLayer *layer = (SpatiaLiteLayer *)shapeLayer;

                    layerconfig.labelColor = [layer.defaultLabelSymbol.color stringFromColor];
                    layerconfig.labelFontSize = layer.defaultLabelSymbol.fontSize;
                }
                if (layerinfo.fileType == SQLITEFILETYPE)
                {
#if 0
                    SpatiaLiteLayer* spatialliteLayer = (SpatiaLiteLayer*)layerinfo.mapLayer;

                    layerconfig.showShapes = spatialliteLayer.showShapes;
                    layerconfig.showLabels = spatialliteLayer.showLabels;
                    layerconfig.showAnnotationPolygons = spatialliteLayer.showAnnotationPolygonContainers;
                    layerconfig.clipping = spatialliteLayer.clipping;
                    layerconfig.removeLabelDuplicates = spatialliteLayer.removeLabelDuplicates;
                    layerconfig.labelColumnName = spatialliteLayer.labelColumnName;
#endif
                
                }
            }
            
            NSError* error = NULL;
            if ([context hasChanges])
            {
                if (![context save:&error]) 
                {
                    NSLog(@"Error saving MapLayerConfig: %@. %@", layerinfo.tableName, [error localizedDescription]);
                }
            }
        }
        
    }
}
//
// Display the pop-over for the layers
//
-(void) configLayer:(UIBarButtonItem *)btn
{
    self.layerListViewController = [[LayerList alloc] initWithNibName:@"LayerListConf" bundle:nil];
    self.layerListViewController.fileList = self.fileList;
    UINavigationController *navbar = [[UINavigationController alloc] initWithRootViewController:self.layerListViewController];
    self.layerListViewController.navigationItem.title = @"Layers";
    self.layerListViewController.mapController = self;
    // making sure that the layer is closed
    if(self.layerListPopover!=nil)
    {
        [self.layerListPopover dismissPopoverAnimated:NO];
        self.layerListPopover = nil;
    }
    self.layerListPopover = [[UIPopoverController alloc] initWithContentViewController:navbar]; 
    self.layerListViewController.fileList = self.fileList;
    self.layerListPopover.delegate = self;
    [self.layerListPopover presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _popupMenuMode = kPopupLayers;
}
-(void)hideConfigLayer
{
    [self.layerListPopover dismissPopoverAnimated:NO];
}
-(void) layerConfigDone
{
}
#pragma mark - Popover delegate
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popover
{
    if(_popupMenuMode==kPopupLayers)
    {
        self.layerListViewController = nil;
        self.layerListPopover = nil;
    }
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}
#pragma mark - layer load
-(void)resetLayersConfiguration
{
    NSString *file;
    file = [NSString stringWithFormat:@"%@.layers.xml", [RealPropertyApp getWorkingPath]];
    xmlParcels = [[LayersXmlFileParser alloc]initWithXMLFile:file];
    
}
-(void)resetRenderersConfiguration
{
    NSString *file;
    // Menu structure
    file = [NSString stringWithFormat:@"%@.menuStructure", [RealPropertyApp getWorkingPath]];
    _xmlMenuRenderer = [[RendererXmlMenu alloc]initWithXMLFile:file];

    // LabelSets
    file = [NSString stringWithFormat:@"%@.LabelSets", [RealPropertyApp getWorkingPath]];
    _xmlLabel = [[RendererXmlLabel alloc]initWithXMLFile:file];
    
    // Renderers -- Must be done after the label sets since it depends on labelsets
    file = [NSString stringWithFormat:@"%@.Renderers", [RealPropertyApp getWorkingPath]];
    _xmlBreaker = [[RendererXmlBreaker alloc]initWithXMLFile:file withLabels:_xmlLabel.labels];  
    
    // Check when was the last time the renderers where updated
    NSDate *modifDate = [Helper documentModificationDate:file];
    
    // get the current configuration
    NSManagedObjectContext *context = [AxDataManager configContext];
    Configuration *config = [RealPropertyApp getConfiguration];
    double updateDate = config.rendererUpdateDate;
    
    if(updateDate <  [modifDate timeIntervalSinceReferenceDate])
    {
        // Configuration needs to be updated
        config.rendererUpdateDate = [modifDate timeIntervalSinceReferenceDate];
        // Now delete all references to objects

        NSArray *array = [AxDataManager dataListEntity:@"RendererConfig" andSortBy:@"name" sortAscending:YES withContext:context];
        
        for(RendererConfig *renderer in array)
        {
            [context deleteObject:renderer];
        }
        NSError *error;
        [context save:&error];
        // Now re-create the context based on file
        for(UniqueValueRenderer *uniqueValueRenderer in _xmlBreaker.allRenderers)
        {
            RendererConfig *rendererConfig = [AxDataManager getNewEntityObject:@"RendererConfig" andContext:context];
            rendererConfig.name = uniqueValueRenderer.rendererName;
            // Add the breakers
            for(Renderer *breaker in uniqueValueRenderer.renderers)
            {
                BreakerConfig *breakerConfig = [AxDataManager getNewEntityObject:@"BreakerConfig" andContext:context];
                breakerConfig.label = breaker.label;
                breakerConfig.color = [breaker.color stringFromColor];
                breakerConfig.value = breaker.value;
                [rendererConfig addBreakerConfigObject:breakerConfig];
            }
        }
        [context save:&error];
    }
    else 
    {
        // The different renderers need to be updated based on the configuration
        for(UniqueValueRenderer *uniqueValueRenderer in _xmlBreaker.allRenderers)
        {
            [self updateUniqueValueRenderer:uniqueValueRenderer];
        }
    }
}

// Update the breaker layer
-(void) updateUniqueValueRenderer:(UniqueValueRenderer *)uniqueRenderer
{
    NSManagedObjectContext *context = [AxDataManager configContext];
    RendererConfig *rendererConfig = [AxDataManager getEntityObject:@"RendererConfig" andPredicate:[NSPredicate predicateWithFormat:@"name=%@",uniqueRenderer.rendererName] andContext:context];
    if(rendererConfig==nil)
        return;
    
    // Update the breaker...
    NSSet *set = rendererConfig.breakerConfig;
    
    NSEnumerator *enumerator = [set objectEnumerator];
    BreakerConfig *breakerConfig;
    
    while(breakerConfig = [enumerator nextObject])
    {
        // retrieve the breaker
        for(Renderer *breaker in uniqueRenderer.renderers)
        {
            if([breaker.label compare:breakerConfig.label]==NSOrderedSame)
            {
                //  breaker.label = breakerConfig.label;
                breaker.color = [UIColor colorWithString:breakerConfig.color];
                breaker.value = breakerConfig.value;
                break;
            }
        }
    }
    
}
//
// check for map layer files in the documents of the app
//
// 
-(void) checkForFiles
{
    self.fileList = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    publicDocumentsDir = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], [RealPropertyApp getWorkingArea]];   
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&error];
    
    if (files == nil ) 
    {
        // if we see this error, the application is in deep trouble!
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return;
    }
    int i = 0;
    
    // load the default values (if necessary)
    NSString *file;
    [self resetLayersConfiguration];
    
    [self resetRenderersConfiguration];
        
    // First Pass: go through the list of files to look for the background layers. They must
    // be processed before any of the other files.
    
    for (NSString *file in files) 
    {
        NSRange range = [file rangeOfString:[RealPropertyApp getWorkingArea] options:NSCaseInsensitiveSearch];
        
        // Ignore all the files that do not contain the name of the local area
        if(range.length<=0)
            continue;
        
        if ([[file pathExtension] compare:@"sid"] == NSOrderedSame)
        {
            LayerInfo * layerFound = [[LayerInfo alloc] init];
            layerFound.fileName = file;
            layerFound.tableName = file;    // File name & table name are equivalent in that case
            layerFound.filePath = [publicDocumentsDir stringByAppendingPathComponent:file];
            layerFound.index = i;
            NSError* ItemAtPathError = nil;
            NSDictionary *fileAttributes =[[NSFileManager defaultManager] attributesOfItemAtPath:layerFound.filePath error:&ItemAtPathError];
            
            // Error check for file details
            if(ItemAtPathError != nil)
                abort();
            
            // gets the file size in bytes.
            NSNumber *bundleSize = [fileAttributes objectForKey:NSFileSize];
            layerFound.fileSize = [bundleSize doubleValue];
            
            layerFound.numShapes = -1;
            layerFound.tableName = file;
            layerFound.fileType = MRSIDFILETYPE;
            
            [fileList addObject:layerFound];
            [self applyConfiguration:layerFound];

        }
        NSRange rangeTitles = [file rangeOfString:@"tiles"];
        //if ([[file pathExtension] compare:@"tiles"] == NSOrderedSame)
        if(rangeTitles.length >0)
        {
            LayerInfo * layerFound = [[LayerInfo alloc] init];
            layerFound.fileName = file;
            layerFound.tableName = [file stringByReplacingOccurrencesOfString:@".sqlite" withString:@""];
            
            layerFound.filePath = [publicDocumentsDir stringByAppendingPathComponent:file];
            layerFound.index = i;
            NSError* ItemAtPathError = nil;
            NSDictionary *fileAttributes =[[NSFileManager defaultManager] attributesOfItemAtPath:layerFound.filePath error:&ItemAtPathError];
            
            // Error check for file details
            if(ItemAtPathError != nil)
                abort();
            
            // gets the file size in bytes.
            NSNumber *bundleSize = [fileAttributes objectForKey:NSFileSize];
            layerFound.fileSize = [bundleSize doubleValue];
            
            layerFound.numShapes = -1;
            layerFound.fileType = CACHEFILETYPE;
            
            [fileList addObject:layerFound];
            [self applyConfiguration:layerFound];
            
        }    
    }
    // If the file list is empty, abort
    if([fileList count]==0)
    {
        [Helper alertWithOk:@"Error" message:@"Some files are missing. Please re-install the application"];
        return;
    }
    // Look through the configuration file
    if ([fileList count] > 0 && _baseMap == NULL)
    {
        LayerInfo* basemapInfo = (LayerInfo*)[fileList objectAtIndex:0];
        
        MapLayerConfig* baseLayerConfig = [ArcGisViewController getConfigFromLayerInfo:basemapInfo];
                
        [self syncLayerLoader:basemapInfo withConfig:baseLayerConfig];
        _baseMap = (AGSTiledLayer*)basemapInfo.mapLayer;
        [self.mapView zoomToEnvelope:_baseMap.fullEnvelope animated:YES];
    }
    //
    // After reading the SID files, look through the different databases
    //

    file = [NSString stringWithFormat:@"%@.layers.sqlite", [RealPropertyApp getWorkingArea]];
    sqlite3 * db;
    sqlite3_stmt* statement;
    int rc = sqlite3_open([[publicDocumentsDir stringByAppendingPathComponent:file] cStringUsingEncoding:[NSString defaultCStringEncoding]], &db);
    if (rc)
    {
        [Helper alertWithOk:@"Error" message:@"Error while reading a file. Please re-install the application"];
        return;
    }
    else 
    { 

        // Get all the different tables in that database
        const char* pzTail;
        const char* command = "select f_table_name, f_geometry_column, type, ref_sys_name from geom_cols_ref_sys";
        int rc = sqlite3_prepare_v2(db, command, strlen(command), &statement, &pzTail);
        if(rc == SQLITE_OK)
        {
            while(sqlite3_step(statement)==SQLITE_ROW)
            {
                LayerInfo * layerFound = [[LayerInfo alloc] init];
                layerFound.fileName = file;
                layerFound.filePath = [publicDocumentsDir stringByAppendingPathComponent:file];
                layerFound.index = i;
                layerFound.fileSize = 0;
                layerFound.isLoaded = false;
                layerFound.isVisible = false;
                layerFound.numShapes = -1;
                layerFound.fileType = SQLITEFILETYPE;

                layerFound.tableName = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 0) encoding:[NSString defaultCStringEncoding]];
                layerFound.geoColumnName = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 1) encoding:[NSString defaultCStringEncoding]];
                layerFound.shapeTypeName = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 2) encoding:[NSString defaultCStringEncoding]];
                layerFound.projection = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 3) encoding:[NSString defaultCStringEncoding]];
                [fileList addObject:layerFound];
                [self applyConfiguration:layerFound];
            }
            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(db);
}
//
// Open a layer
//
-(void)openLayerFile:(LayerInfo*) layerInfo
{
     [[ATActivityIndicator currentIndicator] displayActivity:[NSString stringWithFormat:@"Opening layer %@", layerInfo.tableName]];
    
    MapLayerConfig* layerconfig = [ArcGisViewController getConfigFromLayerInfo:layerInfo];
    
    [self syncLayerLoader:layerInfo withConfig:layerconfig];
    [self hideIndicator];
}
// Funtion to load a layer in a background thread.
-(void) asyncLayerLoader:(LayerInfo*) layerInfo withConfig: (MapLayerConfig*) layerconfig
{
}
//
// First call when turning on a layer
//
-(void) syncLayerLoader:(LayerInfo*) layerInfo withConfig: (MapLayerConfig*) layerconfig
{
    AGSLayer* layer = NULL;
    NSManagedObjectContext * context = [AxDataManager configContext];
    BOOL isNewConfig = FALSE;
    
    if (layerInfo.fileType == SQLITEFILETYPE) // Only for SQL layers
    {
        SpatiaLiteLayer* spatialliteLayer = [[SpatiaLiteLayer alloc] initWithFilePath:[NSString stringWithFormat:layerInfo.filePath, publicDocumentsDir] andTableName:layerInfo.tableName andGeoColName:layerInfo.geoColumnName forMap:self.mapView withConfig:layerconfig];
        
        layerInfo.isLoaded = true;
        
        [spatialliteLayer setMaxScale:layerconfig.maxScale];
        [spatialliteLayer setMinScale:layerconfig.minScale];
        
        layer = spatialliteLayer;

        spatialliteLayer.showShapes = layerconfig.showShapes;
        spatialliteLayer.showLabels = layerconfig.showLabels;
        spatialliteLayer.scaleLabels = layerconfig.scaleLabel;
        spatialliteLayer.showAnnotationPolygonContainers = NO; // layerconfig.showAnnotationPolygons;
        spatialliteLayer.labelColumnName = layerconfig.columnLabel;
        spatialliteLayer.clipping = layerconfig.clipping;
        spatialliteLayer.removeLabelDuplicates = layerconfig.removeLabelDuplicates;
        spatialliteLayer.isParcel = layerconfig.isParcel;
        spatialliteLayer.isStreet = layerconfig.isStreet;
        spatialliteLayer.isWtrBdy = layerconfig.isWtrBdy;
        spatialliteLayer.labelColumnName = layerconfig.columnLabel;
        spatialliteLayer.defaultLabelSymbol.color = [UIColor  colorWithString:layerconfig.labelColor];
        spatialliteLayer.defaultLabelSymbol.fontSize = layerconfig.labelFontSize;

        
        [self.mapView addMapLayer:spatialliteLayer withName:layerInfo.tableName];
        layerInfo.isVisible = true;
        layerInfo.index = [self.mapView.mapLayers indexOfObject:layer];
        layerInfo.mapLayer = spatialliteLayer;
        layerconfig.isVisible = TRUE;
        
        [spatialliteLayer prepareGeographicQuery];
        
        if (!layerconfig.clipping || (self.mapView.mapScale > 0 && layerconfig.minScale >= self.mapView.mapScale && layerconfig.maxScale <= self.mapView.mapScale))
        {
            [spatialliteLayer executeGeographicQuery]; // Execute the query now...
        }
    }
    else if (layerInfo.fileType == CACHEFILETYPE)
    {
        NSError* err = nil;
        OfflineTiledLayer* tileLayer = [[OfflineTiledLayer alloc] initWithDataFramePath:layerInfo.filePath error:&err];
        if (err == nil)
        {
            layerInfo.isLoaded = true;
            layerInfo.isVisible = true;
            
            [self.mapView insertMapLayer:tileLayer withName:layerInfo.tableName atIndex:0];
            // [self.mapView zoomToEnvelope:tileLayer.initialEnvelope animated:YES];
            layerInfo.isVisible = true;
            layerconfig.isVisible = TRUE;
            layerInfo.index = [self.mapView.mapLayers indexOfObject:tileLayer];
            layerInfo.mapLayer = tileLayer;
            layer = tileLayer;
        }       // I should have self,layerconfig,layerInfo,layer,tileLayer
    }
    else if (layerInfo.fileType == MRSIDFILETYPE)
    {
        NSError* err = nil;
        SidTiledLayer* tileLayer = [[SidTiledLayer alloc] initWithDataFramePath:layerInfo.filePath error:&err];
        if (err == nil)
        {
            layerInfo.isLoaded = true;
            layerInfo.isVisible = true;
            
            [self.mapView insertMapLayer:tileLayer withName:layerInfo.tableName atIndex:0];
            // [self.mapView zoomToEnvelope:tileLayer.initialEnvelope animated:YES];
            layerInfo.isVisible = true;
            layerconfig.isVisible = TRUE;
            layerInfo.index = [self.mapView.mapLayers indexOfObject:tileLayer];
            layerInfo.mapLayer = tileLayer;
            layer = tileLayer;
        }
    }
    
    if (layer != NULL && [layer isKindOfClass:[BaseShapeCustomLayer class]])
    {
        BaseShapeCustomLayer* shapeLayer = (BaseShapeCustomLayer*)layer;
        if (!isNewConfig)
        {
            
            shapeLayer.titleColumnName = layerconfig.titleColumn;
            shapeLayer.descriptionColumName = layerconfig.descriptionColumn;
        }
        else 
        {
            layerconfig.minScale = [shapeLayer minScale];
            layerconfig.maxScale = [shapeLayer maxScale];
            layerconfig.titleColumn = shapeLayer.titleColumnName;
            layerconfig.descriptionColumn = shapeLayer.descriptionColumName;
        }
        if ([layerInfo.shapeTypeName compare:(NSString*)SHAPETYPEMULTILINESTRING] == NSOrderedSame ||
            [layerInfo.shapeTypeName compare:(NSString*)SHAPETYPELINESTRING]==NSOrderedSame)
        {
            if (!isNewConfig)
            {
                shapeLayer.renderSymbol.color = [UIColor colorWithString:layerconfig.lineColor];
                ((AGSSimpleLineSymbol*)shapeLayer.renderSymbol).style = [LayerInfo AGSSimpleLineSymbolStyleFromString:layerconfig.fillStyle];
                ((AGSSimpleLineSymbol*)shapeLayer.renderSymbol).width = layerconfig.lineWidth;
            }
            else 
            {
                layerconfig.lineColor = [shapeLayer.renderSymbol.color stringFromColor];
                layerconfig.fillStyle = [LayerInfo StringFromAGSSimpleLineSymbolStyle:((AGSSimpleLineSymbol*)shapeLayer.renderSymbol).style];
            }
        }
        else if ([layerInfo.shapeTypeName compare:(NSString*)SHAPETYPEMULTIPOINT] == NSOrderedSame ||
                 [layerInfo.shapeTypeName compare:(NSString*)SHAPETYPEPOINT] == NSOrderedSame)
        {
            if (!isNewConfig)
            {
                shapeLayer.renderSymbol.color = [UIColor colorWithString:layerconfig.fillColor];
                ((AGSSimpleMarkerSymbol*)shapeLayer.renderSymbol).style = [LayerInfo AGSSimpleMarkerSymbolStyleFromString:layerconfig.fillStyle];
            }
            else 
            {
                layerconfig.fillColor = [shapeLayer.renderSymbol.color stringFromColor];
                layerconfig.fillStyle = [LayerInfo StringFromAGSSimpleMarkerSymbolStyle:((AGSSimpleMarkerSymbol*)shapeLayer.renderSymbol).style];
            }
        }
        else if ([layerInfo.shapeTypeName compare:(NSString*)SHAPETYPEMULTIPOLYGON] == NSOrderedSame ||
                 [layerInfo.shapeTypeName compare:(NSString*)SHAPETYPEPOLYGON] == NSOrderedSame)
        {
            if (!isNewConfig)
            {
                shapeLayer.renderSymbol.color = [UIColor colorWithString:layerconfig.fillColor];
                ((AGSSimpleFillSymbol*)shapeLayer.renderSymbol).outline.color = [UIColor colorWithString:layerconfig.lineColor];
                ((AGSSimpleFillSymbol*)shapeLayer.renderSymbol).style = [LayerInfo AGSSimpleFillSymbolStyleFromString:layerconfig.fillStyle];
            }
            else 
            {
                layerconfig.fillColor = [shapeLayer.renderSymbol.color stringFromColor];
                layerconfig.lineColor = [((AGSSimpleFillSymbol*)shapeLayer.renderSymbol).outline.color stringFromColor];
                layerconfig.fillStyle = [LayerInfo StringFromAGSSimpleFillSymbolStyle:((AGSSimpleFillSymbol*)shapeLayer.renderSymbol).style];
            }
        }
    }
    
    NSError* error = NULL;  // check results
    if ([context hasChanges])
    {
        if (![context save:&error]) {
            NSLog(@"Error saving MapLayerConfig: %@. %@", layerInfo.tableName, [error localizedDescription]);
        }
    }
    
}

-(void) asyncLayerLoader:(LayerInfo*) layerInfo 
{
    
    @autoreleasepool 
    {
        MapLayerConfig* layerconfig = [ArcGisViewController getConfigFromLayerInfo:layerInfo];
        
        [self syncLayerLoader:layerInfo withConfig:layerconfig];
	}
    //[self performSelectorOnMainThread:@selector(hideIndicator) withObject:nil waitUntilDone:NO];
}
     
-(void) hideIndicator
{
    [self refreshZoomLevel];
    [[ATActivityIndicator currentIndicator] displayCompleted:@"Layer loaded"];
}
     
#pragma mark - layer management


-(void) closeVisibleLayers
{
    //DBaun 2014-07-08 Commenting this out per email with Hoang to try and fix map issues.
    //    for(LayerInfo *info in fileList)
    //    {
    //        // Skip the parcel and aerial layers
    //        MapLayerConfig *config = [ArcGisViewController getConfigFromLayerInfo:info];
    //        if(config.isParcel || config.isSID)
    //            continue;
    //        if(info.isVisible)
    //            [self hideLayer:info];
    //    }
    
    //DBaun 2014-03-17 Commenting this out so the renderer isn't removed when there's a low memory warning.
    //[self cleanUpCaches];
}


-(void) hideLayer: (LayerInfo*) layerInf
{
 //   UIView<AGSLayerView>* lyrView =  [self.mapView.mapLayerViews objectForKey:layerInf.tableName];
 //   lyrView.hidden = YES;
    layerInf.isVisible = NO;
    [self.mapView removeMapLayerWithName:layerInf.tableName];
    layerInf.isLoaded = false;
    layerInf.mapLayer = nil;
    [self saveLayerConfig:layerInf];
}


-(void) showLayer: (LayerInfo*) layerInf
{
    UIView<AGSLayerView>* lyrView =  [self.mapView.mapLayerViews objectForKey:layerInf.tableName];
    lyrView.hidden = NO;
    layerInf.isVisible = YES;
    if ([layerInf.mapLayer isKindOfClass:[SpatiaLiteLayer class]])
    {
        [((SpatiaLiteLayer*)layerInf.mapLayer) executeGeographicQuery];
    }
    [self saveLayerConfig:layerInf];
}


- (void) zoomToLayer:(LayerInfo*) layerInfo
{
    UIView<AGSLayerView>* lyrView =  [self.mapView.mapLayerViews objectForKey:layerInfo.tableName];
    if (lyrView != nil)
    {
        //[self.mapView zoomToEnvelope:lyrView.i animated:YES];
    }
}


-(void) setLayer: (LayerInfo*) layerInf toAlpha: (CGFloat) alpha 
{
    UIView<AGSLayerView>* lyrView =  [self.mapView.mapLayerViews objectForKey:layerInf.tableName];
    lyrView.alpha = alpha;
}


-(void) moveLayer: (LayerInfo*) layerInf to: (int) index 
{
    [self.mapView exchangeSubviewAtIndex:layerInf.index withSubviewAtIndex:index];
    for (int i =0; i < [self.mapView.mapLayers count]; i++) 
    {
        LayerInfo* info = ((LayerInfo*)[fileList objectAtIndex:i]);
        if (info.index == index) {
            info.index = layerInf.index;
        }
    }
    layerInf.index = index;
    [self saveLayerConfig:layerInf];
}




#pragma mark - parcel management

// Change the zoom level of a map
-(void)adjustZoomLevel:(double)zoomLevel
{
    AGSPoint *center = self.mapView.visibleArea.envelope.center;
    [self.mapView zoomToScale:zoomLevel withCenterPoint:center animated:YES];
}


-(void) highlightParcel: (id)pin
{
    if (_parcels != NULL && pin != NULL)
    {
        [self highlightParcels:[NSArray arrayWithObject:pin] selectedParcels:nil];
    }
}


-(void) highlightParcels: (NSArray*) parcelPins selectedParcels:(NSArray *)selectedParcels
{
    [[ATActivityIndicator currentIndicator]show];
    if (_parcels != NULL && parcelPins != NULL && [parcelPins count])
    {
        if (!_parcels.isVisible)
        {
            [self showLayer:_parcels];
        }
        [self addPushpinLayer];
        
        // Load the centers
        if(centers==nil)
        {
            SpatiaLiteLayer *layer = (SpatiaLiteLayer *)_parcels.mapLayer;
            centers = [layer loadParcelCenters];
            if(centers==nil || [centers count]==0)
                centers = [layer calculateCenterOfShape];
        }
        
        // NSArray * graphics = [(SpatiaLiteLayer*)_parcels.mapLayer highlightShapesWhereColumn:@"RealPropId" hasValueIn:parcelPins andIncludeTheAttributes:[NSArray arrayWithObject:@"RealPropId"]];
        
        NSArray *graphics = [((SpatiaLiteLayer *)_parcels.mapLayer) highlightShapes:parcelPins withCenter:centers];
        
        if ([graphics count]>0)
        {
            [_pushPinLayer removeAllGraphics];
            [_pushPinLayer addGraphics:graphics];
            
            AGSSimpleMarkerSymbol *redPin = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor redColor]];
            
            // Change the style for the selected parcels
            for(AGSGraphic *graphic in graphics)
            {
                NSNumber *parcelId = [graphic.attributes valueForKey:@"RealPropId"];
                if([selectedParcels containsObject:parcelId])
                {
                    // CHange it to red
                    graphic.symbol = redPin;
                }
            }
            
            [_pushPinLayer dataChanged];
            [self addSelectedIcon];
            if(_delegate)
                [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];

        }

    }
    else 
    {
        [_pushPinLayer removeAllGraphics];
        [((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes removeAllObjects];
        [_pushPinLayer dataChanged];
        [self addSelectedIcon];
        if(_delegate)
            [_delegate arcGisViewController:self selectionHasChanged:((SpatiaLiteLayer*)_parcels.mapLayer).selectedShapes];
    }
    [[ATActivityIndicator currentIndicator]hide];
}

-(void)centerParcel
{
    if (((SpatiaLiteLayer*)_parcels.mapLayer).highlightShapesEnvelope != NULL && zoomToEnvelop)
    {
        if ([[(SpatiaLiteLayer*)_parcels.mapLayer highlightShapesEnvelope] width] > 320)
        {
            [self.mapView zoomToEnvelope:[(SpatiaLiteLayer*)_parcels.mapLayer initialEnvelope] animated:NO];
            [self.mapView zoomToEnvelope:[(SpatiaLiteLayer*)_parcels.mapLayer highlightShapesEnvelope] animated:YES];
            
        }
        else 
        {
            [self.mapView zoomToScale:1500 withCenterPoint:[[(SpatiaLiteLayer*)_parcels.mapLayer highlightShapesEnvelope] center] animated:YES];
            
        }
    }
}

-(void) selectParcel: (NSNumber*)pin
{
    if (_parcels != NULL && pin != NULL)
    {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [array addObject:pin];
        [self selectParcels:array];
    }
}
-(void) selectParcels:(NSArray*)parcelPins
{
    if (_baseMap != NULL && _parcels != NULL && parcelPins != NULL && [parcelPins count] > 0)
    {
        [(SpatiaLiteLayer*)_parcels.mapLayer filterByShapesWhereColumn:@"RealPropId" hasValueIn:parcelPins];
        if ([[[(SpatiaLiteLayer*)_parcels.mapLayer fullEnvelope] envelope] width] > 500)
        {
            [self.mapView zoomToEnvelope:[(SpatiaLiteLayer*)_parcels.mapLayer fullEnvelope] animated:YES];
        }
        else 
        {
            [self.mapView centerAtPoint:[[(SpatiaLiteLayer*)_parcels.mapLayer fullEnvelope] center] animated:NO];
            
            CGPoint screenPoint = [self.mapView toScreenPoint:[[(SpatiaLiteLayer*)_parcels.mapLayer fullEnvelope] center]];
            int levelToZoomTo = [((OfflineTiledLayer*)_baseMap).tileInfo.lods count]-2;
            if( levelToZoomTo < 0)
                levelToZoomTo = 0;
            AGSLOD* lod = NULL;
            if ([_baseMap isKindOfClass:[OfflineTiledLayer class]])
            {
                lod = [((OfflineTiledLayer*)_baseMap).tileInfo.lods objectAtIndex:levelToZoomTo];
            }
            else 
            {
                lod = [((AGSTiledMapServiceLayer*)_baseMap).mapServiceInfo.tileInfo.lods objectAtIndex:levelToZoomTo];
            }
            
            float zoomFactor = lod.resolution/self.mapView.resolution;
            
            [self.mapView zoomWithFactor:zoomFactor atAnchorPoint:screenPoint animated:YES];
        }
        [(SpatiaLiteLayer*)_parcels.mapLayer removeQuery];

        //[self.mapView zoomToEnvelope:[_parcels fullEnvelope] animated:YES];
    }
}
// Remove the parcel renderers
-(void) clearParcelFilter
{
    
   if (_parcels != NULL)
   {
       [(SpatiaLiteLayer*)_parcels.mapLayer removeQuery];
   }
}
// Add the parcel renderes
-(void) setParcelRenderer: (id)renderer withTitle: (NSString*)title
{
    if (_parcels != NULL)
    {
        if (!_parcels.isVisible)
        {
            // [self showLayer:_parcels];
            [self openLayerFile:_parcels];
        }
        if (renderer == NULL)
        {
            renderer = [AGSSimpleRenderer simpleRendererWithSymbol:[(SpatiaLiteLayer*)_parcels.mapLayer renderSymbol]];
        }
        else
        {
            [renderer cleanUp];
        }
       
        [(SpatiaLiteLayer*)_parcels.mapLayer setRenderer:renderer];
        [(SpatiaLiteLayer*)_parcels.mapLayer dataChanged];
        
        
        if (_mapLegend == NULL)
        {
            _mapLegend = [[MapLegend alloc] initWithNibName:@"MapLegend" andRenderer:renderer];
            _mapLegend.delegate = self;
            [self.view addSubview:_mapLegend.view];
            CGPoint legendCenter = CGPointMake(self.view.frame.size.width - (_mapLegend.view.frame.size.width / 2.0f) - 15, self.view.frame.size.height - (_mapLegend.view.frame.size.height / 2.0f) - 15);
            
            [_mapLegend.view setAlpha:0.8];
            [_mapLegend.view setCenter:legendCenter];
        }
        else 
        {
            _mapLegend.renderer = renderer;
            [_mapLegend.view setHidden:NO]; 
            [_mapLegend loadLegendItems];
        }
        
        // Get the default parcel
        MapLayerConfig *layerConfig = [AxDataManager getEntityObject:@"MapLayerConfig" andPredicate:[NSPredicate predicateWithFormat:@"isParcel=1"] andContext:[AxDataManager configContext]];
        
        _mapLegend.legendTitle.text = [NSString stringWithFormat:@"%@ (%@)", title, [ItemDefinition formatNumber:layerConfig.minScale]];
        
        UniqueValueRenderer *breaker = renderer;
        
        NSArray* labelSets = breaker.labelSets;
        if ([labelSets count]!=0)
        {
            for(RendererLabel *label in labelSets)
                [label cleanUp];
            [(SpatiaLiteLayer*)_parcels.mapLayer setLabelSets:labelSets];
            [(SpatiaLiteLayer*)_parcels.mapLayer performLabeling];
            [(SpatiaLiteLayer*)_parcels.mapLayer dataChanged];
        }
        
    }   
}

- (void)mapLegendCloseButtonClick
{
    [_mapLegend.view setHidden:YES];
    if (_parcels != NULL)
    {
        // remove custom renderer.
        UniqueValueRenderer *renderer = (UniqueValueRenderer *) ((SpatiaLiteLayer*)_parcels.mapLayer).renderer;
        if([renderer isKindOfClass:[UniqueValueRenderer class]])
            [renderer cleanUp];
        
        [(SpatiaLiteLayer*)_parcels.mapLayer setRenderer:[AGSSimpleRenderer simpleRendererWithSymbol:[(SpatiaLiteLayer*)_parcels.mapLayer renderSymbol]]];
        NSArray* labelSets = ((SpatiaLiteLayer*)_parcels.mapLayer).labelSets;
        for(RendererLabel *label in labelSets)
        {
            if([label isKindOfClass:[RendererLabel class]])
                [label cleanUp];
        }
        [(SpatiaLiteLayer*)_parcels.mapLayer setLabelSets:NULL];
        [(SpatiaLiteLayer*)_parcels.mapLayer performLabeling];
        [(SpatiaLiteLayer*)_parcels.mapLayer dataChanged];
    }
}

-(void)cleanUpCaches
{
    UniqueValueRenderer *renderer = (UniqueValueRenderer *) ((SpatiaLiteLayer*)_parcels.mapLayer).renderer;
    
    if([renderer isKindOfClass:[UniqueValueRenderer class]])
        [renderer cleanUp];
    
    [(SpatiaLiteLayer*)_parcels.mapLayer setRenderer:[AGSSimpleRenderer simpleRendererWithSymbol:[(SpatiaLiteLayer*)_parcels.mapLayer renderSymbol]]];
    
    NSArray* labelSets = ((SpatiaLiteLayer*)_parcels.mapLayer).labelSets;
    
    for(RendererLabel *label in labelSets)
    {
        if([label isKindOfClass:[RendererLabel class]])
            [label cleanUp];
    }
}

#pragma mark - sketch management

- (void) addSketchLayer
{
    if (_sketchLyr == NULL)
    {
        _sketchLyr = [[AxSketchLayer alloc] init];
    }
    if (![self.mapView.mapLayers containsObject:_sketchLyr]) 
    {
        [self.mapView addMapLayer:_sketchLyr withName:@"Sketch Layer @dr"];
    }
    
    if (_mapRuler == NULL)
    {
        _mapRuler = [[MapRuler alloc] initWithNibName:@"MapRuler" bundle:nil];
        _mapRuler.delegate = self;
        [self.view addSubview:_mapRuler.view];
        CGPoint center = CGPointMake((_mapRuler.view.frame.size.width / 2.0f) + 15, (_mapRuler.view.frame.size.height / 2.0f) + 15);
        
        [_mapRuler.view setAlpha:0.9];
        [_mapRuler.view setCenter:center];
    }
    else {
        
        [_mapRuler.view setHidden:NO]; 
    }
    _mapRuler.lenghtLabel.text = @"0";
    _mapRuler.areaLabel.text = @"0";
}

- (void) startSketchPolygon
{
    [self addSketchLayer];
    _sketchGeometry = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
    _sketchLyr.geometry = _sketchGeometry;
    
    _previewsTouchDelegate = self.mapView.touchDelegate;
    self.mapView.touchDelegate = _sketchLyr;
    [self.mapView setShowMagnifierOnTapAndHold:YES];
    _isSketching = TRUE;
}

- (void) startSketchPolyline
{
    [self addSketchLayer];
    
    _sketchGeometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    _sketchLyr.geometry = _sketchGeometry;
    
    _previewsTouchDelegate = self.mapView.touchDelegate;
    self.mapView.touchDelegate = _sketchLyr;
    [self.mapView setShowMagnifierOnTapAndHold:YES];
    _isSketching = TRUE;
}

- (void) endSketching
{
    [self.mapView removeMapLayerWithName:[_sketchLyr name]];
    _sketchGeometry = nil;
    self.mapView.touchDelegate = _previewsTouchDelegate;
    _isSketching = FALSE;
    [self.mapView setShowMagnifierOnTapAndHold:NO];
    if (_mapRuler != NULL)
    {
        [_mapRuler.view setHidden:YES];
    }
}

- (void) undoLastSketch
{
    NSUndoManager* mgr = _sketchLyr.undoManager;
    //Undo a change
    if([mgr canUndo]){
        [mgr undo];
    }
}

- (void) redoLastSketch
{
    NSUndoManager* mgr = _sketchLyr.undoManager;
    //Undo a change
    if([mgr canRedo]){
        [mgr redo];
    }
}

- (void)respondToGeomChanged: (NSNotification*) notification 
{
    // handle geo change in the sketch geometry
    if (_sketchGeometry != NULL)
    {
        AGSGeometryEngine* geoEngine = [AGSGeometryEngine defaultGeometryEngine];
        AGSGeometry* geometry = [geoEngine simplifyGeometry:_sketchGeometry];
        
        _sketchLenght = [geoEngine lengthOfGeometry:geometry];
        
       
        if ([_sketchGeometry isKindOfClass:[AGSMutablePolygon class]])
        {
            _sketchArea = [geoEngine areaOfGeometry:geometry];
        }
        else 
        {
            _sketchArea = 0;
        }
        if (_mapRuler != NULL)
        {
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setMaximumFractionDigits:2];
            [formatter setRoundingIncrement:[NSNumber numberWithDouble:0.5]];
            _mapRuler.lenghtLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithDouble:_sketchLenght]]];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setMaximumFractionDigits:0];
            _mapRuler.areaLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithDouble:_sketchArea]]];
        }
    }
}

- (void)mapRulerDoneButtonClick
{
    [self endSketching];
    [menuBar setItemSelected:kBtnMeasure isSelected:NO];
}


#pragma mark - google
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pushpin"];
    annView.pinColor = MKPinAnnotationColorRed;
    if ([annotation isKindOfClass:[parcelAnnotation class]])
    {
        if (((parcelAnnotation*)annotation).fromSearch)
        {
            annView.pinColor = MKPinAnnotationColorPurple;
        }
        else 
        {
            annView.pinColor = MKPinAnnotationColorRed;
        }
    }
    
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}
-(void) showGoogleMap
{
    if (_pushPinLayer != NULL)
    {
        AGSSpatialReference*  wgs84 = [AGSSpatialReference wgs84SpatialReference];
        
        if (googleMapAnnotations != NULL && [googleMapAnnotations count] > 0)
        {
            [self.GoogleMapView removeAnnotations:googleMapAnnotations];
        }
        if (googleMapAnnotations == NULL)
        {
            googleMapAnnotations = [[NSMutableArray alloc] initWithCapacity:[_pushPinLayer.graphics count]];
        }
        else 
        {
            [googleMapAnnotations removeAllObjects];
        }
        
        self.GoogleMapView.hidden = false;
        
        AGSGeometryEngine* geoEngine = [AGSGeometryEngine defaultGeometryEngine];
        
        AGSPolygon* projectedView = (AGSPolygon*)[geoEngine projectGeometry:self.mapView.visibleArea toSpatialReference:wgs84];
        
        AGSEnvelope* viewArea = projectedView.envelope;
        AGSPoint* center = viewArea.center; 
        MKCoordinateSpan span = MKCoordinateSpanMake((viewArea.ymax - viewArea.ymin) * 0.8, (viewArea.xmax - viewArea.xmin) * 0.8);
        self.GoogleMapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(center.y, center.x), span);
        
        for (AGSGraphic * gr in _pushPinLayer.graphics) 
        {
            AGSPoint* pt = (AGSPoint*)[gr geometry];
            AGSPoint* projectePt = (AGSPoint*)[geoEngine projectGeometry:pt toSpatialReference:wgs84];
            parcelAnnotation* annotation = [[parcelAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(projectePt.y, projectePt.x)];
            [annotation setTitle: [gr.attributes valueForKey:@"RealPropID"]];
            annotation.fromSearch = gr.symbol == NULL;
            
            [self.GoogleMapView addAnnotation:annotation];
            [googleMapAnnotations addObject:annotation];
        }
        
        
        self.mapView.hidden = true;
    }
}

- (void) hideGoogleMap
{
    self.mapView.hidden = false;
    self.GoogleMapView.hidden = true;
}

- (void) toogleGoogleMap
{
    if (self.GoogleMapView.hidden)
    {
        [self showGoogleMap];
        [menuBar setItemSelected:kBtnGoogle isSelected:YES];
    }
    else 
    {
        [self hideGoogleMap];
        [menuBar setItemSelected:kBtnGoogle isSelected:NO];
    }
}
#pragma mark - Location
- (void)registerAsObserver 
{
    @try {
        [ self.mapView.gps addObserver:self forKeyPath:@"currentPoint" options:(NSKeyValueObservingOptionNew) context:NULL];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}
- (void)removeAsObserver 
{
    @try {
        [ self.mapView.gps removeObserver:self forKeyPath:@"currentPoint"];
    }
    @catch (NSException *exception) {
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if ([keyPath isEqual:@"currentPoint"]) 
    {
        if(!self.GoogleMapView.hidden)
            return;
        if(![self.mapView.fullEnvelope containsPoint:self.mapView.gps.currentPoint])
        {
            // Outside the visible area -- stop the GPS
            [self stopGPS];
            [Helper alertWithOk:@"GPS" message:@"You have traveled outside the map area!"];
        }
    }
}
-(void) stopGPS
{
    _trackGps = NO;
    self.GoogleMapView.showsUserLocation = NO;
    [self removeAsObserver];
    [self.mapView.gps stop];
    [menuBar setItemSelected:kBtnDropPin isSelected:NO];

}
-(void) startGPS
{
    _trackGps = YES;
    self.GoogleMapView.showsUserLocation = YES;
    [self registerAsObserver];
    [self.mapView.gps start];
    self.mapView.gps.autoPanMode = true;
    [menuBar setItemSelected:kBtnDropPin isSelected:YES];
}
-(void) dropCurrentPosition
{
    [self verifyLocationManager:^(void) {
        if(!_trackGps)
            [self startGPS];
        else
            [self stopGPS];
    }];
}
#pragma mark - Handle compass
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
-(void) verifyLocationManager:(BlockAfterValidation)block
{
    if(![CLLocationManager locationServicesEnabled])
        return;
#if 0
    if(![CLLocationManager locationServicesEnabled])
    {
        _locationAlert = [[UIAlertView alloc]initWithTitle:@"Enable Location Services"
                                                   message:@"Do you want to change the Location Services settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
        [_locationAlert show];
        return;
    }
#if 0
    
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized)
    {
        // this device is not authorized for location
        _locationAlert = [[UIAlertView alloc]initWithTitle:@"Location Services Unavailable"
                        message:@"Do you want to change the Location Services settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
        [_locationAlert show];
        return;
    }
#endif
    if(![CLLocationManager headingAvailable])
    {
        _locationAlert = [[UIAlertView alloc]initWithTitle:@"Compass Unavailable"
                                                   message:@"Do you want to change the Location Services settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
        [_locationAlert show];
        return;
    }
#endif
    block();
}
-(void) toggleCompass
{
    if([menuBar isItemSelected:kBtnCompass])
    {
        [menuBar setItemSelected:kBtnCompass isSelected:NO];
        self.ArrowView.hidden = YES;
        [_locationManager stopUpdatingHeading];
        _locationManager = nil;
    }
    else 
    {
        // Start the compass
        // First verify that the compass is activated
        [self verifyLocationManager:^(void)
         {
             [menuBar setItemSelected:kBtnCompass isSelected:YES];
             self.ArrowView.hidden = NO;
             _locationManager = [[CLLocationManager alloc]init];
             _locationManager.delegate = self;
             [_locationManager startUpdatingHeading];
         }];

    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if(newHeading.headingAccuracy > 0)
    {
        CLLocationDirection heading = newHeading.trueHeading;
        self.ArrowView.transform = CGAffineTransformMakeRotation(-DEGREES_TO_RADIANS(heading));

    }
}
-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}


#pragma mark - TabMapDetail


-(void)createTabMapDetail:(CGPoint)location realPropId:(NSNumber *)realPropId
{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    
    if(_mapDetail!=nil)
    {
        rect = _mapDetail.view.frame;
        [_mapDetail.view removeFromSuperview];
        [_mapDetail removeFromParentViewController];
    }

    _mapDetail = [[TabMapDetail alloc]initWithNibName:@"TabMapDetail" bundle:nil];
    _mapDetailId = [realPropId intValue];
    
    [_mapDetail initDataWithRealPropId:realPropId.intValue];
    _mapDetail.delegate = self;

    if(CGRectIsEmpty(rect))
        rect = _mapDetail.view.frame;
    
    UIView *tabMapView = [TabMapController tabMapControllerView];
    [tabMapView addSubview:_mapDetail.view];
    [tabMapView bringSubviewToFront:_mapDetail.view];

    
    //cv    [_mapDetail initDataWithRealPropId:realPropId.intValue];
    
    
    if(rect.origin.y < 45)
        rect.origin.y = 45;
    _mapDetail.view.frame = rect;
}


-(void)tabMapDetailIsDone
{
    [_mapDetail.view removeFromSuperview];
    [_mapDetail removeFromParentViewController];
    _mapDetail = nil;
    [self removeIcon];
    
}


-(void)tabMapDetailSwitchHome:(RealPropInfo *)info
{
    [self addSelection:info.realPropId];
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    NSNumber *number = [NSNumber numberWithInt:info.realPropId];
    [appDelegate switchToProperty:number];
}


-(void)tabMapDetailSwitchCamera:(RealPropInfo *)info
{
    [self addSelection:info.realPropId];
    RealPropertyApp *appDelegate = (RealPropertyApp*)[[UIApplication sharedApplication] delegate];
    NSNumber *number = [NSNumber numberWithInt:info.realPropId];
    [appDelegate switchToCamera:number];
}


-(void)tabMapDetailRefreshLayers
{
    [self refreshParcelLayer];
}


-(void)tabMapDetailPosition:(RealPropInfo *)info
{
    [self selectParcel:[NSNumber numberWithInt:info.realPropId]];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_mapLegend != NULL)
    {
        [_mapLegend willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
@end
