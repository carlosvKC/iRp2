
#import "GridContentCell.h"


@implementation GridContentCell

@synthesize row, column;
@synthesize gridContentController;
@synthesize label;


-(void) drawRect:(CGRect)rect
{
    GridInfoDesign *headerInfo = gridContentController.gridController.gridDesign;
    NSArray *entities = gridContentController.gridController.gridEntities;

    ItemDefinition *entity = [entities objectAtIndex:self.column];
    // find the alignment
    // Setup the type
    int alignment = NSTextAlignmentLeft;
    switch (entity.type) 
    {
        case ftURL:
        case ftTextL:
        case ftText:
            alignment = NSTextAlignmentLeft;
            break;
        case ftDate:
        case ftBool:
        case ftYear:
            alignment = NSTextAlignmentCenter;
            break;
        case ftPercent:
        case ftFloat:
        case ftNum:
        case ftCurr:
        case ftInt:
            alignment = NSTextAlignmentRight;
            break;
        case ftAuto:
            alignment = NSTextAlignmentCenter;
            break;
        case ftImg:
            alignment = NSTextAlignmentCenter;
            break;
        default:
            
            break;
    }
    
    CGContextRef gc = UIGraphicsGetCurrentContext();

    const CGFloat *f;
    BOOL rowSelected = [gridContentController isRowSelected:row];
    BOOL isEditMode = gridContentController.gridController.isEditMode;

    if(entity.type==ftAuto)
    {
        // First Column?
        if(isEditMode)
        {
            f = CGColorGetComponents([headerInfo.colCellEditColor CGColor]);
            CGContextSetFillColor(gc,f);
            CGContextFillRect(gc, rect);

            // In edit mode, so draw the circle in the column
            NSString *image;
            self.opaque= NO;
            if(rowSelected)
                image = @"redmark";
            else
                image = @"roundmark";
            UIImage *img = [UIImage imageNamed:image];
            CGSize size = img.size;
            
            [img drawAtPoint:CGPointMake((rect.size.width - size.width)/2, (rect.size.height-size.height)/2)];
            
        }
        else
        {
            f = CGColorGetComponents([headerInfo.colBottomBorder CGColor]);
            CGContextSetFillColor(gc,f);
            CGContextFillRect(gc, rect);
            
        }
    }
    else
    {

        if(rowSelected)
        {
            if(isEditMode)
                f = CGColorGetComponents([headerInfo.colCellEditColor CGColor]);
            else
                f = CGColorGetComponents([headerInfo.cellSelectedColor CGColor]);
        }
        else
            f = CGColorGetComponents([headerInfo.cellBackgroundColor CGColor]);

        CGContextSetFillColor(gc, f);    
        CGContextFillRect(gc, rect);
    }
        
    CGContextSetLineWidth(gc, headerInfo.borderWidth);  
    CGContextSetStrokeColor(gc, CGColorGetComponents( [headerInfo.borderColor CGColor] ));

    CGContextSetAllowsAntialiasing(gc, NO);
    
    // Top line

    // Left line
    CGContextMoveToPoint(gc, 0, 0);
    CGContextAddLineToPoint(gc, 0, rect.size.height);        

    // right line (only the last cell)
    if(column==headerInfo.numCols-1)
    {
        CGContextMoveToPoint(gc, rect.size.width-1, 0);
        CGContextAddLineToPoint(gc, rect.size.width-1, rect.size.height);        
    }
    // Bottom line
    CGContextMoveToPoint(gc, 0, rect.size.height);
    CGContextAddLineToPoint(gc, rect.size.width, rect.size.height);
    
    CGContextStrokePath(gc); 

    if(entity.type==ftAuto && isEditMode)
        return;
    
    if(entity.type==ftImg)
    {
        [gridContentController.gridController.delegate drawImgEntity:self.gridContentController.gridController rowIndex:row columnIndex:column intoRect:rect];
    }
    else 
    {
        NSString *displayText;
        
        if([label isKindOfClass:[NSString class]])
            displayText = label;
        else
            displayText = @""; // [NSString stringWithFormat:@"<<ERROR>>%@.%@ is of type %@",entity.entityName,entity.path,[label description ]];
        
        // Draw Text
        if(rowSelected && !isEditMode)
            [headerInfo.cellFontSelectedColor set];
        else
            [headerInfo.cellFontColor set];

        rect = CGRectMake(rect.origin.x+4, rect.origin.y+4, rect.size.width-8, rect.size.height-8);
        
        CGContextSetAllowsAntialiasing(gc, YES);
        UIFont *tempFont = [UIFont fontWithName:headerInfo.cellFontName size:headerInfo.cellFontSize];
        CGFloat pointSize = headerInfo.cellFontSize;
        while(true)
        {
            CGSize destSize = CGSizeMake(rect.size.width, 10000.0);
            CGSize textSize = [displayText sizeWithFont:tempFont constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
            
            if(textSize.height < rect.size.height || pointSize <= headerInfo.minimumHeaderFontSize)
            {
                destSize.height = rect.size.height;
                textSize = [displayText sizeWithFont:tempFont constrainedToSize:destSize lineBreakMode:NSLineBreakByWordWrapping];
                
                CGRect textRect = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - textSize.height)/2  , rect.size.width, textSize.height);
                [displayText drawInRect:textRect withFont:tempFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
                
                break;
            }
            else
            {
                pointSize -= 1.0;
                tempFont = [UIFont fontWithName:headerInfo.cellFontName size:pointSize];
                
            }
        }
        tempFont = nil;
    }
}
@end
