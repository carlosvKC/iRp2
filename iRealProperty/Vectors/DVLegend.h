
#import <Foundation/Foundation.h>

@protocol DVLegendDelegate <NSObject>

-(NSString *)DVLegendGetParcel;
-(NSArray *)DVLegendGetLayers;
-(CGFloat)DVLegendGetScale;
-(CGPoint)locationInModel:(CGPoint)pt;
-(CGPoint)locationInView:(CGPoint)pt;

@end

@interface DVLegend : NSObject
{
    CGPoint     _location;
    NSMutableDictionary *_areas;
    CGFloat     _scale;
}
@property(nonatomic, weak) id<DVLegendDelegate> delegate;
@property(nonatomic) CGRect frame;
@property(nonatomic) CGPoint location;
@property(nonatomic) BOOL hidden;

-(id)initWithPoint:(CGPoint)loc;
-(void)drawLegend:(CGContextRef)gc;
// pt is in screen coordinate
-(BOOL)inside:(CGPoint)pt;
// move the legend around
-(void)move:(CGPoint)delta;
-(void)newArea:(NSString *)name area:(CGFloat)area;
-(void)substractArea:(NSString *)name area:(CGFloat)area;
-(void)addArea:(NSString *)name area:(CGFloat)area;
-(CGFloat)area:(NSString *)name;
@end
