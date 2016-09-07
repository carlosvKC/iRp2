
#import <Foundation/Foundation.h>
/*
 Definition of the graphical representation of the header
 */

typedef enum {
    cellLeft = 0,
    cellMiddle,
    cellRight
} cellTextPosition;

@interface GridInfoDesign : NSObject
{
    int     numCols;                            // Total number of cols
    
    // -- information for the header
    UIColor     *colTopBorder;                    // Color of the background from top
    UIColor     *colBottomBorder;
    UIColor     *colHighlightedTopBorder;        // Color of the background from top
    UIColor     *colHighlightedBottomBorder;

    UIColor     *headerFontColor;                     // default font color
    NSString    *headerFontName;                      // font to use
    CGFloat       headerFontSize;
    CGFloat       minimumHeaderFontSize;                // minimum font size when resizing the label
    
    cellTextPosition  headerTextPosition;

    // -- information for the cell
    UIColor     *cellBackgroundColor;
    UIColor     *cellSelectedColor;             // use it when in selected mode
    UIColor     *cellFontColor;
    UIColor     *cellFontSelectedColor;
    
    NSString    *cellFontName;
    CGFloat       cellFontSize;
    CGFloat       minimumCellFontSize;
    
    UIColor     *backgroundColor;               // background color (used to clear up cell -- round corder)
    
    UIColor     *borderColor;                     // color of the border
    CGFloat     borderWidth;                        // size of the border
    int         radius;                             // radius used for the round corder
    
    UIColor     *colCellEditColor;                  // color while in edit more
    
};


-(void) setHeaderColors: (UIColor *)topColor : (UIColor *)bottomColor : (UIColor *)topHighlitedColor : (UIColor *) bottomHightlitedColor : (UIColor *)borderCol;
-(void) setHeaderFontInfo: (NSString *)nameOfFont :  (CGFloat) textSize : (CGFloat) minTextSize : (UIColor *)fontCol;


@property int     numCols;
@property(nonatomic, retain) UIColor *colTopBorder;
@property(nonatomic, retain) UIColor *colBottomBorder;
@property(nonatomic, retain) UIColor *colHighlightedTopBorder;
@property(nonatomic, retain) UIColor *colHighlightedBottomBorder;
@property(nonatomic, retain) UIColor *backgroundColor;

@property(nonatomic, retain) UIColor *cellBackgroundColor;
@property(nonatomic, retain) UIColor *cellSelectedColor;
@property(nonatomic, retain) UIColor *cellFontColor;
@property(nonatomic, retain) UIColor *cellFontSelectedColor;

@property(nonatomic, retain) NSString *cellFontName;
@property CGFloat   cellFontSize, minimumCellFontSize;

@property(nonatomic, retain) UIColor *borderColor;
@property float   borderWidth;
@property(nonatomic, retain) UIColor     *headerFontColor;
@property(nonatomic, retain) NSString    *headerFontName;
@property CGFloat     headerFontSize;
@property CGFloat     minimumHeaderFontSize;

@property(nonatomic, retain) UIColor *colCellEditColor;

@property cellTextPosition  headerTextPosition;
@property int radius;


@end
