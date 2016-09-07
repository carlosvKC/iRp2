#import "SearchBase.h"
#import "Helper.h"
#import "EntityBase.h"
#import "EntityStructure.h"
#import "RealProperty.h"
#import "ItemDefinition.h"
#import "RealPropertyApp.h"

@implementation SearchBase

@synthesize searchGroups;
@synthesize verbose;

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
    [Helper alertWithOk:@"Invalid SearchDefinition.xml" message:message];
    
    searchGroups = nil;
    [xmlParser abortParsing];
}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // [self abortWithMsg:[parseError localizedDescription]];
    [xmlParser abortParsing];
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
        if([elementName compare:@"irealpropertysearch" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            searchGroups = [[NSMutableArray alloc]init];
        }
        else
        {
            [self abortWithMsg:@"Expected iRealPropertySearch"];
        }
    }
    else if(level==2)
    {
        // SearchGroup
        if([elementName compare:@"searchgroup" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            searchGroup = [[SearchGroup alloc]init];
            searchGroup.title = [attributeDict objectForKey:@"title"];

        }
        else if([elementName compare:@"GridDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            grid = [[GridDefinition alloc]initWithName:[attributeDict valueForKey:@"name"]];
            defaultObject = [attributeDict valueForKey:@"root"];
            if([defaultObject length]==0)
                defaultObject = @"realPropInfo";
            grid.defaultObject = defaultObject;
            grid.tag = [[attributeDict valueForKey:@"tag"]intValue];
            grid.rowHeight = [[attributeDict valueForKey:@"height"]intValue];
            if([[attributeDict valueForKey:@"auto"] compare:@"yes" options:NSCaseInsensitiveSearch]==NSOrderedSame)
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
        }
        else
        {
            [self abortWithMsg:[NSString stringWithFormat:@"Expect 'SearchGroup', received '%@'", elementName]];
        }
        
    }
    else if(level==3)
    {
        // Title, SearchDefinition
        if([elementName compare:@"searchdefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = @"";  // Valid -- but don't expect anything
            searchDefinition = [[SearchDefinition2 alloc]init];
            searchDefinition.title = [attributeDict valueForKey:@"title"];
            searchDefinition.searchDescription = [attributeDict valueForKey:@"description"];
            NSString *mode = [attributeDict valueForKey:@"mode"];
            if(mode==nil)
                searchDefinition.searchType = kSearchByItems;
            else if([mode caseInsensitiveCompare:@"ByParcel"]==NSOrderedSame)
                searchDefinition.searchType = kSearchByParcel;
            else if([mode caseInsensitiveCompare:@"ByStreet"]==NSOrderedSame)
                searchDefinition.searchType = kSearchByStreet;
            else if([mode caseInsensitiveCompare:@"ByItems"]==NSOrderedSame)
                searchDefinition.searchType = kSearchByItems;
            else
                searchDefinition.searchType = kSearchByItems;
            NSString *defaultMap = [attributeDict valueForKey:@"defaultmap"];
            if([defaultMap length]>0 && [defaultMap caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                searchDefinition.isDefaultMap = YES;
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
            
            NSString *object = [attributeDict valueForKey:@"object"];
            if([object length]==0)
                object = defaultObject;
            
            // Update the information based on the database entity
            PropertyDef *prop = [EntityBase findProperty:object property:itemDefinition.path];
            
            itemDefinition.entityName = object;
            itemDefinition.type = prop.type;
            itemDefinition.lookup = prop.lookup;
            itemDefinition.width = [[attributeDict valueForKey:@"width"]intValue];
            itemDefinition.maxWidth = 5000;
            if([attributeDict valueForKey:@"type"]!=nil)
                itemDefinition.type = [EntityBase typeDefinition:[attributeDict valueForKey:@"type"]];            // add a new item
            [grid.columns addObject:itemDefinition];
        }
        else
        {
            [self abortWithMsg:[NSString stringWithFormat:@"Unexpected element '%@'", elementName]];
        }
    }
    else if(level==4)
    {
        if([elementName compare:@"searchitem" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement =elementName;
            searchItem = [[SearchItem alloc]init];
            searchItem.refTitle = [attributeDict valueForKey:@"title"];
            searchItem.itemHelp = [attributeDict valueForKey:@"help"];
            searchItem.refObjectName = [attributeDict valueForKey:@"reference"];
            searchItem.choice = [attributeDict valueForKey:@"choice"];
            NSString *val = [attributeDict valueForKey:@"required"];
            if(val==nil || [val caseInsensitiveCompare:@"no"]==NSOrderedSame)
                searchItem.isRequired = NO;
            else if([val caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                searchItem.isRequired = YES;
            else
                searchItem.isRequired = NO;
            NSString *string = [attributeDict valueForKey:@"filter"];
            if([string compare:@"text" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                searchItem.filter = kSearchAlphabetical;
            else if([string compare:@"num" options:NSCaseInsensitiveSearch]==NSOrderedSame || 
               [string compare:@"numeric" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                searchItem.filter = kSearchNumerical;
            else if([string compare:@"date" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                searchItem.filter = kSearchDate;
            else
            {
                // wrong name
                [self abortWithMsg:[NSString stringWithFormat:@"Expected alpha, num or date. Received '%@'.", string]];
            }
            searchItem.defaultValue = [attributeDict valueForKey:@"default"];
            searchItem.maxChars = [[attributeDict valueForKey:@"maxChar"]intValue];
        }
        else if([elementName compare:@"query" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = elementName;
            QueryDefinition *query = [[QueryDefinition alloc]init];
            // Also looking at the different attributes.
            // The attributes are required
            query.entityName =  [[attributeDict objectForKey:@"entity"] copy];
            query.entitySortBy = [[attributeDict objectForKey:@"sortby"] copy];
            query.entityLink = [[attributeDict objectForKey:@"root"] copy];
            if([query.entityLink length]==0)
                query.entityLink = @"realPropInfo";
            
            if ([attributeDict objectForKey:@"unique"]!=nil && [[attributeDict objectForKey:@"unique"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                query.unique = YES;
            
            if([attributeDict objectForKey:@"ascending"]!=nil)
            {
                NSString *asc = [attributeDict objectForKey:@"ascending"];
                if([asc length]==0 && [asc caseInsensitiveCompare:@"no"]==NSOrderedSame)
                    query.ascending = NO;
                else
                    query.ascending = YES;
            }
            else
                query.ascending = YES;
            
            if([query.entityName length]==0)
                [self abortWithMsg:@"Query must have the attribute 'entity' defined"];
            if([query.entitySortBy length]==0)
                [self abortWithMsg:@"Query must have the atttibute 'sortby' defined"];

            query.query = [[attributeDict objectForKey:@"predicate"] copy];
            searchDefinition.query = query;
            searchDefinition.resultRef = [[attributeDict objectForKey:@"grid"] copy];
       }
        else if([elementName compare:@"joinquery" options:NSCaseInsensitiveSearch]==NSOrderedSame)
        {
            currElement = elementName;
            // Also looking at the different attributes.
            // The attributes are required
            QueryDefinition *query = [[QueryDefinition alloc]init];
            query.entityName =  [[attributeDict objectForKey:@"entity"] copy];
            query.entitySortBy = [[attributeDict objectForKey:@"sortby"] copy];
            query.entityLink = [[attributeDict objectForKey:@"root"] copy];
            if ([attributeDict objectForKey:@"unique"]!=nil && [[attributeDict objectForKey:@"unique"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                query.unique = YES;            
            /// query.join = [[attributeDict objectForKey:@"on"] copy];
            if([query.entityLink length]==0)
                query.entityLink = @"realPropInfo";
            
            if([attributeDict objectForKey:@"ascending"]!=nil)
            {
                NSString *asc = [attributeDict objectForKey:@"ascending"];
                if([asc length]==0 && [asc caseInsensitiveCompare:@"no"]==NSOrderedSame)
                    query.ascending = NO;
                else
                    query.ascending = YES;
            }
            else
                query.ascending = YES;
            /*** we are supporting only the add operation 
            NSString *operation = [attributeDict objectForKey:@"operation"];
            
            if([operation length]==0)
                [self abortWithMsg:@"JoinQuery must have the attribute 'operation' defined"];
            
            if([operation caseInsensitiveCompare:@"add"]==NSOrderedSame)
                query.joinOperation = kQueryAdd;
            if([operation caseInsensitiveCompare:@"join"]==NSOrderedSame)
                query.joinOperation = kQueryInnerJoin;            
            ****/
            // query.joinOperation = kQueryAdd;

            if([query.entityName length]==0)
                [self abortWithMsg:@"JoinQuery must have the attribute 'entity' defined"];
            if([query.entitySortBy length]==0)
                [self abortWithMsg:@"JoinQuery must have the atttibute 'sortby' defined"];
            
            query.query = [[attributeDict objectForKey:@"predicate"] copy];
            if(searchDefinition.joinQueries==nil)
                searchDefinition.joinQueries = [[NSMutableArray alloc]init];
            [searchDefinition.joinQueries addObject:query];
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
    if([elementName compare:@"irealpropertysearch" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        // We are done with parsing
    }
    else if ([elementName compare:@"searchgroup" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        // Close a searchGroup
        [searchGroups addObject:searchGroup];
        searchGroup = nil;
        
    }
    else if([elementName compare:@"searchdefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        // Close a searchDefinition
        [searchGroup.searchDefinitions addObject:searchDefinition];
        searchDefinition = nil;
    }
    else if([elementName compare:@"searchitem" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        // Close an item
        [searchDefinition.items addObject:searchItem];
        searchItem = nil;
    }
    else if([elementName compare:@"GridDefinition" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {  
        [EntityBase addGridDefinition:grid];
    }
    level--;
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}
-(SearchDefinition2 *)findDefinitionByTitle:(NSString *)titleName
{
    for(SearchGroup *group in searchGroups)
    {
        for(SearchDefinition2 *definition in group.searchDefinitions)
        {
            if([definition.title caseInsensitiveCompare:titleName]==NSOrderedSame)
                return definition;
        }
    }
    return nil;
}
-(SearchDefinition2 *)findDefaultMapDefinition
{
for(SearchGroup *group in searchGroups)
{
    for(SearchDefinition2 *definition in group.searchDefinitions)
    {
        if(definition.isDefaultMap)
            return definition;
    }
}
return nil;

}
@end
