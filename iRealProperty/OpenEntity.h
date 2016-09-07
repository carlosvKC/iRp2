
#import <Foundation/Foundation.h>
#import "Helper.h"
#import "AxDataManager.h"
#import "RealProperty.h"
#import "RealPropertyApp.h"
#import "PermitDtl.h"
#import "ReviewJrnl.h"

@interface OpenEntity : NSObject
// Return a real prop info object from an existing object
+(RealPropInfo *)findRealPropInfo:(NSManagedObject *)object;
+(RealPropInfo *)findRealPropInfo:(NSString *)entityKind withGuid:(NSString *)guid;
+(RealPropInfo *)findRealPropInfo:(NSString *)entityKind withGuid:(NSString *)guid withContext:(NSManagedObjectContext *)context;

// Return YES if an object can be inserted into the context
+(BOOL)insertObjectIntoContext:(NSManagedObject *)object withContext:(NSManagedObjectContext *)context;

// Open the tab property tab to the appropriate index and appropriate subindex (when possible)
+(BOOL)Open:(NSString *)className withGuid:(NSString *)guid;

// Return YES if the object was bookmarked with an error
+(BOOL)checkBookmarkError:(NSManagedObject *)object withContext:(NSManagedObjectContext *)context;
@end
