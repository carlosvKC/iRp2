
#import "RendererXmlLabel.h"
#import "Helper.h"
#import <ArcGIS/ArcGIS.h>
#import "AxDataManager.h"
#import "iRealProperty.h"
#import "ItemDefinition.h"
#import "EntityStructure.h"
#import "EntityBase.h"
#import "RealPropertyApp.h"
@implementation RendererLabel
//
//===================================================================
//

@synthesize name = _name;
@synthesize labelSpec1 = _labelSpec1;
@synthesize labelSpec2 = _labelSpec2;
@synthesize labelSpecA = _labelSpecA;
@synthesize labelSpecB = _labelSpecB;
@synthesize labelSpecC = _labelSpecC;
@synthesize minAltitude = _minAltitude;
@synthesize maxAltitude = _maxAltitude;
@synthesize entity = _entity;
@synthesize whereClause = _whereClause;
@synthesize expression = _expression;
@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
@synthesize fontColor = _fontColor;
@synthesize fontBold = _fontBold;
@synthesize fontItalic = _fontItalic;
@synthesize variables = _variables;

-(NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"{name=%@\nentity=%@\nwhereClause=%@\nexpression=%@\n}", _name, _entity, _whereClause, _expression];

    return str;
}
-(void)cleanUp
{
    [_cacheLabels removeAllObjects];
    _cacheLabels = nil;
    _emptyArray = nil;
    [_currentContext reset];
    _currentContext = nil;
}
-(NSArray*)getLabelsForGraphic: (AGSGraphic*)graphic withCenter: (AGSPoint*)center;
{
    NSNumber* rpId = [graphic.attributes valueForKey:@"RealPropId"];

    if(_cacheLabels==nil)
    {
        _cacheLabels = [[NSMutableDictionary alloc]initWithCapacity:100];
        _emptyArray = [[NSMutableArray alloc]init];
    }
    
    NSArray *cacheArray  = [_cacheLabels objectForKey:rpId];
    if(cacheArray!=nil)
    {
        // Parcel exists, but totally not used...
        if([cacheArray count]==0)
            return nil;

        return cacheArray;
    }
    
    if(_currentContext==nil)
    {
        _currentContext = [AxDataManager createManagedObjectContextFromContextName:@"default"];
        if(_currentContext==nil)
        {
            NSLog(@"Can't obtain a MOB");
            return nil;
        }
    }

    NSManagedObject *managedObject = nil;
    
    @try 
    {
        // First thing, get to the real PropInfo
        managedObject = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"realPropId=%d", [rpId intValue]] andContext:_currentContext];
        if(managedObject==nil)
        {
            [_cacheLabels setObject:_emptyArray forKey:rpId];
            return nil;
        }        
        // Second thing, get the object from the entity name
        id entity = [ItemDefinition getItemValue:managedObject property:_entity];
        if(entity==nil || [entity isKindOfClass:[NSString class]])
        {
            [_cacheLabels setObject:_emptyArray forKey:rpId];
            return nil;
        }
        if([entity isKindOfClass:[NSSet class]] && [entity count] > 0)
        {
            entity = [[((NSSet*)entity) allObjects] objectAtIndex:0];
        }
        
        // Now validate that the where clause is actually valid
        if([_whereClause length]>0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[ItemDefinition replaceDateFilter:_whereClause]];
            
            if(![predicate evaluateWithObject:entity])
            {
                [_cacheLabels setObject:_emptyArray forKey:rpId];
                return nil;                
            }
        }
        
        NSMutableArray * labels = [[NSMutableArray alloc] init];
        _fontColor = [_fontColor colorWithAlphaComponent:1.0]; // deactivate tranparency in font
        
        // Convert the expression 

        NSArray *tokens = [_expression componentsSeparatedByString:@"&"];
        NSString* templateText = @"";
        NSMutableArray* labelsTextArray = [[NSMutableArray alloc] init];
        
        for(int i=0;i<[tokens count];i++)
        {
            NSString *token = [tokens objectAtIndex:i];
            
            NSString* trimmedToken = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([trimmedToken compare:@"vbCrLf" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                // new line
                if ([templateText length] > 0)
                {
                    [labelsTextArray addObject:templateText];
                }
                templateText = @"";
            } 
            else if (![trimmedToken hasPrefix:@"\""])
            {
                NSString *path = trimmedToken;
                int type = ftText;
                if([path hasSuffix:@".lookup"] || [path hasSuffix:@".desc"])
                    type = ftLookup;

                NSString *result = [ItemDefinition getStringValue:entity withPath:trimmedToken withType:type withLookup:1];
                if(result==nil)
                    result = @"";
                templateText = [templateText stringByAppendingString:result];
            }
            else if ([trimmedToken hasPrefix:@"\""] && [trimmedToken hasSuffix:@"\""])
            {
                // just remove the quotations and it will be a literal
                trimmedToken = [trimmedToken substringFromIndex:1];  
                trimmedToken = [trimmedToken substringToIndex:([trimmedToken length] - 1)];
                
                templateText = [templateText stringByAppendingString:trimmedToken];
            }
        }
        
        if ([templateText length] > 0)
        {
            [labelsTextArray addObject:templateText];
        }
        double lineHeight = _fontSize + 2.0;
        double yoffset = - ((lineHeight*[labelsTextArray count])/2.0);
        
        for (NSString* text in labelsTextArray) 
        {
            AGSTextSymbol* textSymbol = [AGSTextSymbol textSymbolWithTextTemplate:text color:_fontColor];
            textSymbol.fontFamily = _fontName;
            textSymbol.fontSize = _fontSize ;
            textSymbol.yoffset = yoffset;
            textSymbol.hAlignment = AGSTextSymbolHAlignmentCenter;
            textSymbol.vAlignment = AGSTextSymbolVAlignmentMiddle;
            yoffset += lineHeight;
            
            if (_fontItalic)
            {
                textSymbol.fontStyle = AGSTextSymbolFontStyleItalic;
            }
            
            if (_fontBold)
            {
                textSymbol.fontWeight = AGSTextSymbolFontWeightBold;
            }
            
            AGSGraphic* myLabel =
            [AGSGraphic graphicWithGeometry:[graphic geometry] symbol:textSymbol attributes:nil infoTemplateDelegate:nil];
            
            [labels addObject:myLabel];
        }
        [_cacheLabels setObject:labels forKey:rpId];
        return labels;
    }
    @catch (NSException *exception) 
    {
        NSLog(@"XML Label error '%@'", exception);
        return nil;
    }
}
@end
//
//===================================================================
//

@implementation RendererXmlLabel

@synthesize labels = _labels;

#pragma mark -- Init with file
-(id)initWithXMLFile:(NSString *)xmlFile
{
    self = [super init];
    if(self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *fileName = [[documentDirectory stringByAppendingPathComponent:xmlFile] stringByAppendingString:@".xml"];
        
        // Get it from the existing bundle
        NSString *filePath = [[NSBundle mainBundle] pathForResource:xmlFile ofType:@"xml"];
        NSURL *url;        
        if(filePath!=nil)
            url = [[NSURL alloc]initFileURLWithPath:filePath];
        else
            url = [[NSURL alloc]initFileURLWithPath:fileName];
        
        xmlParser = [[NSXMLParser alloc]initWithContentsOfURL:url];
        [xmlParser setDelegate:self];
        [xmlParser setShouldProcessNamespaces:NO];
        [xmlParser setShouldReportNamespacePrefixes:NO];
        [xmlParser setShouldResolveExternalEntities:NO];
        
        [xmlParser parse];
        
        currentElement = nil;
        
    }
    return self;
}
-(void)abortWithMsg:(NSString *)message
{
    [Helper alertWithOk:@"Invalid LabelSets.xml" message:message];
    
    [xmlParser abortParsing];
}
#pragma mark NSXMLParserDelegate methods
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self abortWithMsg:[parseError localizedDescription]];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(currentElement==nil)
    {
        if([elementName caseInsensitiveCompare:@"LabelSets"]==NSOrderedSame)
        {
            currentElement = @"LabelSets";
        }
        else
        {
            [self abortWithMsg:@"Expected LabelSets"];
        }
    }
    else if([currentElement caseInsensitiveCompare: @"LabelSets"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"LabelSet"]==NSOrderedSame)
        {
            _label = [[RendererLabel alloc]init];
            _label.name = [attributeDict valueForKey:@"name"];
            currentElement = @"LabelSet";
        }
        else
        {
            [self abortWithMsg:@"Expected LabelSet"];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"LabelSet"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"LabelSpecs"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else if([elementName caseInsensitiveCompare:@"Entity"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else if([elementName caseInsensitiveCompare:@"WhereClause"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else if([elementName caseInsensitiveCompare:@"Expr"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else if([elementName caseInsensitiveCompare:@"Font"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else if([elementName caseInsensitiveCompare:@"Var"]==NSOrderedSame)
        {
            if(_label.variables==nil)
                _label.variables = [[NSMutableDictionary alloc]init];
            [_label.variables setValue:[self getVarType:[attributeDict valueForKey:@"value"] type:[attributeDict valueForKey:@"type"]] forKey:[attributeDict valueForKey:@"name"]];
        }
        else
        {
            [self abortWithMsg:@"Unexpected value"];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"Font"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"FontSpecs"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else if([elementName caseInsensitiveCompare:@"Color"]==NSOrderedSame)
        {
            currentElement = [elementName copy];
        }
        else
        {
            [self abortWithMsg:@"Unexpected value"];
        }
        
    }
}
-(id)getVarType:(NSString *)value type:(NSString *)aType
{
    id defaultValue;
    if([aType caseInsensitiveCompare:@"num"]==NSOrderedSame)
    {
        defaultValue = [[NSNumber alloc]initWithInt:[defaultValue intValue]];
    }
    else if([aType caseInsensitiveCompare:@"string"]==NSOrderedSame)
    {
        defaultValue = value;
    }
    else if([aType caseInsensitiveCompare:@"date"]==NSOrderedSame)
    {
        defaultValue = [Helper dateFromString:value];
    }
    else 
    {
        NSLog(@"Wrong type. Use string instead");
        defaultValue = value;
    }
    return defaultValue;
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName caseInsensitiveCompare:@"FontSpecs"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"Color"]==NSOrderedSame )
    {
        currentElement = @"Font";

    }
    else if([elementName caseInsensitiveCompare:@"LabelSpecs"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"Entity"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"WhereClause"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"Expr"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"Font"]==NSOrderedSame )
    {
        currentElement = @"LabelSet";
    }
    else if([elementName caseInsensitiveCompare:@"LabelSet"]==NSOrderedSame)
    {
        currentElement = @"LabelSets";
        if(_labels==nil)
            _labels = [[NSMutableArray alloc]init];
        [_labels addObject:_label];
    }
    else if([elementName caseInsensitiveCompare:@"LabelSets"]==NSOrderedSame)
    {
        currentElement = nil;
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([currentElement caseInsensitiveCompare:@"LabelSpecs"]==NSOrderedSame)
    {
        // Label specs - expect 2 numbers, 2 bool, 3 numbers
        NSArray *nums = [string componentsSeparatedByString:@","];
        if([nums count]!=7)
        {
            NSLog(@"Expected 7 arguments in labelSpecs");
            return;
        }
        _label.minAltitude = [[nums objectAtIndex:0]intValue];
        _label.maxAltitude = [[nums objectAtIndex:1]intValue];
        _label.labelSpec1 = [[nums objectAtIndex:2] caseInsensitiveCompare:@"yes"]==NSOrderedSame?YES:NO;
        _label.labelSpec2 = [[nums objectAtIndex:3] caseInsensitiveCompare:@"yes"]==NSOrderedSame?YES:NO;
        _label.labelSpecA = [[nums objectAtIndex:4]intValue];
        _label.labelSpecB = [[nums objectAtIndex:5]intValue];
        _label.labelSpecC = [[nums objectAtIndex:6]intValue];
        
    }
    else if([currentElement caseInsensitiveCompare:@"Entity"]==NSOrderedSame)
    {
        _label.entity = [string copy];
    }
    else if([currentElement caseInsensitiveCompare:@"WhereClause"]==NSOrderedSame)
    {
        if(_label.whereClause == nil)
            _label.whereClause = @"";
        _label.whereClause = [_label.whereClause stringByAppendingString:string];
    }
    else if([currentElement caseInsensitiveCompare:@"Expr"]==NSOrderedSame)
    {
        if(_label.expression == nil)
            _label.expression = @"";
        _label.expression = [_label.expression stringByAppendingString:string];
    }
    else if([currentElement caseInsensitiveCompare:@"FontSpecs"]==NSOrderedSame)
    {
        NSArray *nums = [string componentsSeparatedByString:@","];
        _label.fontName = [nums objectAtIndex:0];
        _label.fontSize = [[nums objectAtIndex:1]intValue];
        _label.fontBold = [[nums objectAtIndex:2] caseInsensitiveCompare:@"yes"]==NSOrderedSame?YES:NO;
        _label.fontItalic = [[nums objectAtIndex:3] caseInsensitiveCompare:@"yes"]==NSOrderedSame?YES:NO;
    }
    else if([currentElement caseInsensitiveCompare:@"Color"]==NSOrderedSame)
    {
        NSArray *nums = [string componentsSeparatedByString:@","];
        if([nums count]!=4)
        {
            NSLog(@"Expected 4 arguments in color");
            return;
        }
        CGFloat alpha = ([[nums objectAtIndex:0]intValue]/255.0);
        CGFloat red = ([[nums objectAtIndex:1]intValue]/255.0);
        CGFloat green = ([[nums objectAtIndex:2]intValue]/255.0);
        CGFloat blue = ([[nums objectAtIndex:3]intValue]/255.0);
        _label.fontColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];        
    }
}

@end
