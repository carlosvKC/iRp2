#import "DVModelController.h"
#import "DVModelView.h"
#import "MathHelper.h"
#import "MediaView.h"
#import "DVImagePicker.h"
#import "RealProperty.h"
#import "DVKeyboard.h"
#import "Helper.h"
#import "DVLabel.h"
#import "XMLReader.h"
#import "ColorPicker.h"
#import "ReadPictures.h"
#import "RealPropertyApp.h"
#import "FMDatabase.h"

#define MAX_UNDO    16

@implementation DVUndoObject
@synthesize layer, shape;

static     NSString    *copyDrawing;

//enum {
//    mtImages = 1,
//    mtMini = 2,
//    mtcadXml = 3,
//    mtVideo =4
//} _mediaType;


-(id)init:(DVLayer *)alayer shape:(DVShape *)ashape
{
    self = [super init];
    layer = alayer;
    shape = ashape;
    return self;
}

@end

@implementation DVModelController
@synthesize infoLabel = _infoLabel;
@synthesize segDrawMove = _segDrawMove;
@synthesize minScale, maxScale;
@synthesize segTools = _segTools;
@synthesize realPropInfo = _realPropInfo;
@synthesize delegate;
@synthesize btnMoveScreen = _btnMoveScreen;
@synthesize mediaBldg;
// 4/27/16 HNN not used
//@synthesize mediaAccy;
@synthesize mediaMode;
@synthesize sketchGuid;

//@synthesize mediaBldgNew;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinch];

    minScale = 0.50;
    maxScale = 5.0;
    _currentScale = 1.0;
    
    _model = [[DVModelView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_model];
    _model.multipleTouchEnabled = YES;
    _model.realPropInfo = _realPropInfo;
    
    // Basic init
    _currentTool = kToolLine;
    _model.currentTool = kToolLine;
    _model.crossMode = DVCrossRed;
    [self setPenMode:kDrawing];
    
    // Add the keyboard
    _keyboard = [[DVKeyboard alloc]initWithNibName:@"DVKeyboard" bundle:nil];
    
    [self addChildViewController:_keyboard];
    [self.view addSubview:_keyboard.view];
    [self.view bringSubviewToFront:_keyboard.view];
    
    _keyboard.delegate = self;

    // Bring the move button to front
    [self.view bringSubviewToFront:_btnMoveScreen];
    
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation] duration:0];

    // 4/27/16 HNN not sure why calling the open here since the pictcontroller calls loadmodel
//    if(mediaMode==kCadUpdate)
//        [self openModel];
    
    UIView *view = [self.view viewWithTag:60];
    
    _adjustButton = [Helper createBlueButton:view.frame withTitle:@"Done"];
    
    [view removeFromSuperview];
    
    [_adjustButton addTarget:self action:@selector(adjustDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_adjustButton];   
    _adjustButton.hidden = YES;
    
    [self registerForKeyboardNotifications:self withDelta:10];
    
    _keyboard.showLegend = YES;
    _model.showLegend = YES;

}
-(void)setRealPropInfo:(RealPropInfo *)info
{
    _realPropInfo = info;
    _model.realPropInfo = info;
}
- (void)viewDidUnload
{
    [self deregisterFromKeyboardNotifications];
    [self setInfoLabel:nil];
    [self setSegDrawMove:nil];
    [self setSegTools:nil];
    [self setBtnMoveScreen:nil];
    [super viewDidUnload];

}

#pragma mark -- Business logic to handle the diffent touches
- (void)touchesBegan:(NSSet *)theTouches withEvent:(UIEvent *)event 
{
    NSSet *touches= [event allTouches];
    
    if(_textView!=nil)
    {
        [_textView resignFirstResponder];
        return;
    }
    UITouch *aTouch = [touches anyObject];
    _currentTouch = [aTouch locationInView: _model];
    _beginLoc = _currentTouch;
    _currentLoc = _beginLoc;

    _longTouchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkLongTouch:) userInfo:nil repeats:NO];
    CGPoint modelPoint = [_model locationInModel:_currentTouch];
    
    if([touches count]==1)
    {
        // No need to go much further...
        if(_penMode==kMoveScreen || _penMode==kMoveBackground)
            return;
        
        // CHeck if there is a click in the legend
        if([_model.modelLegend inside:_currentLoc])
        {
            _penMode = kMoveLegend;
            return;
        }
        
        // Touch a selected object first?
        DVShape *shape;
        CGPoint resultPoint;
        if((shape = [_model findIntersectShape:modelPoint])!=nil)
        {
            _penMode = kDrawNone;
            [self setPenMode:kDrawNone];

            if(shape.selected)
            {
                _selectedShape = shape;
                [self performSelection:modelPoint withShape:shape];
            }
            else if(shape.length < 20 || ![self touchEndOfShape:modelPoint withShape:shape result:&resultPoint ])
            {
                if(shape==_selectedShape)
                    _selectedShape.selected = NO; // deselect previous shape
                _selectedShape = shape;
                _selectedShape.selected = YES;  // reselect current shape
                _model.activeShape = _selectedShape;
                
                int tool;
                if([_selectedShape isKindOfClass:[DVShapeArc class]])
                    tool = kToolArc;
                else if([_selectedShape isKindOfClass:[DVShapeLine class]])
                    tool = kToolLine;
                else if([_selectedShape isKindOfClass:[DVShapeText class]])
                    tool = kToolText;

                _keyboard.currentTool = tool;
                _currentTool = tool;
                _model.currentTool = tool;
                _model.hideDiagonal = NO;
                
            }
            else
            {
                _model.activePoint = resultPoint;
                _model.crossPoint = resultPoint;
                _penMode = kDrawing;
                [self setPenMode:kDrawing];
            }
        }
        else
        {
            // Check if the user clicks close to an existing end of segment -- force to align with the segment
            CGPoint pt = modelPoint;
            int n;
            if((n = [_model findIntersectEndSegment:&pt])!=0)
            {
                _model.activePoint = pt;
                _model.crossPoint = pt; 
            }
            else
            {
                pt = [_model constrainPoint:pt];
                _model.activePoint = pt;
                _model.crossPoint = pt;                    
            }
            _selectedShape.selected = NO;
            _model.activeShape = nil;
            _selectedShape = nil;
            [_model.activeLayer selectShapes:NO];
        }
    }
    else if([touches count]==3)
    {
        [self moveScreenSelection:nil];
    }
    if(_penMode==kRotateShape || _penMode==kMoveShape)
        _model.crossMode = DVCrossSmall;
    [_model setNeedsDisplay];

}
// Update the action label...
-(void)updateActionLabel
{
    
}

-(void)touchesMoved:(NSSet *)theTouches withEvent:(UIEvent *)event 
{
    NSSet *touches= [event allTouches];
    
    // NSLog(@"Move with %d %d", fingers, [touches count]);
    if([touches count]==1 && _penMode!=kMoveScreen && _penMode!=kMoveBackground && _penMode!=kMoveLegend && _penMode!=kDrawNone)
    {
        UITouch *aTouch = [touches anyObject];
        CGPoint point = [aTouch locationInView:_model];
        _currentLoc = point;
        CGPoint modelPoint = [_model locationInModel:point];
        
        // Look if there is an end-point in the current layer
        CGPoint pt = modelPoint;
        if([_model findIntersectEndSegment:&pt excludeShape:_selectedShape]!=0)
        {
            // there is a point -- align with it
            modelPoint = pt;
        }
        else 
        {
            //    if(![_selectedShape isKindOfClass:[DVShapeArc class]] && _penMode!=kRotateShape)
                modelPoint = [_model constrainPoint:modelPoint];
        }
        CGFloat deltaX = modelPoint.x - _model.crossPoint.x;
        CGFloat deltaY = modelPoint.y - _model.crossPoint.y;
        
        _model.crossPoint = modelPoint;
        
        if(_penMode==kRotateShape)
        {           
            _isDirty = YES;
            if([_selectedShape isKindOfClass:[DVShapeLine class]])
            {
                DVShapeLine *line = (DVShapeLine *)_selectedShape;
                if(_touchPoint==1)
                {
                    // rotate accross the end-point
                    line.start = _model.crossPoint;
                }
                else if(_touchPoint==2)
                {
                    line.end = _model.crossPoint;
                }
            }
            else if([_selectedShape isKindOfClass:[DVShapeArc class]])
            {
                // Change the angle
                _model.hideDiagonal = YES;
                CGFloat angle = [_model constrainAngle:[MathHelper angleToRadian:((DVShapeArc *)_selectedShape).center point:modelPoint]];
                if(_touchPoint==kAngleEnd)
                    ((DVShapeArc *)_selectedShape).endAngle = angle;
                else if(_touchPoint==kAngleStart)
                    ((DVShapeArc *)_selectedShape).startAngle = angle;

            }
            else if([_selectedShape isKindOfClass:[DVShapeText class]])
            {
                DVShapeText *shape = (DVShapeText *)_selectedShape;
                [shape adjustRect:modelPoint atCorner:_touchPoint];                
            }
        }
        else if(_penMode==kMoveShape)
        {
            CGPoint delta = CGPointMake(deltaX, deltaY);
            [self moveAllShapes:modelPoint delta:delta];
        }
        else if(_penMode==kResizeArc)
        {

            // Resize the circle
            DVShapeArc *arc = (DVShapeArc *)_selectedShape;
            arc.radius = [MathHelper distanceBetweenPoints:arc.center pt2:modelPoint];
            _model.hideDiagonal = YES;
        }
    } 
    else if(_penMode==kMoveScreen)
    {
        NSEnumerator *enumerator = [touches objectEnumerator];
        
        UITouch *aTouch = [enumerator nextObject];
        CGPoint point = [aTouch locationInView:_model];
        
        
        CGFloat x = _model.offset.width - (point.x - _currentTouch.x);
        CGFloat y = _model.offset.height - (point.y - _currentTouch.y);

        _model.offset = CGSizeMake(x, y);
        
        // Move the background as well
        _model.imageOffset = CGPointMake(_model.imageOffset.x - (point.x - _currentTouch.x), _model.imageOffset.y - (point.y - _currentTouch.y));
        _currentTouch = point;
    }
    else if(_penMode==kMoveBackground)
    {
        UITouch *aTouch = [touches anyObject];
        CGPoint point = [aTouch locationInView:_model];
        _model.imageOffset = CGPointMake(_model.imageOffset.x - (point.x - _currentTouch.x), _model.imageOffset.y - (point.y - _currentTouch.y));
        _currentTouch = point;
        
    }    
    else if(_penMode==kMoveLegend)
    {
        UITouch *aTouch = [touches anyObject];
        CGPoint point = [aTouch locationInView:_model];
        [_model.modelLegend move:CGPointMake(point.x - _currentTouch.x, point.y - _currentTouch.y)];
        _currentTouch = point;
    }     
    [_model setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)theTouches withEvent:(UIEvent *)event 
{
    // NSSet *touches= [event allTouches];
    
    [_longTouchTimer invalidate];
    _longTouchTimer = nil;
    if(_penMode==kMoveScreen || _penMode==kMoveBackground)
        return;
    if( _penMode==kMoveLegend)
    {
        _penMode = kDrawNone;
    }
    
    if(_penMode==kDrawing)
    {
        [self createObject];
    }
    _model.activePoint = _model.crossPoint;
    _model.crossPoint = _model.activePoint;

    [_model setNeedsDisplay];
    
    if(_keyboard.crossSelected)
        _penMode = kDrawing;
    else
        _penMode = kDrawNone;
    
    if(_penMode==kDrawing)
        _model.crossMode = DVCrossRed;
    else if(_penMode==kDrawNone)
        _model.crossMode = DVCrossBlue;
}
-(BOOL)touchEndOfShape:(CGPoint)modelPoint withShape:(DVShape *)shape result:(CGPoint *)resultPoint
{
    
    CGPoint pt = modelPoint;
    if((_touchPoint = [_model findIntersectEndSegment:&pt])!=0)
    {
        *resultPoint = pt;
        if([shape isKindOfClass:[DVShapeArc class]])
        {
            if (_touchPoint == kAngleStart || _touchPoint == kAngleEnd)
                return YES;
        }
        else if([shape isKindOfClass:[DVShapeText class]])
        {
            switch (_touchPoint) {
                case 1:
                case 2:
                case 3:
                case 4:
                    return YES;
            }
        }
        else if([shape isKindOfClass:[DVShapeLine class]])
        {
            if(_touchPoint==2 || _touchPoint==1)
                return YES;
        }
        
    }
    return NO;
}
//
// Move all the shapes that are selected
//
-(void)moveAllShapes:(CGPoint)modelPoint delta:(CGPoint)delta
{
    NSArray *shapes = [_model.activeLayer getSelectedShapes];
    
    for(DVShape *shape in shapes)
    {
        if(shape==_selectedShape)
        {
            if([shape isKindOfClass:[DVShapeText class]])
            {
                CGPoint center = shape.center;
                center = CGPointMake(center.x + delta.x, 
                                     center.y + delta.y);
                shape.center = center;
                _model.hideDiagonal = YES;
            }
            else if([shape isKindOfClass:[DVShapeLine class]])
            {
                CGPoint center = shape.center;
                center = CGPointMake(center.x + delta.x, 
                                     center.y + delta.y);
                shape.center = center;            
                _model.crossPoint = modelPoint;
            }
            else if([shape isKindOfClass:[DVShapeArc class]])
            {
                shape.center = modelPoint;
                _model.crossPoint = modelPoint;  
                _model.hideDiagonal = YES;
            }
        }
        else
        {
            CGPoint center = shape.center;
            center = CGPointMake(center.x + delta.x, 
                                 center.y + delta.y);
            shape.center = center;            
        }
    }

}
-(void)selectAllShapes
{
    [_model.activeLayer selectShapes:YES];
    [_model setNeedsDisplay];
}
//
// Look the selection on the object
//
-(void)performSelection:(CGPoint)modelPoint withShape:(DVShape *)shape
{
    // if the touch is close to one of the extremity, move to that extremity
    CGPoint pt = modelPoint;
    _keyboard.labelAction.text = @"";
    
    if((_touchPoint = [_model findIntersectEndSegment:&pt])!=0)
    {
        if([shape isKindOfClass:[DVShapeArc class]])
        {
            DVShapeArc *arc = (DVShapeArc *)shape;
            _lastSelection = _touchPoint;
            switch(_touchPoint)
            {
                case kAngleCenter:
                    _model.activePoint = modelPoint;
                    _model.crossPoint = modelPoint;
                    _penMode = kMoveShape;
                    [self setPenMode:kMoveShape];
                    break;
                case kAngleStart:
                    [self setPenMode:kRotateShape];
                    _penMode = kRotateShape;
                    _model.activePoint = arc.endPoint;
                    _model.crossPoint = arc.startPoint;
                    _keyboard.labelAction.text = @"Angle Value";
                    break;
                case kAngleEnd:
                    [self setPenMode:kRotateShape];
                    _penMode = kRotateShape;
                    _model.activePoint = arc.startPoint;
                    _model.crossPoint = arc.endPoint;
                    _keyboard.labelAction.text = @"Angle Value";
                    break;
                case kAngleShape:
                    _model.activePoint = pt;
                    _model.crossPoint = pt;
                    _penMode = kMoveShape;
                    [self setPenMode:kResizeArc];
                    _keyboard.labelAction.text = @"Change Diameter";
                    break;
            }
        }
        else if([shape isKindOfClass:[DVShapeText class]])
        {
            switch (_touchPoint) {
                case 1:
                case 2:
                case 3:
                case 4:
                    _model.activePoint = pt;
                    _model.crossPoint = pt;
                    _penMode = kRotateShape;
                    [self setPenMode:kRotateShape];
                    break;
                case 5:
                    _model.activePoint = pt;
                    _model.crossPoint = pt;
                    _penMode = kMoveShape;
                    [self setPenMode:kMoveShape];
                    break;
                case 6:
                    [self editTextField];
                    break;
                default:
                    break;
            }
        }
        else if([shape isKindOfClass:[DVShapeLine class]])
        {
            _penMode = kRotateShape;
            [self setPenMode:kRotateShape];
            
            if(_touchPoint==2)
            {
                _model.activePoint = ((DVShapeLine *)_selectedShape).start;
                _model.crossPoint = ((DVShapeLine *)_selectedShape).end;
                _keyboard.labelAction.text = @"Line Length";
                _lastSelection = kLineLength2;
            }
            else if(_touchPoint==1)
            {
                _model.activePoint = ((DVShapeLine *)_selectedShape).end;
                _model.crossPoint = ((DVShapeLine *)_selectedShape).start;
                _keyboard.labelAction.text = @"Line Length";
                _lastSelection = kLineLength1;
            }
        }
        
    }
    else if([shape isKindOfClass:[DVShapeLine class]])
    {
        _penMode = kMoveShape;
        [self setPenMode:kMoveShape];
        _intersectPoint = modelPoint; // _selectedShape.center;
        _model.activePoint = _intersectPoint;
        _model.crossPoint = _intersectPoint;
        _model.crossMode = DVCrossSmall;
    }
}
-(void)editTextField
{
    _model.hideCross = YES;
    DVShapeText *shapeText = (DVShapeText *)_selectedShape;
    _shapeEdited = shapeText;
    if(_textView!=nil && _shapeEdited!=nil)
        [self storeTextInfo];
    
    _textView = [[UITextView alloc]initWithFrame:[_model shapeGetRectInScreenCoordinates:shapeText.frame]];
    _textView.text = shapeText.text;
    _textView.font = [shapeText getFontForScale:_model.scale];
    _textView.textColor = shapeText.color;
    
    [_model addSubview:_textView];
    _textView.delegate = self;
    [_textView becomeFirstResponder];
    _textView.backgroundColor = [UIColor whiteColor];
}
-(void)storeTextInfo
{
    
}
#pragma mark - Delegates
-(void)pinchDetected:(UIPinchGestureRecognizer *)sender
{
    [_longTouchTimer invalidate];
    _longTouchTimer = nil;
    CGFloat scale = [sender scale];
    if(sender.state==UIGestureRecognizerStateBegan)
    {
        if(_penMode==kMoveBackground)
            _originalScale = _model.imageScale;
        else
            _originalScale = _model.scale;
    }
    else if(sender.state==UIGestureRecognizerStateChanged)
    {
        CGPoint locInView = [sender locationInView:_model];
        CGPoint locInModel = [_model locationInModel:locInView]; // center
        CGFloat newScale = _originalScale * scale;
        
        if(newScale < minScale)
            newScale = minScale;
        else if(newScale >maxScale)
            newScale = maxScale;

        if(_penMode==kMoveBackground)
            _model.imageScale = newScale;
        else
            _model.scale = newScale;
        // Reposition the view
        CGPoint newLocInView = [_model locationInView:locInModel];
        _model.offset = CGSizeMake(_model.offset.width + (newLocInView.x - locInView.x), 
                                   _model.offset.height + (newLocInView.y - locInView.y));
        [_model setNeedsDisplay];
    }

}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    _shapeEdited.text = textView.text;
    [textView resignFirstResponder];
    [textView removeFromSuperview];
    _textView = nil;
    
    [_model setNeedsDisplay];
    _model.hideCross = NO;
}



#pragma mark - Keyboard delegate
-(void)dvKeyboardInput:(CGFloat)value direction:(int)direction
{
    if(_penMode==kMoveScreen)
        return;
    if([_selectedShape selected])
    {
        if([_selectedShape isKindOfClass:[DVShapeLine class]])
        {
            DVShapeLine *line = (DVShapeLine *)_selectedShape;
            // Adjust the size of the line
            [line adjustLength:value];
            [_model setNeedsDisplay];
        }
        else if([_selectedShape isKindOfClass:[DVShapeArc class]])
        {
            DVShapeArc *arc = (DVShapeArc *)_selectedShape;
            
            switch(_lastSelection)
            {
                case kAngleStart:
                    arc.startAngle = [self calculateAngle:value];
                    break;
                case kAngleEnd:
                    arc.endAngle = [self calculateAngle:value];
                    break;
                case kAngleShape:
                    // New Diameter
                    [arc setRadius:value/2.0 * _model.pointsPerUnit];
                    break;
            }
            [_model setNeedsDisplay];
            _model.hideDiagonal = YES;
            [_model drawArcAngles:arc clean:YES];
        }
    }
    else
    {
        [self increaseValue:value createObject:(_penMode==kDrawing)?YES:NO direction:direction];
    }
}
-(CGFloat)calculateAngle:(CGFloat)angle
{
    if(angle<0 || angle>360)
        angle = 0;
    angle = 360 - angle;
    angle = (angle/180)*M_PI;
    return angle;
}
-(void)increaseValue:(CGFloat)value createObject:(BOOL)createObject direction:(int)direction
{
    CGPoint point = [_model crossPoint];
    switch (direction)
    {
        case 0: // going up
            point.y -= [_model pointsPerUnit] * value;
            break;
        case 1: // going right
            point.x += [_model pointsPerUnit] * value;
            break;
        case 2: // going down
            point.y += [_model pointsPerUnit] * value;
            break;
        case 3: // going left
            point.x -= [_model pointsPerUnit] * value;
            break;
            
    }
    if(_penMode==kDrawNone)
    {
        if(createObject)
        {
            _model.crossPoint = point;
            [self createObject];
            _isDirty = YES;
        }
        
        _model.activePoint = point;
        _model.crossPoint = point;
    }
    else if(_penMode==kMoveShape)
    {
        // We are moving the shape
        _selectedShape.center = point;
        _model.crossPoint = point;
        if(createObject && value==0)
        {
            _model.activePoint = point;
            _penMode = kDrawNone;
            [self setPenMode:kDrawNone];
            _selectedShape.selected = NO;
        }
        _isDirty = YES;
    }
    else if(_penMode==kRotateShape)
    {
        _isDirty = YES;
        if([_selectedShape isKindOfClass:[DVShapeLine class]])
        {
            _model.crossPoint = point;

            if(_touchPoint==1)
                ((DVShapeLine *)_selectedShape).start = point;
            else if(_touchPoint==2)
                ((DVShapeLine*)_selectedShape).end = point;
            [((DVShapeLine*)_selectedShape) updateInfo:_model.activePoint to:_model.crossPoint];
            //_model.hideDiagonal = YES;
        }
        else if([_selectedShape isKindOfClass:[DVShapeArc class]])
        {
            _model.hideDiagonal = YES;
            _model.activeShape = _selectedShape;
            DVShapeArc *arc = (DVShapeArc *)_selectedShape;
            CGFloat delta = 0;
            if(direction==0 || direction==1)
                delta = value * (M_PI/180.0);
            else
                delta = -value * (M_PI/180.0);
            if(_touchPoint==kAngleStart)
            {
                CGFloat angle = arc.startAngle + delta;
                arc.startAngle = angle;
            }
            else if(_touchPoint==kAngleEnd)
            {
                CGFloat angle = arc.endAngle + delta;
                arc.endAngle = angle;
            }

        }
        else if([_selectedShape isKindOfClass:[DVShapeText class]])
        {
            _model.hideDiagonal = YES;
            
        }
        if(createObject && value==0)
        {
            _model.crossPoint = point;
            _model.activePoint = point;
            // _penMode = kDrawNone;
            _model.hideDiagonal = NO;
            _selectedShape.selected = NO;
        }
    }
    else if(_penMode==kDrawing && createObject)
    {
        _model.crossPoint = point;
        [self createObject];
        _isDirty = YES;
         

    }
    else if(_penMode== kDrawing)
    {
        _model.crossPoint = point;
    }
    if(createObject)
    {
        _model.activePoint = _model.crossPoint;
        _model.crossPoint = _model.activePoint; // to force the draw
    }
    [_model setNeedsDisplay];
}
-(void)createObject
{
    _isDirty = YES;
    if(CGPointEqualToPoint(_model.center, _model.activePoint))
        return;
    switch (_keyboard.currentTool)
    {
        case kToolLine:
        {
            // Create a new line
            if(!CGPointEqualToPoint(_model.crossPoint, _model.activePoint))
            {
                DVShapeLine *line = [[DVShapeLine alloc]initLine:_model.activePoint to:_model.crossPoint];
                
                line.color = [UIColor blackColor];
                line.label.textColor = line.color;
                line.label.fontSize = 14.0;
                line.label.offset = 10.0;    
                
                [_model addShape:line];
                // after to make sure that the delegate is set
                [line updateInfo:_model.activePoint to:_model.crossPoint];
                _selectedShape = nil;
            }
        }
            break;
        case kToolArc:
        {
            DVShapeArc *arc;
            CGFloat a=M_PI, b=2*M_PI;
            CGFloat radius = [MathHelper distanceBetweenPoints:_model.activePoint pt2:_model.crossPoint]/2.0;
            if(radius>0)
            {
                CGPoint center = [MathHelper centerOfLine:_model.crossPoint end:_model.activePoint];
                arc = [[DVShapeArc alloc]initArc:center radius:radius startAngle:a endAngle:b];
                
                arc.color = [UIColor blackColor];
                arc.label.textColor = arc.color;
                arc.label.fontSize = 14.0;
                arc.label.offset = 10.0;
                [_model addShape:arc];
                _model.activeShape = arc;
                _selectedShape = nil;
            }

        }
            break;
        case kToolText:
        {
            CGRect frame = CGRectMake(_model.activePoint.x, _model.activePoint.y, _model.crossPoint.x-_model.activePoint.x, _model.crossPoint.y-_model.activePoint.y);
            
            if(_model.crossPoint.x-_model.activePoint.x > 40 &&  _model.crossPoint.y-_model.activePoint.y > 10)
            {
                DVShapeText *text = [[DVShapeText alloc]initWithFrame:frame];
                [_model addShape:text];
            }
        }
        default:
            break;
    }

}
-(void)getFormAngle:(int)direction firstAngle:(CGFloat *)first secondAngle:(CGFloat *)second
{
    CGFloat a, b,c ;
    switch(direction)
    {
        case 0: a=M_PI_2; b= M_PI; c= 3*M_PI/2; break;
        case 1: a=M_PI;b=1.5*M_PI;c=2*M_PI; break;
        case 2: a= 3*M_PI/2;b=2*M_PI;c=M_PI_2; break;
        case 3: a= 0; b = M_PI_2; c=M_PI; break;
    }
    a=M_PI;b=1.5*M_PI;c=2*M_PI;
    if(_keyboard.currentTool==kToolArc)
        b = c;
    
    // adjust the angle
    CGFloat angle = [MathHelper angleToRadian:_model.activePoint point:_model.crossPoint];
    
    *first = [MathHelper normalizeAngle:a+angle];
    *second = [MathHelper normalizeAngle:b+angle];
}
-(void)dvKeyboardCheckbox:(int)cb on:(BOOL)on
{
    if(cb==kCbBackground)
        _model.imageVisible = on;
    else if(cb==kCbGrid)
        _model.gridVisible = on;
    [_model setNeedsDisplay];
}
-(void)dvKeyboardAlign:(BOOL)alignGrid
{
    _model.alignToGrid = alignGrid;
}
-(void)dvKeyboardShowGrid:(BOOL)show
{
    _model.gridVisible = show;
    [_model setNeedsDisplay];    
}
-(void)dvKeyboardAngle:(int)angleDegree
{
}
-(void)dvKeyboardArrow:(int)arrow
{
    [self increaseValue:1.0 createObject:NO direction:arrow];
}
-(NSArray *)dvKeyboardGetLayers
{
    return [_model layers];
}
-(void)dvKeyboardSelectLayer:(DVLayer *)layer
{
    _model.activeLayer = layer;
    [_model setNeedsDisplay];
}
// Cross acrross is selected
-(void)dvKeyboardCross:(BOOL)selection
{
    _selectedShape.selected = NO;
    if(!selection)
    {
        // Reset the cross to its current position
        _model.crossPoint = _model.activePoint;
        _penMode = kDrawNone;
        [self setPenMode:kDrawNone];
        _model.crossMode = DVCrossBlue;
    }
    else
    {
        // Reset the screen moving screen
        // Deselect the shape if any were selected
        _selectedShape.selected = NO;
        _penMode = kDrawing;
        [self setPenMode:kDrawing];
        _model.crossMode = DVCrossRed;
    }
    [_model setNeedsDisplay];
}
-(void)dvKeyboardSelectTool:(int)tool
{
    _currentTool = tool;
    _model.currentTool = tool;
    switch(tool)
    {
        case kToolLine:
            _model.hideDiagonal = NO;
            break;
        case kToolArc:
            _model.hideDiagonal = NO;
            break;
        case kToolText:
            _model.hideDiagonal = YES;
            break;
        case kToolMove:
            _penMode = kMoveScreen;
            [self setPenMode:kMoveScreen];
            _model.hideCross = YES;
            break;
        case kToolAdjustBackground:
            _penMode = kMoveBackground;
            [self setPenMode:kMoveBackground];
            _model.hideCross = YES;
            break;
    }

    [_model setNeedsDisplay];
}

-(void)dvKeyboardClose
{
    int error;
    
    _model.path = [_model.activeLayer calculateArea:&error];
    if(_model.path==nil)
    {
        if(error == -1)
            [Helper alertWithOk:@"No segment selected" message:@"Please select one segment before trying to calculate the area."];
        else if(error == -2)
            [Helper alertWithOk:@"Not enough segments" message:@"You need at least 3 segments to calculate the area."];
        return;
    }
    else
    {
        // Calculate the area
        CGFloat area = [_model calculateAreaFromPath];
        CGFloat displayArea = rintf(area);
        _model.modelLegend.hidden = NO;
        // Check if the layer has already something
        area = [_model.modelLegend area:_model.activeLayer.name];
        if(area <= 0)
            [_model.modelLegend newArea:_model.activeLayer.name area:displayArea];
        else 
        {
            // Area already exists
            _currentArea = displayArea;
            NSString *title = [NSString stringWithFormat:@"New area: %d sqft", (int)displayArea];
            _alertArea = [[UIAlertView alloc]initWithTitle:title message:@"There is already an area calculated for this layer. What do you want to do?"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Replace the area", @"Add to the area", @"Substract from the area", nil];
            [_alertArea show];

            
        }
    }
    
    [_model setNeedsDisplay];
}

-(void)dvKeyboardRefreshAll
{
    [_model setNeedsDisplay];
}
#pragma mark - Open/Save model
-(void)dvKeyboardAction:(int)action
{
    if(!_isDirty)
    {
        [self deregisterFromKeyboardNotifications];
        [delegate dvModelCompleted:self completion:YES animate:YES];
        return;
    }
    switch(action)
    {
        case kOptionCancel:
            // Need to confirm if there are any changes or modification
            if(_isDirty)
            {
                _alert = [[UIAlertView alloc]initWithTitle:@"Discard Changes?" message:@"Are you sure you want to discard the changes you made to this drawing?"  delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No Way!", nil];
                [_alert show];
            }
            else
            {
                [self deregisterFromKeyboardNotifications];
                [delegate dvModelCompleted:self completion:YES animate:YES];

            }
            break;
        case kOptionSave:
            {
                [self saveModel];
                [self deregisterFromKeyboardNotifications];
                //    if([mediaBldg.rowStatus caseInsensitiveCompare:@"I"]==NSOrderedSame)
                //    mediaBldg.rowStatus = @"U";
                [delegate dvModelCompleted:self completion:NO animate:YES];
            }
            break;
    }
}

// 2 possible cases:
// if the media was previously created, delete the 2 files from the database.
// not always set false otherwise

// then add the new files
// if false  add new files based on "newMediabldg"
-(NSString *)saveModel
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    ReadPictures *pictures = [app pictureManager];
    
    // Delete the files (assuming that they exist)
    // 4/26/16 HNN update existing png by deleting and creating new if media record is new since we only
    // want the latest changes of a new drawing
    // updating an existing should create a new png and cadxml in order to preserve existing data
    sketchGuid =@"";
    if(mediaMode==kCadNew || mediaMode==kCadUpdateNew)
    {
        sketchGuid = mediaBldg.guid; // 4/26/16 HNN reuse guid of new drawings
        [pictures deleteFileWithGUID:sketchGuid]; // 4/26/16 HNN this will delete the png, cadxml and mini
    }
    else
        sketchGuid = [Helper generateGUID]; // 4/26/16 HNN save changes to existing drawing under new guid
    
    NSData *data = [_model createImageFromModel:50];
    [pictures saveNewData:data
                     guid:sketchGuid
     //                        mediaType:mtImages
                mediaType:kMediaPict // 4/25/16 HNN wrong enum
                      ext:@"PNG"];
    
    
    NSString *str = [_model modelToXML];
    data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    // Saving new cadxml
    [pictures saveNewData:data
                     guid:sketchGuid
                mediaType:kMediaFplan
                      ext:@"CADXML"];
    
    // Remove the buffer to make sure that the images are reloaded
    [app cleanUpZipCache];
    
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    
    //return xmlName;
//    if (isDefault)
//    {
// 4/26/16 HNN don't update existing media record; updates are saved as new records
//        if (!mediaBldg)
//        {
//            [RealPropertyApp updateUserDate:mediaAccy];
//            mediaAccy.year = [components year];
//            return mediaAccy.guid;
//        }
//        else
//        {
//            [RealPropertyApp updateUserDate:mediaBldg];
//            mediaBldg.year = [components year];
//            return mediaBldg.guid;
//        }
//    }
//    else
//    {
//        [RealPropertyApp updateUserDate:mediaBldgNew];
//        mediaBldgNew.year = [components year];
//        return mediaBldgNew.guid;
//        
//    }
    return sketchGuid;
}

-(void)openModel
{
    // cv 4/26/16 when you save changes to a cadxml, we want to preserve the existing cadxml by creating a new version of the cadxml based on the old one.

    NSString *xmlName =@"";
    
    xmlName = mediaBldg.guid;
    [self loadModel:xmlName];
}

-(void)pasteModel
{
    if([copyDrawing length]==0)
        return;
    [self loadModel:copyDrawing];
}
-(void)loadModel:(NSString *)xmlName
{
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    ReadPictures *pictures = [app pictureManager];
    // Get the data
    NSData *data = [pictures getFileDataWithMediaTypeFromDatabase:xmlName mediaType:kMediaFplan];
    // 3/18/13 HNN kludge: &,<,> in cadxml label crashes. I need to replace those xml reserved characters with escape characters
    // If the data is not null-terminated, you should use -initWithData:encoding:
    // else use  [NSString stringWithUTF8String:[theData bytes]];
    // ref http://stackoverflow.com/questions/2467844/convert-utf-8-encoded-nsdata-to-nsstring
    NSString* xml = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    NSRange verRange = [xml rangeOfString:@"CADiRealProperty version=\"1.0\"" options:NSCaseInsensitiveSearch];
    NSData *data2=data;
    if (verRange.location > 0 && verRange.location!=NSNotFound)
    {    
        NSString *xmlStr = [xml stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        data2 = [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    [_model openModel:data2 error:nil];
    [_model setNeedsDisplay];
    
    if(_model.showLegend)
        _keyboard.showLegend = YES;
    [_keyboard updateLayer:_model.activeLayer];

}
-(void)setSketchGuid:(NSString *)_sketchGuid
{
    sketchGuid = _sketchGuid;
}
-(void)setMediaBldg:(MediaBldg *)_mediaBldg
{
    mediaBldg = _mediaBldg;
    // 4/26/16 HNN don't set the rowstatus of the media we are viewing to an I because we want to preserve the existing record.
    // changes to an existing drawing should be saved to a new media record
//    if([mediaBldg.rowStatus length]==0)
//        mediaBldg.rowStatus = @"I";
}
// 4/27/16 HNN not used
//-(void)setMediaAccy:(MediaAccy *)_mediaAccy
//{
//    mediaAccy = _mediaAccy;
//    // 4/26/16 HNN don't set the rowstatus of the media we are viewing to an I because we want to preserve the existing record.
//    // changes to an existing drawing should be saved to a new media record
////    if([mediaAccy.rowStatus length]==0)
////        mediaAccy.rowStatus = @"I";
//}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView== _alert)
    {
        if(buttonIndex==0)
        {
            [delegate dvModelCompleted:self completion:YES animate:YES];
        }
    }
    else if(alertView == _pasteAlert)
    {
        if(buttonIndex==0)
        {
            [self pasteModel];
        }
    }
    else if(alertView == _alertArea)
    {
        switch(buttonIndex)
        {
            case 0:
                break;
            case 1:
                [_model.modelLegend newArea:_model.activeLayer.name area:_currentArea];
                break;
            case 2:
                [_model.modelLegend addArea:_model.activeLayer.name area:_currentArea];
                break;
            case 3:
                [_model.modelLegend substractArea:_model.activeLayer.name area:_currentArea];
                break;        
        }
        [_model setNeedsDisplay];
    }
}
#pragma mark - Undo/Redo section
-(void)dvKeyboardCut
{
    NSArray *array = [_model getSelectedShapes];
    
    if([array count]==0)
        return;
    
    [self addToUndo:array];
    [_model deleteSelected];
    [_model setNeedsDisplay];
    
    _model.activePoint = _model.crossPoint;
    _model.crossPoint = _model.activePoint;
}
//
// Just save the current shape(s)
//
-(void)addToUndo:(NSArray *)shapes
{
    _undoObjects = [[NSMutableArray alloc]initWithCapacity:shapes.count];

    for(DVShape *shape in shapes)
    {
        DVShape *undoShape = [shape copy];
        undoShape.selected = NO;
        [_undoObjects addObject:undoShape];
    }
}
-(void)dvKeyboardPaste
{
    if([_undoObjects count]==0)
        return;
    // Pull out the object from the undo queue
    for(DVShape *shape in _undoObjects)
    {
        DVShape *newShape = [shape copy];
        // Change a new GUID???
        [_model addShape:newShape];
    }

    [_model setNeedsDisplay];
}
-(void)dvKeyboardRedo
{
}
#pragma mark - Hide/Show Keyboard
-(void)hideKeyboard:(BOOL)hide
{
    int screenWidth = [Helper isDeviceInLandscape]?1024:768;
    CGFloat time = 0.3;
    if(hide)
    {
        // hide the keyboard to the right of the screen
        [UIView animateWithDuration:time animations:^{
            CGRect r = _keyboard.view.frame;
            _keyboard.view.frame = 
            CGRectMake(screenWidth, r.origin.y, r.size.width, r.size.height);
        }];
        
    }
    else 
    {
        // Show the keyboard from the right of the screen
        [UIView animateWithDuration:time animations:^{
            CGRect r = _keyboard.view.frame;
            _keyboard.view.frame = 
            CGRectMake(screenWidth - r.size.width, r.origin.y, r.size.width, r.size.height);
        }];
    }
}
#pragma mark - Handle rotation
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_textView resignFirstResponder];
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.view.frame = CGRectMake(0,0,1024,768);
        _model.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
        _keyboard.view.frame = CGRectMake(1024-_keyboard.view.frame.size.width,
                                          0, _keyboard.view.frame.size.width, _keyboard.view.frame.size.height);
    }
    else 
    {
        self.view.frame = CGRectMake(0,0,768,1024);
        _model.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
        _keyboard.view.frame = CGRectMake(768-_keyboard.view.frame.size.width,
                                          0, _keyboard.view.frame.size.width, _keyboard.view.frame.size.height);
    }
    [_model setNeedsDisplay];
}

-(void)willRotateToLandscapeOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_textView resignFirstResponder];
    
//    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
//    {
        self.view.frame = CGRectMake(0,0,1024,768);
        _model.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
        _keyboard.view.frame = CGRectMake(1024-_keyboard.view.frame.size.width,
                                          0, _keyboard.view.frame.size.width, _keyboard.view.frame.size.height);
//    }
    [_model setNeedsDisplay];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}
#pragma mark - Close an area
-(void)closeArea
{
    // Look for any se
}
- (IBAction)moveScreenSelection:(UIButton *)sender 
{
    if(_penMode==kMoveScreen)
    {
        [_btnMoveScreen setImage:[UIImage imageNamed:@"ArrowBlack.png"] forState:UIControlStateNormal];
        _penMode = _previousPenMode;
        [self hideKeyboard:NO];
    }
    else
     {
         [_btnMoveScreen setImage:[UIImage imageNamed:@"ArrowBlue.png"] forState:UIControlStateNormal];
         _previousPenMode = _penMode;
         _penMode = kMoveScreen;
         [self hideKeyboard:YES];
     }
}
-(void)setPenMode:(int)mode
{
    _penMode = mode;
    
    if(mode==kDrawing)
    {
        _model.crossMode = DVCrossRed;
        _keyboard.crossSelected = YES;
    }
    else
    {
        _model.crossMode = DVCrossBlue;
        _keyboard.crossSelected = NO;
        
    }
}
#pragma mark - Manage the background
-(void)dvKeyboardBackground:(MediaBldg *)media
{
    _model.backgroundImage = [MediaView getImageFromMedia:media];
    _model.imageVisible = YES;
    [_model setNeedsDisplay];
}
-(void)dvKeyboardShowBackground:(BOOL)on
{
    _model.imageVisible = on;
    [_model setNeedsDisplay];    
}
-(void)dvKeyboardAdjustBackground:(BOOL)on
{
    [self setPenMode:kMoveBackground];
    [self hideKeyboard:YES];
    _adjustButton.hidden = NO;
    _btnMoveScreen.hidden = YES;
}
-(void)dvKeyboardShowLegend:(BOOL)on
{
    _model.showLegend = on;
    [_model setNeedsDisplay];    
}
-(void)dvKeyboardAdjustLegend:(BOOL)on
{
    [self setPenMode:kMoveLegend];
    [self hideKeyboard:YES];
    _adjustButton.hidden = NO;
    _btnMoveScreen.hidden = YES;
}
-(void)dvKeyboardCopyLayer
{
    if(_model.activeLayer.shapes.count==0)
        return;
    // Copy each shape...
    
    copyLayer = [[DVLayer alloc]initWithName:@"Copied Layer"];
    for(DVShape *shapes in _model.activeLayer.shapes)
    {
        DVShape *shape = [shapes copy];
        [copyLayer addShape:shape];
    }
    // Activate the paste button
    [_keyboard pasteLayerButtonActive:YES];
}
-(void)dvKeyboardPasteLayer
{
    for(DVShape *shape in copyLayer.shapes)
    {
        [_model.activeLayer addShape:[shape copy]];
    }
    [_model setNeedsDisplay];
}
-(int)dvKeyboardCountLayersToPaste
{
    return copyLayer.shapes.count;
}
-(void)dvKeyboardCopyDrawing
{
    // 4/26/16 HNN not sure why it was calling savemodel when all it needs is the guid of the drawing we are on
    //    copyDrawing = [self saveModel];
    copyDrawing = mediaBldg.guid;

}
-(void)dvKeyboardPasteDrawing
{
    _pasteAlert = [[UIAlertView alloc]initWithTitle:@"Paste Drawing?" message:@"Are you sure you want to replace the current drawing with the one you are pasting? This action can't be undo."  delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [_pasteAlert show];
}
-(void)dvFlipVertical:(BOOL)vertical
{
    [_model flipModel:vertical];
}
-(void)adjustDone:(UIButton *)btn
{
    _adjustButton.hidden = YES;
    // Show the keyboard
    [self hideKeyboard:NO];
    [self setPenMode:kDrawNone];
    [_model setNeedsDisplay];
    _btnMoveScreen.hidden = NO;
}
#pragma mark - Pop-up menu
-(void)longTouch:(CGPoint)pt shape:(DVShape *)shape
{
    _popMenu = [[DVSelection alloc]initWithFrame:CGRectMake(pt.x, pt.y, 0, 0)];
    _popMenu.delegate = self;
    // [_popMenu setBackgroundColor:[UIColor whiteColor]];
    
    [_model addSubview:_popMenu];
    [_model bringSubviewToFront:_popMenu];
    
    [_popMenu showMenu:_popMenu.frame inView:_model shape:_selectedShape];
}
-(void)checkLongTouch:(id)param
{
    int delta = 10;
    CGRect fingerRect = CGRectMake(_beginLoc.x - (delta/2), _beginLoc.y - (delta/2), delta, delta);
    if(CGRectContainsPoint(fingerRect, _currentLoc) )
    {
        if(_penMode!= kDrawing && _penMode!= kDrawNone && _penMode!=kMoveShape)
            return;

        if([_selectedShape isKindOfClass:[DVShapeText class]])
        {
            [self editTextField];
            return;
        }
        [self longTouch:_currentTouch shape:_selectedShape];
    }
}


//- (id)createEmptyMediaObject
//{
//    // Create a new entity object
//    MediaBldg *media = [AxDataManager getNewEntityObject:@"MediaBldg"];
//    [self defaultMediaInformation:media];
//    media.mediaType  = kMediaPlan;   // special case with 2 attached files
//    media.postToWeb  = YES;    // default value
//    media.primary    = NO;
//    media.imageType  = 2;
//    
//    return media;
//}


-(void)dealloc
{
    
}

@end
