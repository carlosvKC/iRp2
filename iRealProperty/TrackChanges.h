#import <Foundation/Foundation.h>

@class NSManagedObject;


// This class is a simple map to the existing change
@interface Change : NSObject   

@property(nonatomic, strong) NSString *className;        // Name of the class that has changed
@property(nonatomic, strong) NSNumber *uniqueId;                        // A unique ID that uniquely identifies the class that has changed
@property(nonatomic, strong) NSString *operation;   // CRUD operation performed on the class
@property(nonatomic, strong) NSDate *date;          // date of the operation in GLOBAL time
@end


@interface TrackChanges : NSObject

// Return a new ID for a specific
+(int) getNewId:(NSManagedObject *)object;


#ifdef COMPLEX_WAY
// Return a unique new ID for the class name
+(NSNumber *) getNewId:(NSString *)className;
// Return the name of the property that is the ID for that class
+(NSNumber *)getCurrentId:(id)classObject;
// Return the name of the object
+(NSNumber *)getNewIdFromObject:(id)classObject;

// Update automatically the property with a class name
+(void) updateClassWithNewId:(id)classObject;
// Commit the changes (the object is being saved)
+(void) commit;
// Undo the changes (the user has done an undo)
+(void) undo;
// Record the change
+(void) recordChange:(id)classObject operation:(NSString *)operation;

+(void)instantiateChanges:(NSDictionary *)classDict;
#endif

@end
