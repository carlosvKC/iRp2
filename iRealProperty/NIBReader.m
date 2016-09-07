
#import "NIBReader.h"
#import "XMLReader.h"


@implementation NIBObject

@synthesize frame, tag, subviews, altFrame;
-(NSString *)description
{
    return [NSString stringWithFormat:@"tag=%d frame=%@ altframe=%@ subviews=%d",tag,NSStringFromCGRect(frame),NSStringFromCGRect(altFrame), [subviews count]]; 
}
@end

@implementation NIBReader
//
// Case where the XML (copied from the NIB) contains both the 2 views:
// tag = 1000 is for the portrait while 2000 is the landscape
//
-(id)initWithNibName:(NSString *)name
{
    self = [super init];
    
    if(self)
    {
        NSError *error = nil;
        objectName = name;
        
        NSDictionary *xmlDict = [XMLReader dictionaryForURL:name error:&error];
        
        if(xmlDict==nil)
        {
            return self;
        }
        
        id dict = [[xmlDict objectForKey:@"archive"]objectForKey:@"data"];
        
        id array = [dict objectForKey:@"array"];
        
        for(NSDictionary *objDict in array)
        {
            // Look for object with the key="IBDocuments.RootObjects"
            NSString *string = [objDict objectForKey:@"@key"];
            if([string length]==0)
                continue;
            if([string isEqualToString:@"IBDocument.RootObjects"])
            {
                // Retrieve the "object" type
                NSArray *objectArray = [objDict objectForKey:@"object"];
                
                for(NSDictionary *objectDict in objectArray)
                {
                    NSString *string = [objectDict objectForKey:@"@class"];
                    if([string length]==0)
                        continue;
                    if([string isEqualToString:@"IBUIView"])
                    {
                        NIBObject *nibObject = [[NIBObject alloc]init];
                        // add it to the list of current dictionary of views

                        [self addIBUIView:objectDict nibObject:nibObject];
                        if(nibObject.tag==1000)
                            portraitView = nibObject;
                        else if(nibObject.tag==2000)
                            landscapeView = nibObject;
                    }
                }
                xmlDict = nil;
                [self mergeViews:portraitView landscape:landscapeView];
                
                return self;
            }
        }
        
    }
    return self;
}
//
// In that case the portrait XML is in the first file while the landscape XML is in the second
//
-(id)initWithNibName:(NSString *)portrait portraitId:(int)pId landscape:(NSString *)landscape landscapeId:(int)lId
{
    self = [super init];
    objectName = portrait;
    
    portraitView = [self loadNBFromXML:portrait tagId:pId];
    landscapeView = [self loadNBFromXML:landscape tagId:lId];
    
    if(portraitView==nil )
    {
        NSLog(@"objectName=%@ Can't find portraitView",objectName);
    }
    if(landscapeView==nil )
    {
        NSLog(@"objectName=%@ Can't find landscape",objectName);
    }
    [self mergeViews:portraitView landscape:landscapeView];
    return self;
    
}

-(id)initWithNibName:(NSString *)portrait landscape:(NSString *)landscape
{
    return [self initWithNibName:portrait portraitId:1000 landscape:landscape landscapeId:1000];
}

-(NIBObject *)loadNBFromXML:(NSString *)fileName tagId:(int)tagId
{
    NSError *error = nil;

    
    NSDictionary *xmlDict = [XMLReader dictionaryForURL:fileName error:&error];
    
    if(xmlDict==nil)
        return nil;
    
    id dict = [[xmlDict objectForKey:@"archive"]objectForKey:@"data"];
    id array = [dict objectForKey:@"array"];
    for(NSDictionary *objDict in array)
    {
        // Look for object with the key="IBDocuments.RootObjects"
        NSString *string = [objDict objectForKey:@"@key"];
        if([string length]==0)
            continue;
        if([string isEqualToString:@"IBDocument.RootObjects"])
        {
            // Retrieve the "object" type
            NSArray *objectArray = [objDict objectForKey:@"object"];
            
            for(NSDictionary *objectDict in objectArray)
            {
                NSString *string = [objectDict objectForKey:@"@class"];
                if([string length]==0)
                    continue;
                if([string isEqualToString:@"IBUIView"])
                {
                    NIBObject *nibObject = [[NIBObject alloc]init];
                    // add it to the list of current dictionary of views
                    
                    [self addIBUIView:objectDict nibObject:nibObject];
                    if(nibObject.tag==tagId)
                    {
                        xmlDict = nil;
                        return nibObject;
                    }
                }
            }
        }
    }
    return nil;
}

//
// Add a complete subview hierarchy that might multiple views
//
-(void)addIBUIView:(NSDictionary *)dict nibObject:(NIBObject *)nibObject
{
    id intArray = [dict valueForKey:@"int"];
    int tag;
    CGRect frame;
    
    if(![intArray isKindOfClass:[NSArray class]])
    {
        NSString *string = [intArray objectForKey:@"@key"];        
        if([string isEqualToString:@"IBUITag"])
        {
            tag = [[intArray objectForKey:@"text"]intValue];
        }
    }
    
    else
    {
        // Look for the "int" tag
        for(NSDictionary *objDict in intArray)
        {
            @try
            {
                NSString *string = [objDict objectForKey:@"@key"];
                if(![string isKindOfClass:[NSString class]])
                {
                    NSLog(@"Did not get a string");
                }

                if([string length]==0)
                    continue;
                if([string isEqualToString:@"IBUITag"])
                {
                    tag = [[objDict objectForKey:@"text"]intValue];
                    break;
                }
            }
            @catch (NSException *exeption) {
            }
        }
    }
    NSArray *stringArray = [dict valueForKey:@"string"];
    
    // look for the frame or framesize
    for(NSDictionary *objDict in stringArray)
    {
        @try
        {
            NSString *string = [objDict objectForKey:@"@key"];
            if(![string isKindOfClass:[NSString class]])
            {
                NSLog(@"Did not get a string");
            }        
            if([string length]==0)
                continue;
        

            if([string isEqualToString:@"NSFrameSize"])
            {
                CGSize size = CGSizeFromString([objDict objectForKey:@"text"]);
                frame = CGRectMake(0, 0, size.width, size.height);
                break;
            }
            else if([string isEqualToString:@"NSFrame"])
            {
                frame = CGRectFromString([objDict objectForKey:@"text"]);
                break;
            }
        }
        @catch(NSException *exception)
        {

        }
    }
    nibObject.tag = tag;
    nibObject.frame = frame;
    nibObject.subviews = nil;
    
   
    id arrays = [dict valueForKey:@"array"];
    if(arrays==nil)
    {
        return;
    }
    // Subviews
    nibObject.subviews = [[NSMutableArray alloc]init];
    NSDictionary *objDict = arrays;

    if([objDict isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *objDict in arrays)
        {
            [self addSubviews:objDict nibObject:nibObject];
        }
    }
    else
    {
        [self addSubviews:objDict nibObject:nibObject]; 
    }

}
-(void)addSubviews:(NSDictionary *)objDict nibObject:(NIBObject *)nibObject
{
    NSString *string = [objDict objectForKey:@"@key"];
    if(![string isKindOfClass:[NSString class]])
    {
        NSLog(@"Did not get a string");
    } 
    
    
    if([string length]>0 && [string isEqualToString:@"NSSubviews"])
    {
        id objectsArray = [objDict valueForKey:@"object"];
        
        if([objectsArray isKindOfClass:[NSArray class]])
        {
            
            for(NSDictionary *objDict in objectsArray)
            {
                NIBObject *subObject = [[NIBObject alloc]init];
                [self addIBUIView:objDict nibObject:subObject];
                [nibObject.subviews addObject:subObject];
            }
        }
        else
        {
            NIBObject *subObject = [[NIBObject alloc]init];
            [self addIBUIView:objectsArray nibObject:subObject];
            [nibObject.subviews addObject:subObject];
        }
    }
}

-(void)dumpViews:(NIBObject *)object
{
    NSLog(@"%@Tag=%d Frame=%@ altFrame=%@",@"", object.tag,NSStringFromCGRect(object.frame), NSStringFromCGRect(object.altFrame));
    [self dumpViews:object.subviews header:@""];          
}

-(void)dumpViews:(NSArray *)subs header:(NSString *)header
{
    for(NIBObject *object in subs)
    {
        NSLog(@"%@Tag=%d Frame=%@ altFrame=%@",header, object.tag,NSStringFromCGRect(object.frame), NSStringFromCGRect(object.altFrame));
        if(object.subviews!=nil)
        {
            [self dumpViews:object.subviews header:[NSString stringWithFormat:@"%@  ", header]];
        }
    }
}

// Merge the views from portrait and landscape to landscape and destroy the other
-(void)mergeViews:(NIBObject *)portrait landscape:(NIBObject *)landscape
{
    // must have the same ID except for the 1000/2000 views
    if(portrait.tag == landscape.tag || (portrait.tag==1000 && landscape.tag==2000))
        portrait.altFrame = landscape.frame;
    else
    {
        NSLog(@"Error in '%@': view %d in portrait does not match %d in landscape",objectName,portrait.tag,landscape.tag);
        return;
    }
    
    if([portrait.subviews count]!=0)
    {
        // go down...
        NSArray *portraitArray = portrait.subviews;
        NSArray *landscapeArray = landscape.subviews;
        
        for(NIBObject *portraitObject in portraitArray)
        {
            // Find the corresponding object in landscape
            bool found = NO;
            for(NIBObject *landscapeObj in landscapeArray)
            {
                if(landscapeObj.tag==portraitObject.tag)
                {
                    found = YES;
                    [self mergeViews:portraitObject landscape:landscapeObj];
                    break;
                }
            }
            if(!found)
            {
                NSLog(@"***Error: tag=%d is not found in landscape",portraitObject.tag);
            }
        }
    }
    landscapeView = nil;
}
-(void)rotateViews:(UIView *)view landscapeMode:(BOOL)landscapeMode
{
    [self rotateViews:view landscapeMode:landscapeMode nibObject:portraitView];
}
-(void)rotateViews:(UIView *)view landscapeMode:(BOOL)landscapeMode nibObject:(NIBObject *)nibObject
{
    UIView *subview = [view viewWithTag:nibObject.tag];
    if(subview==nil)
    {
        // NSLog(@"RotateViews: can't find view with tag %d", nibObject.tag);
        return;
    }
    CGRect newFrame = landscapeMode?nibObject.altFrame:nibObject.frame;
    // NSLog(@"Rotate %d from %@ to %@", subview.tag, NSStringFromCGRect(subview.frame), NSStringFromCGRect(newFrame));
    subview.frame = newFrame;

    for(NIBObject *object in nibObject.subviews)
    {
        [self rotateViews:subview landscapeMode:landscapeMode nibObject:object];
    }
}
@end
