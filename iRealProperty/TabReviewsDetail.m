#import "TabReviewsDetail.h"
#import "ReviewTracking.h"
#import "ReviewNotes.h"


@implementation TabReviewsDetail

    - (void)setupBusinessRules:(id)baseEntity
        {
            ReviewTracking *trackingController = [self.controllerList valueForKey:@"ReviewTracking"];
            if (trackingController == nil)
                {
                    NSLog(@"TabReviewsDetail: can't find the trackingController");
                    return;
                }
            Review *review = (Review *) [self workingBase];
            [trackingController loadTracking:review];

            ReviewNotes *notesController = [self.controllerList valueForKey:@"ReviewNotes"];
            if (notesController == nil)
                {
                    NSLog(@"RabReviewsDetail: can't find the ReviewNotes");
                    return;
                }
            [notesController loadNotesForReview:review];
        }

@end
