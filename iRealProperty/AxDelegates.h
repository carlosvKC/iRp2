
#ifndef Ax_Delegate_h
#define Ax_Delegate_h

typedef  void(^BlockWithArray)(NSArray *array);


@protocol ModalViewControllerDelegate <NSObject>

- (void)didDismissModalView:(NSObject *)dialog saveContent:(BOOL)saveContent;
@end

enum{
    kResBldg = 1,
    kCndoBldg =2,
    kCmlBldg =3,
    kAccy =4,
    kMobile=5,
    kMediaBldg
};

//=============== GRID DELEGATE ==========
@protocol GridDelegate <NSObject>
// Return the content of a cell (when the delegate provides the information
-(id)getCellData:(id)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex;

// Number of rows in the grid
-(int)numberOfRows:(id)grid;

// Return TRUE if the delegate provides the data (instead of the attached arrays)
-(BOOL)getDataFromDelegate:(id)grid;

@optional
// A grid has been selected
-(void)gridMediaSelection:(id)grid media:(id)media columnIndex:(int)columnIndex;

// An add a picture button has been selected
-(void)gridMediaAddPicture:(id)grid;

// Sorting is requested to be performed
-(void)headerSortSelection:(id)grid entityDefinition:(id)def;

// Draw an image --called when an entity of type ftImg is foumd
-(void)drawImgEntity:(id)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex intoRect:(CGRect)rect;

// Button action from the associated grid control bar
-(void)gridControlBarAction:(id)grid action:(int)param;

-(void)gridMediaAddCad:(id)grid;

-(void)gridMediaAddCad:(id)grid mediaType:(int)kMediaBldg;


// a long button has been pressed on this cell
-(void)gridMediaLongSelection:(id)grid inCell:(id)cell withMedia:(id)media;

// Filtering is requested to be performed
-(void)headerFilterSelection:(id)grid entityDefinition:(id)def;
-(void)headerFilterSelection;
-(void)gridFilterRetrieveUniqueEntries:(id)grid columnIndex:(int)columnIndex completion:(BlockWithArray)code;
-(void)gridFilterLoadASyncData:(id)target selector:(SEL)selector title:(NSString *)tile ;
// A row has been selected
-(void)gridRowSelection:(id)grid rowIndex:(int)rowIndex;
-(void)gridRowSelection:(id)grid rowIndex:(int)rowIndex selected:(BOOL)selected;


@end


// Delegate to receive the combo box popover (internal)
@protocol ComboBoxPopOverDelegate <NSObject>
@optional
- (void)popoverItemSelected:(id)item;
-(void)popoverItemSelected:(id)item index:(int)index;
@end

// Delegate when implementing a combox box
@protocol ComboBoxDelegate <NSObject>
- (void) comboxBoxClicked:(id)comboBoxView value:(id)value;
@optional
- (void) willDisplayList:(id)comboBoxView;
@end

// Delegate when implementing a check box
@protocol CheckBoxDelegate <NSObject>
-(void) checkBoxClicked:(id)checkBox isChecked:(BOOL)checked;
@end

// Delegate for the menu bar
@protocol MenuBarDelegate<NSObject>
@optional
// A button has been selected. Pass the associated tag
-(void)menuBarBtnSelected:(int)tag;
// The back button has been clicked
-(void)menuBarBtnBackSelected;
@end

@protocol MenuTableDelegate<NSObject>
// A menu item is selected
-(void)menuTableMenuSelected:(NSString *)menuName withTag:(int)tag withParam:(id)param;
@optional
-(void)menuTableBeforeDisplay:(NSString *)menuName withItems:(NSArray *)array;

@end

@protocol BaseViewDelegate<NSObject>

-(void)swipeRight;
-(void)swipeLeft;
-(void)swipeTop;
-(void)swipeBottom;

@end

#endif
