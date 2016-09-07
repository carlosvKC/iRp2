#import "LayerDisplayConfController.h"
#import "LayerInfo.h"
#import <ArcGIS/ArcGIS.h>
#import "BaseShapeCustomLayer.h"
#import "SHPFileLayer.h"
#import "SpatiaLiteLayer.h"
#import "StylePickerController.h"
#import "ArcGisViewController.h"
#import "LayerList.h"
#import "AxColorPicker.h"
#import "MapLayerConfig.h"
#import "ColorPicker.h"

@implementation LayerDisplayConfController


@synthesize layerInfo;
@synthesize mapView;
@synthesize mapController;
@synthesize layerListController;
@synthesize targetLayer;


@synthesize stylePicker = _stylePicker;
@synthesize stylePickerPopover = _stylePickerPopover;
@synthesize attrPicker = _attrPicker;
@synthesize attrPickerPopover = _attrPickerPopover;
@synthesize axColorPicker = _colorPicker;
@synthesize colorPickerPopover = _colorPickerPopover;
@synthesize layerConfig = _layerConfig;

@synthesize mainColor;
@synthesize borderColor;
@synthesize styleSelector;

@synthesize slider;
@synthesize labelBorderColor;
@synthesize fontSlider;
@synthesize labelFontSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
//
// Helper to remove the transparency
//
-(UIColor *)noTransparency:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    UIColor *result = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return result;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.mainColor setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:1.0]];
    [self.borderColor setBackgroundColor:[UIColor blackColor]];
    
    if (self.targetLayer != nil)
    {
        if ([self.targetLayer isKindOfClass:[BaseShapeCustomLayer class]])
        {
            BaseShapeCustomLayer* shpLayer = (BaseShapeCustomLayer*)self.targetLayer;

            AGSSymbol* currentSymbol = shpLayer.renderSymbol;
            [self.borderColor setEnabled:NO];
            if ([currentSymbol isKindOfClass:[AGSSimpleMarkerSymbol class]])
            {
                switch (((AGSSimpleMarkerSymbol*)currentSymbol).style)
                {
                    case AGSSimpleMarkerSymbolStyleCircle:
                        [self.styleSelector setTitle:@"Circle" forState:UIControlStateNormal];
                        break;
                    case AGSSimpleMarkerSymbolStyleCross:
                        [self.styleSelector setTitle:@"Cross" forState:UIControlStateNormal];
                        
                        break; 
                    case AGSSimpleMarkerSymbolStyleDiamond:
                        [self.styleSelector setTitle:@"Diamond" forState:UIControlStateNormal];
                        
                        break;
                    case AGSSimpleMarkerSymbolStyleSquare:
                        [self.styleSelector setTitle:@"Square" forState:UIControlStateNormal];
                        
                        break;
                    case AGSSimpleMarkerSymbolStyleX:
                        [self.styleSelector setTitle:@"X" forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
                [self.mainColor setBackgroundColor:[self noTransparency:((AGSSimpleMarkerSymbol*)currentSymbol).color]];
                backColor = ((AGSSimpleMarkerSymbol*)currentSymbol).color;
            }
            else  if ([currentSymbol isKindOfClass:[AGSSimpleLineSymbol class]])
            {
                switch (((AGSSimpleLineSymbol*)currentSymbol).style)
                {
                    case  AGSSimpleLineSymbolStyleDash:
                        [self.styleSelector setTitle:@"Dash" forState:UIControlStateNormal];
                        break;
                        
                    case  AGSSimpleLineSymbolStyleDot:
                        [self.styleSelector setTitle:@"Dot" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleLineSymbolStyleDashDot:
                        [self.styleSelector setTitle:@"DashDot" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleLineSymbolStyleDashDotDot:
                        [self.styleSelector setTitle:@"DashDotDot" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleLineSymbolStyleInsideFrame:
                        [self.styleSelector setTitle:@"InsideFrame" forState:UIControlStateNormal];
                        break;
	
                    case  AGSSimpleLineSymbolStyleNull:
                        [self.styleSelector setTitle:@"None" forState:UIControlStateNormal];
                        break;

                    case AGSSimpleLineSymbolStyleSolid:
                        [self.styleSelector setTitle:@"Solid" forState:UIControlStateNormal];
                        break;
                }
                [self.mainColor setBackgroundColor:[self noTransparency:((AGSSimpleMarkerSymbol*)currentSymbol).color]];
                backColor = ((AGSSimpleMarkerSymbol*)currentSymbol).color;
            }
            else  if ([currentSymbol isKindOfClass:[AGSSimpleFillSymbol class]])
            {
                switch (((AGSSimpleFillSymbol*)currentSymbol).style)
                {
                    case  AGSSimpleFillSymbolStyleBackwardDiagonal:
                        [self.styleSelector setTitle:@"BackwardDiagonal" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleFillSymbolStyleCross:
                        [self.styleSelector setTitle:@"Cross" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleFillSymbolStyleDiagonalCross:
                        [self.styleSelector setTitle:@"DiagonalCross" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleFillSymbolStyleForwardDiagonal:
                        [self.styleSelector setTitle:@"ForwardDiagonal" forState:UIControlStateNormal];
                        break;
	
                    case  AGSSimpleFillSymbolStyleHorizontal:
                        [self.styleSelector setTitle:@"Horizontal" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleFillSymbolStyleNull:
                        [self.styleSelector setTitle:@"None" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleFillSymbolStyleSolid:
                        [self.styleSelector setTitle:@"Solid" forState:UIControlStateNormal];
                        break;

                    case  AGSSimpleFillSymbolStyleVertical:
                        [self.styleSelector setTitle:@"Vertical" forState:UIControlStateNormal];
                        break;
                }
                [self.mainColor setBackgroundColor:[self noTransparency:((AGSSimpleMarkerSymbol*)currentSymbol).color]];
                backColor = ((AGSSimpleMarkerSymbol*)currentSymbol).color;
                [self.borderColor setBackgroundColor:((AGSSimpleMarkerSymbol*)currentSymbol).outline.color];
                [self.borderColor setEnabled:YES];
            }

        }
    }
    // Set the value of the slider
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;

    
    CGFloat red, green, blue, alpha;
    [backColor getRed:&red green:&green blue:&blue alpha:&alpha];

    slider.value = alpha;
    
    // get the image view
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:10];
    imageView.image = [UIImage imageNamed:@"Image80x62.png"];
    
    // Get the view on top of it and assign the current color
    [self changeSliderValue:nil];
    UIView *myview = [self.view viewWithTag:1];
    self.contentSizeForViewInPopover = CGSizeMake(350, myview.frame.size.height);
    
    // Change the different elements depending if it is a polygon or a line
    if(!_layerConfig.isPolygon)
    {
        // we are handling a line
        for(int i=100;i<105;i++)
        {
            UIView *view = [self.view viewWithTag:i];
            if(view==nil)
                continue;
            view.hidden = YES;
        }
        // Change the title
        UILabel *label = (UILabel *)[self.view viewWithTag:9];
        label.text = @"Adjust Line Width";
        slider.minimumValue = 1.0;
        slider.maximumValue = 20.0;
        slider.value = _layerConfig.lineWidth;
        
        fontSlider.minimumValue = 0.0;
        fontSlider.maximumValue = 40.0;
        fontSlider.value = _layerConfig.labelFontSize;
        
        [self changeSliderValue:nil];
        
        labelBorderColor.hidden = NO;
        labelBorderColor.text = @"Text Color:";
        borderColor.hidden = NO;
        borderColor.enabled = YES;
        borderColor.backgroundColor = [UIColor colorWithString:_layerConfig.labelColor];
    }
    else 
    {
        // Multi-lines
        fontSlider.hidden = YES;
        labelFontSize.hidden = YES;
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;

}

#pragma mark - popups
-(IBAction)SetLayerStyle:(id)sender
{
    if (self.targetLayer != nil)
    {
        if ([self.targetLayer isKindOfClass:[BaseShapeCustomLayer class]])
        {
            if (_stylePicker == nil) 
            {
                self.stylePicker = [[StylePickerController alloc] 
                                     initWithStyle:UITableViewStylePlain];
                _stylePicker.delegate = self;
                self.stylePickerPopover = [[UIPopoverController alloc] 
                                            initWithContentViewController:_stylePicker];               
            }
            [self.stylePickerPopover presentPopoverFromRect:((UIButton*)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        }
    }
}

-(IBAction)SetLayerMainColor:(id)sender
{
    if (self.targetLayer != nil)
    {
        if ([self.targetLayer isKindOfClass:[BaseShapeCustomLayer class]])
        {
            if (_axColorPicker == nil) 
            {
                self.axColorPicker = [[AxColorPicker alloc] initWithNibName:@"AxColorPicker" bundle:nil];
                self.axColorPicker.target = sender;
                self.colorPickerPopover = [[UIPopoverController alloc] initWithContentViewController:self.axColorPicker];  
                self.axColorPicker.delegate = self;
            }
          
            _colorPicker.target = sender;
            [self.colorPickerPopover presentPopoverFromRect:((UIButton*)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        }
    }
}
-(void)lineWidth:(double)width
{
    [self.colorPickerPopover dismissPopoverAnimated:YES];
    self.colorPickerPopover = nil;
    
    if([((AGSSimpleLineSymbol *)((BaseShapeCustomLayer *) self.targetLayer).renderSymbol) respondsToSelector:@selector(setWidth:)])
        ((AGSSimpleLineSymbol *)((BaseShapeCustomLayer *) self.targetLayer).renderSymbol).width = width;
    [self.targetLayer dataChanged];    
}
//
// Change the transparency
//
-(IBAction)changeSliderValue:(id)sender
{
    // Adjust the slider
    UIView *view = [self.view viewWithTag:11];
    
    CGFloat red, green, blue, alpha;
    [backColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    backColor = [UIColor colorWithRed:red green:green blue:blue alpha:slider.value];
    view.backgroundColor = backColor;
    
    if(_layerConfig.isPolygon)
    {
        if(sender!=nil)
            [self colorSelected:backColor forTarget:mainColor];
    }
    else
    {
        UIView *pictView = [self.view viewWithTag:10];
        int height = slider.value;

        view.frame = CGRectMake(0, pictView.frame.size.height/2 -height/2,  pictView.frame.size.width, height);
        view.backgroundColor = backColor;

        if(sender!=nil)
            [self lineWidth:slider.value];
        
    }
}
//
// Change the font size
//
-(IBAction)changeFontSliderValue:(id)sender
{
    
    SpatiaLiteLayer *layer = (SpatiaLiteLayer *)self.targetLayer;
    layer.defaultLabelSymbol.fontSize = fontSlider.value;

    [self.targetLayer dataChanged]; 
    if([self.targetLayer isKindOfClass:[SpatiaLiteLayer class]]==TRUE)
    {
        [((SpatiaLiteLayer*)self.targetLayer) executeGeographicQuery];
    }
}
-(IBAction)SetLayerBorderColor:(id)sender
{
    [self SetLayerMainColor:sender];
}

// handle the color change delegate
-(void)colorSelected:(UIColor *)color forTarget:(id)target
{
    [self.colorPickerPopover dismissPopoverAnimated:YES];
    self.colorPickerPopover = nil;
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    [((UIButton*)target) setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
    
    
    if(target==mainColor)
        backColor = [UIColor colorWithRed:red green:green blue:blue alpha:slider.value];
    
    if (target == labelColor)
    {
        if ([self.targetLayer isKindOfClass:[SpatiaLiteLayer class]])
        {
            AGSTextSymbol* labelSymbol = ((SpatiaLiteLayer*)self.targetLayer).defaultLabelSymbol;
            labelSymbol.color = backColor;
            if([self.targetLayer isKindOfClass:[SpatiaLiteLayer class]]==TRUE)
            {
                [((SpatiaLiteLayer*)self.targetLayer) executeGeographicQuery];
            }
        }
    }
    else 
    {
        if ([self.targetLayer isKindOfClass:[BaseShapeCustomLayer class]])
        {
            AGSSymbol* currentSymbol = ((BaseShapeCustomLayer*)self.targetLayer).renderSymbol;
            if ([currentSymbol isKindOfClass:[AGSSimpleMarkerSymbol class]])
            {
                if (target == mainColor)
                    ((AGSSimpleMarkerSymbol*)currentSymbol).color = backColor;
            }
            else  if ([currentSymbol isKindOfClass:[AGSSimpleLineSymbol class]])
            {
                if (target == mainColor)
                    ((AGSSimpleLineSymbol*)currentSymbol).color = backColor;
                else  // font color, actually!
                {
                    SpatiaLiteLayer *layer = (SpatiaLiteLayer *)self.targetLayer;
                    layer.defaultLabelSymbol.color = color;
                    
                }
            }
            else  if ([currentSymbol isKindOfClass:[AGSSimpleFillSymbol class]])
            {
                if (target == mainColor)
                {
                    ((AGSSimpleFillSymbol*)currentSymbol).color = backColor;
                }
                else if (target == borderColor)
                {
                    ((AGSSimpleFillSymbol*)currentSymbol).outline.color = color;
                }
            }
        }
    }
    [self changeSliderValue:nil];
    [self.targetLayer dataChanged];
}

-(void)styleSelected:(NSString *)styleName withID:(int)styleid
{
    [self.stylePickerPopover dismissPopoverAnimated:YES];
    self.stylePickerPopover = nil;
    if (self.targetLayer != nil)
    {
        if ([self.targetLayer isKindOfClass:[BaseShapeCustomLayer class]])
        {
            [self.styleSelector setTitle:styleName forState:UIControlStateNormal];
            AGSSymbol* currentSymbol = ((BaseShapeCustomLayer*)self.targetLayer).renderSymbol;
            if ([currentSymbol isKindOfClass:[AGSSimpleMarkerSymbol class]])
            {
                ((AGSSimpleMarkerSymbol*)currentSymbol).style = styleid;
            }
            else  if ([currentSymbol isKindOfClass:[AGSSimpleLineSymbol class]])
            {
                ((AGSSimpleLineSymbol*)currentSymbol).style = styleid;
            }
            else  if ([currentSymbol isKindOfClass:[AGSSimpleFillSymbol class]])
            {
                ((AGSSimpleFillSymbol*)currentSymbol).style = styleid;   
            }
            
            [self.targetLayer dataChanged];
        }
    }
}

-(void)attributeSelected:(NSString *)attributeName forTarget:(id)target
{
    [((UIButton*)target) setTitle:attributeName forState:UIControlStateNormal];
    if (target == selectTitleColumn)
    {
        ((BaseShapeCustomLayer*)self.targetLayer).titleColumnName = attributeName;
    }
    else if (target == selectDescriptionColumn)
    {
        ((BaseShapeCustomLayer*)self.targetLayer).descriptionColumName = attributeName;
    }
    else if (target == selectLabelColumn)
    {
        if ([self.targetLayer isKindOfClass:[SpatiaLiteLayer class]])
        {
            ((SpatiaLiteLayer*)self.targetLayer).labelColumnName = attributeName;
            ((SpatiaLiteLayer*)self.targetLayer).defaultLabelSymbol.textTemplate = [NSString stringWithFormat:@"${%@}", attributeName];

        }
    }

}
-(void)updateStyle:(id)sender
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    if([self.targetLayer isKindOfClass:[SpatiaLiteLayer class]]==TRUE)
    {
        [((SpatiaLiteLayer*)self.targetLayer) executeGeographicQuery];
    }
    [mapController saveLayerConfig:layerInfo];
    if (layerListController != NULL)
    {
        [layerListController.tvList reloadData];
    }
    [super viewWillDisappear:animated];
}

@end
