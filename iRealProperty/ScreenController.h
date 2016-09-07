
#import <UIKit/UIKit.h>
#import "AxGridPictController.h"
#import "GridController.h"
#import "SQLEntity.h"
#import "GridControlBarView.h"
#import "AxDelegates.h"
#import "EntityBase.h"
#import "KeyboardController.h"


enum GridManagementConstant {
    kGridNewContent = 0,
    kGridViewContent
};


#define kBackgroundView 1000

@class ItemDefinition;
@class ComboBoxView;
@class RealPropInfo;
@class RealProperty;
@class EnvRes;
@class ComboBoxController;
@class DVModelController;


@interface ScreenController : KeyboardController<UITextFieldDelegate,
                                                    UITextViewDelegate,
                                                    CheckBoxDelegate,
                                                    ComboBoxDelegate,
                                                    GridDelegate,
                                                    ModalViewControllerDelegate,
                                                    BaseViewDelegate>
    {   
        ScreenDefinition *screenDefinition; // the current screen definition
        
        NSString    *backupFieldText;       // Hold text between 2 edits
        BOOL        isCanceling;            // when TRUE, do not check field values
        
        NSString    *defaultSort;           // property used for default sorting
        BOOL        defaultSortOrderAsc;    // direction of the sorting
    }
    // Global property controller - all tabs report to it
    @property(nonatomic, strong) RealProperty *propertyController;

    // If there is a UIViewController in between
    @property(nonatomic, weak) ScreenController *itsController;
    // List of entities on this tab
    @property(nonatomic, strong) NSArray *entities;
    // Media Controller attached to this page
    @property(nonatomic, strong) AxGridPictController *mediaController;
    // List of all the grids in the current page
    @property(nonatomic, strong) NSMutableDictionary *gridList;

    // List of all the other controllers in the current page
    @property(nonatomic, strong) NSMutableDictionary *controllerList;
    // the base entity used for this screen
    @property(nonatomic, strong) NSManagedObject *workingBase; 

    // If there have been any changes in one of the views
    @property(nonatomic) BOOL isDirty;
    // if the view has only new content
    @property(nonatomic) BOOL isNewContent;
    // The current index in a list of controllers (ifd the screen controller was created from a list)
    @property(nonatomic) int screenIndex;

    // return TRUE if the firstResponder does not want to exit
    -(BOOL)checkTextfieldsAreValid;

    -(ItemDefinition *)findEntityByView:(UIView *)view;
    -(ItemDefinition *)findEntityByName:(NSString *)name;
    -(UIView *)findViewByEntityName:(NSString *)name;
    -(void) addMedia:(int)tagId mediaArray:(NSArray *)medias;

    // Method is called whenever a field has changed
    -(void)entityContentHasChanged:(ItemDefinition *)entity;

    // Business RUles methods
    -(BOOL)validateBusinessRules;
    // Called before filling the form. Base entity is the entity to use to check. detail.isNew indicates if it is a brand new entity
    -(void)setupBusinessRules:(id)baseEntity;
    -(BOOL)shouldSaveData;
    -(void)setupGrid:(id)tempBaseEntity withItem:(ItemDefinition *)item;

    // Update grid and object the first time
    -(void)gridUpdateContent:(GridController *)grid;
    -(void)objectUpdateContent:(id)controller;

    // Refresh the content
    -(void)setScreenEntities;

    // Disable or enable fields based on tagId
    -(void)enableFieldWithTag:(int)tagId enable:(BOOL)enable;

    // Return first Grid in the list
    -(GridController *)getFirstGridController;

    // Refresh current medias
    -(void)refreshMedias:(NSArray *)medias;
    -(void)refreshMedias;

    // SetEntityValue: change the value of a property
    -(void)setEntityValue:(NSManagedObject *)base withPath:(NSString *)path value:(id)value;
    -(void)setEntityValueWithInt:(NSManagedObject *)base withPath:(NSString *)path value:(int)value;
    -(id)getEntityValue:(NSManagedObject *)base withPath:(NSString *)path;

    -(BOOL)shouldSwitchView:(NSManagedObject *)baseEntity;

    -(int)validationError:(int)errorType;
    -(NSArray *)validationErrorList;
    -(void)cancelValidationError;

    // Internal functions
    +(BOOL)checkIfEntitiesHaveValue:(id)baseEntity withScreen:(ScreenDefinition *)screen;

    -(void)debugTags;
    -(void)debugTypes;
    -(void)debugLabels;

    -(void)deleteMedia:(id)media;

@end

