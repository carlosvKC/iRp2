

#import <UIKit/UIKit.h>

@class RPPropInfo;

@interface SQLSync : UIViewController
{
    // Current propId used for all the insertions
    RPPropInfo *realProp;
}
// Create one entry only -- need the real parcel ID
-(void)createRealProperty:(int)parcelNbr;

// Create all the properties
-(void)createAllRealProperty;
// Display a log
@property int verbose;
@property(nonatomic, retain) NSManagedObjectContext *destContext;
@end
