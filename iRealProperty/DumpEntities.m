#import "DumpEntities.h"
#import "AxDataManager.h"
#import "RealProperty.h"
#import "ItemDefinition.h"

@implementation DumpEntities

id objc_getClass(const char *name);

-(id)initWith:(NSString *)root
{
    self = [super init];
    if(self)
    {
        // Create the file name
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        destString = [[NSMutableString alloc]init];
        
        //make a file name to write the data to using the documents directory:
        fileName = [NSString stringWithFormat:@"%@/iRealProp.xml", documentsDirectory];
        
        entities = [[NSMutableArray alloc]init];
        keys = [[NSMutableArray alloc]init];
        [self retrieveExistingEntities];
        
        [destString appendString:@"\t<Structure>\n"];
        [self dumpEntity:@"RealPropInfo" isRoot:YES];
        [destString appendString:@"\t</Structure>\n"];
        
        // Now dump the different objects
        [self dumpObjects];
        
        // [destString writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
    return self;
}
-(void) dumpObjects
{
    for(int index=0;index<[definitions count];index++)
    {
        // find the key
        NSString *key = [keys objectAtIndex:index];
        NSRange range = [key rangeOfString:@"Grid"];
        if(range.location==0 && range.length==4)
            continue;

        NSArray *array = [definitions objectAtIndex:index];
        ItemDefinition *def = [array objectAtIndex:0];
        [destString appendString:[NSString stringWithFormat:@"<!-- %@ -->\n",def.entityName]];
        
        NSString *out = [NSString stringWithFormat:@"\t<ScreenDefinition name=\"%@\" object=\"%@\">\n", key, def.entityName];
        [destString appendString:out];
        
        for(def in array)
        {
            NSString *dest = [NSString stringWithFormat:@"\t\t<item tag=\"%d\" label=\"%@\" property=\"%@\" />\n", def.tag, def.labelName, def.property];
            [destString appendString:dest];
        }
        
        [destString appendString:@"\t</ScreenDefinition>\n\n"];
        
    }        
    for(int index=0;index<[definitions count];index++)
    {
        // find the key
        NSString *key = [keys objectAtIndex:index];
        NSRange range = [key rangeOfString:@"Grid"];
        if(range.location==0 && range.length==4)
        {
            // it is a grid definition
            NSArray *array = [definitions objectAtIndex:index];
            ItemDefinition *def = [array objectAtIndex:0];
            [destString appendString:[NSString stringWithFormat:@"<!-- %@ -->\n",def.entityName]];
            NSString *out = [NSString stringWithFormat:@"\t<GridDefinition name=\"%@\" tag=\"40\" height=\"30\" object=\"%@\" auto=\"yes\">\n", key, def.entityName];
            [destString appendString:out];
            
             for(def in array)
             {
                 NSString *dest = [NSString stringWithFormat:@"\t\t<col label=\"%@\" width=\"%d\" property=\"%@\" />\n", def.labelName, def.width, def.property];
                 [destString appendString:dest];
             }
            
            [destString appendString:@"\t</GridDefinition>\n\n"];
        }

    }
}
-(void)retrieveExistingEntities
{
    definitions = [[NSMutableArray alloc]init];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PropertyDefinition" ofType:@"plist"];
    NSDictionary *levelDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *allKeys = [levelDictionary allKeys];
    
    for(NSString *key in allKeys)
    {
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        NSArray *levelArea = [levelDictionary valueForKey:key];
        [keys addObject:key];
        for(NSString *res in levelArea)
        {
            ItemDefinition *obj = [[ItemDefinition alloc]initPropertyDefinitionFromList:res];
            [mArray addObject:obj];
        }
        [definitions addObject:mArray];
    }
}
-(void)dumpEntity:(NSString *)entity isRoot:(BOOL)isRoot
{
    if([entities containsObject:entity])
        return;
    [entities addObject:entity];
    
    NSManagedObject *source = [AxDataManager getNewEntityObject:entity];
    
    NSString *out = [NSString stringWithFormat:@"\t\t<entity name=\"%@\" root=\"%@\">\n", entity, isRoot?@"yes":@"no"];
    [destString appendString:out];
    
    NSArray *properties = [[source entity] properties];
    // First pass: dump the entity
    for (NSPropertyDescription* property in properties) 
    {
        NSString *entityName = [property name];
        if([property isKindOfClass:(id)objc_getClass("NSAttributeDescription")])
        {
            NSAttributeDescription* attribute = (NSAttributeDescription*)property;
            [self dumpAttr:entity withAttribute:entityName withAttr:attribute withObject:source];
        }
    }
    for (NSPropertyDescription* property in properties) 
    {
        NSString *entityName = [property name];
        if([property isKindOfClass:(id)objc_getClass("NSRelationshipDescription")])
        {
            NSRelationshipDescription *relation = (NSRelationshipDescription *)property;
            [self describeRelation:entity withAttribute:entityName withRelation:relation withObject:property];
        }
    }        

    [destString appendString:@"\t\t</entity>\n"];
    // Second pass: the relations
    for (NSPropertyDescription* property in properties) 
    {
        NSString *entityName = [property name];
        if([property isKindOfClass:(id)objc_getClass("NSRelationshipDescription")])
        {
            NSRelationshipDescription *relation = (NSRelationshipDescription *)property;
            [self dumpRelation:entity withAttribute:entityName withRelation:relation withObject:property];
        }
    }        
}
-(void)dumpAttr:(NSString *)root withAttribute:(NSString *)attrName withAttr:(id)attribute withObject:(id)source;
{
    NSString *type; // = [attribute attributeValueClassName];
    // Retrieve the specific type used for that particular object
    int lookup = 0;
    type = @"";
    for(NSArray *array in definitions)
    {
        // loop through the array
        for(ItemDefinition *def in array)
        {
            if([def.entityName length]==0 || [def.property length]==0)
                continue;
            if([def.entityName compare:root options:NSCaseInsensitiveSearch]==NSOrderedSame &&
               [def.property compare:attrName options:NSCaseInsensitiveSearch]==NSOrderedSame)
            {
                switch (def.type) 
                {
                    case ftText:
                        type = @"TEXT";
                        break;
                    case ftLookup:
                        type = @"LOOKUP";
                        lookup = def.lookup;
                        break;
                        
                    case ftAuto:
                        type = @"AUTO";
                        break;
                    case ftNum:
                        type = @"NUM";
                        break;
                    case ftBool:
                        type = @"BOOL";
                        break;
                    case ftCurr:
                        type = @"CURR";
                        break;
                    case ftPercent:
                        type = @"PERCENT";
                        break;
                    case ftDate:
                        type = @"DATE";
                        break;
                    case ftFloat:
                        type = @"FLOAT";
                        break;
                    case ftInt:
                        type = @"INT";
                        break;
                    case ftYear:
                        type = @"YEAR";
                        break;
                    case ftTextL:
                        type = @"TEXTL";
                        break;
                    case ftURL:
                        type = @"URL";
                        break;
                    default:
                        type = @"????";
                        break;
                }
                break;
            }
            if([type length]!=0)
               break;
        }
        if([type length]!=0)
            break;
    }
    if([type length]==0)
    {
        if([attribute attributeType]==NSDateAttributeType)
            type = @"DATE";
        else if([attribute attributeType]==NSStringAttributeType)
            type = @"TEXT";
        else if([attribute attributeType]==NSInteger32AttributeType)
            type = @"INT";
    }
    NSString *out;
    
    if(lookup!=0)
        out = [NSString stringWithFormat:@"\t\t\t<property name=\"%@\" type=\"%@\" lookup=\"%d\" />\n", attrName, type, lookup]; 
    else
        out = [NSString stringWithFormat:@"\t\t\t<property name=\"%@\" type=\"%@\" />\n", attrName, type]; 
    [destString appendString:out];
}
-(void)dumpRelation:(NSString *)root withAttribute:(NSString *)attrName withRelation:(id)relation withObject:(id)object
{
    NSEntityDescription *description = [relation destinationEntity];

    [self dumpEntity:[description name] isRoot:NO];
}
-(void)describeRelation:(NSString *)root withAttribute:(NSString *)attrName withRelation:(id)relation withObject:(id)object
{
    NSEntityDescription *description = [relation destinationEntity];

    NSString *out = [NSString stringWithFormat:@"\t\t\t<link name=\"%@\" target=\"%@\" />\n", description.name,
                            description.managedObjectClassName]; 
    [destString appendString:out];
}
@end
