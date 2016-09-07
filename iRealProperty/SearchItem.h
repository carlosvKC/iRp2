#import <Foundation/Foundation.h>

enum searchFilterConstant 
{
    kSearchAlphabetical = 0,
    kSearchNumerical,
    kSearchDate
};

@interface SearchItem : NSObject
{
    // Reference object (typically a $name) to refer this entry
    NSString    *refObjectName;
    // Title of the item
    NSString    *refTitle;
    // If an input is required
    BOOL        isRequired;
    // Type filter. Filter can be numerical or alphabetical (default)
    enum searchFilterConstant filter;
    // maximum of characters
    int         maxChars;
    // Help message
    NSString    *itemHelp;
    // Default value (can be nil)
    NSString    *defaultValue;
}

@property(nonatomic, strong) NSString   *refObjectName;
@property(nonatomic, strong) NSString    *refTitle;
@property(nonatomic) BOOL        isRequired;
@property(nonatomic) enum searchFilterConstant filter;
@property(nonatomic) int         maxChars;
@property(nonatomic, strong) NSString    *itemHelp;
@property(nonatomic, strong) NSString *defaultValue;
@property(nonatomic, strong) NSString *choice;

@end
