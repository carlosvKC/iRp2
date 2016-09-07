
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStore : NSObject
@property(nonatomic, strong)    NSPersistentStoreCoordinator    *storeCoordinator;
@property(nonatomic, strong)    NSManagedObjectContext          *managedContext;
@property(nonatomic, strong)    NSString *storeName;
    
@end

@interface AxDataManager : NSObject 
{
	NSManagedObjectContext * parentContext;
}

#pragma mark Public Methods

#pragma mark Static Methods

// Create the object context
+(NSManagedObjectContext *)createManagedObjectContext:(NSString *)name storeName:(NSString *)storeName modelName:(NSString *)model;
+(NSManagedObjectContext *)createManagedObjectContext:(NSString *)name storeName:(NSString *)storeName modelName:(NSString *)model mustExist:(BOOL)mustExist;

// Return the current object context
+ (NSManagedObjectContext *)getContext:(NSString *)name;

// Release an object from the sore
+(void)releaseManagedObjectStore:(NSString *)name;
// Return the name of the permanent store
+ (NSString *)permanentStoreName:(NSString *)name;

// Create an object context from an existing store coordinator
+ (NSManagedObjectContext *)createManagedObjectContextFromContextName:(NSString *)contextName;
// gets the total number of entities of type EntityName
+(int) countEntities: (NSString*)EntityName;

// gets the total number of entities of type EntityName
+(int) countEntities: (NSString*)EntityName andContext: (id)context;

// gets the total number of entities of type EntityName that match the predicate
+(int) countEntities: (NSString*)EntityName andPredicate: (NSPredicate*) predicate;

// gets the total number of entities of type EntityName that match the predicate
+(int) countEntities: (NSString*)EntityName andPredicate: (NSPredicate*) predicate andContext: (id)context;

// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField
+(NSMutableArray *) dataListEntity: (NSString *) entityName andSortBy: (NSString *) sortField;

//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField and filter by the predicate
//
+(NSMutableArray *) dataListEntity: (NSString *) entityName andSortBy: (NSString *) sortField andPredicate: (NSPredicate *) predicate withContext:(NSManagedObjectContext *)context;

+(NSMutableArray *) dataListEntity: (NSString *) entityName andSortBy:(NSString *)sortField sortAscending:(BOOL)sortOrder withContext:(NSManagedObjectContext *)context;
+(NSMutableArray *) dataListEntity: (NSString *) entityName andPredicate:(NSPredicate *)predicate andSortBy:(NSString *)sortField sortAscending:(BOOL)sortOrder withContext:(NSManagedObjectContext *)context;

// return the NSMutableArray with the full list of entities of type entityName
// and sorted desending by sortField
+(NSMutableArray *) dataListEntityDescending: (NSString *) entityName andSortBy: (NSString *) sortField;

// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField and filter by the predicate
+(NSMutableArray *) dataListEntity: (NSString *) entityName andSortBy: (NSString *) sortField andPredicate: (NSPredicate *) predicate;

// return the NSMutableArray with the full list of entities of type entityName
// and sorted desending by sortField and filter by the predicate
+(NSMutableArray *) dataListEntityDescending: (NSString *) entityName andSortBy: (NSString *) sortField andPredicate: (NSPredicate *) predicate;

// ... same with the maximum limit
+(NSMutableArray *) dataListEntityWithLimit: (NSString *) entityName andSortBy: (NSString *) sortField andPredicate: (NSPredicate *) predicate andLimit:(int)maxCount;


// Return an NSFetchedResultsController
+(NSFetchedResultsController *) getFetchedResultsController: (NSString *)entityName andSortBy:(NSString *)sortField ascending:(BOOL)ascending andPredicate:(NSPredicate *)predicate cacheName:(NSString *)cache;

+(NSFetchedResultsController *) getFetchedResultsController: (NSString *)entityName andSortBy:(NSString *)sortField ascending:(BOOL)ascending andPredicate:(NSPredicate *)predicate batchSize:(int)batchSize withContext:(NSManagedObjectContext *)context cacheName:(NSString *)cacheName;


// return the NSMutableArray with the full list of entities of type entityName
// and sorted desending by sort descriptors and filter by the predicate
+(NSMutableArray *) dataListEntityDescending: (NSString *) entityName andSortDescriptors: (NSArray *) sortDescriptors andPredicate: (NSPredicate *) predicate;




// return the object found for the specific predicate
+(id) getEntityObject: (NSString *) entityName andPredicate: (NSPredicate *) predicate;

// return the object found for the specific predicate
+(id) getEntityObject: (NSString *) entityName andPredicate: (NSPredicate *) predicate andContext: (NSManagedObjectContext*) context;

// return a new object created for the especific entity
+(id) getNewEntityObject: (NSString *) entityName;
// return a new object created for the especific entity
+(id) getNewEntityObject: (NSString *) entityName andContext: (id) context;

// return the first Object for one list
+(id) getFirstFromList: (NSString *) entityName;
// return the first Object for one list
+(id) getFirstFromList: (NSString *) entityName andContext: (id)context;



// return the object found for the specific logical key
+(id) getEntityObjectbyLogicalKey: (NSString *) entityName andLogicalKey: (NSString *) logicalKey;


// transform a local date to a GTM date.
+ (NSDate*) getGTMDateFromDate: (NSDate*) date;

// transform a UTC date to a local date.
+ (NSDate*) getDateFromGTMDate: (NSDate*) date;

// Parsing

+(void)copyManagedObject:(NSManagedObject *)source destination:(NSManagedObject *)destination withSets:(BOOL)sets withLinks:(BOOL)links;

//Function used to get specific numeric values for aggreation operations on entities
+(NSNumber *)aggregatedOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate onEntity: (NSString *)entityName;

// Clone an NSManagedObject
+(NSManagedObject *) clone:(NSManagedObject *)source ;
+(NSManagedObject *) clone:(NSManagedObject *)source withSets:(BOOL)sets withLinks:(BOOL)links;
+(NSManagedObject *) clone:(NSManagedObject *)source withSets:(BOOL)sets withLinks:(BOOL)links andContext:(NSManagedObjectContext *)context;

// Convert a set to a NSArray
+(NSArray *)setToArray:(NSSet *)set;

// Convert a set to an ordered NSArray
+(NSArray *)orderSet:(NSSet *)set property:(NSString *)property ascending:(BOOL)ascending;

// Sort an NSArray
+(NSArray *)orderArray:(NSMutableArray *)unsortedArray property:(NSString *)property ascending:(BOOL)ascending;

// Return the default context
+(NSManagedObjectContext*) defaultContext;
// Return the configuration context
+(NSManagedObjectContext*) configContext;
// Return the note context
+(NSManagedObjectContext*) noteContext;

+(BOOL)migrateStore:(NSString *)modelName storeName:(NSString *)storeName toModelName:(NSString *)dstModelName toVersionTwoStore:(NSString *)storeTwoName error:(NSError **)outError;
// This method will migrate manually (i.e. re-create completely) from an existing store to a new store
//+(BOOL)manualMigration:(NSString *)modelName storeName:(NSString *)storeName toVersionTwoStore:(NSString *)storeTwoName error:(NSError **)outError rootObject:(NSString *)rootObject sortName:(NSString *)sortName;

// disctinctSelect
+(NSArray *)distinctSelect:(NSString *)entityName fieldName:(NSString *)fieldName sortAscending:(BOOL)sortOrder andPredicate:(NSPredicate *)predicate withContext:(NSManagedObjectContext *)managedObjectContext;

@end
