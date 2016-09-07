
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMLReader.h"

@class NIBObject;

@interface NIBReader : NSObject
{
    NIBObject *portraitView;
    NIBObject *landscapeView;
    NSString *objectName;
}
// init the base class
-(id)initWithNibName:(NSString *)name;
-(id)initWithNibName:(NSString *)portrait landscape:(NSString *)landscape;
-(id)initWithNibName:(NSString *)portrait portraitId:(int)pId landscape:(NSString *)landscape landscapeId:(int)lId;
// Rotate the views
-(void)rotateViews:(UIView *)view landscapeMode:(BOOL)landscapeMode;
@end

// List of all the objects in the NIB file
@interface NIBObject : NSObject

@property(nonatomic) CGRect     frame;      // landscape
@property(nonatomic) int        tag;
@property(nonatomic) CGRect     altFrame;   // portrait
// Used if the views has
@property(nonatomic, strong)    NSMutableArray *subviews;


@end

