//
//  SaleVerif.m
//  iRealProperty
//
//  Created by carlos venero on 4/29/14.
//  Copyright (c) 2014 to be changed. All rights reserved.
//

#import "SaleVerif.h"
#import "Sale.h"

#import "Helper.h"
#import "RealPropertyApp.h"


@implementation SaleVerif

@dynamic guid;
@dynamic rowStatus;
@dynamic saleGuid;
@dynamic serverUpdateDate;
@dynamic stagingGUID;
@dynamic updateDate;
@dynamic updatedBy;
@dynamic verificationLevel;
@dynamic vYVerifDate;
@dynamic vYVerifiedAtMarket;
@dynamic vYVerifiedBy;
@dynamic sale;
@dynamic nonRepComp1;
@dynamic nonRepComp2;

-(void)entityContentHasChanged:(ItemDefinition *)entity
{
//    [super entityContentHasChanged:entity];
//    // If any content has changed, change indicate status
//    MHAccount *account = (MHAccount *)self.workingBase;
//    [RealPropertyApp updateUserDate:account];
//    [self setScreenEntities];
//    if(![account.rowStatus isEqualToString:@"I"] && ![account.rowStatus isEqualToString:@"D"])
//        account.rowStatus = @"U";

}

@end
