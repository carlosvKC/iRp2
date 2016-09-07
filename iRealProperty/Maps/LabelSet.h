#import <Foundation/Foundation.h>

@class AGSGraphic;
@class AGSPoint;

@interface LabelSet : NSObject
{
    NSString* name;
    NSString* labelSpecs;
    double maxZoom;
    double minZoom;
    NSString* expression;
    NSString* whereClause;
    NSString* fontFamily;
    double fontSize;
    BOOL fontBold;
    BOOL fontItalic;
    UIColor* fontColor;
}

@property (nonatomic, strong)  NSString* name;
@property (nonatomic, strong)  NSString* labelSpecs;
@property (nonatomic, strong)  NSString* expression;
@property (nonatomic, strong)  NSString* whereClause;
@property (nonatomic, strong)  NSString* fontFamily;
@property (nonatomic, strong)  UIColor* fontColor;
@property (nonatomic, assign) double maxZoom;
@property (nonatomic, assign) double minZoom;
@property (nonatomic, assign) double fontSize;
@property (nonatomic, assign) BOOL fontBold;
@property (nonatomic, assign) BOOL fontItalic;

-(NSArray*)getLabelsForGraphic: (AGSGraphic*)graphic withCenter: (AGSPoint*)center;

@end
