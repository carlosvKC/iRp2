#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@interface parcelAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
    BOOL fromSearch;
}

@property (nonatomic, assign) BOOL fromSearch;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c;

- (void) setTitle: (NSString*) t;
@end
