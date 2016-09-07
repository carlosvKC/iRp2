
#import <UIKit/UIKit.h>

@interface Options : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSMutableArray *sectionArray;

@end

@interface OptionSection : NSObject

@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *footer;
@property(nonatomic, strong) NSMutableArray *optionArray;

@end

@interface Option : NSObject

@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *param;
@property(nonatomic, strong) NSString *choices;
@property(nonatomic, strong) NSString *defaultStr;
@end