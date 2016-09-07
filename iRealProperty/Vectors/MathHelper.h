

#import <Foundation/Foundation.h>

@interface MathHelper : NSObject
+(BOOL)lineIntersectWithRectangle:(CGPoint)startPt endPoint:(CGPoint)endPt withRect:(CGRect)rect;
+(CGFloat)distanceBetweenPoints:(CGPoint)pt1 pt2:(CGPoint)pt2;
+(BOOL)circleIntersectWithRectangle:(CGPoint)center radius:(CGFloat)radius rect:(CGRect)rect;
+(CGPoint)angleToPoint:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle;
+(CGFloat)angleToRadian:(CGPoint)center point:(CGPoint)point;
+(int)angleToDegree:(CGPoint)center point:(CGPoint)point;
+(CGPoint)circlePoint:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle;
+(int)angleToDegreeReversed:(CGFloat)anglef;
+(CGPoint)centerOfLine:(CGPoint)start end:(CGPoint)end;
+(CGFloat)normalizeAngle:(CGFloat)angle;
+(CGPoint)pointAtDistanceOfPoint:(CGPoint)start end:(CGPoint)end distance:(CGFloat)distance;

@end
