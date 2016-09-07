#import "TabChangesDetail.h"
#import "AxDataManager.h"


@implementation TabChangesDetail

    - (void)setupBusinessRules:(id)baseEntity
        {
            ChngHist *chngHist = (ChngHist *) [self workingBase];

            GridContentController *grid = [self.gridList valueForKey:@"GridTabChangesDetail"];
            [grid setGridContent:[AxDataManager orderSet:chngHist.chngHistDtl property:@"ChngHist" ascending:YES]];


        }



    - (void)gridUpdateContent:(GridController *)grid
        {
            ChngHist *chngHist = (ChngHist *) [self workingBase];

            [grid setGridContent:[AxDataManager orderSet:chngHist.chngHistDtl property:@"ChngHist" ascending:YES]];
        }



    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
            ChngHist *chngHist = (ChngHist *) [self workingBase];
            chngHist.rowStatus = @"U";
            [super entityContentHasChanged:entity];
        }
@end
