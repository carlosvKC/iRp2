//
//  RealPropInfo.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Accy, ApplHist, ChngHist, HIExmpt, Inspection, Land, MHAccount, NoteRealPropInfo, ParcelAssignment, Permit, ResBldg, Review, SaleParcel, TaxRoll, UndividedInt, ValEst, ValHist, XLand, Bookmark;

@interface RealPropInfo : NSManagedObject

    @property (nonatomic, retain) NSString * applGroup;
    @property (nonatomic) int16_t area;
    //@property (nonatomic, retain) NSString * assignedUser;
    @property (nonatomic, retain) NSString * changeSource;
    @property (nonatomic, retain) NSString * city;
    @property (nonatomic) int32_t districtId;
    @property (nonatomic, retain) NSString * folio;
    @property (nonatomic) int16_t geoArea;
    @property (nonatomic) int16_t geoNbrhd;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic, retain) NSString * lndGuid;
    @property (nonatomic, retain) NSString * legalDesc;
    @property (nonatomic, retain) NSString * levyCode;
    @property (nonatomic, retain) NSString * major;
    @property (nonatomic, retain) NSString * minor;
    @property (nonatomic, retain) NSString * nbrFraction;
    @property (nonatomic) int32_t neighborhood;
    @property (nonatomic, retain) NSString * parcelNbr;
    @property (nonatomic, retain) NSString * platBlock;
    @property (nonatomic, retain) NSString * platLot;
    @property (nonatomic, retain) NSString * propName;
    @property (nonatomic, retain) NSString * propType;
    @property (nonatomic, retain) NSString * quarterSection;
    @property (nonatomic) int16_t range;
    @property (nonatomic) int32_t realPropId;
    @property (nonatomic, retain) NSString * resArea;
    @property (nonatomic, retain) NSString * resSubArea;
    @property (nonatomic, retain) NSString * rowStatus;
    @property (nonatomic) int16_t section;
    @property (nonatomic) NSTimeInterval serverUpdateDate;
    @property (nonatomic) int16_t specArea;
    @property (nonatomic) int16_t specNbrhd;
    @property (nonatomic, retain) NSString * stagingGUID;
    @property (nonatomic, retain) NSString * status;
    @property (nonatomic, retain) NSString * street;
    @property (nonatomic) int32_t streetId;
    @property (nonatomic, retain) NSString * streetNbr;
    @property (nonatomic) int16_t township;
    @property (nonatomic, retain) NSString * unitDescr;
    @property (nonatomic) NSTimeInterval updateDate;
    @property (nonatomic, retain) NSString * updatedBy;
    @property (nonatomic, retain) NSString * zipCode;
    @property (nonatomic, retain) Account *account;
    @property (nonatomic, retain) NSSet *accy;
    @property (nonatomic, retain) NSSet *applHist;
    @property (nonatomic, retain) NSSet *chngHist;
    @property (nonatomic, retain) NSSet *hIExempt;
    @property (nonatomic, retain) Inspection *inspection;
    @property (nonatomic, retain) Land *land;
    @property (nonatomic, retain) NSSet *mHAccount;
    @property (nonatomic, retain) NSSet *noteRealPropInfo;
    @property (nonatomic, retain) ParcelAssignment *parcelAssignment;
    @property (nonatomic, retain) NSSet *permit;
    @property (nonatomic, retain) NSSet *resBldg;
    @property (nonatomic, retain) NSSet *review;
    @property (nonatomic, retain) NSSet *saleParcel;
    @property (nonatomic, retain) NSSet *taxRoll;
    @property (nonatomic, retain) NSSet *undividedInt;
    @property (nonatomic, retain) NSSet *valEst;
    @property (nonatomic, retain) NSSet *valHist;
    @property (nonatomic, retain) XLand *xland;
    @property (nonatomic, retain) NSSet *Bookmark;

@end

@interface RealPropInfo (CoreDataGeneratedAccessors)

- (void)addAccyObject:(Accy *)value;
- (void)removeAccyObject:(Accy *)value;
- (void)addAccy:(NSSet *)values;
- (void)removeAccy:(NSSet *)values;

- (void)addApplHistObject:(ApplHist *)value;
- (void)removeApplHistObject:(ApplHist *)value;
- (void)addApplHist:(NSSet *)values;
- (void)removeApplHist:(NSSet *)values;

- (void)addChngHistObject:(ChngHist *)value;
- (void)removeChngHistObject:(ChngHist *)value;
- (void)addChngHist:(NSSet *)values;
- (void)removeChngHist:(NSSet *)values;

- (void)addHIExemptObject:(HIExmpt *)value;
- (void)removeHIExemptObject:(HIExmpt *)value;
- (void)addHIExempt:(NSSet *)values;
- (void)removeHIExempt:(NSSet *)values;

- (void)addBookmarkObject:(Bookmark *)value;
- (void)removeBookmarkObject:(Bookmark *)value;
- (void)addBookmark:(NSSet *)values;
- (void)removeBookmark:(NSSet *)values;


- (void)addMHAccountObject:(MHAccount *)value;
- (void)removeMHAccountObject:(MHAccount *)value;
- (void)addMHAccount:(NSSet *)values;
- (void)removeMHAccount:(NSSet *)values;

- (void)addNoteRealPropInfoObject:(NoteRealPropInfo *)value;
- (void)removeNoteRealPropInfoObject:(NoteRealPropInfo *)value;
- (void)addNoteRealPropInfo:(NSSet *)values;
- (void)removeNoteRealPropInfo:(NSSet *)values;

- (void)addPermitObject:(Permit *)value;
- (void)removePermitObject:(Permit *)value;
- (void)addPermit:(NSSet *)values;
- (void)removePermit:(NSSet *)values;

- (void)addResBldgObject:(ResBldg *)value;
- (void)removeResBldgObject:(ResBldg *)value;
- (void)addResBldg:(NSSet *)values;
- (void)removeResBldg:(NSSet *)values;

- (void)addReviewObject:(Review *)value;
- (void)removeReviewObject:(Review *)value;
- (void)addReview:(NSSet *)values;
- (void)removeReview:(NSSet *)values;

- (void)addSaleParcelObject:(SaleParcel *)value;
- (void)removeSaleParcelObject:(SaleParcel *)value;
- (void)addSaleParcel:(NSSet *)values;
- (void)removeSaleParcel:(NSSet *)values;

- (void)addTaxRollObject:(TaxRoll *)value;
- (void)removeTaxRollObject:(TaxRoll *)value;
- (void)addTaxRoll:(NSSet *)values;
- (void)removeTaxRoll:(NSSet *)values;

- (void)addUndividedIntObject:(UndividedInt *)value;
- (void)removeUndividedIntObject:(UndividedInt *)value;
- (void)addUndividedInt:(NSSet *)values;
- (void)removeUndividedInt:(NSSet *)values;

- (void)addValEstObject:(ValEst *)value;
- (void)removeValEstObject:(ValEst *)value;
- (void)addValEst:(NSSet *)values;
- (void)removeValEst:(NSSet *)values;

- (void)addValHistObject:(ValHist *)value;
- (void)removeValHistObject:(ValHist *)value;
- (void)addValHist:(NSSet *)values;
- (void)removeValHist:(NSSet *)values;

@end
