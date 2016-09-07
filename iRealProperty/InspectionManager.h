
#import <Foundation/Foundation.h>
@class RealPropInfo;

@interface InspectionManager : NSObject
{
    int     propertyId;
    RealPropInfo *realPropInfo;
}
-(id)initWithPropId:(int)propId realPropInfo:(RealPropInfo *)info;
// set the current inspection state
-(void) setCurrentState:(int)state commit:(BOOL)commit;
// get the current inspection state
-(int) getCurrentState;

@end
