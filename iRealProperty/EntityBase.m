#import "EntityStructure.h"
#import "EntityBase.h"
#import "Helper.h"
#import "RealPropertyApp.h"

@implementation EntityBase

static  NSMutableArray *structureDefinition;
static  NSMutableArray *screenDefinitions;
static  NSMutableArray *gridDefinitions;
static  NSMutableArray *menuDefinitions;
static  NSMutableArray *multiScreenDefinitions;
static  NSMutableArray *optionsList;

-(id)initWithXMLFile:(NSString *)xmlFile
{
    self = [super init];
    if(self)
    {
        verbose = NO;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *fileName = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"common/%@", xmlFile]];
        fileName = [fileName stringByAppendingPathExtension:@"xml"];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
    
        NSURL *url;
        
        if(fileExists)
            url = [[NSURL alloc]initFileURLWithPath:fileName];
        else
        {
            // Get it from the existing bundle
            NSString *filePath = [[NSBundle mainBundle] pathForResource:xmlFile ofType:@"xml"];
            url = [[NSURL alloc]initFileURLWithPath:filePath];
        }
        
        xmlParser = [[NSXMLParser alloc]initWithContentsOfURL:url];
        [xmlParser setDelegate:self];
        [xmlParser setShouldProcessNamespaces:NO];
        [xmlParser setShouldReportNamespacePrefixes:NO];
        [xmlParser setShouldResolveExternalEntities:NO];
        
        [xmlParser parse];
        
    }
    return self;
}
-(void)abortWithMsg:(NSString *)message
{
    [Helper alertWithOk:@"Invalid iRealProperty2.xml" message:message];
    
    [xmlParser abortParsing];
}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self abortWithMsg:[parseError localizedDescription]];
}
//
// First element
//
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    level++;
    if(verbose)
        NSLog(@"Open=%d, '%@'",level, elementName);
    if(level==1)
    {
        // Expect iRealPropertySearch
        if([elementName compare:@"iRealProperty" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
        }
        else
        {
            [self abortWithMsg:[NSString stringWithFormat:@"expected iRealproperty, found '%@'", elementName]];
        }
    }
    else if(level==2)
    {
        // SearchGroup
        if([elementName compare:@"Structure" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            // Allocate the database structure
            if(structureDefinition==nil)
                structureDefinition = [[NSMutableArray alloc]init];
        }
        else if([elementName compare:@"ScreenDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            
            if(screenDefinitions==nil)
                screenDefinitions = [[NSMutableArray alloc]init];
            
            screen = [[ScreenDefinition alloc]initWithName:[attributeDict valueForKey:@"name"]];
            
            // Default object can be skipped
            defaultObject = [attributeDict valueForKey:@"object"];
            screen.defaultEntity = defaultObject;
        }
        else if([elementName compare:@"MultiScreen" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            
            if(multiScreenDefinitions==nil)
                multiScreenDefinitions = [[NSMutableArray alloc]init];
            multiScreenDefinition = [[MultiScreenDefinition alloc]initWithName:[attributeDict valueForKey:@"name"]];
        }
        else if([elementName compare:@"GridDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            if(gridDefinitions==nil)
                gridDefinitions = [[NSMutableArray alloc]init];
            grid = [[GridDefinition alloc]initWithName:[attributeDict valueForKey:@"name"]];
            grid.editLevel = 1;

            defaultObject = [attributeDict valueForKey:@"object"];
            grid.tag = [[attributeDict valueForKey:@"tag"]intValue];
            grid.rowHeight = [[attributeDict valueForKey:@"height"]intValue];
            if([attributeDict valueForKey:@"auto"]!=nil && [[attributeDict valueForKey:@"auto"] compare:@"yes" options:NSCaseInsensitiveSearch]==NSOrderedSame)
            {
                grid.autoColumn = YES;
                itemDefinition = [[ItemDefinition alloc]init];
                itemDefinition.type = ftAuto;
                itemDefinition.labelName = nil;
                itemDefinition.width = GRID_NUMBER_WIDTH;
                itemDefinition.maxWidth = GRID_NUMBER_WIDTH;
                [grid.columns addObject:itemDefinition];
            }
            grid.sortOption = [attributeDict valueForKey:@"sort"];
            grid.sortDescending = NO;
            if([attributeDict valueForKey:@"ascending"]!=nil && [[attributeDict valueForKey:@"ascending"] compare:@"no" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                grid.sortDescending = YES;
            NSString *editLevel = [attributeDict valueForKey:@"editable"];
            if([editLevel length]>0)
            {
                if([editLevel caseInsensitiveCompare:@"level0"]==NSOrderedSame)
                    grid.editLevel = 0;
                else if([editLevel caseInsensitiveCompare:@"level1"]==NSOrderedSame)
                    grid.editLevel = 1;
                else if([editLevel caseInsensitiveCompare:@"level2"]==NSOrderedSame)
                    grid.editLevel = 2;
                else if([editLevel caseInsensitiveCompare:@"no"]==NSOrderedSame)
                    grid.editLevel = -1;
            }
        }
        else if([elementName compare:@"MenuDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            if(menuDefinitions==nil)
                menuDefinitions = [[NSMutableArray alloc]init];
            menu = [[MenuDefinition alloc]initWithName:[attributeDict valueForKey:@"name"]];
        }
        else if([elementName compare:@"Options" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            if(optionsList==nil)
                optionsList = [[NSMutableArray alloc]init];
            options = [[Options alloc]init];
            options.name = [attributeDict valueForKey:@"name"];
            options.label = [attributeDict valueForKey:@"label"];
            options.sectionArray = [[NSMutableArray alloc]init];
            [optionsList addObject:options];
        }
        else
        {
            [self abortWithMsg:[NSString stringWithFormat:@"Unexpected element '%@'", elementName]];
        }
        
    }
    else if(level==3)
    {
        if([elementName compare:@"entity" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"entity"; 
            entityDefinition = [[EntityDef alloc]init];
            entityDefinition.name = [[attributeDict valueForKey:@"name"]copy];
            if([[attributeDict valueForKey:@"root"] compare:@"yes" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                entityDefinition.root = YES;
            else
                entityDefinition.root = NO;
            
        }
        else if([elementName compare:@"section" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            optionSection = [[OptionSection alloc]init];
            optionSection.label = [attributeDict valueForKey:@"label"];
            optionSection.footer = [attributeDict valueForKey:@"footer"];
            optionSection.optionArray = [[NSMutableArray alloc]init];
            [options.sectionArray addObject:optionSection];
        }
        else if([elementName compare:@"screen" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"screen";
            MultiScreenItem *item = [[MultiScreenItem alloc]init];
            item.label = [[attributeDict valueForKey:@"label"]copy];
            item.screenName = [[attributeDict valueForKey:@"screenDefinition"] copy];
            item.path = [[attributeDict valueForKey:@"path"] copy];
            NSString *repeat = [attributeDict valueForKey:@"repeatHeader"];
            item.repeatHeader = YES;
            if(repeat.length!=0 && [repeat caseInsensitiveCompare:@"NO"]==NSOrderedSame)
                item.repeatHeader = NO;
            NSString *cellHeight = [attributeDict valueForKey:@"cellHeight"];
            item.cellHeight = [cellHeight intValue];
            item.sortField = [attributeDict valueForKey:@"sort"];
            NSString *ascending = [attributeDict valueForKey:@"ascending"];
            if([ascending caseInsensitiveCompare:@"YES"]==NSOrderedSame)
                item.sortAscending = YES;
            else
                item.sortAscending = NO;
            [multiScreenDefinition.screens addObject:item];
        }
        else if([elementName compare:@"validation" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"validation";
            validation = [[Validation alloc]init];
            validation.message = [attributeDict valueForKey:@"message"];
            validation.evaluate = [attributeDict valueForKey:@"predicate"];
            NSString *warning = [attributeDict valueForKey:@"warning"];
            if([warning length]>0 && [warning caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                validation.warning = YES;
            else
                validation.warning = NO;
            if(screen.validations==nil)
                screen.validations = [[NSMutableArray alloc]init];
            [screen.validations addObject:validation];
        }
        else if([elementName compare:@"item" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"item";
            itemDefinition = [[ItemDefinition alloc]init];
            if([attributeDict objectForKey:@"label"]!=nil)
            {
                itemDefinition.labelName = [[attributeDict valueForKey:@"label"]copy];
                itemDefinition.path = [[attributeDict valueForKey:@"path"]copy];

                if([attributeDict valueForKey:@"auto"]!=nil && [[attributeDict valueForKey:@"auto"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                    itemDefinition.autoField = YES;
                if([attributeDict valueForKey:@"required"]!=nil && [[attributeDict valueForKey:@"required"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                    itemDefinition.required = YES; 
                NSString *editable = [attributeDict valueForKey:@"editable"];
                if(editable==nil)
                    itemDefinition.editLevel = 1;
                else if([editable caseInsensitiveCompare:@"level0"]==NSOrderedSame || [editable caseInsensitiveCompare:@"0"]==NSOrderedSame)
                    itemDefinition.editLevel = 0;
                else if([editable caseInsensitiveCompare:@"level1"]==NSOrderedSame || [editable caseInsensitiveCompare:@"1"]==NSOrderedSame)
                    itemDefinition.editLevel = 1;
                else if([editable caseInsensitiveCompare:@"level2"]==NSOrderedSame || [editable caseInsensitiveCompare:@"2"]==NSOrderedSame)
                        itemDefinition.editLevel = 2;                
                else if([editable caseInsensitiveCompare:@"no"]==NSOrderedSame)
                    itemDefinition.editLevel = -1; 
                
                if([attributeDict objectForKey:@"path"]!=nil)
                {
                    // Update the information based on the database entity
                    PropertyDef *prop = [EntityBase findProperty:(NSString *)defaultObject property:itemDefinition.path];
                    itemDefinition.entityName = [defaultObject copy];
                    itemDefinition.type = prop.type;
                    itemDefinition.lookup = prop.lookup;
                    itemDefinition.tag = [[attributeDict valueForKey:@"tag"]intValue];
                    itemDefinition.length = [[attributeDict valueForKey:@"length"]intValue];
                }
                itemDefinition.maxPercentValue = 100;
                itemDefinition.percentIncrement = 5;
                //cv
                itemDefinition.maxPercentValueNeg = -100;
                itemDefinition.percentIncrementNeg = -5;
                if([attributeDict objectForKey:@"maxValue"]!=nil)
                    itemDefinition.maxPercentValue = [[attributeDict objectForKey:@"maxValue"]intValue];
                if([attributeDict objectForKey:@"increment"]!=nil)
                    itemDefinition.percentIncrement = [[attributeDict objectForKey:@"increment"]intValue];                
                //cv
                if([attributeDict objectForKey:@"incrementNeg"]!=nil)
                    itemDefinition.percentIncrementNeg = [[attributeDict objectForKey:@"incrementNeg"]intValue];
                
                if([attributeDict objectForKey:@"maxValueNeg"]!=nil)
                    itemDefinition.maxPercentValueNeg = [[attributeDict objectForKey:@"maxValueNeg"]intValue];

            }
            else if([attributeDict objectForKey:@"grid"]!=nil)
            {
                itemDefinition.type = ftGrid;
                itemDefinition.tag = [[attributeDict valueForKey:@"tag"]intValue]; 
                itemDefinition.entityName = [[attributeDict valueForKey:@"grid"]copy];
                itemDefinition.path = [[attributeDict valueForKey:@"path"]copy];
            }
            else if([attributeDict objectForKey:@"embedded"]!=nil)
            {
                itemDefinition.tag = [[attributeDict valueForKey:@"tag"]intValue]; 
                itemDefinition.entityName = [[attributeDict valueForKey:@"embedded"]copy];
                itemDefinition.type = ftEmbedded;
                itemDefinition.actionMethod = [[attributeDict valueForKey:@"method"]copy];
            }
            // add a new item
            [screen.items addObject:itemDefinition];
        }
        else if([elementName compare:@"col" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"col";
            itemDefinition = [[ItemDefinition alloc]init];
            itemDefinition.labelName = [[attributeDict valueForKey:@"label"]copy];
            itemDefinition.path = [[attributeDict valueForKey:@"path"]copy];
            NSString *result = [attributeDict valueForKey:@"result"];
            if([result length]!=0)
                itemDefinition.path = [NSString stringWithFormat:@"%@ ~ %@",itemDefinition.path,result];
            // Update the information based on the database entity
            PropertyDef *prop = [EntityBase findProperty:(NSString *)defaultObject property:itemDefinition.path];
            itemDefinition.entityName = [defaultObject copy];
            itemDefinition.type = prop.type;
            itemDefinition.lookup = prop.lookup;
            itemDefinition.width = [[attributeDict valueForKey:@"width"]intValue];
            itemDefinition.maxWidth = 5000;
            if([attributeDict valueForKey:@"type"]!=nil)
                itemDefinition.type = [EntityBase typeDefinition:[attributeDict valueForKey:@"type"]];
            // Check if the new entry is a media
            if([attributeDict valueForKey:@"media"]!=nil)
            {
                if([[attributeDict valueForKey:@"media"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                {
                    itemDefinition.type = ftImg;
                }
            }
            // add a new item
            [grid.columns addObject:itemDefinition];
        }
        else if([elementName compare:@"menu" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"menu";
            menuItem = [[MenuItem alloc]init];
            menuItem.menuLabel = [[attributeDict valueForKey:@"label"]copy];
            menuItem.menuParam = [[attributeDict valueForKey:@"param"]copy];
            
            if([attributeDict objectForKey:@"checked"]!=nil)
            {
                if([[attributeDict valueForKey:@"checked"] compare:@"yes" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                    menuItem.menuChecked = YES;

            }
            [menu.menus addObject:menuItem];
        }
    }
    else if(level==4)
    {
        if([elementName compare:@"link" options:NSCaseInsensitiveSearch]==NSOrderedSame || 
           [elementName compare:@"backlink" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = elementName;
            propertyDefinition = [[PropertyDef alloc]init];
            propertyDefinition.name = [[attributeDict valueForKey:@"name"]copy];
            propertyDefinition.type = ftLink;
            propertyDefinition.link = [[attributeDict valueForKey:@"target"]copy];
            propertyDefinition.isSet = NO;
            // Add it to the list
            [entityDefinition.properties addObject:propertyDefinition];
            if([elementName compare:@"backlink" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                propertyDefinition.isBackLink = YES;
        }
        else if([elementName compare:@"option" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            option = [[Option alloc]init];
            option.label = [attributeDict valueForKey:@"label"];
            option.param = [attributeDict valueForKey:@"param"];
            option.defaultStr = [attributeDict valueForKey:@"default"];
            option.choices = [attributeDict valueForKey:@"choices"];
            [optionSection.optionArray addObject:option];
        }
        else if([elementName compare:@"property" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = elementName;
            propertyDefinition = [[PropertyDef alloc]init];
            propertyDefinition.name = [[attributeDict valueForKey:@"name"]copy];
            
            NSString *str = [attributeDict valueForKey:@"type"];
            propertyDefinition.type = [EntityBase typeDefinition:str];
            // DBaun 2014-08-04: Commenting out next line because the enumeration being compared to -1 has no -1 value, and will always be false per error message.
            //  if(propertyDefinition.type== -1)
            //      NSLog(@"Mishandled '%@' for '%@'", str,propertyDefinition.name);
            if(propertyDefinition.type==ftLookup)
                propertyDefinition.lookup = [[attributeDict valueForKey:@"lookup"]intValue];
            // Add it to the list
            [entityDefinition.properties addObject:propertyDefinition];
            propertyDefinition.isUniqueId = NO;
            str = [attributeDict valueForKey:@"uniqueid"];
            if(str !=nil && [str caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                propertyDefinition.isUniqueId = YES;
        }
        else
        {
            [self abortWithMsg:[NSString stringWithFormat:@"Unexpected element '%@'", elementName]];
        }
        
    }
    
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(verbose)
        NSLog(@"Close=%d, '%@'",level, elementName);
    if([elementName compare:@"ScreenDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        [screenDefinitions addObject:screen];
    }
    else if([elementName compare:@"MultiScreen" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {       
        [multiScreenDefinitions addObject:multiScreenDefinition];
    }
    else if([elementName compare:@"GridDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {       
        [gridDefinitions addObject:grid];
    }
    else if([elementName compare:@"MenuDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {       
        [menuDefinitions addObject:menu];
    }
    else if([elementName compare:@"entity" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        // Close a searchDefinition
        [structureDefinition addObject:entityDefinition];
    }
    level--;
}
+(NSString *)findRelationInObject:(NSManagedObject *)object  entityName:(NSString *)entityName
{
    NSString *objectClass = [[object class]description];
    
    for(EntityDef *entity in structureDefinition)
    {
        if([entity.name compare:objectClass options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            // look at the properties
            for(PropertyDef *property in entity.properties)
            {
                if(property.type==ftLink && [entityName compare:property.name options:NSCaseInsensitiveSearch]==NSOrderedSame)
                    return property.link;
            }
        }
    }
    return nil;
}
+(BOOL)isRelationBack:(NSString *)name property:(NSString *)propertyName
{
    for(EntityDef *entity in structureDefinition)
    {
        if([entity.name compare:name options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            // look at the properties
            for(PropertyDef *property in entity.properties)
            {
                if(property.type==ftLink && [propertyName compare:property.name options:NSCaseInsensitiveSearch]==NSOrderedSame)
                    return property.isBackLink;
            }
        }
    }
    return NO;
}
//
// Return the property definition of an entry based on the entity name and propertyname
//
+(PropertyDef *)findProperty:(NSString *)entityName property:(NSString *)propertyNane
{
    NSArray *strItems = [propertyNane componentsSeparatedByString:@"."];
    
    NSString *root = @"";
    NSString *prop = @"";
    
    if([strItems count]==1)
    {
        root = entityName;
        prop = propertyNane;
    }
    else if([strItems count]>1)
    {
        int count = strItems.count;
        root = [strItems objectAtIndex:count-2];
        prop = [strItems objectAtIndex:count-1];
    }
    for(EntityDef *entity in structureDefinition)
    {
        if([entity.name caseInsensitiveCompare:root]==NSOrderedSame)
        {
            for(PropertyDef *property in entity.properties)
            {
                if([property.name compare:prop options:NSCaseInsensitiveSearch]==NSOrderedSame)
                {
                    return property;
                }
                
            }
        }
    }
    //NSLog(@"Can't identify %@.%@",entityName, propertyNane);
    return nil;
}
+(int)typeDefinition:(NSString *)str
{
    if([str caseInsensitiveCompare:@"TEXT"]==NSOrderedSame)
        return ftText;
    else if([str caseInsensitiveCompare:@"LOOKUP"]==NSOrderedSame)
        return ftLookup;
    else if([str caseInsensitiveCompare:@"TEXTL"]==NSOrderedSame)
        return ftTextL;
    else if([str caseInsensitiveCompare:@"BOOL"]==NSOrderedSame)
        return ftBool;
    else if([str caseInsensitiveCompare:@"INT"]==NSOrderedSame)
        return ftInt;
    else if([str caseInsensitiveCompare:@"FLOAT"]==NSOrderedSame)
        return ftFloat;
    else if([str caseInsensitiveCompare:@"NUM"]==NSOrderedSame)
        return ftNum;
    else if([str caseInsensitiveCompare:@"YEAR"]==NSOrderedSame)
        return ftYear;
    else if([str caseInsensitiveCompare:@"DATE"]==NSOrderedSame)
        return ftDate;
    else if([str caseInsensitiveCompare:@"CURR"]==NSOrderedSame)
        return ftCurr;
    else if([str caseInsensitiveCompare:@"PERCENT"]==NSOrderedSame)
        return ftPercent;
    else if([str caseInsensitiveCompare:@"URL"]==NSOrderedSame)
        return ftURL;
    else
        return -1;    
}
//
// Return a grid definition
//
+(GridDefinition *)getGridWithName:(NSString *)name
{
    for(GridDefinition *def in gridDefinitions)
    {
        if([def.name isEqualToString:name])
            return def;
    }
    return nil;
}
+(ScreenDefinition *)getScreenWithName:(NSString *)name
{
    for(ScreenDefinition *def in screenDefinitions)
    {
        if([def.name isEqualToString:name])
            return def;
    }
    return nil;
}
+(MenuDefinition *)getMenuWithName:(NSString *)name
{
    for(MenuDefinition *def in menuDefinitions)
    {
        if([def.name isEqualToString:name])
            return def;
    }
    return nil;
}
// Return entity definition based on a name
+(EntityDef *)getEntityDefinition:(NSString *)entityName
{
    for(EntityDef *def in structureDefinition)
    {
        if([entityName caseInsensitiveCompare:def.name]==NSOrderedSame)
        {
            return def;
        }
    }
    return nil;
}
+(PropertyDef *)getPropertyDefinition:(NSString *)propertyName from:(EntityDef *)entity
{
    for(PropertyDef *property in entity.properties)
    {
        if([property.name caseInsensitiveCompare:propertyName]==NSOrderedSame)
        {
            return property;
        }
    }
    return nil;
}

// Return null in case of error
+(PropertyDef *)getObjectType:(NSString *)entity withPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"."];
    EntityDef *entityDef = [EntityBase getEntityDefinition:entity];
    
    if([components count]<=1)
    {
        // Single component
        return [EntityBase getPropertyDefinition:path from:entityDef];
    }
    // Multiple components
    entityDef = [EntityBase getEntityDefinition:[components objectAtIndex:[components count]-2]];
    return [EntityBase getPropertyDefinition:[components objectAtIndex:[components count]-1] from:entityDef];
}

+(void)addGridDefinition:(GridDefinition *)definition
{
    if(gridDefinitions==nil)
        gridDefinitions = [[NSMutableArray alloc]init];
    [gridDefinitions addObject:definition];
}
+(void)addScreenDefinition:(ScreenDefinition *)definition
{
    if(screenDefinitions==nil)
        screenDefinitions = [[NSMutableArray alloc]init];
    [screenDefinitions addObject:definition];
}
+(void)addMenuDefinition:(MenuDefinition *)definition
{
    if(menuDefinitions==nil)
        menuDefinitions = [[NSMutableArray alloc]init];
    [menuDefinitions addObject:definition];
}
+(MultiScreenDefinition *)getMultiScreenWithName:(NSString *)name
{
    for(MultiScreenDefinition *multi in multiScreenDefinitions)
    {
        if([multi.name caseInsensitiveCompare:name]==NSOrderedSame)
            return multi;
    }
    return nil;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}
//
// Return a dictionary [ClassName/PropertyName] of each unique ID
+(NSDictionary *)getUniqueKeys
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    for(EntityDef *def in structureDefinition)
    {
        for(PropertyDef *property in def.properties)
        {
            if(property.isUniqueId)
            {
                [dictionary setValue:property.name forKey:def.name];
                break;
            }
        }
    }
    return dictionary;
}
//
// return the option definition
+(Options *)getOptionsDefinition:(NSString *)optionName
{
    for(Options *options in optionsList)
    {
        if([options.name caseInsensitiveCompare:optionName]==NSOrderedSame)
            return options;
    }
    return nil;
}
-(void)print
{
}

@end
