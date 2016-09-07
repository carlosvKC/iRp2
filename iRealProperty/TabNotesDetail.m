#import "TabNotesDetail.h"
#import "RealPropertyApp.h"


@implementation TabNotesDetail

    - (void)setupBusinessRules:(id)baseEntity
        {
            RealPropInfo *info = [RealProperty realPropInfo];
            NoteRealPropInfo *note = (NoteRealPropInfo *) [self workingBase];

            if (self.isNewContent)
                {
                    [RealPropertyApp updateUserDate:note];
                    note.src = @"realprop";
                    note.rowStatus = @"I";
                    note.srcGuid = info.guid;
                    [self enableFieldWithTag:1 enable:YES];
                    [self enableFieldWithTag:300 enable:YES];                    
                }
            else
                {
                    if([note.updatedBy caseInsensitiveCompare:[RealPropertyApp getUserName]]== NSOrderedSame)
                        {
                            [self enableFieldWithTag:1 enable:YES];
                            [self enableFieldWithTag:300 enable:YES];
                        }
                    else
                        {
                            [self enableFieldWithTag:1 enable:[self isNewContent]];
                            [self enableFieldWithTag:300 enable:[self isNewContent]];
                        }
                
                }
        }

@end
