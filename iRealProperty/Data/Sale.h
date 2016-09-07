//
//  Sale.h
//  iRealProperty2
//
//  Created by Hoang Nguyen on 4/25/16.
//  Copyright (c) 2016 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteSale, SaleParcel, SaleVerif, SaleWarning;

@interface Sale : NSManagedObject

@property (nonatomic, retain) NSNumber * aFCurrentUseLand;
@property (nonatomic, retain) NSNumber * aFForestLand;
@property (nonatomic, retain) NSNumber * aFHistoricProperty;
@property (nonatomic, retain) NSNumber * aFNonProfitUse;
@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSString * buyerAddr;
@property (nonatomic, retain) NSString * buyerName;
@property (nonatomic, retain) NSNumber * exciseTaxNbr;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * identifiedBy;
@property (nonatomic, retain) NSDate * identifiedDate;
@property (nonatomic, retain) NSString * instrument;
@property (nonatomic, retain) NSString * principalUse;
@property (nonatomic, retain) NSNumber * propCnt;
@property (nonatomic, retain) NSNumber * propertyClass;
@property (nonatomic, retain) NSString * propertyType;
@property (nonatomic, retain) NSString * rERecordingNbr;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic, retain) NSDate * saleDate;
@property (nonatomic, retain) NSNumber * salePrice;
@property (nonatomic, retain) NSString * saleProcess;
@property (nonatomic, retain) NSString * saleReason;
@property (nonatomic, retain) NSString * sellerAddr;
@property (nonatomic, retain) NSString * sellerName;
@property (nonatomic, retain) NSDate * serverUpdateDate;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSSet *noteSale;
@property (nonatomic, retain) NSSet *saleParcel;
@property (nonatomic, retain) NSSet *saleVerif;
@property (nonatomic, retain) NSSet *saleWarning;
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

//- (void)addSaleVerifObject:(SaleVerif *)value;
//- (void)removeSaleVerifObject:(SaleVerif *)value;
//- (void)addSaleVerif:(NSSet *)values;
//- (void)removeSaleVerif:(NSSet *)values;

- (void)addSaleWarningObject:(SaleWarning *)value;
- (void)removeSaleWarningObject:(SaleWarning *)value;
- (void)addSaleWarning:(NSSet *)values;
- (void)removeSaleWarning:(NSSet *)values;

@end
