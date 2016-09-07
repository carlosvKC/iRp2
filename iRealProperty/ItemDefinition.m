
#import "ItemDefinition.h"
#import "StreetDataModel.h"
#import "Helper.h"
#import "RealProperty.h"
#import "EntityBase.h"
#import "EntityStructure.h"

@implementation ItemDefinition

@synthesize tag;
@synthesize type = _type;
@synthesize length;
@synthesize lookup;
@synthesize path;
@synthesize entityName;
@synthesize labelName;
@synthesize width;
@synthesize maxWidth;
@synthesize tableAttribute;
@synthesize filterOptions;
@synthesize label;
@synthesize alphaSorted;
@synthesize autoField, editLevel, required;
//cv
@synthesize maxPercentValue, percentIncrement;
@synthesize maxPercentValueNeg, percentIncrementNeg;
@synthesize actionMethod;
static int districtId;

-(NSString *)description
{
    return [NSString stringWithFormat:@"{ labelName='%@'\nentityName='%@'\npath='%@'\ntag=%d\ntype=%d\nlookup=%d\nalphaSorted=%d\nwidth=%f }", labelName, entityName, path, tag, _type, lookup, alphaSorted,width];
}
+(void)setDistrictId:(int)d
{
    districtId = d;
}
//
// Format a number with separator
//
+(NSString *)formatNumber :(int)value
{
    
    NSString *str = [NSString stringWithFormat:@"%d", value];
    
    char dest[256];    
    char *destPtr = dest+255;
    const char *srcPtr = [str UTF8String];
    srcPtr += [str length];
    
    *destPtr = 0;
    int count = 0;
    for(int i=0;i<[str length];i++)
    {
        *--destPtr = *--srcPtr;
        count++;
        if(count==3 && i<[str length]-1)
        {
            *--destPtr = ',';
            count = 0;
        }
    }
    str = [[NSString alloc]initWithUTF8String: destPtr];
    return str;
}


// Return the object for complex path
// 
+(id)objectWithComplexPath:(NSManagedObject *)baseEntity property:(NSString *)propertyName
{
    if(baseEntity==nil)
        return nil;
    // do the split using 
    
    // Loops through the different separators
    NSArray *paths = [self splitWithDot:propertyName];
    
    NSString *baseName = NSStringFromClass([baseEntity class]);
    @try
    {
        int index = 0;
        // Case where the baseEntity is the first element of the propertyName
        if([baseName caseInsensitiveCompare:[paths objectAtIndex:0]]==NSOrderedSame)
            index = 1;
        // Loop through each object
        for(;index<[paths count];index++)
        {
            // NSString *relationName = [EntityBase findRelationInObject:baseEntity entityName:[paths objectAtIndex:index]];
            baseEntity =  [ItemDefinition valueFromObject:baseEntity path:[paths objectAtIndex:index]];     //[baseEntity valueForKey:relationName];
            if(baseEntity==nil)
                return nil;
            // Special case where the baseEntity is an NSSet
            if([baseEntity isKindOfClass:[NSSet class]])
            {
                // Check to see what is the next parameter (if any)
                if(index < [paths count]-1)
                {
                    NSString *next = [paths objectAtIndex:index+1];
                    if([next isEqualToString:@"@count"])
                    {
                        NSSet *set;
                        set = (NSSet *)baseEntity;
                        NSNumber *number = [[NSNumber alloc]initWithInt:[set count]];
                        return number;
                    }
                }
                // if the set is empty
                if([(NSSet *)baseEntity count]==0)
                    return nil;
                // Then take any object since we don't know which one to take
                if(index+1==[paths count])
                    return baseEntity;
                baseEntity = [(NSSet *)baseEntity anyObject];
            }
        }
        return baseEntity;
    }
    @catch (NSException *exception)
    {
        // NSLog(@"getItemValue exception (%@) '%@'", exception, propertyName);
        return nil;
    }
    return nil;
}
+(NSArray *)splitWithDot:(NSString *)source
{
    const char *src = [source UTF8String];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    char buffer[1024];
    
    char *dest = buffer;
    int index = 0;
    while(*src!=0 && index < sizeof(buffer)-10)
    {
        if(*src=='[')
        {
            // Copy everything 'til the end
            while(*src!=0 && *src!=']' && index < sizeof(buffer)-10)
            {
                *dest++ = *src++;
                index++;
            }
            if(*src==']')
                *dest++ = *src++;
            continue;
        }
        else if(*src=='.')
        {
            *dest = 0;
            NSString *str = [NSString stringWithCString:buffer encoding:NSStringEncodingConversionAllowLossy];
            if(str.length>0)
                [array addObject:str];
            dest = buffer;
            index = 0;
            src++;
        }
        else
        {
            *dest++ = *src++;
            index++;
        }
    }
    *dest = 0;
    NSString *str = [NSString stringWithCString:buffer encoding:NSStringEncodingConversionAllowLossy];
    if(str.length>0)
        [array addObject:str];
    return array;
}
//
// Internal function -- if the object is NSSet and contains an expression between [ ], evaluate that expression
// on the current object
//
+(id)valueFromObject:(NSManagedObject *)baseEntity path:(NSString *)aPath
{
    NSRange startRange = [aPath rangeOfString:@"["];
    if(startRange.location == NSNotFound)
    {
        aPath = [aPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSArray* properties = [[baseEntity entity] properties];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", aPath];
        NSArray *filteredArray = [properties filteredArrayUsingPredicate:predicate];
        if ([filteredArray count] == 0)
        {
            return nil;
        }
        
        // This is an object without filtering.
        return [baseEntity valueForKeyPath:aPath];
    }
    aPath = [aPath stringByReplacingOccurrencesOfString:@"->" withString:@"."];
    NSString *setName = [aPath substringToIndex:startRange.location];
    baseEntity = [baseEntity valueForKey:setName];
    // The object must be of type NSSet
    if(![baseEntity isKindOfClass:[NSSet class]])
    {
        NSLog(@"Error: %@ must be a set!!!!", setName);
        return nil;
    }
    // Else evaluates the expression
    NSRange endRange = [aPath rangeOfString:@"]"];
    if(endRange.location == NSNotFound)
        return nil;
    startRange.length = (endRange.location - startRange.location)-1;
    startRange.location++;
    NSString *expression = [aPath substringWithRange:startRange];

    // Replace the expression with real value
    NSSet *set = (NSSet *)baseEntity;
    NSEnumerator *enumerator = [set objectEnumerator];
    
    // Check if the expression starts with a MAX or MIN
    if([expression hasPrefix:@"MAX("] || [expression hasPrefix:@"MIN("] || [expression hasPrefix:@"FLR("] || [expression hasPrefix:@"SUM("])
    {

        // Get the expression inside the parenthesis
        NSRange range;
        range.location = 4;
        range.length = [expression length] - 5;
        NSString *property = [expression substringWithRange:range];
        
        double min, max, floor, sum = 0;
        BOOL firstLoop = YES;
        NSTimeInterval minDate = [[Helper localDate]timeIntervalSinceReferenceDate];
        NSTimeInterval maxDate = 0;
        id entity, minEntity = nil, maxEntity = nil, floorEntity = nil;
        while((entity=[enumerator nextObject])!=nil)
        {
            id value = [entity valueForKey:property];
            
            if([value isKindOfClass:[NSNumber class]])
            {
                if(firstLoop)
                {
                    firstLoop = NO;
                    min = [value doubleValue];
                    max = min;
                    floor = min;
                    minEntity = entity;
                    maxEntity = entity;
                    floorEntity= entity;
                    sum = 0;
                }
                
                if([value doubleValue] < min)
                {
                    min = [value doubleValue];
                    minEntity = entity;
                }
                if(([value doubleValue] < floor && [value doubleValue]!=0) || floor == 0)
                {
                    floor = [value doubleValue];
                    floorEntity = entity;
                }
                if([value doubleValue] > max)
                {
                    max = [value doubleValue];
                    maxEntity = entity;
                }
                sum += [value doubleValue];
            }
            else if([value isKindOfClass:[NSDate class]])
            {
                if([value timeIntervalSinceReferenceDate] < minDate)
                {
                    minDate = [value timeIntervalSinceReferenceDate];
                    minEntity = entity;
                }
                if([value timeIntervalSinceReferenceDate] > maxDate)
                {
                    maxDate = [value timeIntervalSinceReferenceDate];
                    maxEntity = entity;
                }
            }        
        }
        if([expression hasPrefix:@"MAX("])
            return maxEntity;
        if([expression hasPrefix:@"MIN("])
            return minEntity;
        if([expression hasPrefix:@"FLR("])
            return floorEntity;
        if([expression hasPrefix:@"SUM("])
        {
            NSNumber *total = [[NSNumber alloc]initWithDouble:sum];
            return total;
        }
    }
    else
    {
        // Evaluate the operator
        id entity;
        NSMutableSet *resultSet = [[NSMutableSet alloc]init];
        while((entity=[enumerator nextObject])!=nil)
        {
            int res = [ItemDefinition checkValuesInPredicate:expression baseEntity:entity];
            if(res==1)
            {
                // Entity matches
                [resultSet addObject:entity];
            }

            if(res== -1)
            {
                // major error, abandon
                return nil;
            }
        }
        return resultSet;
    }
    return nil;
}
//
// Evaluate an expression. The result of the expression is then evaluated against the list of results and the results is returned.
// 
// input:
//  the path expression to evaluate. Syntax: @evaluate:<rest of the expression>
//  the different results (separated by ;): $result=0;<expression>;$result=1;<expression> etc
// 
+(id)evaluateExpression:(NSString *)expression baseEntity:(NSManagedObject *)baseEntity
{

    NSArray *array = [expression componentsSeparatedByString:@"~"];
    if([array count]<2)
        return nil;
    // Expression must be divided in 3
    NSString *operation = [[array objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([operation hasPrefix:@"@if("])
    {
        operation = [operation substringFromIndex:4];
        operation = [operation substringToIndex:operation.length -2];
    }
    else
    {
        return nil;
    }
    NSArray *parts = [operation componentsSeparatedByString:@";"];
    NSMutableArray *components = [[NSMutableArray alloc]initWithArray:parts];
    
    while([components count]<3)
    {
        [components addObject:@""];
    }
    
    id object = [ItemDefinition getItemValue:baseEntity withPath:[array objectAtIndex:0] withType:0 withLookup:0];
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:object, @"result", nil];
    
    int result;
    @try 
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[parts objectAtIndex:0]];
        result = [predicate evaluateWithObject:nil substitutionVariables:dict];

    }
    @catch (NSException *exception) 
    {
        NSLog(@"Error in @if string is not correctly built");
        return nil;
    }
    
    switch(result)
    {
        case -1:
            NSLog(@"Error while evaluating '%@'", expression);
            return nil;
        case 0:
            return [components objectAtIndex:2];
        case 1:
            return [components objectAtIndex:1];
    }

    return nil;
}

//
//
// -1 error in the predicate or format
// 0 error
// 1 no error
+(int)checkValuesInPredicate:(NSString *)string baseEntity:(NSManagedObject *)baseEntity
{
    NSLock *lock = [[NSLock alloc]init];
    [lock lock];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    // Search for all the variables that start with a $
    const char *str = [string UTF8String];
    
    while(*str!=0)
    {
        if(*str=='$')
        {
            // mark the beginning of a new string
            str++;
            char buffer[512];
            char *t = buffer;
            
            while(*str!=' ' && *str!='<' && *str!='>' && *str!='!' && *str!='=' && *str!=0)
                *t++ = *str++;
            *t = 0;
            NSString *var = [NSString stringWithUTF8String:buffer];

            @try 
            {
                id value;
                if([var characterAtIndex:0]=='_')
                {
                    NSString *name = [var substringFromIndex:1];
                    value = [baseEntity valueForKeyPath:name];
                }
                else
                    value = [baseEntity valueForKeyPath:var];
                if(value==nil)
                {
                    value = [NSNumber numberWithBool:NO];
                }
                [dict setValue:value forKey:var];
            }
            @catch (NSException *exception) 
            {
                [lock unlock];
                NSString *message = [NSString stringWithFormat:@"'%@' is not a valid property", var];
                [Helper alertWithOk:@"Error in validation" message:message];
                return -1;
            }
        }
        else
        {
            str++;
        }
    }
    [lock unlock];
    NSPredicate *predicate;
    @try 
    {
        predicate = [NSPredicate predicateWithFormat:string];
        predicate = [predicate predicateWithSubstitutionVariables:dict];
        BOOL res = [predicate evaluateWithObject:baseEntity];           // [predicate evaluateWithObject:baseEntity substitutionVariables:dict];
        return res;
    }
    @catch (NSException *exception) 
    {
        NSLog(@"'%@' is not correctly built (%@)", string, predicate);
        return -1;
    }
    return 0;
}

//
// Return the string of an object.
//
// An object class can be represented between { }
+(NSString *)getStringValue:(NSManagedObject *)baseEntity withPath:(NSString *)aPath withType:(int)aType withLookup:(int)lookup
{
    NSRange range = [aPath rangeOfString:@"{"];
    if(range.length==0)
    {
        // No composite, returns quickly
        id object = [ItemDefinition getItemValue:(NSManagedObject *)baseEntity withPath:(NSString *)aPath withType:(int)aType withLookup:(int)lookup];
        return [ItemDefinition convertObjectToString:object withType:aType];
    }
    // the path is built with subpaths. Each sub path is between { and }
    NSRange openRange, closeRange;

    while(TRUE)
    {
        range.length = aPath.length;
        range.location = 0;

        openRange = [aPath rangeOfString:@"{" options:NSLiteralSearch range:range];
        if(openRange.length==0)
            break;
        
        range.location = openRange.location+1;
        range.length = aPath.length - range.location;
        
        closeRange = [aPath rangeOfString:@"}" options:NSLiteralSearch range:range];
        
        if(closeRange.length==0)
        {
            NSLog(@"'%@' missing the closing }", aPath);
            break;
        }
        range.location = openRange.location + 1;
        range.length = closeRange.location-1 - openRange.location;

        NSString *subPath = [aPath substringWithRange:range];
        PropertyDef *prop = [EntityBase findProperty:NSStringFromClass([baseEntity class]) property:subPath];
        id object = [ItemDefinition getItemValue:(NSManagedObject *)baseEntity withPath:subPath withType:(int)prop.type withLookup:prop.lookup];
        NSString *str = [ItemDefinition convertObjectToString:object withType:aType];
        
        range.location = openRange.location;
        range.length = closeRange.location - openRange.location + 1;
        if (str == nil)
        {
            return @"";     //oh
        }
        else
            {
                aPath = [aPath stringByReplacingCharactersInRange:range withString:str];
                //major-minor                
            }
        
        
    }
    return aPath;
}

+(NSString *)convertObjectToString:(id)object withType:(int)aType
{
    NSNumber *number = object;
    NSString *string = object;
    NSDate *date = object;
    // Setup the type
    switch (aType) 
    {
        case ftTextL:
            return string;
            break;
            
        case ftURL:
        case ftText:
            if([object isKindOfClass:[NSNumber class]])
                return [NSString stringWithFormat:@"%d",[object intValue]];
            else if([object isKindOfClass:[NSDate class]])
                return [Helper stringFromDate:object];
            else
                return string;
            break;
            
        case ftBool:
            if([number intValue]>0)
                return @"YES";
            else
                return @"NO";
            break;
        case ftFloat:
            return [NSString stringWithFormat:@"%0.2f",[number floatValue]];
            break;
        case ftPercent:
            return [NSString stringWithFormat:@"%d%\%",[number intValue]];
            break;
        case ftNum:
            return [NSString stringWithFormat:@"%d",[number intValue]];
            break;
        case ftInt:
            return [NSString stringWithFormat:@"%d",[number intValue]];
            break;
        case ftCurr:
            return [ItemDefinition formatNumber:[number intValue]];
            break;
        case ftDate:
            return [Helper stringFromDate:date];
            break;
        case ftYear:
            return [NSString stringWithFormat:@"%d",[number intValue]];
            break;
        default:
            return object;
    }
    return @"";
}

+(id)getItemValue:(NSManagedObject *)baseEntity withPath:(NSString *)aPath withType:(int)aType withLookup:(int)lookup
{
    @try
    {
        aPath = [ItemDefinition replaceDateFilter:aPath];

        NSRange range = [aPath rangeOfString:@"~"];
        if(range.length >0)
            return [ItemDefinition evaluateExpression:aPath baseEntity:baseEntity];
        
        if(aType==ftLookup)
        {
            int suffix = 0;
            NSString *dest = aPath;
            if([aPath hasSuffix:@".lookup"])
            {
                dest = [aPath stringByReplacingOccurrencesOfString:@".lookup" withString:@""];
                suffix = 1;
            }
            else if([aPath hasSuffix:@".desc"])
            {
                dest = [aPath stringByReplacingOccurrencesOfString:@".desc" withString:@""];
                suffix = 2;
            }
            id object = [ItemDefinition objectWithComplexPath:baseEntity property:dest];
            
            NSNumber *number = object;
            if(suffix==1)
            {
                // Return the number only
                return [NSString stringWithFormat:@"%d", [number intValue]];
            } 
            else if(suffix==2 && lookup>0)
            {
                // Return the string only
                return [LUItems2 LUItemFromTypeId:lookup itemId:[number intValue]];
            }
            else
            {
                // Normal lookup
                if(lookup>0)
                {
                    return [LUItems2 LUItemFromTypeId:lookup itemId:[number intValue]];
                }
                else if(lookup== -1)
                {
                    // Lookup using the street information
                    return [StreetDataModel getStreetNameFromStreetId:[number intValue]];
                }
                else if(lookup== -2)
                {
                    int value = [number intValue];

                    NSArray *items = [LUItems2 LUItemsFromLookup:(int)lookup districtId:districtId];
                    
                    for(LUItems2 *item in items)
                    {
                        if(item.LUItemId == value)
                        {
                            return item.LUItemShortDesc;
                        }
                    }
                    return @"";
                }
            }
        }
        return [ItemDefinition objectWithComplexPath:baseEntity property:aPath];

    }
    @catch (NSException *exception) 
    {
        // NSLog(@"getItemValue exception (%@) '%@'", exception, aPath);
        return nil;
    }
}
+(NSString *)replaceDateFilter:(NSString *)aPath
{
    
    
    
    NSRange dateRange = [aPath rangeOfString:@"#DATE("];
    
    
    if(dateRange.length>0)
    {
        // Expect to find NSDATE(01/01/10). This is replaced by the CAST(double value, NSDATE)
        int index = 6;
        const char *src = [aPath UTF8String];
        src += dateRange.location + 6;
        char buffer[256];
        char *dest = buffer;
        while(*src && *src!=')' && index<64)
        {
            *dest++ = *src++;
            index++;
        }
        *dest = 0;
        index++;
        NSString *dateStr = [NSString stringWithCString:buffer encoding:NSStringEncodingConversionAllowLossy];
        
        NSDate *date = [Helper dateFromString:dateStr];
        NSString *final = [NSString stringWithFormat:@"CAST(%lf, \"NSDate\")", [date timeIntervalSinceReferenceDate]];
        // Replace the original date with this one
        dateRange.length = index;
        aPath = [aPath stringByReplacingCharactersInRange:dateRange withString:final];
    }
    return aPath;
}
//
// baseEntity is the object to start for (i.e. RealPropInfo, Header, etc.)
// propertyName is the path (i.e. Header.StreetName)
//
// Return the object referenced by that name
+(id)getItemValue:(NSManagedObject *)baseEntity property:(NSString *)propertyName
{
    return [ItemDefinition getItemValue:baseEntity withPath:propertyName withType:-1 withLookup:0];
}
// Return true if the definition is complex
-(BOOL)isComplex
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@$[{.->"];
    
    NSRange range = [path rangeOfCharacterFromSet:set];
    if(range.length>0)
        return YES;
    return NO;
}
//
// Find the value of an object and return the string for it.
// BaseEntity is the starting point -- property can be written as complete path form the current baseEntity
// i.e. if baseEntity is RealPropInfo, the propety can contain header.street and the return value will be realPropInfo.header.street
//
-(NSString *)getStringValue:(NSManagedObject *)baseEntity
{
    return [ItemDefinition getStringValue:baseEntity withPath:path withType:_type withLookup:lookup];
}
-(id) getItemValue:(NSManagedObject *)baseEntity
{
    id value = [ItemDefinition getItemValue:baseEntity withPath:path withType:_type withLookup:lookup];
    return value;
}
//
// Return the string value of an entity
//
-(NSString *) getStringValueNotNil:(NSManagedObject *)baseEntity
{
    if(baseEntity==nil)
        return nil;
    @try
    {
        id object = [baseEntity valueForKeyPath:path];
        
        NSNumber *number = object;
        NSString *string = object;
        NSDate  *date = object;
        
        // Setup the type
        switch (_type) 
        {
            case ftTextL:
            case ftURL:
            case ftText:
                if([string length]==0)
                    return nil;
            case ftLookup:
            case ftBool:
            case ftPercent:
            case ftNum:
            case ftInt:
            case ftCurr:
            case ftYear:
                if([number intValue]==0)
                    return nil;
                break;
            case ftDate:
                if([date timeIntervalSinceReferenceDate]==0)
                    return nil;
                break;
            case ftFloat:
                if([number floatValue]==0)
                    return nil;
                break;
                
            default:
                return @"";
        }
    }
    @catch (NSException *exception) 
    {
        NSLog(@"getStringValueNotNil: %d - %@",_type,[[baseEntity entity] name]);
    }
    return [self getStringValue:baseEntity];
}


#pragma - Support functions
//
// very simple function that creates a predicate (example of ResBldg.bldgNbr=MediaBldg.bldgId)
-(void)createPredicateFromFilter
{
    
}

-(void)setType:(enum FieldTypes)t
{
    _type = t;
}

@end
