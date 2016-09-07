#import "ScreenController.h"
#import "CheckBoxView.h"
#import "ComboBoxController.h"

#import "RealProperty.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import "BaseView.h"
#import "ValidationController.h"

@implementation ScreenController

@synthesize entities;
@synthesize mediaController;
@synthesize gridList;
@synthesize controllerList;
@synthesize propertyController;
@synthesize isDirty;
@synthesize isNewContent;
@synthesize itsController;
@synthesize workingBase;
@synthesize screenIndex;

extern id objc_getClass(const char *);

#pragma mark - Override
//
// This method is called before moving to another Entity Controller or a save
// Return NO to cancel the change
-(BOOL) validateBusinessRules
{
    return YES;
}
-(BOOL) shouldSaveData
{
    return YES;
}
// Called the first time to setup business rules
-(void)setupBusinessRules:(id)baseEntity
{
}
-(void) setupGrid:(id)tempBaseEntity withItem:(ItemDefinition *)item
{
}
// a Grid object has been found, call to initialize it
//
-(void)gridUpdateContent:(GridController *)grid
{
}
-(void) objectUpdateContent:(id)controller
{
}
#pragma mark - Initialize the objects
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    entities = nil;

    if (self) 
    {
        screenDefinition = [EntityBase getScreenWithName:nibNameOrNil];
        entities = screenDefinition.items;
        isDirty = NO;
    
    }
    return self;
}
#pragma mark - Swipe
-(void)swipeTop
{
}
-(void)swipeBottom
{
}
-(void)swipeLeft
{
}
-(void)swipeRight
{
}
#pragma mark - Manage the "temp" entities -- those are used for temporary manipulations

-(void)setWorkingBase:(NSManagedObject *)param
{
    workingBase = param;
}
-(NSManagedObject *)getWorkingBase
{
    return workingBase;
}

#pragma mark - All delegates
//
// Check box has been clicked
//
-(void)checkBoxClicked:(id)checkBox isChecked:(BOOL)checked
{
    // One of the check-box has been clicked
    ItemDefinition *entity = [self findEntityByView:checkBox];
    if(entity==nil)
        return;

    id object = [workingBase valueForKeyPath:entity.path];
    
    if([object isKindOfClass:[NSNumber class]] || object==nil)
    {
        [self setEntityValueWithInt:workingBase withPath:entity.path value:checked];
    }
    else if([object isKindOfClass:[NSString class]])
    {
        if(checked)
            [workingBase setValue:@"Y" forKey:entity.path];
        else
            [workingBase setValue:@"N" forKey:entity.path];
    }
    
    [self entityContentHasChanged:entity];
    isDirty = YES;

}
//
// ComboxBox has been clicked
//
-(void)comboxBoxClicked:(id)comboBox value:(id)newValue
{
    // One of the check-box has been clicked
    ItemDefinition *entity = [self findEntityByView:comboBox];
    if(entity==nil)
        return;
    
    id previousValue = [self getEntityValue:workingBase withPath:entity.path];
    
    BOOL same = NO;
    
    if([previousValue isKindOfClass:[NSNumber class]])
    {
        if([previousValue intValue] == [newValue intValue])
            same = YES;
    }
    else if([previousValue isKindOfClass:[NSDate class]])
    {
        if([previousValue timeIntervalSinceReferenceDate] == [newValue timeIntervalSinceReferenceDate])
            same = YES;
    }
    
    if(!same)
    {
        if([newValue isKindOfClass:[NSNumber class]])
            [self setEntityValue:workingBase withPath:entity.path value:newValue];
        else if([newValue isKindOfClass:[NSDate class]])
        {
            BOOL error = NO;
            @try {
                [self setEntityValue:workingBase withPath:entity.path value:newValue];
            }
            @catch (NSException *exception) {
                error = YES;
            }
            @try {
                if(error)
                {
                    [self setEntityValue:workingBase withPath:entity.path value:newValue];
                     NSNumber *value = [[NSNumber alloc]initWithDouble:[newValue timeIntervalSinceReferenceDate]];
                    [self setEntityValue:workingBase withPath:entity.path value:value];
                }
            }
            @catch (NSException *exception) 
            {
                NSLog(@"Data applied to something that does not take a date!!!!!");
            }
        }
        [self entityContentHasChanged:entity];
        isDirty = YES;
    }
}

#pragma mark - Delegates for both UITextField and UITextView

-(void)textDidBeginEditing:(NSString *)text
{
    backupFieldText = text;

}
-(void)textDidEndEditing:(NSString *)text view:(UIView *)view
{
    if(isCanceling)
        return;
    ItemDefinition *entity = [self findEntityByView:view];

    if([backupFieldText compare:text]==NSOrderedSame)
        return;

    [self entityContentHasChanged:entity];
    isDirty = YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    [self textDidBeginEditing:textField.text];
}
-(void)textViewDidBeginEditing:(UITextView *)textView 
{
    [super textViewDidBeginEditing:textView];
    [self textDidBeginEditing:textView.text];
}

//
// End editing in the text field 
//
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    [self textDidEndEditing:textField.text view:textField];
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [super textViewDidEndEditing:textView];
    [self textDidEndEditing:textView.text view:textView];
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    ItemDefinition *entityDefinition = [self findEntityByView:textView];
    if(entityDefinition==nil || isCanceling)
        return YES;
    
    UIView *subview = [self.view viewWithTag:entityDefinition.tag];
    
    if(subview==nil)
    {
        NSLog(@"Can't find tag=%d", entityDefinition.tag);
        return YES;
    }
    [self setEntityValue:workingBase withPath:entityDefinition.path value:textView.text];
    return YES;
}

// DBaun - This method is key to setting a textField's value in core data

//
// Modify the value of the CoreData entity
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    ItemDefinition *entityDefinition = [self findEntityByView:textField];
    if(entityDefinition==nil)
        return YES;
    if(isCanceling)
        return YES;
    
    if(entityDefinition.required)
    {
        if([textField.text length]==0 || [textField.text intValue]==0)
            textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
        else
           textField.backgroundColor = [RealPropertyApp editableBackgroundColor];
    }
    
    UIView *subview = [self.view viewWithTag:entityDefinition.tag];
    
    if(subview==nil)
    {
        NSLog(@"Can't find tag=%d", entityDefinition.tag);
        return YES;
    }
    @try 
    {
        id value;
        CGFloat numberFloat;
        int numberInt;
        NSString *str;
        switch (entityDefinition.type) 
        {
            case ftURL:
            case ftTextL:
            case ftText:
                value = textField.text;
                break;
            case ftYear:
            case ftInt:
                numberInt = [textField.text intValue];
                value = [NSNumber numberWithInt:numberInt];    
                break;
            case ftNum:
                value = textField.text;
                break;
            case ftFloat:
                str = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                numberFloat = [str floatValue];
                value = [NSNumber numberWithFloat:numberFloat];
                break;
            case ftPercent:
                numberInt = [textField.text intValue];
                if(numberInt <0 || numberInt>100)
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid value" message:@"A percentage must be between 0 and 100" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    alert = 0;
                    // textField.text = backupFieldText;
                    return NO;
                }
                value = [NSNumber numberWithInt:numberInt];
                break;
            case ftCurr:
                str = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                numberInt = [str intValue];
                value = [NSNumber numberWithInt:numberInt];
                break;
            case ftDate:
            {
                NSString *text = textField.text;
                NSDate *date = [Helper dateFromString:text];
                
                if(date==0)
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid value" message:@"A date must be entered in the following format: MM/DD/YYYY" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    alert = 0;
                    // textField.text = backupFieldText;
                    return NO;
                } 
                value = [[NSNumber alloc]initWithDouble:[date timeIntervalSinceReferenceDate]];
            }
                break;
            default:
                break;
                
        }
        [self setEntityValue:workingBase withPath:entityDefinition.path value:value];
    }
    @catch (NSException *exception) 
    {
        NSLog(@"%@", exception.reason);
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void)dealloc
{
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.length==1)
        return YES;
    // Find the correct ItemDefinition
    ItemDefinition *prop;
    for(ItemDefinition *def in entities)
    {
        if(def.tag==textField.tag)
        {
            prop = def;
            break;
        }
    }
    if(prop==nil)
        return NO;
    NSString *allowedChars;
    int defaultLength = 100;
    switch(prop.type)
    {
        case ftText:
            defaultLength = 256;
            allowedChars = nil;
            break;
        case ftTextL:
            allowedChars = nil;
            defaultLength = 2048;
            break;
        case ftNum:
            allowedChars = @"0123456789";
            defaultLength = 10;
            break;
        case ftPercent:
            allowedChars = @"0123456789";
            defaultLength = 3;
            break;
        case ftYear:
            allowedChars = @"0123456789";
            defaultLength = 4;
            break;
        case ftInt:
            allowedChars = @"0123456789";
            defaultLength = 10;
            break;
        case ftCurr:
            allowedChars = @"0123456789.,";
            defaultLength = 20;
            break;
        case ftDate:
            allowedChars = @"0123456890/-";
            defaultLength = 20;
            break;
        case ftFloat:
            allowedChars = @"01234567890.,";
            defaultLength = 20;
            break;
        default:
            return NO;
    }
    
    if(prop.length>0)
        defaultLength = prop.length;
    
    // Check if the characters can be included
    if(allowedChars!=nil)
    {
        NSCharacterSet *allowedSet = [[NSCharacterSet characterSetWithCharactersInString:allowedChars] invertedSet];
        string = [string stringByTrimmingCharactersInSet:allowedSet];
        
        if(string.length==0)
            return NO;
    }
    // Check that the total numberof characters will not be longer than required
    if(textField.text.length + string.length > defaultLength)
        return NO;
    return YES;
}

#pragma mark - Base Entity Utilities

//
// Return the value of an object. Base is the object to start from (it can't be null)
// Path is the value of the entity
//
-(id)getEntityValue:(NSManagedObject *)base withPath:(NSString *)path
{
    if(base==nil)
        return nil;
    return [base valueForKeyPath:[self validateString:path]];
}

//
// Set the value for an entity. The base is the object to start from.
-(void)setEntityValue:(NSManagedObject *)base withPath:(NSString *)path value:(id)value
{
    if(base==nil)
        NSLog(@"setEntityValue: base is nil");
    
    
    
    [base setValue:value forKeyPath:[self validateString:path]];
}


//
// Set the value for an entity. The base is the object to start from.
-(void)setEntityValueWithInt:(NSManagedObject *)base withPath:(NSString *)path value:(int)value
{
    NSNumber *num = [[NSNumber alloc]initWithInt:value];
    [self setEntityValue:base withPath:path value:num];
}


-(NSString *)validateString:(NSString *)string
{
    unichar ch = [string characterAtIndex:0];
    if(ch >= 'A' && ch<='Z')
    {
        NSString *firstParth = [string substringToIndex:1];
        firstParth = [firstParth lowercaseString];
        string = [firstParth stringByAppendingString:[string substringFromIndex:1]];
    }
    return string;
}


#pragma - Create the different fields in the view

//
// Insert the data from the NSManagedObject Entity into the different views
//
// default base is workingBase
//
-(void) setScreenEntities
{
    if(screenDefinition.items==nil /* || [RealProperty realPropInfo]==nil */)
        return;
    
    // Save the entities
    entities = screenDefinition.items;
    
    NSNumber *number;
    NSString *string;
    NSDate *date;
    
    for(ItemDefinition *entityDefinition in entities)
    {
        id object;
        @try
        {
            UIView *subview = [self.view viewWithTag:entityDefinition.tag];
            if(subview==nil)
            {
//#ifdef _DEBUG_SCREEN_
                NSLog(@"setScreenEntities: can't find view with tag=%d",entityDefinition.tag);
//#endif
                continue;
            }
            UITextField *textField = nil;
            UITextView *textView = nil;
            ComboBoxView *comboView = nil;
            CheckBoxView *checkBoxView = nil;
            
            if([subview isKindOfClass:[UITextField class]])
            {
                textField = (UITextField *)subview;
                if(textField.enabled)
                    textField.backgroundColor = [RealPropertyApp editableBackgroundColor];
            }
            else if([subview isKindOfClass:[ComboBoxView class]])
                comboView = (ComboBoxView *)subview;
            else if([subview isKindOfClass:[CheckBoxView class]])
                checkBoxView = (CheckBoxView *)subview;
            else if([subview isKindOfClass:[UITextView class]])
                textView = (UITextView *)subview;
            
            // Get the field based on the info
            if(entityDefinition.type!=ftLabel && entityDefinition.type!=ftEmbedded && entityDefinition.type!=ftGrid)
                object = [self getEntityValue:workingBase withPath:entityDefinition.path];

            number = object;
            string = object;
            date = object;
            
            // Setup the type, and from the database record, the value, for this control.
            switch (entityDefinition.type) 
            {
                case ftLabel:
                {
                    UILabel *view = (UILabel *)subview;
                    view.text = [ItemDefinition getStringValue:workingBase withPath:entityDefinition.path withType:entityDefinition.type withLookup:entityDefinition.lookup];
                }
                    break;
                case ftTextL:
                    textView.text = string;
                    textView.keyboardType = UIKeyboardTypeDefault;
                    break;

                case ftURL:
                case ftText:
                    textField.text = string;
                    textField.keyboardType = UIKeyboardTypeDefault;
                    if(textField.enabled && entityDefinition.required && [textField.text length]==0)
                    {
                        textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
                    }
                    break;
                case ftDate:
                    if(comboView!=nil)
                    {
                        ComboBoxController *cmb = comboView.itsController;
                        [cmb setSelectionDate:date];
                    }
                    break;
                case ftPercent:
                    if(comboView!=nil)
//                    {
//                        ComboBoxController *cmb = comboView.itsController;
//                        [cmb initPercent:entityDefinition.maxPercentValue increment:entityDefinition.percentIncrement];  // Default value
//                        [cmb setSelection:[number intValue]];
//                    }
                    
                    {
                        ComboBoxController *cmb = comboView.itsController;
                        //cv 8_6_13
                        switch (entityDefinition.tag) {
                            
                            case 7:; case 79:; case 80:; case 81:; case 84:; case 85:; case 86:; case 87:; case 88:; case 99:; case 107:; case 108:;
                          case 109:;case 110:; case 111:; case 115:; case 116:      //; case 109:
                                [cmb initPercentNeg:entityDefinition.maxPercentValueNeg increment:entityDefinition.percentIncrementNeg];
                                [cmb setSelection:[number intValue]];
                                break;
//                            case 109:
//                                [self.debugScreenEntities];
//                                break;
                            default:    //case case 97 & 98 are positives
                                [cmb initPercent:entityDefinition.maxPercentValue increment:entityDefinition.percentIncrement];
                                [cmb setSelection:[number intValue]];
                                break;
                        }

                    }
                        break;
                case ftLookup:
                    if(entityDefinition.lookup>0)
                    {
                        // Lookup using LUItems2

                        ComboBoxController *cmb = comboView.itsController;
                        [cmb setSelection:[number intValue]];
                    }
                    else if(entityDefinition.lookup== -1)
                    {
                        // Lookup using the street information
                        ComboBoxController *cmb = comboView.itsController;
                        NSString *street = [StreetDataModel getStreetNameFromStreetId:[number intValue]];
                        [cmb setSelection:[number intValue]];
                        [cmb setSelectionWithText:street];
                    }
                    else if(entityDefinition.lookup== -2)
                    {
                        // Lookup using the current land.zoning (similar to LUItems2)
                        ComboBoxController *cmb = comboView.itsController;
                        [cmb setSelection:[number intValue]];                        
                    }
                    else if(entityDefinition.lookup== -3)
                    {
                        // Lookup using the current Park (similar to LUItems2)
                        ComboBoxController *cmb = comboView.itsController;
                        [cmb setSelection:[number intValue]];
                    }


                    break;
                case ftBool:
                    if([object isKindOfClass:[NSNumber class]])
                        [checkBoxView setChecked:[number intValue]];
                    else if([object isKindOfClass:[UITextField class]])
                    {
                        NSString *text = textField.text;
                        if([text caseInsensitiveCompare:@"Y"]==NSOrderedSame || [text caseInsensitiveCompare:@"YES"]==NSOrderedSame)
                            [checkBoxView setChecked:YES];
                        else                         
                            [checkBoxView setChecked:NO];
                    }
                    checkBoxView.delegate = self;
                    break;
                case ftFloat:
                    textField.text = [NSString stringWithFormat:@"%0.2f",[number floatValue]];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    if(textField.enabled && entityDefinition.required && [number floatValue]==0)
                    {
                        textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
                        textField.text = @"";
                    }
                    break;

                case ftInt:
                    if([number intValue]==0)
                        textField.text = @"";
                    else
                        textField.text = [NSString stringWithFormat:@"%d",[number intValue]];
                    
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    if(textField.enabled && entityDefinition.required && [number intValue]==0)
                    {
                        textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
                    }
                    break;
                case ftNum:
                    if([number intValue]==0)
                        textField.text = @"";
                    else
                        textField.text = [NSString stringWithFormat:@"%d",[number intValue]];

                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    if(textField.enabled && entityDefinition.required && [number intValue]==0)
                    {
                        textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
                    }
                    break;
                case ftCurr:
                    if([number intValue]==0)
                        textField.text = @"";
                    else
                        textField.text = [ItemDefinition formatNumber:[number intValue]];

                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    if(textField.enabled && entityDefinition.required && [number intValue]==0)
                    {
                        textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
                    }
                    break;

                case ftYear:
                    if([number intValue]==0)
                        textField.text = @"";
                    else
                        textField.text = [NSString stringWithFormat:@"%d",[number intValue]];

                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    if(textField.enabled && entityDefinition.required && [number intValue]==0)
                    {
                        textField.backgroundColor = [RealPropertyApp requiredBackgroundColor];
                    }
                   break;
                case ftGrid:
                    [self gridUpdateContent:[gridList valueForKey:entityDefinition.path]];
                    break;
                case ftEmbedded:
                    if(entityDefinition.actionMethod==nil)
                        [self objectUpdateContent:[controllerList valueForKey:entityDefinition.path]];
                    break;
                default:
                    break;
            }
        }
        @catch (NSException *exception)
        {
            NSLog(@"SetScreen:%d name:%@ path:%@ object:%@",entityDefinition.type, entityDefinition.labelName, entityDefinition.path,[[object entity]name]);
        }

    }
}

//
// Setup the alignment based on the types of fields
//
-(void)setScreenAlignment
{
    if(entities==nil)
        return;
    for(ItemDefinition *prop in entities)
    {
        UIView *subview = [self.view viewWithTag:prop.tag];
        if(subview==nil)
            continue;
        UITextField *textField;
       
        if([subview isKindOfClass:[UITextField class]])
            textField = (UITextField *)subview;

        // Setup the type
        switch (prop.type) 
        {
            case ftURL:
            case ftTextL:
            case ftText:
            case ftLookup:
                textField.textAlignment = NSTextAlignmentLeft;
                break;
            case ftDate:
                textField.textAlignment = NSTextAlignmentCenter;
                break;
            case ftFloat:
            case ftPercent:
            case ftNum:
            case ftCurr:
            case ftYear:
            case ftInt:
            default:
                textField.textAlignment = NSTextAlignmentRight;
                break;
        }
    }

}

//
// Loop through the properties to assign the different views
//
- (void)createViewsUsingEntities
{
    if(entities==nil)
        return;
    for(ItemDefinition *prop in entities)
    {
        @try
        {
            UIView *subview = [self.view viewWithTag:prop.tag];
            if(subview==nil)
            {
#ifdef _DEBUG_SCREEN_

                NSLog(@"createViewsUsingEntities: view with tag '%d' not found", prop.tag);
#endif
                continue;
            }
            
            if(prop.type==ftURL)
                continue;
            if(prop.type==ftEmbedded)
            {
                if(subview == nil)
                {
                    NSLog(@"createViewsUsingEntities [ftEmbedded] : Can't find the view with tag=%d", prop.lookup);
                    continue;
                }
                if(prop.actionMethod==nil)
                {
                    // Create another controller and insert it in the view
                    ScreenController *newController = [[NSClassFromString(prop.entityName)alloc]initWithNibName:prop.entityName bundle:nil];
                    if(newController==nil)
                    {
                        NSLog(@"ftEmbedded: can't create the object '%@'", prop.entityName);
                        continue;
                    }
                    newController.propertyController = self.propertyController;
                    newController.itsController = self;
                    [self addChildViewController:newController];
                    CGRect rect = CGRectMake(0, 0, subview.frame.size.width, subview.frame.size.height);

                    newController.view.frame = rect;
                    [subview addSubview:newController.view];
                    
                    if(controllerList==nil)
                        controllerList = [[NSMutableDictionary alloc]init];
                    [controllerList setObject:newController forKey:prop.entityName];
                    continue;
                }
                else 
                {
                    if([subview isKindOfClass:[UIButton class]])
                    {
                        UIButton *btn = (UIButton *)subview;
                        SEL selector = NSSelectorFromString(prop.actionMethod);
                        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
                    }
                }
            }
            if(prop.type==ftGrid)
            {
                // Create a grid -- First, get the overall container view
                if(subview == nil)
                {
                    NSLog(@"createViewsUsingEntities: Can't find the view '%d'", prop.tag);
                    return;  
                }
                GridDefinition *gridDefinition = [EntityBase getGridWithName:prop.entityName];

                if(gridDefinition==nil)
                {
                    NSLog(@"Can't find the grid '%@'", prop.entityName);
                    return;
                }
                GridController *gridController;
                gridController = [[GridController alloc]initWithGridDefinition:gridDefinition];
                gridController.delegate = self;
                // Insert the grid controller into the list of grid controllers for this screen
                if(gridList==nil)
                    gridList = [[NSMutableDictionary alloc]init];
                [gridList setObject:gridController forKey:prop.entityName];

                
                gridController.view = [self.view viewWithTag:gridDefinition.tag];
                
                [self addChildViewController:gridController];
                [gridController viewDidLoad];
                

                // [gridView setBackgroundColor:[UIColor clearColor]];
                continue;
            }
            if(prop.type==ftBool)
            {
                // Check box
                if([subview isKindOfClass:[CheckBoxView class]])
                {
                    CheckBoxView *cb = (CheckBoxView *)subview;
                    if(cb==nil)
                        continue;
                    
                    cb.delegate = self;
                    // Add users right
                    if(prop.editLevel > [RealPropertyApp getUserLevel] || prop.editLevel== -1)
                        cb.enabled = NO;
                    else
                        cb.enabled = YES;
                }
                else
                    NSLog(@"'%@.%@' expects to find a CheckBox view", prop.entityName, prop.path);

                continue;
            }
            if(prop.type==ftTextL)
            {
                UITextView *uiField = (UITextView *)subview;
                uiField.delegate = self;
                if(prop.editLevel > [RealPropertyApp getUserLevel] || prop.editLevel== -1)
                    uiField.editable = NO;
                else
                    uiField.editable = YES;
                continue;
            }
            if(prop.type==ftLookup || prop.type==ftDate || prop.type==ftPercent)
            {
                // Create the controller for the ComboBox
                if([subview isKindOfClass:[ComboBoxView class]])
                {
                    ComboBoxController *cmb = [self CreateComboxController:(ComboBoxView *)subview itemDefinition:prop];
                    // Add users right
                    if(prop.editLevel > [RealPropertyApp getUserLevel] || prop.editLevel== -1)
                        cmb.enabled = NO;
                    else
                        cmb.enabled = YES;

                    cmb.required = prop.required;

                }
                else
                    NSLog(@"%@.%@ expect to find a ComboBox view", prop.entityName, prop.path);
                continue;
            }
            if([subview isKindOfClass:[UILabel class]])
            {
                prop.type = ftLabel;
                continue;
            }
            
            // ok, we have a UITextView
            UITextField *uiText = (UITextField *)subview;
            if(![uiText isKindOfClass:[UITextField class]])
            {
#ifdef _DEBUG_SCREEN_
                NSLog(@"Can't assign object %@.%@", prop.entityName, prop.path);
#endif
                continue;
            }
            uiText.delegate = self;
            // Add user's right
            if(prop.editLevel > [RealPropertyApp getUserLevel] || prop.autoField || prop.editLevel == -1)
            {
                uiText.enabled = NO;
                // Change the back color to light gray
                uiText.backgroundColor = [RealPropertyApp disabledBackgroundColor];
            }
            else
                uiText.enabled = YES;
        }
        @catch (NSException *ex)
        {
            NSLog(@"'%@'", prop);
            NSLog(@"Exception: %@",ex);
        }
    }
   
}
//
// Create a combo box controller
//
-(ComboBoxController *)CreateComboxController:(ComboBoxView *)view  itemDefinition:(ItemDefinition *)entity
{
    NSMutableArray *luitems2 = nil;
    enum ComboBoxStyleConstant style = kComboBoxStyleLUItems;

    // Get the list of items (if positive)
    if((int)entity.lookup>0)
    {
        luitems2 = (NSMutableArray *)[LUItems2 LUItemsFromLookup:(int)entity.lookup];
        if(luitems2==nil)
            return nil;

        style = kComboBoxStyleLUItems;
    }
    else if((int)entity.lookup== -1)    // street lookup
    {
        style = kComboBoxStyleStreet;
    }
    else if((int)entity.lookup== -2)    // land.zoning lookup
    {

        RealPropInfo *info = [RealProperty realPropInfo];
        luitems2 = (NSMutableArray *)[LUItems2 LUItemsFromLookup:(int)entity.lookup districtId:info.districtId];
        if(luitems2==nil)
            return nil;
        
    }
    else if((int)entity.lookup== -3)    // ParkId
    {
        luitems2 = (NSMutableArray *)[LUItems2 LUItemsFromLookup:(int)entity.lookup];
        if(luitems2==nil)
            return nil;
    }
    // Create the comboBox
    ComboBoxController *cmbBoxController = [[ComboBoxController alloc]initWithArrayAndViewRect:luitems2 :view];
    cmbBoxController.comboBoxStyle = style;
    view.itsController = cmbBoxController;
    [self addChildViewController:cmbBoxController];
    cmbBoxController.delegate = self;
    return cmbBoxController;
}
//
// Create the list of medias that is visible. 
//
-(void) addMedia:(int)tagId mediaArray:(NSArray *)medias
{
    UIView *subview = [self.view viewWithTag:tagId];
    // Create the view required for the pictures
    for(int i=0;i<3;i++)
    {
        UIView *subview = [self.view viewWithTag:tagId+i];
        if(subview == nil)
            NSLog(@"Add Media: Can't find the view with tag=%d", tagId+i);
    }
    // Create the controller
    mediaController = [[AxGridPictController alloc]initWithMediaArray:medias destinationViewId:tagId];
    mediaController.view = subview;

    [self addChildViewController:mediaController];
    [mediaController viewDidLoad]; 
    mediaController.delegate = self;
    
}
- (void)refreshMedias:(NSArray *)medias
{
    [mediaController updateMedias:medias];
}
-(void)refreshMedias
{
    [mediaController updateMedias:[RealProperty sortMedia: mediaController.mediaArray]];
}
#pragma mark - Entity Utilities
//
// Return a RealProperty info based on the container view.
//
-(ItemDefinition *)findEntityByView:(UIView *)v
{
    for(ItemDefinition *prop in entities)
    {
        if([self.view viewWithTag:prop.tag] == v)
            return prop;
    }
    return nil;
}
// Return a RealProperty info based on the container name.
-(ItemDefinition *)findEntityByName:(NSString *)nameStr
{
   
    for(ItemDefinition *prop in entities)
    {
        if([[prop labelName] isEqualToString:nameStr])
            return prop;
    }
    return nil;
}
// Return a view based on the label name.
-(UIView *)findViewByEntityName:(NSString *)name
{
    for(ItemDefinition *prop in entities)
    {
        if([[prop labelName] isEqualToString:name])
        {
            return [self.view viewWithTag:prop.tag];
        }
    }
    return nil;
}

//
// Return YES if any entity has a value (i.e. different than 0 or blank)
//
+(BOOL)checkIfEntitiesHaveValue:(id )baseEntity withScreen:(ScreenDefinition *)screen
{
    for(ItemDefinition *prop in screen.items)
    {
        @try
        {
            if([prop.entityName length]==0 || ([prop.path length]==0 && prop.type!=ftGrid))
                continue;

            id object = [ItemDefinition getItemValue:baseEntity property:prop.path]; 
            
            if(object==nil)
                continue;
            
            NSString *string = object;
            NSNumber *number = object;
            NSSet *set = object;
            
            switch (prop.type) 
            {
                case ftURL:
                case ftText:
                case ftTextL:
                    string = [string stringByReplacingOccurrencesOfString:@"_" withString:@""];  
                    if([string length]>0)
                        return YES;
                    break;
                case ftDate:

                    break;
                case ftFloat:
                case ftPercent:
                case ftNum:
                case ftCurr:
                case ftYear:
                case ftBool:
                case ftLookup:
                case ftInt:
                    if([number intValue]!=0)
                        return YES;
                    break;
                case ftGrid:
                    if([set isKindOfClass:[NSSet class]])
                    {
                        if([set count]>0)
                            return YES;
                    }
                    else
                    {
                        // GridController *grid = [gridList valueForKey:entityName];
                        
                    }
                    break;
                default:
                    break;
            }
        }
        @catch (NSException *exception) 
        {
            NSLog(@"exception %@", exception);
            NSLog(@"'%@.%@', type=%d", prop.entityName, prop.path, prop.type);
        }
    }
    return NO;
}
//
// Validate that the required fields are not empty.
//
-(BOOL)shouldSwitchView:(NSManagedObject *)baseEntity
{
    if(baseEntity==nil)
        return YES;
    ValidationController *val = [ValidationController validation];
    [val clearError:self index:screenIndex];
    
    // Required sections
    for(ItemDefinition *prop in screenDefinition.items)
    {
        if(prop.required)
        {
            id object = [ItemDefinition getItemValue:baseEntity property:prop.path]; 
            NSString *string = object;
            NSNumber *number = object;
            
            if(prop.type==ftLookup && prop.type==0)
            {
                NSString *message = [NSString stringWithFormat:@"%@ must have a selection", prop.labelName];
                
                [val addError:self type:kValidationRequired description:message item:prop index:screenIndex];
               
            }
            else if([object isKindOfClass:[NSString class]] && [string length]==0)
            {
                NSString *message = [NSString stringWithFormat:@"%@ cannot be empty", prop.labelName];  
                [val addError:self type:kValidationRequired description:message item:prop index:screenIndex];

            }
            else if([object isKindOfClass:[NSNumber class]] && number.intValue==0)
            {
                NSString *message = [NSString stringWithFormat:@"%@ cannot be null", prop.labelName];
                [val addError:self type:kValidationRequired description:message item:prop index:screenIndex];
            }
        }
    }
    // Validation sections
    
    for(Validation *validation in screenDefinition.validations)
    {
        int value = [ItemDefinition checkValuesInPredicate:validation.evaluate baseEntity:baseEntity];
        if(value == 1)
        {
            int errorType;
            if(validation.warning)
                errorType = kValidationWarning;
            else
            {
                errorType = kValidationError;
            }

            [val addError:self type:errorType description:validation.message item:nil index:screenIndex];
        }
    }
    if([val countErrors:self]==0)
        return YES;
    else
        return NO;

}
-(int)validationError:(int)errorType
{
    ValidationController *val = [ValidationController validation];

    switch(errorType)
    {
        case kValidationRequired:
        case kValidationError:
            return [val countErrors:self];
        case kValidationWarning:
            return [val countWarnings:self];
            
    }
    return 0;
}
-(int)validationErrorNumber
{
    ValidationController *val = [ValidationController validation];
    return [val countErrors:self];
}
-(void)cancelValidationError
{
    ValidationController *val = [ValidationController validation];
    [val clearError:self index:screenIndex];
}
-(NSArray *)validationErrorList
{
    ValidationController *val = [ValidationController validation];
    return [val errorList:self];
}
#pragma mark - Utilities
//
// Return the first entry from the GridDictionary list
//
-(GridController *)getFirstGridController
{
    NSArray *array = [gridList allKeys];
    if([array count]==0)
    {
        NSLog(@"getFirstGridController returns nil!");
        return nil;
    }
    return [gridList objectForKey:[array objectAtIndex:0]];
}
//
// Hide the keyboard when finding the background view (by convention, tag==1000)
//
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.view.tag==kBackgroundView)
    {
        [self.view endEditing:YES];
        return;
    }
    // Enumerate through all the touch objects.
    for (UITouch *touch in touches) 
    {
        for (UIView *aView in [self.view subviews]) 
        {
            if (CGRectContainsPoint([aView frame], [touch locationInView:self.view]) && aView.tag==kBackgroundView)
            {
                [aView endEditing:YES];
                return;
            }
        }
    }	
}

//
// Check if any field will cause an issue
//
-(BOOL)checkTextfieldsAreValid
{
    UIResponder *firstResponder = [Helper findFirstResponder:self.view];
    if(![firstResponder isKindOfClass:[UITextField class]])
        return YES;
    UITextField *textField = (UITextField *)firstResponder;

    return [self textFieldShouldEndEditing:textField]; 
}
// Return the RealPropertyInfo
-(id)getRealPropertyInfo
{
    return [RealProperty realPropInfo];
}
//
// Enable or disable any object. Change the background color if appropriate
//
-(void)enableFieldWithTag:(int)tagId enable:(BOOL)enable
{
    UIView *view = [self.view viewWithTag:tagId];
    if(view==nil)
    {
        NSLog(@"Change Status: can't find the view with Tag:%d", tagId);
        return;
    }
    if([view isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)view;
        textView.editable = enable;
        if(enable)
            textView.backgroundColor = [RealPropertyApp editableBackgroundColor];
        else
            textView.backgroundColor = [RealPropertyApp disabledBackgroundColor];
        
        return;
    }
    if([view isKindOfClass:[UITextField class]])
    {
        UITextField *textView = (UITextField *)view;
        textView.enabled = enable;
        if(enable)
            textView.backgroundColor = [RealPropertyApp editableBackgroundColor];
        else
            textView.backgroundColor = [RealPropertyApp disabledBackgroundColor];
        
        return;
    }    
    if([view isKindOfClass:[ComboBoxView class]])
    {
        ComboBoxView *comboBoxView = (ComboBoxView *)view;
        [comboBoxView setEnabled:enable];
        return;
    }
    if([view isKindOfClass:[CheckBoxView class]])
    {
        CheckBoxView *checkBoxView = (CheckBoxView *)view;
        [checkBoxView setEnabled:enable];
        return;
    }
    if ([view isKindOfClass:[UIButton class]])
    {
        UIButton *uiButtonView = (UIButton *)view;
        uiButtonView.enabled = enable;
        return;
    }
    NSLog(@"Can't change the status of the view with tag=%d", tagId);
}
//
// Copy one entity over the other - Shallow copy
//
-(void)copyEntityFrom:(NSManagedObject *)srcEntity to:(NSManagedObject *)destEntity
{
    NSArray *properties = [[srcEntity entity] properties];
    
    for (NSPropertyDescription *property in properties) 
    {
        if(![property isKindOfClass:objc_getClass("NSAttributeDescription")])
            continue;
        
        [destEntity setValue:[srcEntity valueForKey:[property name]] forKey:[property name]];
    }
}
#pragma mark - Content Management
//
// Override this method to do what is required by the descendant classes
//
-(void)entityContentHasChanged:(ItemDefinition *)entity
{
    if(itsController!=nil)
        [itsController entityContentHasChanged:entity];
}
#pragma mark - Debug Utilities
//-------------------------------------------------- 
// Use debugTags to display all the active tags in the view
//--------------------------------------------------

- (void) debugTags
{
    for(ItemDefinition *prop in entities)
    {
        
        UIView *subview = [self.view viewWithTag:prop.tag];
        if(subview==nil)
            continue;
        UIFont *font = [UIFont systemFontOfSize:12.0];
        NSString *text = [NSString stringWithFormat:@"[%d",prop.tag];
        CGSize size = [text sizeWithFont:font];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.text = text;
        label.font = font;
        label.minimumScaleFactor = 10.0/[UIFont labelFontSize];
        label.backgroundColor = [UIColor lightGrayColor];
        
        [subview addSubview:label];
        
    }

}

//-------------------------------------------------- DEBUG
// Use this method to draw the labels
//--------------------------------------------------
- (void) debugLabels
{
    for(ItemDefinition *prop in entities)
    {

        UIView *subview = [self.view viewWithTag:prop.tag];
        if(subview==nil)
            continue;
        UIFont *font = [UIFont systemFontOfSize:12.0];
        NSString *text = [NSString stringWithFormat:@"[%d] '%@'",prop.tag, prop.labelName];
        CGSize size = [text sizeWithFont:font];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.text = text;
        label.font = font;
        label.minimumScaleFactor = 10.0/[UIFont labelFontSize];
        label.backgroundColor = [UIColor lightGrayColor];
        
        [subview addSubview:label];

    }
}
//-------------------------------------------------- DEBUG
// Use this method to draw the type of a view...
//--------------------------------------------------
- (void) debugTypes
{
    for(ItemDefinition *prop in entities)
    {
        NSString *text;
        switch (prop.type) {
            case ftAuto:
                text = @"Auto";
                break;
            case ftBool:
                text = @"Bool";
                break;
            case ftCurr:
                text = @"Curr";
                break;
            case ftLookup:
                text = [NSString stringWithFormat:@"L(%d)", prop.lookup];
                break;
            case ftImg:
                text = @"Img";
                break;
            case ftNum:
                text = @"Num";
                break;
            case ftInt:
                text = @"Int";
                break;
            case ftURL:
                text = @"URL";
                break;
            case ftDate:
                text = @"Date";
                break;
            case ftGrid:
                text = @"Grid";
                break;
            case ftEmbedded:
                text = @"Embedded";
                break;
            case ftText:
                text = @"Text";
                break;
            case ftLabel:
                text = @"Label";
                break;
            case ftYear:
                text = @"Year";
                break;
            case ftFloat:
                text = @"Float";
                break;
            case ftTextL:
                text = @"TextLong";
                break;
            case ftPercent:
                text = @"%";
                break;
            default:
                text = @"????";
                break;
        }
        
        
        UIView *subview = [self.view viewWithTag:prop.tag];
        if(subview==nil)
            continue;
        UIFont *font = [UIFont systemFontOfSize:12.0];
        CGSize size = [text sizeWithFont:font];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.text = text;
        label.font = font;
        label.minimumScaleFactor = 10.0/[UIFont labelFontSize];
        label.backgroundColor = [UIColor lightGrayColor];
        
        [subview addSubview:label];
    }
}
///////////////////////////////////////////////////////////
// debug content
///////////////////////////////////////////////////////////
-(void) debugScreenEntities
{
    if(entities==nil)
        return;
    
    for(ItemDefinition *entityDefinition in entities)
    {
        @try
        {
            NSString *result;
            UIView *subview = [self.view viewWithTag:entityDefinition.tag];
            if(subview==nil)
                continue;
            
            // Get the field based on the info
            id object = [self getEntityValue:workingBase withPath:entityDefinition.path];
            
            NSNumber *number = object;
            NSString *string = object;
            NSDate *date;
            // Setup the type
            switch (entityDefinition.type) 
            {
                case ftURL:
                case ftTextL:
                case ftText:
                case ftLabel:
                    result = string;
                    break;
                case ftLookup:
                    if(entityDefinition.lookup>0)
                    {
                        result = [NSString stringWithFormat:@"[>0]=%d in %d", [number intValue],entityDefinition.lookup];
                    }
                    else if(entityDefinition.lookup== -1)
                    {
                        result = [NSString stringWithFormat:@"[-1]=%d", [number intValue]];
                    }
                    else if(entityDefinition.lookup== -2)
                    {
                        result = [NSString stringWithFormat:@"[-2]=%d", [number intValue]];                       
                    }
                    break;
                case ftBool:
                    result = [NSString stringWithFormat:@"%@",[number intValue]>0?@"Y":@"N"];
                    break;
                case ftFloat:
                    result = [NSString stringWithFormat:@"[F]%0.2f",[number floatValue]];
                    break;
                case ftPercent:
                    result = [NSString stringWithFormat:@"[%%]%d",[number intValue]];
                    break;
                case ftNum:
                    result = [NSString stringWithFormat:@"[num]%d",[number intValue]];
                    break;
                case ftInt:
                    result = [NSString stringWithFormat:@"[int]%@",string];
                    break;
                
                case ftCurr:
                    result = [NSString stringWithFormat:@"[$]%d",[number intValue]];
                    break;
                case ftDate:
                    result = [NSString stringWithFormat:@"[D]%@",[Helper stringFromDate:date  ]];
                    break;
                case ftYear:
                    result = [NSString stringWithFormat:@"[Y]%d",[number intValue]];
                    break;
                case ftGrid:
                    result = [NSString stringWithFormat:@"Grid:%d", entityDefinition.lookup];
                default:
                    break;
            }
            UIFont *font = [UIFont systemFontOfSize:12.0];
            CGSize size = [result sizeWithFont:font];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            label.text = result;
            label.font = font;
            label.minimumScaleFactor = 10.0/[UIFont labelFontSize];
            label.backgroundColor = [UIColor lightGrayColor];
            
            [subview addSubview:label];
        }
        @catch (NSException *exception) {
            NSLog(@"'%@' '%@'", entityDefinition.entityName, entityDefinition.path);
            NSLog(@"Exception in debugScreenentities: %@",exception);
        }
        
    }
    
}
///////////////////////////////////////////////////////////

- (void)gridView:(AxGridView *)gv selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex 
{
}

#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    if([self.view isKindOfClass:[BaseView class]])
    {
        BaseView *baseView = (BaseView *)self.view;
        baseView.delegate = self;
    }
    // ------------------------ DEBUG Leave this function to debug the tags
    //    [self debugTags];
    //    [self debugTypes];
    //   [self debugScreenEntities];
    // [self debugLabels];
    
    // Go through the views to make appropriate changes...
    [self createViewsUsingEntities];
    [self setScreenAlignment];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Grid Delegate (to be overriden)

-(void)gridRowSelection:(NSObject *)grid rowIndex:(int)rowIndex
{
}
-(id)getCellData:(NSObject *)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex
{
    return nil;
}
-(int)numberOfRows:(NSObject *)grid;
{
    return 0;
}
-(void)gridControlBarAction:(int)param
{
}
- (void)didDismissModalView:(NSObject *)dialog saveContent:(BOOL)saveContent
{
}
-(BOOL)getDataFromDelegate:(NSObject *)gridController
{
    return NO;
}
-(void)drawImgEntity:(NSObject *)grid rowIndex:(int)rowIndex columnIndex:(int)columnIndex intoRect:(CGRect)rect
{
    
}
-(void)gridControlBarAction:(NSObject *)grid action:(int)param
{
}
#pragma mark - Media Delegates
//
// An image has been clicked, switch to the picture controller
//
-(void)gridMediaSelection:(id)grid media:(id)media columnIndex:(int)columnIndex
{
}
-(void)gridMediaAddPicture:(id)grid
{
}
#pragma mark - Sorting & Filtering

//
// Provide a sorting based on the content of the grid
//
-(void)headerSortSelection:(NSObject *)grid entityDefinition:(NSObject *)entityDef
{
    GridController *gridController = (GridController *)grid;
    NSArray *rows = [gridController getGridContent];
    ItemDefinition *def = (ItemDefinition *)entityDef;

    BOOL ascending = (def.filterOptions.sortOption==kFilterAscent)?YES:NO;
    
    //  if(def.type==ftDate)
    //    sortOptions = !sortOptions; // Interesting case of sorting...
    
    NSArray *sortedArray = [rows sortedArrayUsingComparator:^NSComparisonResult(id d1, id d2) 
    {
        id obj1 = [ItemDefinition getItemValue:d1 property:def.path];
        id obj2 = [ItemDefinition getItemValue:d2 property:def.path];
        
        int result;
        
        if([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]])
        {
            
            NSString *str1 = obj1;
            NSString *str2 = obj2;
            
            result = [str1 caseInsensitiveCompare:str2];
        }
        else if([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]])
        {
            double val1 = [obj1 doubleValue];
            double val2 = [obj2 doubleValue];
            
            result = val1 - val2;
        }
        else if([obj1 isKindOfClass:[NSDate class]] && [obj2 isKindOfClass:[NSDate class]])
        {
            double val1 = [obj1 timeIntervalSinceReferenceDate];
            double val2 = [obj2 timeIntervalSinceReferenceDate];
            
            result = val1 - val2;
        }
        else
            result = NSOrderedAscending;

        if(!ascending)
            result = -result;
        
        if(result==0)
            return NSOrderedSame;
        if(result>0)
            return NSOrderedDescending;
        else
            return NSOrderedAscending;

    }];
    
    [gridController setGridContent:sortedArray];
    [gridController refreshAllContent];
}
-(void)gridFilterRetrieveUniqueEntries:(id)grid columnIndex:(int)columnIndex completion:(BlockWithArray)code
{
    GridController *gridController = (GridController *)grid;
    NSArray *results = [gridController getGridContent];
    ItemDefinition *col = [gridController.gridEntities objectAtIndex:columnIndex];

    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:results.count];
    
    NSArray *luItems2 = nil;
    
    if(col.type==ftLookup)
        luItems2 = [LUItems2 LUItemsFromLookup:col.lookup];
    
    for(id object in results)
    {
        @try {
            id res = [object valueForKeyPath:col.path];
            if(col.type==ftLookup)
            {
                LUItems2 *item = [luItems2 objectAtIndex:[res intValue]];
                res = item.LUItemShortDesc;
            }
            NSString *filter = [NSString stringWithFormat:@"%@", res];
            if(![array containsObject:filter])
                [array addObject:filter];
        }
        @catch (NSException *exception) {

        }

    }
    
    code(array);

}
-(void)deleteMedia:(id)media
{
}
@end
