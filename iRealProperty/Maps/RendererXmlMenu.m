#import "RendererXmlMenu.h"
#import "AxDataManager.h"
#import "MapLayerConfig.h"
#import "RealPropertyApp.h"
#import "Helper.h"

//
//===================================================================
//
@implementation RendererMenu

@synthesize menuCaption = _menuCaption;
@synthesize click = _click;
@synthesize rendName = _rendName;
@synthesize menus = _menus;
@synthesize parent = _parent;

-(NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"{menuCaption=%@\nclick=%d\nrendName=%@\nparent=0x%x\n{", _menuCaption, _click, _rendName, (unsigned int)_parent];
    
    for(int i=0;i<[_menus count];i++)
    {
        result = [result stringByAppendingFormat:@"{%d {%@}\n}\n",i,[[_menus objectAtIndex:i]description]];
    }
    return result;
}
@end
//
//===================================================================
//

@implementation RendererXmlMenu

@synthesize rootMenu = _rootMenu;

#pragma mark -- Init with file
-(id)initWithXMLFile:(NSString *)xmlFile
{
    self = [super init];
    if(self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *fileName = [[documentDirectory stringByAppendingPathComponent:xmlFile] stringByAppendingString:@".xml"];
        NSURL *url;
        
        // Get it from the existing bundle
        NSString *filePath = [[NSBundle mainBundle] pathForResource:xmlFile ofType:@"xml"];

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
    [Helper alertWithOk:@"Invalid menuStructure.xml" message:message];
    
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
        if([elementName caseInsensitiveCompare:@"MenuStructure"]==NSOrderedSame)
        {
            currentElement = @"MenuStructure";
        }
        else
        {
            [self abortWithMsg:@"Expected MenuStructure"];
        }
    }
    else if([currentElement caseInsensitiveCompare: @"MenuStructure"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"ParcelMenu"]==NSOrderedSame)
        {
            currentElement = @"ParcelMenu";
            if(_rootMenu==nil)
                _rootMenu = [[RendererMenu alloc]init];
            _currentMenu = _rootMenu;
        }
        else
        {
            [self abortWithMsg:@"Expected ParcelMenu"];
        }
    }
    else if([currentElement caseInsensitiveCompare:@"ParcelMenu"]==NSOrderedSame || [currentElement caseInsensitiveCompare:@"Parent"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"Parent"]==NSOrderedSame || [elementName caseInsensitiveCompare:@"Click"]==NSOrderedSame)
        {
            currentElement = elementName;
            // Got a new menu element
            _menu = [[RendererMenu alloc]init];
            _menu.menuCaption = [attributeDict valueForKey:@"menucaption"];
            _menu.rendName = [attributeDict valueForKey:@"rendname"];
            if([elementName caseInsensitiveCompare:@"Click"]==NSOrderedSame)
            {
                _menu.click = YES;
            }
            if(_currentMenu.menus==nil)
                _currentMenu.menus = [[NSMutableArray alloc]init];
            _menu.parent = _currentMenu;
            [_currentMenu.menus addObject:_menu];
            _currentMenu = _menu;
        }
        else
        {
            [self abortWithMsg:@"Expected Parent or Click"];
        }
    }
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName caseInsensitiveCompare:@"Click"]==NSOrderedSame)
    {
        currentElement = @"Parent";
        _currentMenu = _currentMenu.parent;       
    }
    else if([elementName caseInsensitiveCompare:@"Parent"]==NSOrderedSame)
    {
        _currentMenu = _currentMenu.parent;
        if(_currentMenu.parent == _rootMenu)
            elementName = @"ParcelMenu";
        else
            elementName = @"Parent";
        
    }
    else if([elementName caseInsensitiveCompare:@"parcelMenu"]==NSOrderedSame)
    {
        currentElement = @"MenuStructure";
    }
    else if([elementName caseInsensitiveCompare:@"MenuStructure"]==NSOrderedSame)
    {
        currentElement = nil;
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}


@end
