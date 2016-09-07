
#import <Foundation/Foundation.h>

@interface AzureContainer : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *etag;
@property (nonatomic, strong)NSString *lastModifiedDate;
@property (nonatomic, strong)NSString *url;
@property (nonatomic, strong)NSMutableArray *blobs;

-(id)init:(id)containerObject;
-(unsigned long long)getLength;

@end
