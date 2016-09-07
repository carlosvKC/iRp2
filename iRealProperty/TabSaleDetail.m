#import "TabSaleDetail.h"
#import "SaleNotes.h"
#import "SaleWarnings.h"
#import "iRealProperty.h"
#import "AxDataManager.h"
#import "GridControlBar.h"
#import "SaleVerif.h"
#import "TabSale.h"
#import "TabSaleParcels.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation TabSaleDetail

-(void)updateUserName:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];    
    NSDate *verifDate = [dateFormatter dateFromString:@"1900-01-01"];
    NSDate *updateDate = [dateFormatter dateFromString:@"1900-01-01"];

    
    verifDate = [NSDate date];
    updateDate = [NSDate date];
    NSString *rowStatus=@"U";
    NSString *updatedBy=[RealPropertyApp getUserName];
    
    //4/29/14 cvGuid
    Sale *sale = (Sale *)[self workingBase];
    [sale.saleVerif setValue:[RealPropertyApp getUserName] forKey:@"vYVerifiedBy"]; // 4/29/16 HNN key fields starts with lower case
    [sale.saleVerif setValue:verifDate forKey:@"vYVerifDate"];// 4/29/16 HNN key fields starts with lower case. specifying VYVerifDate crashes the app when they tap on set in the sale detail tab
    [sale.saleVerif setValue:updateDate forKey:@"updateDate"];
    [sale.saleVerif setValue:updatedBy forKey:@"updatedBy"];

    [sale.saleVerif setValue:rowStatus forKey:@"rowStatus"];
    

    self.isDirty = YES;
   [self contentHasChanged];
    [self setScreenEntities];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation]  duration:0];
    
}
-(void) setupBusinessRules:(id)baseEntity
{
    // Reset the different controllers

    SaleNotes *saleNotesController = [self.controllerList valueForKey:@"SaleNotes"];
    saleNotesController.propertyController = self.propertyController;
    
    if(saleNotesController==nil)
    {
        NSLog(@"TabSaleDetail: can't find the saleNotes controller");
        return;
    }
    Sale *sale = (Sale *)[self workingBase];

    [saleNotesController loadNotesForSale:sale];
    
    SaleWarnings *saleWarningsController = [self.controllerList valueForKey:@"SaleWarnings"];
    saleWarningsController.propertyController = self.propertyController;
    
    if(saleWarningsController==nil)
    {
        NSLog(@"TabSaleDetail: can't find saleWarningsController");
        return;
    }
    [saleWarningsController loadWarningForSale:sale];
    
    TabSaleParcels *saleParcelsController = [self.controllerList valueForKey:@"TabSaleParcels"];
    saleParcelsController.propertyController = self.propertyController;
    
    if(saleParcelsController==nil)
    {
        NSLog(@"TabSaleDetail: can't find saleParcelsController");
        return;
    }
    [saleParcelsController loadParcelForSale:sale];    
    [super setupBusinessRules:baseEntity];
}
-(void)contentHasChanged
{
    [(TabSale *)(self.itsController) entityContentHasChanged:nil];
    //[(TabSale *)(self.itsController) entityContentHasChanged:(ItemDefinition *)baseEntity];
    
    
    //cv move rowStatus to data field level if possible
    
    //Sale *sale = (Sale *) (detailController.workingBase);
    //Sale *sale = (Sale *) (controller.workingBase);
    //Sale *sale = (Sale *)[self workingBase];

    //check row status on 3 pieces
    //according to the path set rowStatus
    //NSString * childpath = entity.path;
    
//    
//    NSString * childpath = baseEntity.path;
//    if ([childpath rangeOfString:@"saleVerif"].length == 0) {
//        NSLog(@"SaleVerif doesnt exist");
//    }
//    else {
//        ////////
//        //RealPropInfo *info = [RealProperty realPropInfo];
//        NSSet *SaleVerifs = sale.saleVerif;  // List of sales...
//        //Sale *sale;
//        
//        for(SaleVerif *saleVerif in SaleVerifs)
//        {
//            //Sale *s = saleParcel.sale;
//            saleVerif.rowStatus = @"U";
//            //                if(s.guid==defaultSale.guid)
//            //                {
//            //                    sale = s;
//            break;
//            //                }
//        }
//        ////////
//    }

    
    
    ///////////////////////
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Adjust the subviews
    UIView *view = [self.view viewWithTag:33];
    TabSaleParcels *saleParcelsController = [self.controllerList valueForKey:@"TabSaleParcels"];
    GridController *grid = [saleParcelsController getFirstGridController];
    [grid resizeToView:view headerHeight:30];
    [grid autoFitToView:view.frame.size.width];
    
    // Adjust the subviews
    view = [self.view viewWithTag:32];
    SaleWarnings *saleWarningsController = [self.controllerList valueForKey:@"SaleWarnings"];
    grid = [saleWarningsController getFirstGridController];
    [grid resizeToView:view headerHeight:30];
    [grid autoFitToView:view.frame.size.width];

    // Adjust the subviews
    view = [self.view viewWithTag:31];
    SaleNotes *saleNotesController = [self.controllerList valueForKey:@"SaleNotes"];
    grid = [saleNotesController getFirstGridController];
    [grid resizeToView:view headerHeight:30];
    [grid autoFitToView:view.frame.size.width];

}
-(void)adjustController:(int)tag name:(NSString *)name
{
    
}
@end
