#import <UIKit/UIKit.h>
#import "SingleGrid.h"
#import "AxDelegates.h"
#import "BaseNote.h"
@class ControlBar;
@class KeyboardNotes;
@class BaseNote;
@class XMLSurvey;
@class MenuTable;
@class SurveyNote;

enum kTAbNotesConstant {
    kNotesKeyboard = 1,
    kNotesDraw = 2,
    kNotesVoice = 3,
    kNotesSurvey = 4,
    kNotesDelete = 6,
    kNotesTrash = 7
    };

@interface TabNotesController : SingleGrid<MenuBarDelegate, MenuTableDelegate, NoteMgrDelegate >
{
    ControlBar  *menuBar;
    BaseNote *baseNote;
    SurveyNote *surveyNote;
    
    UIViewController *controller;
    
    XMLSurvey *xmlSurvey;
    
    NSMutableArray *surveyMenu;
    MenuTable *menu;
    
    BOOL inEditMode;
}
@property(nonatomic, strong) NSFetchedResultsController *fetchedController;

// Switch to  notes
-(void)baseNote:(id)note;

@end
