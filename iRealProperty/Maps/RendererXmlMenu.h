#import <Foundation/Foundation.h>

@class RendererMenu;

@interface RendererXmlMenu:NSObject<NSXMLParserDelegate> 
{
    NSString    *currentElement;

    // the XML parser
    NSXMLParser *xmlParser; 

    // Working variables
    RendererMenu       *_currentMenu;
    RendererMenu        *_menu;
    
    // List of objects
    RendererMenu       *_rootMenu;

}
@property(nonatomic, strong) RendererMenu *rootMenu;

-(id)initWithXMLFile:(NSString *)xmlFile;
@end
//
// Definition of the <MenuStructure> ================================
//
@interface RendererMenu : NSObject
{
@protected
    NSString    *_menuCaption;
    BOOL        _click;
    NSString    *_rendName;
    RendererMenu *_parent;
    // Possible list of sub-menus
    NSMutableArray     *_menus; // or clicks
}
@property(nonatomic, strong) NSString *menuCaption;
@property(nonatomic) BOOL click;
@property(nonatomic, strong) NSString *rendName;
@property(nonatomic, strong) NSMutableArray *menus;
@property(nonatomic, strong) RendererMenu *parent;
@end
