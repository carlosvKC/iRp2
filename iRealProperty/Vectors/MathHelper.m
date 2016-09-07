

#import "MathHelper.h"

@implementation MathHelper
// http://tog.acm.org/resources/GraphicsGems/gemsii/intersect
/* lines_intersect:  AUTHOR: Mukesh Prasad
 *
 *   This function computes whether two line segments,
 *   respectively joining the input points (x1,y1) -- (x2,y2)
 *   and the input points (x3,y3) -- (x4,y4) intersect.
 *   If the lines intersect, the output variables x, y are
 *   set to coordinates of the point of intersection.
 *
 *   All values are in integers.  The returned value is rounded
 *   to the nearest integer point.
 *
 *   If non-integral grid points are relevant, the function
 *   can easily be transformed by substituting floating point
 *   calculations instead of integer calculations.
 *
 *   Entry
 *        x1, y1,  x2, y2   Coordinates of endpoints of one segment.
 *        x3, y3,  x4, y4   Coordinates of endpoints of other segment.
 *
 *   Exit
 *        x, y              Coordinates of intersection point.
 *
 *   The value returned by the function is one of:
 *
 *        DONT_INTERSECT    0
 *        DO_INTERSECT      1
 *        COLLINEAR         2
 *
 * Error conditions:
 *
 *     Depending upon the possible ranges, and particularly on 16-bit
 *     computers, care should be taken to protect from overflow.
 *
 *     In the following code, 'long' values have been used for this
 *     purpose, instead of 'int'.
 *
 */

#define	DONT_INTERSECT    0
#define	DO_INTERSECT      1
#define COLLINEAR         2

/**************************************************************
 *                                                            *
 *    NOTE:  The following macro to determine if two numbers  *
 *    have the same sign, is for 2's complement number        *
 *    representation.  It will need to be modified for other  *
 *    number systems.                                         *
 *                                                            *
 **************************************************************/

#define SAME_SIGNS( a, b )	((a*b)>0)

+(int)lines_intersect:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 x3:(float)x3 y3:(float)y3 x4:(float)x4 y4:(float)y4 x:(float *)x y:(float *)y
{
    float a1, a2, b1, b2, c1, c2; /* Coefficients of line eqns. */
    float r1, r2, r3, r4;         /* 'Sign' values */
    float denom, offset, num;     /* Intermediate values */
    
    /* Compute a1, b1, c1, where line joining points 1 and 2
     * is "a1 x  +  b1 y  +  c1  =  0".
     */
    
    a1 = y2 - y1;
    b1 = x1 - x2;
    c1 = x2 * y1 - x1 * y2;
    
    /* Compute r3 and r4.
     */
    
    
    r3 = a1 * x3 + b1 * y3 + c1;
    r4 = a1 * x4 + b1 * y4 + c1;
    
    /* Check signs of r3 and r4.  If both point 3 and point 4 lie on
     * same side of line 1, the line segments do not intersect.
     */
    
    if ( r3 != 0 &&
        r4 != 0 &&
        SAME_SIGNS( r3, r4 ))
        return ( DONT_INTERSECT );
    
    /* Compute a2, b2, c2 */
    
    a2 = y4 - y3;
    b2 = x3 - x4;
    c2 = x4 * y3 - x3 * y4;
    
    /* Compute r1 and r2 */
    
    r1 = a2 * x1 + b2 * y1 + c2;
    r2 = a2 * x2 + b2 * y2 + c2;
    
    /* Check signs of r1 and r2.  If both point 1 and point 2 lie
     * on same side of second line segment, the line segments do
     * not intersect.
     */
    
    if ( r1 != 0 &&
        r2 != 0 &&
        SAME_SIGNS( r1, r2 ))
        return ( DONT_INTERSECT );
    
    /* Line segments intersect: compute intersection point. 
     */
    
    denom = a1 * b2 - a2 * b1;
    if ( denom == 0 )
        return ( COLLINEAR );
    offset = denom < 0 ? - denom / 2 : denom / 2;
    
    /* The denom/2 is to get rounding instead of truncating.  It
     * is added or subtracted to the numerator, depending upon the
     * sign of the numerator.
     */
    
    num = b1 * c2 - b2 * c1;
    *x = ( num < 0 ? num - offset : num + offset ) / denom;
    
    num = a2 * c1 - a1 * c2;
    *y = ( num < 0 ? num - offset : num + offset ) / denom;
    
    return ( DO_INTERSECT );
} /* lines_intersect */
+(CGFloat)distanceBetweenPoints:(CGPoint)pt1 pt2:(CGPoint)pt2
{
    CGFloat d = ((pt2.x - pt1.x) * (pt2.x - pt1.x)) + ((pt2.y - pt1.y) * (pt2.y - pt1.y));
    d = sqrt(d);
    return d;
}
// Find a point that is on a line at a distance from the start point
+(CGPoint)pointAtDistanceOfPoint:(CGPoint)start end:(CGPoint)end distance:(CGFloat)distance
{
    CGPoint pt;
    if(start.x==end.x)
    {
        // Vertical line
        pt.x = start.x;
        pt.y = start.y + distance;
    }
    else
    {
        // standard line.
        // Calculate the angle
        CGFloat angle = [MathHelper angleToRadian:start point:end];
        pt.x = start.x + cosf(angle)*distance;
        pt.y = start.y + sinf(angle)*distance;
    }
    return pt;
}

+(BOOL)circleIntersectWithRectangle:(CGPoint)center radius:(CGFloat)radius rect:(CGRect)rect
{
    CGFloat left, top, right, bottom;
    left = rect.origin.x;
    top = rect.origin.y;
    right = left + rect.size.width;
    bottom = top + rect.size.height;
    int count = 0;
    CGFloat distance = [MathHelper distanceBetweenPoints:center pt2:CGPointMake(left, top)];
    if(distance < radius)
        count++;
    
    distance = [MathHelper distanceBetweenPoints:center pt2:CGPointMake(left, bottom)];
    if(distance < radius)
        count++;

    distance = [MathHelper distanceBetweenPoints:center pt2:CGPointMake(right, bottom)];
    if(distance < radius)
        count++;

    distance = [MathHelper distanceBetweenPoints:center pt2:CGPointMake(right, top)];
    if(distance < radius)
        count++;
    if(count>=1 && count<=3)
        return YES;
    return NO;
}
// Return the point on a circle based on the angle
+(CGPoint)circlePoint:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle
{
    CGPoint pt = CGPointMake(cosf(angle)*radius + center.x, sinf(angle)*radius + center.y);
    return pt;
}
#if 0
/* A main program to test the function.
 */

main()
{
    long x1, x2, x3, x4, y1, y2, y3, y4;
    long x, y;
    
    for (;;) {
        printf( "X1, Y1: " );
        scanf( "%ld %ld", &x1, &y1 );
        printf( "X2, Y2: " );
        scanf( "%ld %ld", &x2, &y2 );
        printf( "X3, Y3: " );
        scanf( "%ld %ld", &x3, &y3 );
        printf( "X4, Y4: " );
        scanf( "%ld %ld", &x4, &y4 );
        
        switch ( lines_intersect( x1, y1, x2, y2, x3, y3, x4, y4, &x, &y )) {
            case DONT_INTERSECT:
                printf( "Lines don't intersect\n" );
                break;
            case COLLINEAR:
                printf( "Lines are collinear\n" );
                break;
            case DO_INTERSECT:
                printf( "Lines intersect at %ld,%ld\n", x, y );
                break;
        }
    }
} /* main */

#endif

+(BOOL)lineIntersectWithRectangle:(CGPoint)startPt endPoint:(CGPoint)endPt withRect:(CGRect)rect
{
    CGFloat x, y;
    CGFloat left, top, right, bottom;
    left = rect.origin.x;
    top = rect.origin.y;
    right = left + rect.size.width;
    bottom = top + rect.size.height;
    
    if(CGRectContainsPoint(rect, startPt) || CGRectContainsPoint(rect, endPt))
        return YES;

    if([MathHelper lines_intersect:startPt.x y1:startPt.y x2:endPt.x y2:endPt.y x3:left y3:top x4:left y4:bottom x:&x y:&y]==DO_INTERSECT)
        return YES;
    if([MathHelper lines_intersect:startPt.x y1:startPt.y x2:endPt.x y2:endPt.y x3:left y3:top x4:right y4:top x:&x y:&y]==DO_INTERSECT)
        return YES;

    if([MathHelper lines_intersect:startPt.x y1:startPt.y x2:endPt.x y2:endPt.y x3:right y3:top x4:right y4:bottom x:&x y:&y]==DO_INTERSECT)
        return YES;

    if([MathHelper lines_intersect:startPt.x y1:startPt.y x2:endPt.x y2:endPt.y x3:left y3:bottom x4:right y4:bottom x:&x y:&y]==DO_INTERSECT)
        return YES;
    // Case to handle very small pieces -- check the inside line
    
    return NO;
}
// Return the coordinates of a point based on an an angle in radian
+(CGPoint)angleToPoint:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle
{
    CGPoint pt;
    pt.x = cos(angle) * radius + center.x;
    pt.y = sin(angle) * radius + center.y;
    
    return pt;
}
// Return the angle from a point
+(CGFloat)angleToRadian:(CGPoint)center point:(CGPoint)point
{
    CGFloat deltaY = (point.y - center.y);
    CGFloat deltaX = (point.x - center.x);
    if(deltaX==0)
    {
        if(point.y < center.y)
            return M_PI_2;
        else
            return 1.5 * M_PI_2;
    }
    CGFloat tangente = ABS(deltaY) / ABS(deltaX);
    
    CGFloat angle = atan(tangente);

    if(point.x < center.x)
    {
        angle = M_PI - angle;
    }
    if(point.y < center.y)
    {
        angle = 2*M_PI - angle;
    }
    return angle;
}
+(int)angleToDegree:(CGPoint)center point:(CGPoint)point
{
    int angle = ([MathHelper angleToRadian:center point:point] * 180.0)/M_PI + 0.1;
    return angle;
}
// Return an angle in degree and revere it
+(int)angleToDegreeReversed:(CGFloat)anglef
{
    int angle = rintf((anglef * 180.0)/M_PI);
    return 360-angle;
}
+(CGPoint)centerOfLine:(CGPoint)start end:(CGPoint)end
{
    return CGPointMake(start.x + (end.x-start.x)/2.0, start.y+(end.y-start.y));
}
// Return a normalized angle
+(CGFloat)normalizeAngle:(CGFloat)angle
{
    while(angle<0)
        angle += 2*M_PI;
    
    while(angle>2*M_PI)
        angle -= 2*M_PI;
    
    return angle;
}
@end
