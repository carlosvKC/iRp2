//
//  XLand.h
//  iRealProperty
//
//  Created by carlos venero on 9/4/13.
//  Copyright (c) 2013 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealPropInfo;

@interface XLand : NSManagedObject

@property (nonatomic, retain) NSNumber * adjacentGolfFairway;
@property (nonatomic, retain) NSNumber * adjacentGreenbelt;
@property (nonatomic, retain) NSNumber * adjacGolfdollars;
@property (nonatomic, retain) NSNumber * adjacGolfvalpct;
@property (nonatomic, retain) NSNumber * adjacGreenbeltvaldollars;
@property (nonatomic, retain) NSNumber * adjacGreenbeltvalpct;
@property (nonatomic, retain) NSNumber * airportNoise;
@property (nonatomic, retain) NSNumber * airportValdollars;
@property (nonatomic, retain) NSNumber * airportValpct;
@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSNumber * cascades;
@property (nonatomic, retain) NSNumber * currentUseDesignation;
@property (nonatomic, retain) NSNumber * deedRestrictions;
@property (nonatomic, retain) NSNumber * deedRestrictvalpct;
@property (nonatomic, retain) NSNumber * developmentRightsPurchased;
@property (nonatomic, retain) NSNumber * devRightsvalpct;
@property (nonatomic, retain) NSNumber * dNRLease;
@property (nonatomic, retain) NSNumber * dnrLeasevalpct;
@property (nonatomic, retain) NSNumber * easements;
@property (nonatomic, retain) NSNumber * easementsValpct;
@property (nonatomic, retain) NSNumber * economicUnit;
@property (nonatomic, retain) NSString * economicUnitname;
@property (nonatomic, retain) NSString * economicUnitparcellist;
@property (nonatomic, retain) NSNumber * excessLand;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * historicSite;
@property (nonatomic, retain) NSNumber * lakeSammamish;
@property (nonatomic, retain) NSNumber * lakeWashington;
@property (nonatomic, retain) NSNumber * landId;
@property (nonatomic, retain) NSNumber * lotDepthFactor;
@property (nonatomic, retain) NSNumber * mtRainier;
@property (nonatomic, retain) NSNumber * nativeGrowthProtEsmt;
@property (nonatomic, retain) NSNumber * nativeGrowthValpct;
@property (nonatomic, retain) NSNumber * nbrBldgSites;
@property (nonatomic, retain) NSNumber * olympics;
@property (nonatomic, retain) NSNumber * otherDesignation;
@property (nonatomic, retain) NSNumber * otherDesigvalpct;
@property (nonatomic, retain) NSNumber * otherNuisances;
@property (nonatomic, retain) NSNumber * otherNuisvalpct;
@property (nonatomic, retain) NSNumber * otherProblems;
@property (nonatomic, retain) NSNumber * otherProblemsvalpct;
@property (nonatomic, retain) NSNumber * otherView;
@property (nonatomic, retain) NSNumber * powerLines;
@property (nonatomic, retain) NSNumber * powerLinesvalpct;
@property (nonatomic, retain) NSNumber * pugetSound;
@property (nonatomic, retain) NSNumber * roadAccessvalpct;
@property (nonatomic, retain) NSString * rowStatus;
@property (nonatomic, retain) NSNumber * seattleSkyline;
@property (nonatomic) NSTimeInterval serverUpdateDate;
@property (nonatomic, retain) NSNumber * smallLakeRiverCreek;
@property (nonatomic, retain) NSNumber * splitZoning;
@property (nonatomic, retain) NSString * stagingGUID;
@property (nonatomic, retain) NSNumber * territorial;
@property (nonatomic, retain) NSNumber * tidelandShoreland;
@property (nonatomic, retain) NSNumber * topoValpct;
@property (nonatomic, retain) NSNumber * trafficNoise;
@property (nonatomic, retain) NSNumber * trafficValdollars;
@property (nonatomic, retain) NSNumber * trafficValpct;
@property (nonatomic, retain) NSNumber * transportationConcurrency;
@property (nonatomic) NSTimeInterval updateDate;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSNumber * waterProblems;
@property (nonatomic, retain) NSNumber * waterProblemsvalpct;
@property (nonatomic, retain) NSNumber * wetlandValpct;
@property (nonatomic, retain) NSNumber * wfntAccessRights;
@property (nonatomic, retain) NSNumber * wfntBank;
@property (nonatomic, retain) NSNumber * wfntFootage;
@property (nonatomic, retain) NSNumber * wfntLocation;
@property (nonatomic, retain) NSNumber * wfntPoorQuality;
@property (nonatomic, retain) NSNumber * wfntProximityInfluence;
@property (nonatomic, retain) NSNumber * wfntRestrictedAccess;
@property (nonatomic, retain) RealPropInfo *realPropInfo;

@end
