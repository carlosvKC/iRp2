#import <Foundation/Foundation.h>
//
// migration class
//

@interface DumpEntities : NSObject
{
    NSMutableArray  *entities;
    
    // List of definitions from the pList
    NSMutableArray *definitions;
    NSMutableArray *keys;
    
    // file name
    NSString *fileName;
    
    // current text
    NSMutableString *destString;
}
-(id)initWith:(NSString *)root;
-(void)dumpEntity:(NSString *)entity isRoot:(BOOL)isRoot;
-(void)dumpAttr:(NSString *)root withAttribute:(NSString *)attrName withAttr:(id)attribute withObject:(id)source;
-(void)describeRelation:(NSString *)root withAttribute:(NSString *)attrName withRelation:(id)relation withObject:(id)object;
-(void)dumpRelation:(NSString *)root withAttribute:(NSString *)attrName withRelation:(id)relation withObject:(id)object;
-(void)retrieveExistingEntities;
-(void)dumpObjects;
@end
