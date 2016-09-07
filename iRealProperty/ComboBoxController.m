#import "ComboBoxController.h"
#import "StreetController.h"
#import "DatePicker.h"
#import "Helper.h"

@implementation ComboBoxController;

@synthesize popoverController;
@synthesize streetController;
@synthesize comboListItems;
@synthesize comboBoxSelectedItem;
@synthesize selectedItem;
@synthesize textAlign;
@synthesize comboBoxStyle;
@synthesize delegate;
@synthesize datePicker;
@synthesize dateSelection;
@synthesize enabled;
@synthesize required;

- (id)initWithArrayAndViewRect:(NSArray *)luitems :(ComboBoxView *)cmbView
{
    self = [super init];
    if(self)
    {
        self.comboListItems = luitems;
        self.view = cmbView;
        self.textAlign = NSTextAlignmentLeft;
        enabled = YES;
    }
    return self;
}
- (id)initForDate:(CGRect)viewRect
{
    self = [super init];
    if(self)
    {
        self.comboListItems = nil;
        ComboBoxView *view = [[ComboBoxView alloc]initWithFrame:viewRect];
        view.itsController = self;
        self.textAlign = NSTextAlignmentLeft;
        self.comboBoxStyle = kComboBoxStyleDate;
        self.view = view;
        enabled = YES;
    }
    return self;
    
}
-(void)initPercent:(int)maximum increment:(int)increment
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for(int pc=0;pc<=maximum;pc += increment)
    {
        NSString *str = [NSString stringWithFormat:@"%d", pc];
        [array addObject:str];
    }
    enabled = YES;
    self.comboListItems = array;
    self.comboBoxStyle = kComboBoxStylePercent;
}

//cv 8_6_13
-(void)initPercentNeg:(int)maximum increment:(int)increment
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for(int pc=0; pc >= maximum;pc += increment)
    {
        
        NSString *str = [NSString stringWithFormat:@"%d", pc];
        //NSLog(@"%@ ",str);
        [array addObject:str];
    }
    enabled = YES;
    self.comboListItems = array;
    self.comboBoxStyle = kComboBoxStylePercent;
}

- (id)initForPercent:(CGRect)viewRect maximum:(int)maximum increment:(int)increment
{
    self = [super init];
    if(self)
    {
        [self initPercent:maximum increment:increment];
        ComboBoxView *view = [[ComboBoxView alloc]initWithFrame:viewRect];
        view.itsController = self;
        self.textAlign = NSTextAlignmentLeft;
        self.view = view;
        enabled = YES;
    }
    return self;
    
}
-(id)initForStrings:(NSArray *)array inRect:(CGRect)viewRect
{
    self = [super init];
    if(self)
    {
        self.comboListItems = array;
        self.comboBoxStyle = kComboBoxStyleText;
        ComboBoxView *view = [[ComboBoxView alloc]initWithFrame:viewRect];
        view.itsController = self;
        self.textAlign = NSTextAlignmentLeft;
        self.view = view;
        enabled = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
//
// Implement the click in the display
//
- (void)clickInCombox
{
    if(!enabled)
        return;
    ComboBoxView *view = (ComboBoxView *)self.view;

    if([delegate respondsToSelector:@selector(willDisplayList:)])
        [delegate performSelector:@selector(willDisplayList:) withObject:self.view];
    
    CGRect rect = CGRectMake(view.frame.size.width /2, 20, 1.0, 1.0);

    if(comboBoxStyle==kComboBoxStyleLUItems)
    {
        popoverController = [[ComboBoxPopOver alloc] initWithArrayAndViewRect:comboListItems inView:view destRect:rect selectedRow:rowIndex];
        popoverController.delegate = self;
    }
    else if(comboBoxStyle==kComboBoxStyleStreet)
    {
        streetController = [[StreetController alloc]initWithdViewAndRect:view destRect:rect];
        streetController.delegate = self;
    }
    else if(comboBoxStyle==kComboBoxStyleDate)
    {
        // Select the date
        datePicker = [[DatePicker alloc]initWithParams:view destRect:rect date:dateSelection];
        datePicker.delegate = self;
    }
    else if(comboBoxStyle==kComboBoxStylePercent)
    {
        popoverController = [[ComboBoxPopOver alloc] initWithArrayAndViewRect:comboListItems inView:view destRect:rect selectedRow:rowIndex withMaxItems:21];
        popoverController.delegate = self;
    }
    else if(comboBoxStyle==kComboBoxStyleText)
    {
        popoverController = [[ComboBoxPopOver alloc] initWithArrayAndViewRect:comboListItems inView:view destRect:rect selectedRow:rowIndex withMaxItems:[comboListItems count]];
        popoverController.delegate = self;
    }
}                                                                                  
- (LUItems2 *)getSelectedItem
{
    return comboBoxSelectedItem;
}
//
// Setup the default value in the box. For LUItems, the number is the LUItemId
// 
-(void)setSelection:(int)selection
{
    if([self.view isKindOfClass:[ComboBoxView class]])
        ((ComboBoxView *)(self.view)).index = selection;
    if(comboBoxStyle==kComboBoxStyleLUItems)
    {
        rowIndex = 0;
         // Get the list of items
        comboBoxSelectedItem = nil;
        for(LUItems2 *item in comboListItems)
        {
            if(item.LUItemId==selection)
            {
                comboBoxSelectedItem = item;
                break;
            }
            rowIndex++;
        }
        if(comboBoxSelectedItem==nil)
            return;
        selectedItem = selection;
        
        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setComboItem:comboBoxSelectedItem];
    }
    else if(comboBoxStyle == kComboBoxStyleStreet)
    {
        streetId = selection;
    }
    else if(comboBoxStyle == kComboBoxStylePercent)
    {
        rowIndex = selection/5;
        percent = selection;
        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setComboItemWithString:[NSString stringWithFormat:@"%d%%",selection]];
    }
    else if(comboBoxStyle == kComboBoxStyleText)
    {
        selectedItem = selection;
        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setComboItemWithString:[comboListItems objectAtIndex:selection]];
    }
}
//
// Display the date from global to local
//
-(void)setSelectionDate:(NSDate *)date
{
    NSDateComponents *components;
    
    self.comboBoxStyle = kComboBoxStyleDate;
    dateSelection = [date copy];
    ComboBoxView *view = (ComboBoxView *)self.view;
    
    if (date)
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    if(dateSelection== nil || ([components year]==1899 && [components month]==12 && [components day]==31))
        [view setComboItemWithString:@"n/a"];
    else
        [view setComboItemWithString:[Helper stringFromDate:dateSelection]];
}
-(int)getSelection
{
    if(comboBoxStyle==kComboBoxStyleLUItems)
    {
        return selectedItem;
    }
    else if(comboBoxStyle == kComboBoxStyleStreet)
    {
        return streetId;
    }
    else if(comboBoxStyle == kComboBoxStylePercent)
    {
        return percent;
    }
    else if(comboBoxStyle==kComboBoxStyleText)
    {
        return selectedItem;
    }
   return -1;
}
-(NSDate *)getSelectionDate
{
    return [dateSelection copy];
}
// Setup the text in the drop-box (no other choices)
-(void)setSelectionWithText:(NSString *)selection
{
    ComboBoxView *view = (ComboBoxView *)self.view;
    [view setComboItemWithString:selection];
}
-(void)popoverItemSelected:(id)item
{
    [self popoverItemSelected:item index:0];
}
// Call back if the item has been selected
- (void)popoverItemSelected:(id)object index:(int)index
{
    if([object isKindOfClass:[LUItems2 class]])
    {
        LUItems2 *item = (LUItems2 *)object;

        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setIndex:index];
        [view setComboItem:item];
        
        NSNumber *number = [[NSNumber alloc]initWithInt:item.LUItemId];
        [delegate comboxBoxClicked:self.view value:number];
        rowIndex = 0;
        // Get the list of items
        for(LUItems2 *it in comboListItems)
        {
            if(it.LUItemId==item.LUItemId)
                break;
            rowIndex++;
        }
        return;
    }
    else if([object isKindOfClass:[NSNumber class]] && comboBoxStyle==kComboBoxStyleStreet)
    {
        int stId = [(NSNumber *)object intValue];
        ComboBoxView *view = (ComboBoxView *)self.view;
        NSString *street = [StreetDataModel getStreetNameFromStreetId:stId];
        [view setComboItemWithString:street];

        NSNumber *number = [[NSNumber alloc]initWithInt:stId];
        [delegate comboxBoxClicked:self.view value:number];
    }
    else if([object isKindOfClass:[NSDate class]])
    {
        dateSelection = [object copy];
        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setComboItemWithString:[Helper stringFromDate:dateSelection]];

        [delegate comboxBoxClicked:self.view value:dateSelection];
    }
    else if([object isKindOfClass:[NSString class]] && comboBoxStyle==kComboBoxStylePercent)
    {
        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setComboItemWithString:object];
        
        NSNumber *number = [[NSNumber alloc]initWithInt:[object intValue]];
        [delegate comboxBoxClicked:self.view value:number];
        rowIndex = number.intValue / 5;
        return;
    }
    else if([object isKindOfClass:[NSString class]] && comboBoxStyle==kComboBoxStyleText)
    {
        ComboBoxView *view = (ComboBoxView *)self.view;
        [view setComboItemWithString:object];
        [view setIndex:index];
        
        int i;
        for(i=0;i<[comboListItems count];i++)
        {
            if([(NSString *)[comboListItems objectAtIndex:i]compare:(NSString *)object]==NSOrderedSame)
                break;
                
        }
        
        NSNumber *number = [[NSNumber alloc]initWithInt:i];
        [delegate comboxBoxClicked:self.view value:number];
        rowIndex = number.intValue;
        selectedItem = i;
        return;
    }
}
-(void) setEnabled:(BOOL)value
{
    enabled = value;
    [((ComboBoxView *)self.view) setEnabled:value];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    popoverController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
