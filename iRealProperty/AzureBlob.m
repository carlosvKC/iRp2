
#import "AzureBlob.h"

@implementation AzureBlob

@synthesize name;
@synthesize type;
@synthesize length;
@synthesize contentType;
@synthesize eTag;
@synthesize lastModifiedDate;
@synthesize leaseStatus;
@synthesize url;


//
// Constructor of the class
//
-(id)init:(id)blobObject
{
    self= [super init];
    if (self)
    {
        @try
        {
            if ([blobObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dic = blobObject;
                self.name = [dic objectForKey:@"Name"];
                self.url = [dic objectForKey:@"Url"];
                NSDictionary *props = [dic objectForKey:@"Properties"];
                if (props != nil) 
                {
                    self.eTag = [props objectForKey:@"Etag"];
                    self.lastModifiedDate = [props objectForKey:@"Last-Modified"];
                    self.type = [props objectForKey:@"BlobType"];
                    if ([[props allKeys]containsObject:@"Content-Length"])
                    {
                        self.length = [[props objectForKey:@"Content-Length"] longLongValue];
                    }
                    self.contentType = [props objectForKey:@"Content-Type"];
                    self.leaseStatus = [props objectForKey:@"LeaseStatus"];
                }
            }
        }
        @catch (NSException *ex)
        {
            NSLog(@"AzureBlob Init exception: %@", ex);
        }
    }
    
    return self;
}

@end
