#import <Foundation/Foundation.h>
#import "SearchItem.h"

enum searchItemConstant 
{
    kSearchByItems = 0,
    kSearchByParcel,
    kSearchByStreet
};
enum QueryJoin
{
    kQueryNone,
    kQueryInnerJoin,
    kQueryAdd
};

@interface QueryDefinition : NSObject
{
    // Query to be executed
    NSString    *query;
    // Name of the entity to execute the query on
    NSString    *entityName;
    // Sorting field
    NSString    *entitySortBy;
    // Sorting order
    BOOL        ascending;
    // Definition of the table of result
    NSString    *resultRef;
    // Predicate to execute
    NSPredicate *predicate;
    // Unique key
    BOOL        unique;
}
@property(nonatomic, strong) NSString *entityName;
@property(nonatomic, strong) NSString *entitySortBy;
@property(nonatomic, strong) NSString *entityLink;
@property(nonatomic) BOOL ascending;
@property(nonatomic, strong) NSString *query;
@property(nonatomic, strong) NSPredicate *predicate;
@property(nonatomic) BOOL unique;
@end

@interface SearchDefinition2 : NSObject
{
    // Type of search
    enum searchItemConstant searchType;

    // Title of the search
    NSString    *title;
    // List of all the searches
    NSMutableArray *items;
    // Error message if the form is not fully filled
    NSString    *errorMsg;
    // Description (below the title)
    NSString    *searchDescription;
    // Query definition
    QueryDefinition *query;
    // Join-Query definition (can be null for single query)
    NSMutableArray *joinQueries;
    // true if the the search definition is used for the default map
    BOOL isDefaultMap;

}
@property(nonatomic,retain) NSString *title;
@property(nonatomic, retain) NSMutableArray *items;
@property(nonatomic, retain) NSString *errorMsg;
@property(nonatomic, retain) NSString *searchDescription;

@property(nonatomic, retain) NSString *resultRef;
@property(nonatomic) enum searchItemConstant searchType;

@property(nonatomic, strong) QueryDefinition *query;
@property(nonatomic, strong) NSMutableArray *joinQueries;
@property(nonatomic) BOOL isDefaultMap;
@end
