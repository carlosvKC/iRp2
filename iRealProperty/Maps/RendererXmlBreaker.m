#import "RendererXmlBreaker.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "Helper.h"
#import "RendererXmlLabel.h"
#import "RealPropertyApp.h"
#import "Sale.h"
#import "ItemDefinition.h"
#import "ArcGisViewController.h"
#import "UIColor+Hex.h"
#import "ColorPicker.h"
#import "MapLayerConfig.h"
#import "LayerInfo.h"
//
//===================================================================
//

@implementation Renderer

@synthesize value = _value;
@synthesize label = _label;
@synthesize color = _color;
@synthesize fillSymbol = _fillSymbol;

-(NSString *)description
{
    int red=0, green=0, blue=0, alpha=0;
    if(_color!=nil)
    {
        CGColorRef colorRef = [_color CGColor];
        const CGFloat *components = CGColorGetComponents(colorRef);
        red = components[0]*255.0;
        green = components[1]*255.0;
        blue = components[2]*255.0;
        alpha = components[3]*255.0;
    }
    
    NSString *result =  [NSString stringWithFormat:@"{ value=%@\nlabel=%@\n RGB-A=%d,%d,%d - %d }\n", _value,_label, red,green,blue,alpha];

    return result;
}
@end

@implementation UniqueValueRenderer

@synthesize rendererName = _rendererName;
@synthesize entityName = _entityName;
@synthesize lookupId = _lookupId;
@synthesize fieldName = _fieldName;
@synthesize whereClause = _whereClause;
@synthesize renderers = _renderers;
@synthesize labelSets = _labelSets;
@synthesize variables = _variables;

-(NSString *)description
{
    NSString *base = [NSString stringWithFormat:@"renderName=%@\nentityName=%@\nlookupId=%d\nfieldName=%@\nwhereClause=%@\n", _rendererName, _entityName, _lookupId, _fieldName, _whereClause];
                    
    for(Renderer *renderer in _renderers)
    {
        NSString *desc = [renderer description];
        base = [base stringByAppendingString:desc];
    }
    return base;
}
-(void)cleanUp
{
    [_graphicCache removeAllObjects];
    _graphicCache = nil;
    [_currentContext reset];
    _currentContext = nil;
}
-(void)addToCache:(id)symbol forPropId:(NSNumber *)realPropId
{
    if(_graphicCache==nil)
    {
        _graphicCache = [[NSMutableDictionary alloc]initWithCapacity:100];
    }
    if(symbol==nil)
        symbol = _graphicNull;
    [_graphicCache setObject:symbol forKey:realPropId];
}
-(AGSSymbol *)symbolForGraphic:(AGSGraphic *)graphic timeExtent:(AGSTimeExtent *)timeExtent
{
    if(_graphicNull==nil)
    {
        MapLayerConfig *layerConfig = [ArcGisViewController getConfigFromLayerName:@"Parcel"];
        
        _graphicNull = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithString:layerConfig.fillColor] outlineColor:[UIColor colorWithString:layerConfig.lineColor]];    
        _graphicNull.style = AGSSimpleFillSymbolStyleSolid;

    }
    
    NSNumber* propId = [graphic.attributes valueForKey:@"RealPropId"];
    
    AGSSymbol *result = [_graphicCache objectForKey:propId];
    if(result!=nil)
    {
        return result;
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
    id property, entity;

    @try 
    {
        // First thing, get to the real PropInfo
        managedObject = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"realPropId=%d", [propId intValue]] andContext:_currentContext];
        if(managedObject==nil)
        {
            [self addToCache:_graphicNull forPropId:propId];
            return _graphicNull;
        }        
        // Second thing, get the object from the entity name
        unichar ch = [_entityName characterAtIndex:0 ];
        NSString *name = _entityName;
        if(ch >='A' && ch <='Z')
        {
            name = [_entityName lowercaseString];
        }
        entity = [ItemDefinition getItemValue:managedObject property:name];
        if(entity==nil || [entity isKindOfClass:[NSString class]])
        {
            [self addToCache:_graphicNull forPropId:propId];
            return _graphicNull;
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
                [self addToCache:_graphicNull forPropId:propId];
                return _graphicNull;                
            }

        }
        
        property = [ItemDefinition getItemValue:entity withPath:_fieldName withType:0 withLookup:0];
        
        if(property==nil || ![property isKindOfClass:[NSNumber class]])
        {
            [self addToCache:_graphicNull forPropId:propId];
            return _graphicNull;
        }

        double value = [property doubleValue];
        
        for(int i=0;i<[_renderers count];i++)
        {
            Renderer *render = [_renderers objectAtIndex:i];
            if(value <= [render.value doubleValue])
            {
                [self addToCache:render.fillSymbol forPropId:propId];
                return render.fillSymbol;
            }
        }
        
        
        [self addToCache:_graphicNull forPropId:propId];
        return _graphicNull;
    }
    @catch (NSException *exception) 
    {
        NSLog(@"Render predicate error '%@'", exception);
        
    }

}

@end

@implementation RendererXmlBreaker

@synthesize allRenderers = _allRenderers;
@synthesize allLabels;

#pragma mark -- Init with file
-(id)initWithXMLFile:(NSString *)xmlFile withLabels:(NSArray *)labels
{
    self = [super init];
    if(self)
    {
        allLabels = labels;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *fileName = [[documentDirectory stringByAppendingPathComponent:xmlFile]stringByAppendingString:@".xml"];
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
    [Helper alertWithOk:@"Invalid Renderers.xml" message:message];
    
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
        if([elementName caseInsensitiveCompare:@"AllRenderers"]==NSOrderedSame)
        {
            currentElement = @"AllRenderers";
        }
        else
        {
            [self abortWithMsg:@"Expected AllRenderers"];
        }
    }
    else if([currentElement caseInsensitiveCompare: @"AllRenderers"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"UniqueValueRenderers"]==NSOrderedSame)
        {
            currentElement = @"UniqueValueRenderers";
        }
        else
        {
            [self abortWithMsg:@"Expected UniqueValueRenderers"];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"UniqueValueRenderers"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"UniqueValueRenderer"]==NSOrderedSame)
        {
            currentElement = @"UniqueValueRenderer";
            _uniqueValueRenderer = [[UniqueValueRenderer alloc]init];
            _uniqueValueRenderer.rendererName = [attributeDict valueForKey:@"RendererName"];
            if(_allRenderers==nil)
                _allRenderers = [[NSMutableArray alloc]init];
            [_allRenderers addObject:_uniqueValueRenderer];
        }
        else
        {
            [self abortWithMsg:@"expected UniqueValueRenderer"];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"UniqueValueRenderer"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"Entity"]==NSOrderedSame)
            currentElement = @"Entity";
        if([elementName caseInsensitiveCompare:@"RendererName"]==NSOrderedSame)
            currentElement = @"RendererName";
        else if([elementName caseInsensitiveCompare:@"LuTypeId"]==NSOrderedSame)
            currentElement = @"LuTypeId";
        else if([elementName caseInsensitiveCompare:@"FieldName"]==NSOrderedSame)
            currentElement = @"FieldName";
        else if([elementName caseInsensitiveCompare:@"WhereClause"]==NSOrderedSame)
            currentElement = @"WhereClause";
        else if([elementName caseInsensitiveCompare:@"Renderers"]==NSOrderedSame)
            currentElement = @"Renderers";
        else if([elementName caseInsensitiveCompare:@"LabelSets"]==NSOrderedSame)
            currentElement = @"LabelSets";
        else if([elementName caseInsensitiveCompare:@"Var"]==NSOrderedSame)
        {
            if(_uniqueValueRenderer.variables==nil)
                _uniqueValueRenderer.variables = [[NSMutableDictionary alloc]init];
            [_uniqueValueRenderer.variables setValue:[self getVarType:[attributeDict valueForKey:@"value"] type:[attributeDict valueForKey:@"type"]] forKey:[attributeDict valueForKey:@"name"]];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"LabelSets"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"LabelSet"]==NSOrderedSame)
        {
            if(_uniqueValueRenderer.labelSets==nil)
                _uniqueValueRenderer.labelSets = [[NSMutableArray alloc]init];
            for(RendererLabel *label in allLabels)
            {
                if([label.name caseInsensitiveCompare:[attributeDict valueForKey:@"name"]]==NSOrderedSame)
                {
                    [_uniqueValueRenderer.labelSets addObject:label];
                    break;
                }
            }
        }
    }
    else if([currentElement caseInsensitiveCompare:@"Renderers"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"RI"]==NSOrderedSame)
        {
            currentElement = @"RI";
            _renderer = [[Renderer alloc]init];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"RI"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"Val"]==NSOrderedSame)
            currentElement = @"Val";
        else if([elementName caseInsensitiveCompare:@"Lbl"]==NSOrderedSame)
            currentElement = @"Lbl";
        else if([elementName caseInsensitiveCompare:@"Color"]==NSOrderedSame)
            currentElement = @"Color";
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
    if([elementName caseInsensitiveCompare:@"Val"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"Lbl"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"Color"]==NSOrderedSame)
    {
        currentElement = @"RI";
    }
    else if([elementName caseInsensitiveCompare:@"Entity"]==NSOrderedSame ||
            [elementName caseInsensitiveCompare:@"RendererName"]==NSOrderedSame ||
            [elementName caseInsensitiveCompare:@"LuTypeId"]==NSOrderedSame ||
            [elementName caseInsensitiveCompare:@"FieldName"]==NSOrderedSame ||
            [elementName caseInsensitiveCompare:@"Renderers"]==NSOrderedSame ||
            [elementName caseInsensitiveCompare:@"WhereClause"]==NSOrderedSame)
    {
        currentElement = @"UniqueValueRenderer";
    }
    else if([elementName caseInsensitiveCompare:@"RI"]==NSOrderedSame)
    {
        currentElement = @"Renderers";
        if(_uniqueValueRenderer.renderers==nil)
            _uniqueValueRenderer.renderers = [[NSMutableArray alloc]init];
        [_uniqueValueRenderer.renderers addObject:_renderer];
    }
    else if([elementName caseInsensitiveCompare:@"UniqueValueRenderer"]==NSOrderedSame)
    {
        currentElement = @"UniqueValueRenderers";
    }
    else if([elementName caseInsensitiveCompare:@"UniqueValueRenderers"]==NSOrderedSame)
    {
        currentElement = @"AllRenderers";
    }
    else if([elementName caseInsensitiveCompare:@"LabelSets"]==NSOrderedSame)
    {
        currentElement = @"UniqueValueRenderer";
    }
    else if([elementName caseInsensitiveCompare:@"LabelSet"]==NSOrderedSame)
    {
        currentElement = @"LabelSets";
    }
    else if([elementName caseInsensitiveCompare:@"UniqueValueRenderers"]==NSOrderedSame)
    {
        currentElement = nil;
    }
    
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([currentElement caseInsensitiveCompare:@"color"]==NSOrderedSame)
    {
        // Label specs - expect 2 numbers, 2 bool, 3 numbers
        NSArray *nums = [string componentsSeparatedByString:@","];
        if([nums count]!=4)
        {
            NSLog(@"Expected 4 arguments in color");
            return;
        }
        CGFloat alpha = ([[nums objectAtIndex:0]intValue]/255.0)/2.0; 
        CGFloat red = ([[nums objectAtIndex:1]intValue]/255.0);
        CGFloat green = ([[nums objectAtIndex:2]intValue]/255.0);
        CGFloat blue = ([[nums objectAtIndex:3]intValue]/255.0);
        _renderer.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        _renderer.fillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:_renderer.color outlineColor:[UIColor blackColor]];
    }
    else if([currentElement caseInsensitiveCompare:@"Val"]==NSOrderedSame)
    {
        _renderer.value = [string copy];
    }
    else if([currentElement caseInsensitiveCompare:@"Lbl"]==NSOrderedSame)
    {
        _renderer.label = [string copy];
    }
    else if([currentElement caseInsensitiveCompare:@"WhereClause"]==NSOrderedSame)
    {
        if(_uniqueValueRenderer.whereClause == nil)
            _uniqueValueRenderer.whereClause = @"";
        _uniqueValueRenderer.whereClause = [_uniqueValueRenderer.whereClause stringByAppendingString:string];
    }
    else if([currentElement caseInsensitiveCompare:@"FieldName"]==NSOrderedSame)
    {
        _uniqueValueRenderer.fieldName = [string copy];
    }
    else if([currentElement caseInsensitiveCompare:@"LuTypeId"]==NSOrderedSame)
    {
        _uniqueValueRenderer.lookupId = [string intValue];
    }
    else if([currentElement caseInsensitiveCompare:@"Entity"]==NSOrderedSame)
    {
        _uniqueValueRenderer.entityName = [string copy];
    }
    else if([currentElement caseInsensitiveCompare:@"RendererName"]==NSOrderedSame)
    {
        _uniqueValueRenderer.rendererName = [string copy];
    }
}

@end


