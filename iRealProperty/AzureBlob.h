
#import <Foundation/Foundation.h>

@interface AzureBlob : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* type;
@property (nonatomic) int64_t length;
@property (nonatomic, strong) NSString* contentType;
@property (nonatomic, strong) NSString* eTag;
@property (nonatomic, strong) NSString* lastModifiedDate;
@property (nonatomic, strong) NSString* leaseStatus;
@property (nonatomic, strong) NSString* url;

-(id)init:(id)blobObject;

@end
