
#import "AxGridPictView.h"
#import "Helper.h"
#import "iRealProperty.h"
#import "MediaView.h"

@implementation AxGridPictView

@synthesize colNum;
@synthesize gridPictController;


-(void) drawRect:(CGRect)rect
{
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    CGFloat white[4] = {1.0,1.0,1.0,1.0};
    CGContextSetFillColor(gc, white);
    CGContextFillRect(gc, rect);

    NSManagedObject *media = [gridPictController.mediaArray objectAtIndex:colNum];
    
    [MediaView drawImageFromMiniMediaInRect:media destRect:rect scale:YES];

    // Draw the label
    [gridPictController.textColor set];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yy"];
    NSString *label = [dateFormat stringFromDate:[media valueForKey:@"mediaDate"]];

    [Helper drawTextInRect:label fontName:gridPictController.font.familyName fontSize:gridPictController.font.pointSize minimumFontSize:gridPictController.minFontSize destRect:CGRectInset(gridPictController.labelRect,4.0,4.0) textAlign:NSTextAlignmentCenter];
    
}

@end
