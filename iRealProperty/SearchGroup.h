#import <Foundation/Foundation.h>
#include "SearchDefinition2.h"

@interface SearchGroup : NSObject
{
    // Title for the group
    NSString    *title;
    // List of definition
    NSMutableArray *searchDefinitions;
    

}
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSMutableArray *searchDefinitions;

@end
