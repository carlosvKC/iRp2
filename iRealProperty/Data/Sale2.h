//
//  Sale.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/8/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteSale, SaleParcel, SaleWarning, SaleVerif;

@interface Sale : NSManagedObject
    @property (nonatomic) BOOL aFCurrentUseLand;
    @property (nonatomic) BOOL aFForestLand;
    @property (nonatomic) BOOL aFHistoricProperty;
    @property (nonatomic) BOOL aFNonProfitUse;
    @property (nonatomic) int16_t area;
    @property (nonatomic, retain) NSString * buyerAddr;
    @property (nonatomic, retain) NSString * buyerName;
    @property (nonatomic) int32_t exciseTaxNbr;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic, retain) NSString * identifiedBy;
    @property (nonatomic) NSTimeInterval identifiedDate;
    @property (nonatomic, retain) NSString * instrument;
    //@property (nonatomic, retain) NSString * noteGuid;
    @property (nonatomic, retain) NSString * principalUse;
    @property (nonatomic) int16_t propCnt;
    @property (nonatomic) int16_t propertyClass;
    @property (nonatomic, retain) NSString * propertyType;
    @property (nonatomic, retain) NSString * rERecordingNbr;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic) NSTimeInterval saleDate;
    @property (nonatomic) int32_t salePrice;
    @property (nonatomic, retain) NSString * saleProcess;
    @property (nonatomic, retain) NSString * saleReason;
    @property (nonatomic, retain) NSString * sellerAddr;
    @property (nonatomic, retain) NSString * sellerName;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) NSSet *noteSale;
    @property (nonatomic, retain) NSSet *saleParcel;
    @property (nonatomic, retain) NSSet *saleWarning;
    @property (nonatomic, retain) NSSet *saleVerif;
@end

@interface Sale (CoreDataGeneratedAccessors)
    - (void)addNoteSaleObject:(NoteSale *)value;
    - (void)removeNoteSaleObject:(NoteSale *)value;
    - (void)addNoteSale:(NSSet *)values;
    - (void)removeNoteSale:(NSSet *)values;

    - (void)addSaleParcelObject:(SaleParcel *)value;
    - (void)removeSaleParcelObject:(SaleParcel *)value;
    - (void)addSaleParcel:(NSSet *)values;
    - (void)removeSaleParcel:(NSSet *)values;

    - (void)addSaleWarningObject:(SaleWarning *)value;
    - (void)removeSaleWarningObject:(SaleWarning *)value;
    - (void)addSaleWarning:(NSSet *)values;
    - (void)removeSaleWarning:(NSSet *)values;

- (void)addSaleVerifObject:(SaleVerif *)value;
- (void)removeSaleVerifObject:(SaleVerif *)value;
- (void)addSaleVerif:(NSSet *)values;
- (void)removeSaleVerif:(NSSet *)values;

@end
