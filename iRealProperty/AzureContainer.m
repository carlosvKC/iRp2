

#import "AzureContainer.h"
#import "AzureBlob.h"


@implementation AzureContainer

@synthesize name;
@synthesize etag;
@synthesize lastModifiedDate;
@synthesize url;
@synthesize blobs;



//
// Constructor of the class
//
-(id)init:(id)containerObject
{
    self= [super init];
    if (self)
    {
        @try 
        {
            if ([containerObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dic = containerObject;
                self.name = [dic objectForKey:@"Name"];
                self.url = [dic objectForKey:@"Url"];
                NSDictionary *props = [dic objectForKey:@"Properties"];
                if (props != nil) 
                {
                    self.etag = [props objectForKey:@"Etag"];
                    self.lastModifiedDate = [props objectForKey:@"Last-Modified"];
                }
            }
            self.blobs = [[NSMutableArray alloc]init];
        }
        @catch (NSException *ex)
        {
            NSLog(@"AzureContainer Init exception: %@", ex);
        }
    }
    
    return self;
}



-(unsigned long long)getLength
{
    unsigned long long length = 0;
            if (blobs != nil)
                {
        for (AzureBlob *actBlob in blobs) 
        {
            length += actBlob.length;
        }
    }
    return length;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Blob count='%i', Name=%@ eTag=%@ url=%@",[blobs count], self.name,  etag, url];
}


@end
