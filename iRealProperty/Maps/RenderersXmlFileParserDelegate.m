#import "RenderersXmlFileParserDelegate.h"
#import "ColorPicker.h"
#import "LabelSet.h"

@implementation RenderersXmlFileParserDelegate

@synthesize currentElement = _currentElement;
@synthesize error = _error;
@synthesize classBreakRenderers = _classBreakRenderers;
@synthesize uniqueValueRenderers = _uniqueValueRenderers;
@synthesize labelSetsByRenderer = _labelSetsByRenderer;

#pragma mark -
#pragma mark NSXMLParserDelegate methods

#ifdef _ZORRO_
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
    //Save the error
	self.error = parseError;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	self.currentElement = elementName;
    if (!_rootNodeFinded)
    {
        if ([self.currentElement isEqualToString:@"AllRenderers"])
        {
            _rootNodeFinded = true;
            parsingClassBreakRenderer = false;
            parsingUniqueValueRenderer = false;
            parsingRI = FALSE;
            _labelSetsByRenderer = [[NSMutableDictionary alloc]init];
        }
        else 
        {
            NSDictionary* dict = [NSDictionary dictionaryWithObject:@"The file is not a renderers xml" forKey:NSLocalizedDescriptionKey];
			self.error = [[NSError alloc] initWithDomain:@"Parsing renderers xml" code:0 userInfo:dict];
			[parser abortParsing]; 
            return;
        }
    }
    
    if ([self.currentElement isEqualToString:@"ClassBreakRenderers"])
    {
		self.classBreakRenderers = [[NSMutableDictionary alloc]init];
    }
    else if ([self.currentElement isEqualToString:@"UniqueValueRenderers"])
    {
        self.uniqueValueRenderers = [[NSMutableDictionary alloc] init];
    }
    else if ([self.currentElement isEqualToString:@"ClassBreakRenderer"])
    {
        _currentClassBreakRenderer = [[AGSClassBreaksRenderer alloc] init];
        _labelSets = [[NSMutableArray alloc] init];
        _renderers = [[NSMutableArray alloc] init];
        parsingClassBreakRenderer = TRUE;
        _rendererName = [attributeDict valueForKey:@"name"];
        _RIValue = NULL;
        _RILabel = NULL;
        _RIColor = NULL;
        [_classBreakRenderers setValue:_currentClassBreakRenderer forKey:_rendererName];
        [_labelSetsByRenderer setValue:_labelSets forKey:_rendererName];
        
    }
    else if ([self.currentElement isEqualToString:@"UniqueValueRenderer"])
    {
        _currentUniqueValueRenderer = [[AGSUniqueValueRenderer alloc] init];
        parsingUniqueValueRenderer = TRUE;
        _labelSets = [[NSMutableArray alloc] init];
         _renderers = [[NSMutableArray alloc] init];
        _rendererName = [attributeDict valueForKey:@"name"];
        _RIValue = NULL;
        _RILabel = NULL;
        _RIColor = NULL;
        [_uniqueValueRenderers setValue:_currentUniqueValueRenderer forKey:_rendererName];
        [_labelSetsByRenderer setValue:_labelSets forKey:_rendererName];

    }
    else if ([self.currentElement isEqualToString:@"RI"])
    {
        parsingRI = TRUE;
    }
    else if ([self.currentElement isEqualToString:@"LabelSet"])
    {
        _currentLabelSet = [[LabelSet alloc] init];
        _currentLabelSet.name = [attributeDict valueForKey:@"name"];
        [_labelSets addObject:_currentLabelSet];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value
{
   
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([value length] < 1)
    {
        return;
    }
    if ([self.currentElement isEqualToString:@"FieldName"]){
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([value length] < 1)
        {
            return;
        }

        NSArray* fieldNameComponents = [value componentsSeparatedByString:@" - "];
        if (_currentClassBreakRenderer != NULL) {
            if ([fieldNameComponents count] > 1)
            {
                _currentClassBreakRenderer.field = [NSString stringWithFormat:@"%@", [fieldNameComponents objectAtIndex:1]];
                if ([(NSString*)[fieldNameComponents objectAtIndex:0] compare:@"GISMAPDATA"] != NSOrderedSame)
                {
                     NSLog(@"RENDERERSPARSER There is a class break renderer field without GISMAPDATA: %@", value);
                }
            }
            else {
                _currentClassBreakRenderer.field = [NSString stringWithFormat:@"%@", value];
                NSLog(@"RENDERERSPARSER There is a class break renderer field without GISMAPDATA: %@", value);
            }
        }
        else if (_currentUniqueValueRenderer != NULL) {
            if ([fieldNameComponents count] > 1)
            {
                _currentUniqueValueRenderer.field1 = [NSString stringWithFormat:@"%@", [fieldNameComponents objectAtIndex:1]];
                if ([(NSString*)[fieldNameComponents objectAtIndex:0] compare:@"GISMAPDATA"] != NSOrderedSame)
                {
                    NSLog(@"RENDERERSPARSER There is a class break renderer field without GISMAPDATA: %@", value);
                }
            }
            else {
                _currentUniqueValueRenderer.field1 = [NSString stringWithFormat:@"%@", value];
                NSLog(@"RENDERERSPARSER There is a class break renderer field without GISMAPDATA: %@", value);
            }
        }
    }
    else if ([self.currentElement isEqualToString:@"Lbl"])
    {
        if (parsingRI)
        {	
            if (_RILabel == nil)
            {
                _RILabel = value;
            }
            else {
                _RILabel = [NSString stringWithFormat:@"%@%@",_RILabel, value];
            }
        }
    }
    else if ([self.currentElement isEqualToString:@"LBrk"])
    {
        if (parsingRI)
        {
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([value length] < 1)
            {
                return;
            }
            _RILBrk = [value doubleValue];
        }
    }
    else if ([self.currentElement isEqualToString:@"UBrk"])
    {
        if (parsingRI)
        {
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([value length] < 1)
            {
                return;
            }
            _RIUBrk = [value doubleValue];
        }
    }
    else if ([self.currentElement isEqualToString:@"Val"])
    {
        if (parsingRI)
        {
            if (_RIValue == nil)
                _RIValue = value;
            else 
                _RIValue = [_RIValue stringByAppendingString:value];
        }
    }
    else if ([self.currentElement isEqualToString:@"Color"])
    {
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([value length] < 1)
        {
            return;
        }
        if (parsingRI)
        {
            _RIColor = [NSString stringWithFormat:@"{%@}", value];
        }
        else if (_currentLabelSet != NULL)
        {
            _currentLabelSet.fontColor = [UIColor colorWithByteString:[NSString stringWithFormat:@"{%@}", value]];
        }
    }
    else if ([self.currentElement isEqualToString:@"LabelSpecs"])
    {
       if (_currentLabelSet != NULL)
       {
           _currentLabelSet.labelSpecs = value;
           // parse label specs
           NSArray* labelSpecsComponents = [value componentsSeparatedByString:@","];
           //format minZoom,maxZoom,?,?,?,?,?... ejm 201,5000,True,False,0,0,2
           if ([labelSpecsComponents count] > 2)
           {
               _currentLabelSet.minZoom = [(NSString*)[labelSpecsComponents objectAtIndex:0] doubleValue]; 
               
               _currentLabelSet.maxZoom = [(NSString*)[labelSpecsComponents objectAtIndex:1] doubleValue];
           }
       }
    }
    else if ([self.currentElement isEqualToString:@"Expr"])
    {
        if (_currentLabelSet != NULL)
        {
            if (_currentLabelSet.expression == nil)
                _currentLabelSet.expression = value;
            else
                _currentLabelSet.expression = [_currentLabelSet.expression stringByAppendingString:value];
        }
    }
    else if ([self.currentElement isEqualToString:@"WhereClause"])
    {
        if (_currentLabelSet != NULL)
        {
            if (_currentLabelSet.whereClause == NULL)
            {
                _currentLabelSet.whereClause = value;
            }
            else {
                _currentLabelSet.whereClause= [_currentLabelSet.whereClause stringByAppendingString:value];
            }
        }
    }
    else if ([self.currentElement isEqualToString:@"FontSpecs"])
    {
        if (_currentLabelSet != NULL)
        {
            // parse font specs value;
             NSArray* fontSpecsComponents = [value componentsSeparatedByString:@","];
            // expected format: fontFamily,fontSize,bold,italic,?,?
            if ([fontSpecsComponents count] > 3)
            {
                _currentLabelSet.fontFamily = [fontSpecsComponents objectAtIndex:0];
                _currentLabelSet.fontSize = [(NSString*)[fontSpecsComponents objectAtIndex:1] doubleValue];
                _currentLabelSet.fontBold = [(NSString*)[fontSpecsComponents objectAtIndex:2] boolValue];
                _currentLabelSet.fontItalic = [(NSString*)[fontSpecsComponents objectAtIndex:3] boolValue];
            }
        }

    }
   
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"ClassBreakRenderer"])
    {
        if (_currentClassBreakRenderer != NULL)
        {
            [_currentClassBreakRenderer setClassBreaks:_renderers];
        }
        _currentClassBreakRenderer = NULL;
        parsingClassBreakRenderer = FALSE;
        _rendererName = NULL;
        _RIValue = NULL;
        _RILabel = NULL;
        _RIColor = NULL;
        
    }
    else if ([elementName isEqualToString:@"UniqueValueRenderer"])
    {
        if (_currentUniqueValueRenderer != NULL)
        {
            [_currentUniqueValueRenderer.uniqueValues addObjectsFromArray:_renderers];
        }
        _currentUniqueValueRenderer = NULL;
        parsingUniqueValueRenderer = FALSE;
        _rendererName = NULL;
        _RIValue = NULL;
        _RILabel = NULL;
        _RIColor = NULL;
        _RILBrk = 0;
        _RIUBrk = 0;
    }
    else if ([elementName isEqualToString:@"RI"])
    {
        if (parsingClassBreakRenderer)
        {
            AGSSimpleFillSymbol* fillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithByteString:_RIColor] outlineColor:[UIColor blackColor]];
            _RILabel = [_RILabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            AGSClassBreak* classBreak = [[AGSClassBreak alloc] initWithLabel:_RILabel description:@"" maxValue:_RIUBrk symbol:fillSymbol];
            
            [_renderers addObject:classBreak];
        }
        else if (parsingUniqueValueRenderer)
        {
            AGSSimpleFillSymbol* fillSymbol = [AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithByteString:_RIColor] outlineColor:[UIColor blackColor]];
            
            AGSUniqueValue* uniqueValue = [[AGSUniqueValue alloc] initWithValue:[_RIValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] label:[_RILabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] description:@"" symbol:fillSymbol];
            
            [_renderers addObject:uniqueValue];
        }
        parsingRI = FALSE;
        _RIValue = NULL;
        _RILabel = NULL;
        _RIColor = NULL;
        _RILBrk = 0;
        _RIUBrk = 0;
    }
    else if ([elementName isEqualToString:@"LabelSet"])
    {
        //_currentLabelSet.expression = [[[_currentLabelSet.expression stringByReplacingOccurrencesOfString:@"[" withString:@"${"] stringByReplacingOccurrencesOfString:@"]" withString:@"}"] stringByReplacingOccurrencesOfString:@"&" withString:@""];
        _currentLabelSet = NULL;
    }

}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
}
#endif

@end
