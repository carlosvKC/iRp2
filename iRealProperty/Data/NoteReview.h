//
//  NoteReview.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/21/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NoteInstance.h"

@class Review;

@interface NoteReview : NoteInstance

@property (nonatomic, retain) Review *review;

@end
