
#import <UIKit/UIKit.h>
@class IRNote;
@class IRLine;
@class BaseNote;

@interface Line : NSObject
// Color of the path
@property(strong, nonatomic) UIColor *lineColor;
// Width to draw the line width
@property(nonatomic) CGFloat lineWidth;
// Path
@property(nonatomic) CGMutablePathRef path;
// the correspoding data
@property(nonatomic, strong) NSMutableData *pathData;

-(void) moveToPoint:(CGPoint)pt;
-(void) lineToPoint:(CGPoint)pt;
-(NSData *)savePathToData;
-(void)loadFromPathData:(NSData *)data;
@end    

//////////////////////////////////////////////

@interface DrawContent : UIView
{
    Line       *_line;
    CGPoint     _currentPoint;
}
// List of all the paths in the current view
@property(nonatomic, strong) NSMutableArray *lines; // Line type
@property(nonatomic, weak) BaseNote *itsBaseNote;

-(void)saveLinesTo:(IRNote *)note;
-(void)loadLines:(NSSet *)lineSet;
@end
