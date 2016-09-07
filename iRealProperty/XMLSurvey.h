#import <Foundation/Foundation.h>

@interface SurveyObject:NSObject

// Title of the item
@property(nonatomic, strong) NSString *title;
// Text for the help (if any) -- not required
@property(nonatomic, strong) NSString *help;
// Text for default value
@property(nonatomic, strong) NSString *defaultValue;
// Text for filter
@property(nonatomic, strong) NSString *filter;
// True if it requires number only (just for value)
@property(nonatomic) BOOL isNumerical;
// Position of the text in % -- 50% is middle of the survey
@property(nonatomic) int position;  
// Item type
@property(nonatomic) enum {
        kSurveyText,
        kSurveyLine,
        kSurveyCheckbox,
        kSurveyInput,
        kSurveyDate,
        kSurveyChoices
        } itemType;
// List of choices when in a multiple choice type
@property(nonatomic, strong) NSArray *choices;
// Maxum number of characters (or equivalent)
@property(nonatomic) int maxChars;
//--- objects created dynamically
@property(nonatomic, strong) UIButton *btnHelp;
@property(nonatomic, strong) UILabel *viewLabel;
@property(nonatomic, strong) id viewObject;
@end

@interface SurveyDefinition : NSObject

@property(nonatomic) int surveyTag;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *desc;

@property(nonatomic, strong) NSMutableArray *surveyObjects; // Of type SurveyObject

@end

@interface XMLSurvey : NSObject<NSXMLParserDelegate>
{
    NSString    *_currentElement;
    
    // the XML parser
    NSXMLParser *_xmlParser; 
    
    // Working variables
    SurveyDefinition *_surveyDefinition;
    SurveyObject *_surveyItem;
    int _surveyTag;
    
}
@property(nonatomic, strong) NSMutableArray *surveys;
-(id)initWithXMLFile:(NSString *)xmlFile;

@end
