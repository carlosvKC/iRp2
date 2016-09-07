#import "parcelAnnotation.h"


@implementation parcelAnnotation
@synthesize coordinate;
@synthesize fromSearch;

- (NSString *)subtitle{
    return mSubTitle;
}

- (NSString *)title{
    return mTitle;
}

- (void) setTitle: (NSString*) t{
    mTitle = t;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    NSLog(@"%f,%f",c.latitude,c.longitude);
    return self;
}

@end
