#import "TabPermitsDetail.h"
#import "RealPropertyApp.h"			// DBaun 062914 (New Permit Form) 
#import "Helper.h"					// DBaun 062914 (New Permit Form) 
#import "ComboBoxView.h"			// DBaun 062914 (New Permit Form) 
#import "ComboBoxController.h"		// DBaun 062914 (New Permit Form)
#import "TabPermits.h"

@implementation TabPermitsDetail
{
    UIAlertView *permitStatusAlertView;
}
//#define DEGREES_RADIANS(angle) ((angle) / 45.0 * M_PI)

-(void)setupBusinessRules:(id)baseEntity
{
        if(self.isNewContent)
        {
            RealPropInfo *rpInfo = [RealProperty realPropInfo];
            Permit *permit = baseEntity;
            permit.rowStatus = @"I";
            //permit.hasEPlan = NO;
            [permit setValue:[Helper localDate] forKey:@"issueDate"];
            permit.permitStatus = 1;
            permit.permitType = 3;
            permit.permitVal = 0;
            permit.rpGuid = rpInfo.guid;
            permit.area = rpInfo.area;
            permit.IssuingJurisdiction = rpInfo.city;
}
    }
-(void) setupGrid:(id)tempBaseEntity withItem:(ItemDefinition *)item
{
    [self.itsController setupGrid:tempBaseEntity withItem:item];
    }
    - (void)viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];
        [self enableFieldWithTag:2 enable:[self isNewContent]];
        ComboBoxView *comboView = (ComboBoxView*)[self.view viewWithTag:2];
        ComboBoxController *cmb = comboView.itsController;
        cmb.enabled = [self isNewContent];
        ///Permit value, Description
        Permit *permit = (Permit*)self.workingBase;
 
        if ([permit.permitNbr hasPrefix:@"MDF"] || [permit.rowStatus isEqualToString:@"U"] || [permit.rowStatus isEqualToString:@"I"])
        {
            [self enableFieldWithTag:11 enable: YES];//enable:[self isNewContent]];
            [self enableFieldWithTag:10 enable: YES];//[self isNewContent]];
        }
        else
        {
            [self enableFieldWithTag:11 enable:[self isNewContent]];
            [self enableFieldWithTag:10 enable:[self isNewContent]];
        }
        gridControlBar.btnList.hidden = TRUE;

        if ([self isNewContent])
        {
//            if (UIDeviceOrientationIsLandscape(self))
//                {
//                    permitStatusAlertView.transform = CGAffineTransformRotate(permitStatusAlertView.transform, DEGREES_RADIANS(90));
//                }
            if ((permit.permitVal == 0) || (!permit.permitStatus == 1))
            {
            permitStatusAlertView = [[UIAlertView alloc]initWithTitle:@"Permit Status" message:@"Is the work already complete?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            [permitStatusAlertView show];
            }
        }
    }
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //RealPropInfo *rpInfo = [RealProperty realPropInfo];
    Permit *permit = (Permit*)self.workingBase;
    
    //cv 6/21/16  generate random number instead of using realpropid: +1; generate 1 to 9999999
    int randomValue;
    randomValue = (arc4random() % 9999999) + 1;
    if (buttonIndex==0)
    {
        permit.permitNbr = [NSString stringWithFormat:@"DNQ%i",randomValue];
        permit.permitDescr = [NSString stringWithFormat:@"Complete / %@", [RealPropertyApp getUserName]];
    }
    else
    {
        permit.permitNbr = [NSString stringWithFormat:@"MDF%i",randomValue];
        permit.permitDescr = [NSString stringWithFormat:@"Maintenance Description In Field / %@", [RealPropertyApp getUserName]];
    }
    [self setScreenEntities];
}
// self.isDirty = YES;
// [self setScreenEntities];
//-(void)contentHasChanged;
//{
//    [(TabPermits *)(self.itsController) entityContentHasChanged:nil];
//
//}

- (void)entityContentHasChanged:(ItemDefinition *)entity
{
    Permit *permit = (Permit *) [self workingBase];
    if (![permit.rowStatus isEqualToString:@"I"])
        permit.rowStatus = @"U";
    
    [super entityContentHasChanged:entity];

    //on permitDtl there's an itemValue
    
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation]  duration:0];
    
}

//////////cv/////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.permitValTextField isFirstResponder]) {
        [self.permitValTextField resignFirstResponder];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //check wich superview belongs on permitsDetail
    // Adjust the subviews
    UIView *view = [self.view viewWithTag:20];
    TabPermitsDetail *permitDetailController = [self.controllerList valueForKey:@"TabPermitsDetail"];
    GridController *grid = [permitDetailController getFirstGridController];
    [grid resizeToView:view headerHeight:30];
    [grid autoFitToView:view.frame.size.width];
    
    
}

@end
