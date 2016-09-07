//
//  Container.h
//  iRealProperty
//
//  Created by Regis Bridon on 8/30/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Blob;


@interface Container : NSManagedObject

    @property(nonatomic, retain) NSString *eTag;
    @property(nonatomic, retain) NSString *lastModifiedDate;
    @property(nonatomic, retain) NSString *name;
    @property(nonatomic, retain) NSString *url;
    @property(nonatomic, retain) NSSet *blobs;
@end


@interface Container (CoreDataGeneratedAccessors)

    - (void)addBlobsObject:(Blob *)value;

    - (void)removeBlobsObject:(Blob *)value;

    - (void)addBlobs:(NSSet *)values;

    - (void)removeBlobs:(NSSet *)values;

@end
