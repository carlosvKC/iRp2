#import "TabBuildingDetail.h"


@implementation TabBuildingDetail

    - (void)setupBusinessRules:(id)baseEntity
        {
            if (self.isNewContent)
                {

                    ResBldg *resBldg = (ResBldg *) self.workingBase;

                    RealPropInfo *info = [RealProperty realPropInfo];
                    //Land         *land = info.land;

                    //resBldg.bldgNbr          = land.resBldg.count + 1;
                    resBldg.bldgNbr            = info.resBldg.count +1;
                    resBldg.rowStatus        = @"I";   // New building
                    resBldg.daylightBasement = NO;
                    resBldg.viewUtilization  = NO;
                    resBldg.rpGuid = info.guid;
                    resBldg.area = info.area;
                }

        }

@end
