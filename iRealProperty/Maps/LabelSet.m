
#import "LabelSet.h"
#import "ArcGIS.h"
#import "RendererXmlLabel.h"

@implementation LabelSet

@synthesize name;
@synthesize labelSpecs;
@synthesize expression;
@synthesize whereClause;
@synthesize fontFamily;
@synthesize fontColor;
@synthesize maxZoom;
@synthesize minZoom;
@synthesize fontSize;
@synthesize fontBold;
@synthesize fontItalic;

-(NSArray*)getLabelsForGraphic: (AGSGraphic*)graphic withCenter: (AGSPoint*)center;
{
    
    NSDictionary* attributes = [graphic attributes];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:whereClause];
    BOOL matchCriteria = [predicate evaluateWithObject:attributes];
    
    if (matchCriteria)
    {
        NSMutableArray * labels = [[NSMutableArray alloc] init];
        fontColor = [fontColor colorWithAlphaComponent:1.0]; // de activate tranpancy in fonts.
        NSArray* tokens = [expression componentsSeparatedByString:@"&"];
        double y = 0;
        NSString* templateText = @"";
        NSMutableArray* labelsTextArray = [[NSMutableArray alloc] init];
        for (NSString* token in tokens) {
            NSString* trimmedToken = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([trimmedToken hasPrefix:@"["] && [trimmedToken hasSuffix:@"]"])
            {
                // remove [ and ] and substitu it with ${ and } that is how text template works in ArcGis api for IOS
                trimmedToken = [trimmedToken substringFromIndex:1];  
                trimmedToken = [trimmedToken substringToIndex:([trimmedToken length] - 1)]; 
                //trimmedToken = [NSString stringWithFormat:@"${%@}", trimmedToken];
                id value = [attributes valueForKey:trimmedToken];
                if ([value isKindOfClass:[NSNumber class]])
                {
                    CFNumberType numberType = CFNumberGetType((__bridge CFNumberRef)value);
                    if (numberType == kCFNumberFloat32Type || 
                        numberType == kCFNumberFloat64Type ||
                        numberType == kCFNumberFloatType ||
                        numberType == kCFNumberDoubleType ||
                        numberType == kCFNumberCGFloatType)
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                        trimmedToken = [numberFormatter stringFromNumber:value];
                    }
                    else {
                        trimmedToken = [NSString stringWithFormat:@"%@", value];
                    }
                }
                else if ([value isKindOfClass:[NSDate class]])
                {
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                    trimmedToken = [dateFormatter stringFromDate:value];
                }
                else {
                    trimmedToken = [NSString stringWithFormat:@"%@", value];
                }
            }
            else if ([trimmedToken hasPrefix:@"\""] && [trimmedToken hasSuffix:@"\""])
            {
                // just remove the quatations and it will be a literal
                trimmedToken = [trimmedToken substringFromIndex:1];  
                trimmedToken = [trimmedToken substringToIndex:([trimmedToken length] - 1)];
            }
            
            if ([trimmedToken compare:@"vbCrLf" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                // new line
                if ([templateText length] > 0)
                {
                    [labelsTextArray addObject:templateText];
                }
                templateText = @"";
            }
            else {
                templateText = [templateText stringByAppendingString:trimmedToken];
            }
        }
        
        if ([templateText length] > 0)
        {
            [labelsTextArray addObject:templateText];
        }
           
        for (NSString* text in labelsTextArray) {
            AGSTextSymbol* textSymbol = [AGSTextSymbol textSymbolWithTextTemplate:text color:fontColor];
            textSymbol.fontFamily = fontFamily;
            textSymbol.fontSize = 9 + fontSize ;
            textSymbol.yoffset = y;
            textSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
            textSymbol.vAlignment = AGSTextSymbolVAlignmentMiddle;
            y += textSymbol.fontSize + 2;
            
            if (fontItalic)
            {
                textSymbol.fontStyle = AGSTextSymbolFontStyleItalic;
            }
            
            if (fontBold)
            {
                textSymbol.fontWeight = AGSTextSymbolFontWeightBold;
            }
            
            AGSGraphic* myLabel =
            [AGSGraphic graphicWithGeometry:[graphic geometry]
                                     symbol:textSymbol
                                 attributes:nil
                       infoTemplateDelegate:nil];
            
            [labels addObject:myLabel];
        }
        return labels;
    }
    return NULL;
}

@end
