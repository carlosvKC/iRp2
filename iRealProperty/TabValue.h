#import <UIKit/UIKit.h>
#import "TabBase.h"
#import "ValueTaxRoll.h"
#import "ValueAppraisal.h"
#import "ValueEstimate.h"
#import "CheckBoxView.h"
#import "DialogBoxGetYear.h"
#import "DialogBoxGetValue.h"
#import "Requester.h"
#import "Synchronizator.h"
#import "ATActivityIndicator.h"

@interface TabValue : TabBase <CheckBoxDelegate, ModalViewControllerDelegate, RequesterDelegate, SynchronizatorDelegate, UIAlertViewDelegate>
{
    ValueTaxRoll    *valueTaxRoll;
    ValueAppraisal  *valueAppraisal;
    ValueEstimate   *valueEstimate;
    
    CheckBoxView    *cbTaxRoll,
                    *cbAppraisal,
                    *cbEstimate;
    
    DialogBoxGetYear   *dialogGetYear;
    DialogBoxGetValue  *dialogGetValue;
    
    Requester *req;
    Synchronizator *sync;
    ATActivityIndicator *activity;
    int taxYr;
}

@property (strong, nonatomic)UIAlertView *alert;

@end
