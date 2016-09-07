#import <Foundation/Foundation.h>

@interface MenuItem : NSObject
{
    int         menuTag;            // Menu tag to use
    NSString    *menuLabel;         // Label of the menu to use. Use a "-" in front to create a section
    BOOL        menuChecked;        // YES if the menu is checked
    id          menuParam;          // Some extra information
    id        menuParam2;         // web link
}

@property int menuTag;
@property(nonatomic, retain) NSString *menuLabel;
@property BOOL menuChecked;
@property(nonatomic, retain) id menuParam;
@property(nonatomic, retain) id menuParam2;

-(id)initWithInfo:(NSString *)label tag:(int)tag;
-(id)initWithInfo:(NSString *)label tag:(int)tag param:(id)param;
-(id)initWithInfo:(NSString *)label tag:(int)tag param:(id)param param2:(id)param2;

@end
