#import "AxDataManager.h"
#import "RealPropInfo.h"
#import "RealPropertyApp.h"
#import "Helper.h"


@implementation CoreDataStore

    @synthesize storeCoordinator, managedContext, storeName;
@end




@implementation AxDataManager

#pragma mark Public Methods
    static NSLock *contextLock = nil;

// List of all the managed context
    static NSMutableDictionary *managedContexts;



//
// Create a new managed context AND create a new permanent store
//
    + (NSManagedObjectContext *)createManagedObjectContext:(NSString *)name
                                                 storeName:(NSString *)storeName
                                                 modelName:(NSString *)model
        {
            return [AxDataManager createManagedObjectContext:name storeName:storeName modelName:model mustExist:NO];
        }



    + (NSManagedObjectContext *)createManagedObjectContext:(NSString *)name
                                                 storeName:(NSString *)storeName
                                                 modelName:(NSString *)model
                                                 mustExist:(BOOL)mustExist
        {
            if (managedContexts == nil)
                {
                    managedContexts = [[NSMutableDictionary alloc] init];
                }

            NSPersistentStoreCoordinator *coordinator = [AxDataManager createStoreCoordinator:storeName withModel:model mustExist:mustExist];

            if (coordinator == nil)
                return nil;

            NSManagedObjectContext *managedObjectContext;

            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
            [managedObjectContext setUndoManager:nil];

            // Save the managed context and its store coordinator
            CoreDataStore *store = [[CoreDataStore alloc] init];
            store.storeCoordinator = coordinator;
            store.managedContext   = managedObjectContext;
            store.storeName        = storeName;

            [managedContexts setValue:store forKey:name];

            return managedObjectContext;
        }



    + (void)releaseManagedObjectStore:(NSString *)contextName
        {
            CoreDataStore *store = [managedContexts objectForKey:contextName];
            if (store == nil)
                return;

            store.storeCoordinator = nil;
            store.managedContext   = nil;

            [managedContexts removeObjectForKey:contextName];
        }



//
// Create an object context to be used from another thread. The store coordinate must have
// been created before
//
    + (NSManagedObjectContext *)createManagedObjectContextFromContextName:(NSString *)contextName
        {
            CoreDataStore *store = [managedContexts objectForKey:contextName];
            if (store == nil)
                return nil;
            NSPersistentStoreCoordinator *coordinator = store.storeCoordinator;

            NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
            [context setPersistentStoreCoordinator:coordinator];
            [context setUndoManager:nil];

            return context;
        }



//
// Return the managed object context
//
    + (NSManagedObjectContext *)getContext:(NSString *)name
        {

            CoreDataStore *store = [managedContexts objectForKey:name];

            return store.managedContext;
        }



//
// Return the store name
//
    + (NSString *)permanentStoreName:(NSString *)name
        {

            CoreDataStore *store = [managedContexts objectForKey:name];

            return store.storeName;
        }



/**
 Create a persistent store coordinate
 */
    + (NSPersistentStoreCoordinator *)createStoreCoordinator:(NSString *)storeName
                                                   withModel:(NSString *)modelName
                                                   mustExist:(BOOL)mustExist
        {
            // Example:
            // For Preferences database, the following would be the argument values...
            //   storeName = Preferences.sqlite
            //   modelName = Preferences
            
            NSURL *dir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

            // This will be the full path to the sqlite database in question, located in the Documents directory of the device or the simulator.
            NSURL *storeURL = [dir URLByAppendingPathComponent:storeName];

            //#warning How can this NOT be a bug?  The modelPath will ALWAYS be nil, resulting in range.location ALWAYS being 0
            NSString *modelPath;
            NSRange  range  = [modelPath rangeOfString:@"/"];

            // The full path to the database in question momd file inside the iRealProperty.app bundle
            if (range.location > 0)
                modelPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"mom"];
            else
                modelPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"momd"];
            NSURL *modelURL = [NSURL fileURLWithPath:modelPath];

            NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

            NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

#ifdef LIGHT_WEIGHT_MIGRATION
    // in case small changes
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];    
    if(!mustExist)
        optionsDictionary = nil;
#else
            NSDictionary *optionsDictionary = nil;
#endif
            // Try to create the model if there is an error on the first time
            for (int index = 0; index < 2; index++)
                {

                    NSError *error = nil;
                    store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
                    
                    // This is the actual line of code that creates a new sqlite database if it doesn't exist.
                    if (![store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error])
                        {
                            if (index == 0)
                                {
                                    if (mustExist)
                                        return nil;
                                    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
                                }
                            else
                                return nil;
                        }
                    else
                        break;
                }
            return store;
        }



//
// Migrate stores using the built-in functions
//
    + (BOOL)migrateStore:(NSString *)modelName
               storeName:(NSString *)storeName
             toModelName:(NSString *)dstModelName
       toVersionTwoStore:(NSString *)storeTwoName
                   error:(NSError **)outError
        {
            NSURL *dir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

            NSURL *storeURL    = [dir URLByAppendingPathComponent:storeName];
            NSURL *dstStoreURL = [dir URLByAppendingPathComponent:storeTwoName];


            NSString *modelPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"mom"];
            NSURL    *modelURL  = [NSURL fileURLWithPath:modelPath];

            NSString *modelTwoPath = [[NSBundle mainBundle] pathForResource:dstModelName ofType:@"mom"];
            NSURL    *modelTwoURL  = [NSURL fileURLWithPath:modelTwoPath];


            NSManagedObjectModel *srcModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            if (srcModel == nil)
                {
                    NSLog(@"Error on srcModel");
                    return NO;
                }
            NSManagedObjectModel *dstModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelTwoURL];
            if (dstModel == nil)
                {
                    NSLog(@"Error on dstModel");
                    return NO;
                }

            // Try to get an inferred mapping model.
            NSError        *mapError     = nil;
            NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:srcModel destinationModel:dstModel error:&mapError];

            // If Core Data cannot create an inferred mapping model, return NO.
            if (!mappingModel)
                {
                    return NO;
                }

            // Create a migration manager to perform the migration.
            NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:srcModel destinationModel:dstModel];

            NSError *error  = nil;
            BOOL    success = [manager migrateStoreFromURL:storeURL type:NSSQLiteStoreType
                                                   options:nil withMappingModel:mappingModel toDestinationURL:dstStoreURL
                                           destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];

            return success;
        }



//
// gets the default object context used to access the entities - convention it is called "default"
//
    + (NSManagedObjectContext *)defaultContext
        {
            return [AxDataManager getContext:@"default"];
        }



//
// gets the default object context used to access the configuration objects
//
    + (NSManagedObjectContext *)configContext
        {
            return [AxDataManager getContext:@"config"];
        }



//
// gets the default object context used to access the personal notes
//
    + (NSManagedObjectContext *)noteContext
        {
            return [AxDataManager getContext:@"note"];
        }



//
// gets the total number of entities of type EntityName
//
    + (int)countEntities:(NSString *)EntityName
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [self countEntities:EntityName andContext:context];
        }



//
// gets the total number of entities of type EntityName
//
    + (int)countEntities:(NSString *)EntityName
              andContext:(id)context
        {
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
            if (entity == nil)
                return 0;
            [request setEntity:entity];
            request.predicate = nil;

            // NSFilterDescriptor

            [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)

            NSError *err = 0;

            NSUInteger count = [context countForFetchRequest:request error:&err];
            if (count == NSNotFound)
                {
                    NSLog(@"fetch request error: %@", [err localizedDescription]);
                    return 0;
                }
            else
                return count;
        }



//
// gets the total number of entities of type EntityName
//
    + (int)countEntities:(NSString *)EntityName
            andPredicate:(NSPredicate *)predicate
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [self countEntities:EntityName andPredicate:predicate andContext:context];
        }



//
// gets the total number of entities of type EntityName
//
    + (int)countEntities:(NSString *)EntityName
            andPredicate:(NSPredicate *)predicate
              andContext:(id)context
        {
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:EntityName inManagedObjectContext:context];
            [request setEntity:entity];

            // NSFilterDescriptor
            [request setPredicate:predicate];
            [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)

            NSError    *err;
            int        result            = 0;
            NSUInteger count             = [context countForFetchRequest:request error:&err];
            if (count == NSNotFound)
                {
                    //Handle error
                    NSLog(@"fetch request error: %@", [err localizedDescription]);
                }
            else
                {
                    result = count;
                }

            return result;
        }



//
// Return the list of distinct entries
//
    + (NSArray *)distinctSelect:(NSString *)entityName
                      fieldName:(NSString *)fieldName
                  sortAscending:(BOOL)sortOrder
                   andPredicate:(NSPredicate *)predicate
                    withContext:(NSManagedObjectContext *)managedObjectContext
        {
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
            request.entity                       = entity;
            request.propertiesToFetch            = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:fieldName]];
            request.returnsDistinctResults       = YES;
            request.resultType                   = NSDictionaryResultType;
            request.predicate                    = predicate;

            if (fieldName.length > 0)
                {
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:fieldName ascending:sortOrder];
                    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    sortDescriptor = nil;
                }
            NSError             *error           = nil;
            NSArray             *distinctResults = [managedObjectContext executeFetchRequest:request error:&error];
            // Use the results
            return distinctResults;
        }



    + (NSMutableArray *)dataListEntity:(NSString *)entityName
                          andPredicate:(NSPredicate *)predicate
                             andSortBy:(NSString *)sortField
                         sortAscending:(BOOL)sortOrder
                           withContext:(NSManagedObjectContext *)context
        {
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];

            [request setEntity:entity];
            [request setPredicate:predicate];

            NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:sortOrder];
            NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];

            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    entity = nil;
                    // NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField
//
    + (NSMutableArray *)dataListEntity:(NSString *)entityName
                             andSortBy:(NSString *)sortField
                         sortAscending:(BOOL)sortOrder
                           withContext:(NSManagedObjectContext *)context
        {
            return [AxDataManager dataListEntity:entityName andPredicate:nil andSortBy:sortField sortAscending:sortOrder withContext:context];
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField
//
    + (NSMutableArray *)dataListEntity:(NSString *)entityName
                             andSortBy:(NSString *)sortField
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [AxDataManager dataListEntity:entityName andSortBy:sortField sortAscending:YES withContext:context];
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted desending by sortField
//
    + (NSMutableArray *)dataListEntityDescending:(NSString *)entityName
                                       andSortBy:(NSString *)sortField
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSFetchRequest         *request = [[NSFetchRequest alloc] init];
            NSEntityDescription    *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];

            NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:NO];
            NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];
            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    // NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField and filter by the predicate
//
    + (NSMutableArray *)dataListEntity:(NSString *)entityName
                             andSortBy:(NSString *)sortField
                          andPredicate:(NSPredicate *)predicate
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSFetchRequest         *request = [[NSFetchRequest alloc] init];
            NSEntityDescription    *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setPredicate:predicate];

            NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:YES];
            NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];

            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted by sortField and filter by the predicate
//
    + (NSMutableArray *)dataListEntity:(NSString *)entityName
                             andSortBy:(NSString *)sortField
                          andPredicate:(NSPredicate *)predicate
                           withContext:(NSManagedObjectContext *)context
        {
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setPredicate:predicate];

            if (sortField != nil)
                {
                    NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:YES];
                    NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
                    [request setSortDescriptors:sortDescriptors];
                }

            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



    + (NSMutableArray *)dataListEntityWithLimit:(NSString *)entityName
                                      andSortBy:(NSString *)sortField
                                   andPredicate:(NSPredicate *)predicate
                                       andLimit:(int)maxCount
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSFetchRequest         *request = [[NSFetchRequest alloc] init];
            NSEntityDescription    *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setPredicate:predicate];

            NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:YES];
            NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];
            [request setFetchLimit:maxCount];

            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



//
// Return a fetched results controller / with more details...
//
    + (NSFetchedResultsController *)getFetchedResultsController:(NSString *)entityName
                                                      andSortBy:(NSString *)sortField
                                                      ascending:(BOOL)ascending
                                                   andPredicate:(NSPredicate *)predicate
                                                      batchSize:(int)batchSize
                                                    withContext:(NSManagedObjectContext *)context
                                                      cacheName:(NSString *)cacheName
        {
            [NSFetchedResultsController deleteCacheWithName:cacheName];
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setFetchBatchSize:batchSize];
            [request setPredicate:predicate];
            NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:ascending];
            NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];
            sortDescriptors = nil;

            NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:cacheName];

            request = nil;

            return newController;
        }



//
// Return a fetched results controller
//
    + (NSFetchedResultsController *)getFetchedResultsController:(NSString *)entityName
                                                      andSortBy:(NSString *)sortField
                                                      ascending:(BOOL)ascending
                                                   andPredicate:(NSPredicate *)predicate
                                                      cacheName:(NSString *)cache
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [AxDataManager getFetchedResultsController:entityName andSortBy:sortField ascending:ascending andPredicate:predicate batchSize:20 withContext:context cacheName:cache];
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted desending by sortField and filter by the predicate
//
    + (NSMutableArray *)dataListEntityDescending:(NSString *)entityName
                                       andSortBy:(NSString *)sortField
                                    andPredicate:(NSPredicate *)predicate
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSFetchRequest         *request = [[NSFetchRequest alloc] init];
            NSEntityDescription    *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setPredicate:predicate];

            NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:sortField ascending:NO];
            NSArray          *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];

            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



//
// return the NSMutableArray with the full list of entities of type entityName
// and sorted desending by sort descriptors and filter by the predicate
//
    + (NSMutableArray *)dataListEntityDescending:(NSString *)entityName
                              andSortDescriptors:(NSArray *)sortDescriptors
                                    andPredicate:(NSPredicate *)predicate
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSFetchRequest         *request = [[NSFetchRequest alloc] init];
            NSEntityDescription    *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setPredicate:predicate];
            [request setSortDescriptors:sortDescriptors];

            NSError        *error               = nil;
            NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResults == nil)
                {
                    NSLog(@"Error requesting: %@", [error localizedDescription]);
                    return nil;
                }
            return mutableFetchResults;
        }



//
// return the object found for the specific predicate
//
    + (id)getEntityObject:(NSString *)entityName
             andPredicate:(NSPredicate *)predicate;
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [AxDataManager getEntityObject:entityName andPredicate:predicate andContext:context];
        }



//
// return the object found for the specific predicate
//
    + (id)getEntityObject:(NSString *)entityName
             andPredicate:(NSPredicate *)predicate
               andContext:(NSManagedObjectContext *)context

        {
                //entityName  = IRNote    14 mins to go prior of loading yellow paper
            if (contextLock == nil)
                contextLock = [[NSLock alloc] init];

            [contextLock lock];

            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            //realPropId == 574389
            [request setPredicate:predicate];
            [request setFetchLimit:1];
            id      result = nil;
            NSError *error = nil;
            NSArray *mutableFetchResults;
            @try
                {
                    mutableFetchResults = [context executeFetchRequest:request error:&error];
                }
            @catch (NSException *exception)
                {
                    [contextLock unlock];

                    NSLog(@"Error in '%@' on %@ = %@", predicate, entityName, [exception debugDescription]);
                    return nil;
                }
            if ((mutableFetchResults == nil) || ([mutableFetchResults count] == 0))
                {
                    entity = nil;
                    if (error != nil)
                        {
                            [contextLock unlock];
                             NSLog(@"Data Core, entity not found: %@", [error localizedDescription]);
                            return nil;
                        }
                }
            else
                {
                    result = [mutableFetchResults objectAtIndex:0];
                }
            [contextLock unlock];
            return result;
        }


//
// return a new object created for the especific entity
//

    + (id)getNewEntityObject:(NSString *)entityName
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [AxDataManager getNewEntityObject:entityName andContext:context];

        }



//
// Automatically add a new GUID if the object supports it
//
    + (id)getNewEntityObject:(NSString *)entityName
                  andContext:(id)context
        {
            NSEntityDescription *newEntity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
            if ([newEntity respondsToSelector:@selector(setGuid:)])
                {
                    @try
                        {
                            NSString *guid = [Helper generateGUID];
                            [newEntity setValue:guid forKey:@"guid"];
                        }
                    @catch (NSException *es)
                        {
                        }
                }
            return newEntity;
        }



//
// return the first Object for one list
//
    + (id)getFirstFromList:(NSString *)entityName
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            return [self getFirstFromList:entityName andContext:context];
        }



// return the first Object for one list
    + (id)getFirstFromList:(NSString *)entityName
                andContext:(id)context
        {
            NSFetchRequest      *request = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            [request setEntity:entity];
            [request setFetchLimit:1];

            NSError *error               = nil;
            NSArray *mutableFetchResults = [context executeFetchRequest:request error:&error];
            if (mutableFetchResults == nil)
                {
                    NSLog(@"Error requesting: %@", [error localizedDescription]);
                }
            else
                {
                    id result = [mutableFetchResults objectAtIndex:0];
                    return result;
                }

            return nil;
        }



//
// return the object found for the specific logical key
//
    + (id)getEntityObjectbyLogicalKey:(NSString *)entityName
                        andLogicalKey:(NSString *)logicalKey;
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSFetchRequest         *request = [[NSFetchRequest alloc] init];
            NSEntityDescription    *entity  = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            // 4/15/16 changed Guid to guid
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid == %@", logicalKey];

            [request setEntity:entity];
            [request setPredicate:predicate];
            id      result               = nil;
            NSError *error               = nil;
            NSArray *mutableFetchResults = [context executeFetchRequest:request error:&error];
            if ((mutableFetchResults == nil) || ([mutableFetchResults count] == 0))
                {
                    NSLog(@"Data Core, entity not found: %@", [error localizedDescription]);
                    return nil;
                }
            else
                {
                    result = [mutableFetchResults objectAtIndex:0];
                }
            return result;
        }

#pragma mark - utilities
//
// transform a local date to a UTC date.
//
    + (NSDate *)getGTMDateFromDate:(NSDate *)date
        {
            NSTimeInterval timeZoneOffset  = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
            NSTimeInterval gmtTimeInterval = [date timeIntervalSinceReferenceDate] - timeZoneOffset;
            NSDate *resultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
            return resultDate;
        }



    + (NSNumber *)aggregatedOperation:(NSString *)function
                          onAttribute:(NSString *)attributeName
                        withPredicate:(NSPredicate *)predicate
                             onEntity:(NSString *)entityName
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            NSExpression           *ex      = [NSExpression expressionForFunction:function
                                                                        arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:attributeName]]];

            NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
            [ed setName:@"result"];
            [ed setExpression:ex];
            [ed setExpressionResultType:NSInteger64AttributeType];

            NSArray *properties = [NSArray arrayWithObject:ed];

            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setPropertiesToFetch:properties];
            [request setResultType:NSDictionaryResultType];

            if (predicate != nil)
                [request setPredicate:predicate];

            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                                      inManagedObjectContext:context];
            [request setEntity:entity];

            NSArray      *results           = [context executeFetchRequest:request error:nil];
            NSDictionary *resultsDictionary = [results objectAtIndex:0];
            NSNumber     *resultValue       = [resultsDictionary objectForKey:@"result"];
            return resultValue;

        }
#pragma mark - Utilities
//
// Return a base object 
//
// transform a UTC date to a local date.
//
    + (NSDate *)getDateFromGTMDate:(NSDate *)date
        {
            NSTimeInterval timeZoneOffset  = [[NSTimeZone defaultTimeZone] secondsFromGMT];
            NSTimeInterval gmtTimeInterval = [date timeIntervalSinceReferenceDate] + timeZoneOffset;
            NSDate *resultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
            return resultDate;
        }



    + (void)setObjectToFault:(NSManagedObject *)entity
        {
            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];
            [context refreshObject:entity mergeChanges:NO];
        }



//
// This method will migrate manually (i.e. re-create completely) from an existing store to a new store
// it uses the same model.
//
//    + (BOOL)manualMigration:(NSString *)modelName
//                  storeName:(NSString *)storeName
//          toVersionTwoStore:(NSString *)storeTwoName
//                      error:(NSError **)outError
//                 rootObject:(NSString *)rootObject
//                   sortName:(NSString *)sortName
//        {
//            NSManagedObjectContext *srcContext = [self createManagedObjectContext:@"srcContext" storeName:storeName modelName:modelName];

//            NSManagedObjectContext *dstContext = [self createManagedObjectContext:@"dstContext" storeName:storeTwoName modelName:modelName];

//            if (srcContext == nil || dstContext == nil)
//                {
//                    NSLog(@"Can't create the contexts in the migration");
//                    return NO;
//                }
//            NSArray *objects = [AxDataManager dataListEntity:rootObject andSortBy:sortName sortAscending:YES withContext:srcContext];

//            int               count     = 0;
//            int               skipAhead = 1850;
//            for (RealPropInfo *object in objects)
//                {
//                    count++;
//                    if (count < skipAhead)
//                        continue;
//                    NSPredicate  *predicate = [NSPredicate predicateWithFormat:@"realPropId=%d", [object realPropId]];
//                    RealPropInfo *real      = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:predicate andContext:dstContext];
//                    if (real != nil)
//                        continue;
//                    NSLog(@"%d id=%d", count, object.realPropId);
//                    [AxDataManager copyManagedObject:object srcContext:srcContext dstContext:dstContext origin:@"RealPropInfo" indent:0 count:count];
//                    NSError *error = nil;
//                    [dstContext save:&error];
//                    if (error != nil)
//                        {
//                            NSLog(@"%@", [error userInfo]);
//                            return NO;
//                        }
//

//        }



    + (NSManagedObject *)copyManagedObject:(NSManagedObject *)srcObject
                                srcContext:(NSManagedObjectContext *)srcContext
                                dstContext:(NSManagedObjectContext *)dstContext
                                    origin:(NSString *)origin
                                    indent:(int)indent
                                     count:(int)count
        {
            NSString        *name      = NSStringFromClass([srcObject class]);
            NSManagedObject *newEntity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:dstContext];

            // NSString *space = @"";

            // NSLog(@"====================== %@%d '%@' origin='%@'",space, count, name, origin);
            // First pass, copy all the attributes
            NSDictionary *attributes = [[NSEntityDescription entityForName:name inManagedObjectContext:dstContext] attributesByName];

            for (NSString *attr in attributes)
                {
                    [newEntity setValue:[srcObject valueForKey:[attr copy]] forKey:attr];
                }

            // Now copy the relationships
            NSDictionary                   *relationships = [[NSEntityDescription entityForName:name inManagedObjectContext:dstContext] relationshipsByName];
            for (NSRelationshipDescription *rel in relationships)
                {
                    NSString *keyName = [NSString stringWithFormat:@"%@", rel];
                    //get a set of all objects in the relationship
                    @try
                        {
                            if ([name caseInsensitiveCompare:@"Sale"] == NSOrderedSame && [keyName caseInsensitiveCompare:@"SaleParcel"] == NSOrderedSame)
                                continue;

                            NSManagedObject *managedObject = [srcObject valueForKey:keyName];

                            if ([managedObject isKindOfClass:[NSSet class]])
                                {

                                    NSSet        *set       = (NSSet *) managedObject;
                                    NSMutableSet *clonedSet = [newEntity mutableSetValueForKey:keyName];
                                    // NSLog(@"%@Set '%@' (%d objects)", space, keyName, [set count]);

                                    int     setCount = 0;
                                    for (id object in set)
                                        {
                                            NSManagedObject *newObject = [AxDataManager copyManagedObject:object srcContext:srcContext dstContext:dstContext origin:name indent:indent count:++setCount];
                                            [clonedSet addObject:newObject];
                                        }
                                }
                            else
                                {
                                    if ([keyName caseInsensitiveCompare:origin] == NSOrderedSame)
                                        continue;

                                    if ([srcObject valueForKey:keyName] == nil)
                                        continue;

                                    // NSLog(@"%@Relation '%@'",space, keyName);
                                    NSManagedObject *newObject = [AxDataManager copyManagedObject:[srcObject valueForKey:keyName] srcContext:srcContext dstContext:dstContext origin:name indent:indent count:0];
                                    [newEntity setValue:newObject forKey:keyName];

                                }
                        }
                    @catch (NSException *ex)
                        {
                            NSLog(@"Exception: %@", ex);
                        }
                }
            // NSLog(@"%@---------------------- '%@'", space, name);
            return (NSManagedObject *) newEntity;
        }



//
// Copy an object from a src to a dest
//
    + (void)copyManagedObject:(NSManagedObject *)source
                  destination:(NSManagedObject *)destination
                     withSets:(BOOL)sets
                    withLinks:(BOOL)links
        {
            NSManagedObjectContext *context    = [AxDataManager getContext:@"default"];
            NSString               *entityName = [[source entity] name];

            //loop through all attributes and assign then to the clone
            NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName];

            for (NSString *attr in attributes)
                {
                    [destination setValue:[source valueForKey:[attr copy]] forKey:attr];
                }

            //Loop through all relationships, and clone them.
            NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] relationshipsByName];

            for (NSRelationshipDescription *rel in relationships)
                {
                    NSString *keyName = [NSString stringWithFormat:@"%@", rel];
                    //get a set of all objects in the relationship

                    NSObject *object = [source valueForKey:keyName];

                    if ([object isKindOfClass:[NSSet class]] && sets)
                        {

                            NSSet        *sourceSet = [source mutableSetValueForKey:keyName];
                            NSMutableSet *clonedSet = [destination mutableSetValueForKey:keyName];

                            [clonedSet removeAllObjects];   // clean it before doing a copy

                            // Additional layer to avoid the object bein mutated while looping
                            // Not sure why, because the source object is not being mutated
                            int srcCount = [sourceSet count];

                            for (int index = 0; index < srcCount; index++)
                                {
                                    // Get object at position index
                                    NSManagedObject *srcObject;
                                    int             i = 0;
                                    for (srcObject in sourceSet)
                                        {
                                            if (i == index)
                                                break;
                                            i++;
                                        }
                                    // Clone it, and add clone to set
                                    NSManagedObject *clonedRelatedObject = [AxDataManager clone:srcObject];

                                    [clonedSet addObject:clonedRelatedObject];
                                }
                        }
                    else if (links)
                        {
                            if (![EntityBase isRelationBack:entityName property:keyName] && [source valueForKey:keyName] != nil)
                                {
                                    NSManagedObject *clonedRelatedObject = [AxDataManager clone:[source valueForKey:keyName]];
                                    [destination setValue:clonedRelatedObject forKey:keyName];
                                }
                        }
                }

        }



//
// Clone an NSManagedObject
//
    + (NSManagedObject *)clone:(NSManagedObject *)source
        {
            return [AxDataManager clone:source withSets:YES withLinks:YES];
        }



    + (NSManagedObject *)clone:(NSManagedObject *)source
                    andContext:(NSManagedObjectContext *)context
        {
            return [AxDataManager clone:source withSets:YES withLinks:YES andContext:context];
        }



    + (NSManagedObject *)clone:(NSManagedObject *)source
                      withSets:(BOOL)sets
                     withLinks:(BOOL)links
        {
            return [AxDataManager clone:source withSets:sets withLinks:links andContext:[AxDataManager defaultContext]];
        }



    + (NSManagedObject *)clone:(NSManagedObject *)source
                      withSets:(BOOL)sets
                     withLinks:(BOOL)links
                    andContext:(NSManagedObjectContext *)context
        {
            NSString        *entityName = [[source entity] name];
            NSManagedObject *cloned     = [AxDataManager getNewEntityObject:entityName andContext:context];
            [AxDataManager copyManagedObject:source destination:cloned withSets:sets withLinks:links];

            return cloned;
        }



    + (NSArray *)setToArray:(NSSet *)set
        {
            NSMutableArray *unsortedArray = [[NSMutableArray alloc] initWithCapacity:[set count]];

            for (id object in set)
                {
                    if ([object respondsToSelector:@selector(rowStatus)] && [[object rowStatus] isEqualToString:@"D"])
                        continue;
                    [unsortedArray addObject:object];
                }
            return (NSArray *) unsortedArray;
        }



    + (NSArray *)orderArray:(NSMutableArray *)unsortedArray
                   property:(NSString *)property
                  ascending:(BOOL)ascending
        {
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:property ascending:ascending];

            NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
            NSArray *sortedArray = [unsortedArray sortedArrayUsingDescriptors:descriptors];
            descriptors   = nil;
            unsortedArray = nil;

            return sortedArray;
        }



    + (NSArray *)orderSet:(NSSet *)set
                 property:(NSString *)property
                ascending:(BOOL)ascending
        {
            NSMutableArray *unsortedArray = [[NSMutableArray alloc] initWithCapacity:[set count]];

            for (id object in set)
                {
                    if ([object respondsToSelector:@selector(rowStatus)] && [[object rowStatus] isEqualToString:@"D"])
                        continue;
                    [unsortedArray addObject:object];
                }
            return [AxDataManager orderArray:unsortedArray property:property ascending:ascending];
        }

#pragma mark - dispose

    - (void)dealloc
        {

        }
@end


#if 0
#import "RecipesAppDelegate.h"
#import "RecipeListTableViewController.h"
#import "UnitConverterTableViewController.h"

@implementation RecipesAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize recipeListController;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    recipeListController.managedObjectContext = self.managedObjectContext;
    
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}


/**
 * applicationWillTerminate: saves changes in the application's managed object context,
 * before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, 
 * it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created by merging all the models found in the app bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    //    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Recipes" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];    
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];        
    
    return managedObjectModel;
}


/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
	NSString *storePath = [[self applicationDocumentsDirectory] 
                           stringByAppendingPathComponent:@"Recipes.sqlite"];
    [storePath retain];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Recipes" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    //Check to see what version of the current model we're in. If it's >= 2.0, 
    //then and ONLY then check if migration has been performed...
    NSSet *versionIdentifiers = [[self managedObjectModel] versionIdentifiers];
    NSLog(@"Which Current Version is our .xcdatamodeld file set to? %@", versionIdentifiers);
    
    if ([versionIdentifiers containsObject:@"2.0"]) 
    {        
        BOOL hasMigrated = [self checkForMigration];
        
        if (hasMigrated==YES) {
            [storePath release];
            storePath = nil;
            storePath = [[self applicationDocumentsDirectory] 
                         stringByAppendingPathComponent:@"Recipes2.sqlite"];
        }
    }    
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];	
	NSError *error;    
    NSDictionary *pscOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                [NSNumber numberWithBool:NO], NSInferMappingModelAutomaticallyOption,
                                nil];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil 
                                                            URL:storeUrl 
                                                        options:pscOptions 
                                                          error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
    
    return persistentStoreCoordinator;
}


- (BOOL)checkForMigration
{
    BOOL migrationSuccess = NO;
    NSString *storeSourcePath = [[self applicationDocumentsDirectory] 
                                 stringByAppendingPathComponent:@"Recipes2.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
	if (![fileManager fileExistsAtPath:storeSourcePath]) {
        //Version 2 SQL has not been created yet, so the source is still version 1...
        storeSourcePath = [[self applicationDocumentsDirectory] 
                           stringByAppendingPathComponent:@"Recipes.sqlite"];
    }
	
    NSURL *storeSourceUrl = [NSURL fileURLWithPath: storeSourcePath];
	NSError *error = nil;        
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator 
                                    metadataForPersistentStoreOfType:NSSQLiteStoreType 
                                    URL:storeSourceUrl 
                                    error:&error];
    if (sourceMetadata) {
        NSString *configuration = nil;
        NSManagedObjectModel *destinationModel = [self.persistentStoreCoordinator managedObjectModel];
        
        //Our Source 1 is going to be incompatible with the Version 2 Model, our Source 2 won't be...
        BOOL pscCompatible = [destinationModel isConfiguration:configuration compatibleWithStoreMetadata:sourceMetadata];
        NSLog(@"Is the STORE data COMPATIBLE? %@", (pscCompatible==YES) ?@"YES" :@"NO");
        
        if (pscCompatible == NO) {
            migrationSuccess = [self performMigrationWithSourceMetadata:sourceMetadata toDestinationModel:destinationModel];
        }
    }
    else {
        NSLog(@"checkForMigration FAIL - No Source Metadata! \nERROR: %@", [error localizedDescription]);
    }
    return migrationSuccess;
}


- (BOOL)performMigrationWithSourceMetadata :(NSDictionary *)sourceMetadata 
                         toDestinationModel:(NSManagedObjectModel *)destinationModel
{
    BOOL migrationSuccess = NO;
    //Initialise a Migration Manager...
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil 
                                                                    forStoreMetadata:sourceMetadata];
    //Perform the migration...
    if (sourceModel) {
        NSMigrationManager *standardMigrationManager = [[NSMigrationManager alloc] 
                                                        initWithSourceModel:sourceModel 
                                                        destinationModel:destinationModel];
        //Retrieve the appropriate mapping model...
        NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil 
                                                                forSourceModel:sourceModel 
                                                              destinationModel:destinationModel];
        if (mappingModel) {
            NSError *error = nil;
            NSString *storeSourcePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Recipes.sqlite"];
            NSURL *storeSourceUrl = [NSURL fileURLWithPath: storeSourcePath];
            NSString *storeDestPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Recipes2.sqlite"];
            NSURL *storeDestUrl = [NSURL fileURLWithPath:storeDestPath];
            
            //Pass nil here because we don't want to use any of these options:
            //NSIgnorePersistentStoreVersioningOption, NSMigratePersistentStoresAutomaticallyOption, or NSInferMappingModelAutomaticallyOption
            NSDictionary *sourceStoreOptions = nil;
            NSDictionary *destinationStoreOptions = nil;
            
            migrationSuccess = [standardMigrationManager migrateStoreFromURL:storeSourceUrl 
                                                                        type:NSSQLiteStoreType
                                                                     options:sourceStoreOptions 
                                                            withMappingModel:mappingModel 
                                                            toDestinationURL:storeDestUrl 
                                                             destinationType:NSSQLiteStoreType 
                                                          destinationOptions:destinationStoreOptions 
                                                                       error:&error];
            NSLog(@"MIGRATION SUCCESSFUL? %@", (migrationSuccess==YES)?@"YES":@"NO");
        }
    }   
    else {
        //TODO: Error to user...
        NSLog(@"checkForMigration FAIL - No Mapping Model found!");
        abort();    
    }
    return migrationSuccess;
}//END


#pragma mark -
#pragma mark Application's documents directory

/**
 * Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [recipeListController release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end
#endif
