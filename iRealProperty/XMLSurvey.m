#import "XMLSurvey.h"
#import "AxDataManager.h"
#import "RealPropertyApp.h"
#import "Helper.h"

//
//===================================================================
//
@implementation SurveyObject

@synthesize title, help, defaultValue, isNumerical, position, choices, itemType, filter;
@synthesize btnHelp, viewLabel, viewObject, maxChars;

-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{title = %@\n help = %@\nDefaultValue = %@\nisNumerical = %d position = %d type = %d\n",
                        title, help,defaultValue,isNumerical,position,itemType];
    
    for(int i=0;i<[choices count];i++)
    {
        result = [result stringByAppendingFormat:@"{%d} %@\n",i,[choices objectAtIndex:i]];
    }
    result = [result stringByAppendingString:@"}\n"];
    
    return result;
}
@end

//
//===================================================================
//
@implementation SurveyDefinition

@synthesize surveyTag;

@synthesize title, desc, surveyObjects;

-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{title = %@\n description = %@\n",
                        title, desc];
    
    for(int i=0;i<[surveyObjects count];i++)
    {
        result = [result stringByAppendingFormat:@"%@\n",[surveyObjects objectAtIndex:i]];
    }
    result = [result stringByAppendingString:@"}\n"];
    
    return result;
}

@end

//
//===================================================================
//
@implementation XMLSurvey

@synthesize surveys;
#pragma mark -- Init with file
-(id)initWithXMLFile:(NSString *)xmlFile
{
    self = [super init];
    if(self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *fileName = [documentDirectory stringByAppendingPathComponent:xmlFile];
        NSURL *url = [[NSURL alloc]initFileURLWithPath:fileName];
        
        
        _xmlParser = [[NSXMLParser alloc]initWithContentsOfURL:url];
        [_xmlParser setDelegate:self];
        [_xmlParser setShouldProcessNamespaces:NO];
        [_xmlParser setShouldReportNamespacePrefixes:NO];
        [_xmlParser setShouldResolveExternalEntities:NO];
        
        [_xmlParser parse];
        
        _currentElement = nil;
        
    }
    return self;
}
-(void)abortWithMsg:(NSString *)message
{
    [Helper alertWithOk:@"Invalid Surveys.xml" message:message];
    
    [_xmlParser abortParsing];
}
#pragma mark NSXMLParserDelegate methods
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self abortWithMsg:[parseError localizedDescription]];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    if(_currentElement==nil)
    {
        if([elementName caseInsensitiveCompare:@"Surveys"]==NSOrderedSame)
        {
            _currentElement = @"Surveys";
        }
        else
        {
            [self abortWithMsg:@"Expected Surveys"];
        }
    }
    else if([_currentElement caseInsensitiveCompare: @"Surveys"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"SurveyDefinition"]==NSOrderedSame)
        {
            _currentElement = @"SurveyDefinition";
            _surveyDefinition = [[SurveyDefinition alloc]init];
            _surveyDefinition.title = [attributeDict valueForKey:@"title"];
            _surveyDefinition.desc = [attributeDict valueForKey:@"description"];
            _surveyDefinition.surveyTag = ++_surveyTag;
        }
        else
        {
            [self abortWithMsg:@"Expected SurveyDefinition"];
        }
    }
    else if([_currentElement caseInsensitiveCompare:@"SurveyDefinition"]==NSOrderedSame)
    {
        _currentElement = @"item";
        
        _surveyItem = [[SurveyObject alloc]init];           
        _surveyItem.itemType = kSurveyDate;
        _surveyItem.help = [attributeDict valueForKey:@"help"];
        _surveyItem.position = [attributeDict valueForKey:@"pos"]==nil?50:[[attributeDict valueForKey:@"pos"]intValue];
        _surveyItem.filter = [attributeDict valueForKey:@"filter"];
        _surveyItem.choices = nil;
        _surveyItem.defaultValue = [attributeDict valueForKey:@"default"];
        _surveyItem.title = [attributeDict valueForKey:@"title"];
        
        if([elementName caseInsensitiveCompare:@"text"]==NSOrderedSame)
        {         
            _surveyItem.itemType = kSurveyText;
        }
        else if([elementName caseInsensitiveCompare:@"separator"]==NSOrderedSame)
        {          
            _surveyItem.itemType = kSurveyLine;
        }
        else if([elementName caseInsensitiveCompare:@"checkbox"]==NSOrderedSame)
        {          
            _surveyItem.itemType = kSurveyCheckbox;
        }
        else if([elementName caseInsensitiveCompare:@"input"]==NSOrderedSame)
        {
            _surveyItem.itemType = kSurveyInput;
        }
        else if([elementName caseInsensitiveCompare:@"date"]==NSOrderedSame)
        {
            _surveyItem.itemType = kSurveyDate;
        }
        else if([elementName caseInsensitiveCompare:@"multichoice"]==NSOrderedSame)
        {    
            _surveyItem.itemType = kSurveyChoices;
            _surveyItem.choices = [_surveyItem.defaultValue componentsSeparatedByString:@","];
        }
        else
        {
            [self abortWithMsg:@"Unexpected value"];
        }
    }

}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([_currentElement caseInsensitiveCompare:@"item"]==NSOrderedSame)
    {
        if(_surveyDefinition.surveyObjects==nil)
            _surveyDefinition.surveyObjects = [[NSMutableArray alloc]init];
        [_surveyDefinition.surveyObjects addObject:_surveyItem];
        _currentElement = @"SurveyDefinition";
    }
    else if([elementName caseInsensitiveCompare:@"SurveyDefinition"]==NSOrderedSame)
    {
        if(surveys==nil)
            surveys = [[NSMutableArray alloc]init];
        [surveys addObject:_surveyDefinition];
        _currentElement = @"Surveys";
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}


@end
