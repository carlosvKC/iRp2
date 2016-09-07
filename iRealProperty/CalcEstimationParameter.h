//
//  CalcEstimationParameter.h
//  iRealProperty
//
//  Created by George on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalcEstimationParameter : NSObject

@property (nonatomic) int RealPropId;
@property (nonatomic) int TaxYr;
@property (nonatomic) int Area;
@property (nonatomic) int SubArea;
@property (nonatomic, strong) NSString *ApplGroup;

@end
