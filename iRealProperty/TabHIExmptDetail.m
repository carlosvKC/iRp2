#import "TabHIExmptDetail.h"
#import "GridHIESaleNotes.h"
#import "TabHIExmpt.h"
#import "Helper.h"


@implementation TabHIExmptDetail

    - (void)setupBusinessRules:(id)baseEntity
        {
            HIExmpt *exmpt = baseEntity;

            UILabel *label = (UILabel *) [self.view viewWithTag:60];

            if (exmpt.approved)
                label.text = @"Approved";
            else
                label.text = @"Non Approved";

            GridHIESaleNotes *controller = [self.controllerList valueForKey:@"GridHIESaleNotes"];
            if (controller == nil)
                {
                    NSLog(@"TabHIExmptDetail: can't find the controller");
                    return;
                }
            HIExmpt *hIExmpt = (HIExmpt *) [self workingBase];
            [controller loadNotes:hIExmpt];
        }

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self willRotateToInterfaceOrientation:[Helper deviceOrientation]  duration:0];
    
}

    - (void)contentHasChanged
        {
            [(TabHIExmpt *) (self.itsController) contentHasChanged];
        }
@end
