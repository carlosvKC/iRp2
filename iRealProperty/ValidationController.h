
#import <Foundation/Foundation.h>
#import "ValidationError.h"
@interface ValidationController : NSObject

@property(nonatomic,strong) NSMutableArray *validations;    // All the validations error for all controllers

+(ValidationController *)validation;
+(void)clearAll;
-(void)addError:(id)object type:(int)type description:(NSString *)message item:(ItemDefinition *)item index:(int)index;
-(int)countErrors:(id)object;
-(int)countWarnings:(id)object;
-(NSArray *)errorList:(id)object;
-(void)clearError:(id)target index:(int)index;
@end
