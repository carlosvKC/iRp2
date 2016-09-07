#import "DialogBoxEnvironmentalController.h"
#import "RealPropertyApp.h"
#import "RealProperty.h"


@implementation DialogBoxEnvironmentalController

    - (void)setupBusinessRules:(id)baseEntity
        {
            RealPropInfo *propInfo = [RealProperty realPropInfo];
            Land         *land     = propInfo.land;
            EnvRes       *envRes   = baseEntity;
            //    envRes.landId = land.landId;
            envRes.lndGuid= land.guid;
            [RealPropertyApp updateUserDate:envRes];

            [self enableFieldWithTag:6 enable:NO];
            [self enableFieldWithTag:5 enable:NO];
        }
@end
