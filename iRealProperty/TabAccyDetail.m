
#import "TabAccyDetail.h"
#import "RealPropertyApp.h"
#import "Helper.h"

@implementation TabAccyDetail

    -(void)setupBusinessRules:(id)baseEntity
    {
        if(self.isNewContent)
        {
            [RealPropertyApp updateUserDate:baseEntity];
            NSDate *date = [Helper localDate];
            Accy *accy = baseEntity;
            accy.dateValued = [date timeIntervalSinceReferenceDate];
            accy.rowStatus = @"I";
        }
    }

@end
