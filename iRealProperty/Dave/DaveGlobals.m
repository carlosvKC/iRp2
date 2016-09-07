//
// Created by David Baun on 8/22/13.
// Copyright (c) 2013 to be changed. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DaveGlobals.h"
#import "AzureBlob.h"
#import "AzureContainer.h"
#import "Container.h"
#import "AxDataManager.h"
#import "FilesSync.h"
#import "Blob.h"

#pragma ide diagnostic ignored "RedundantCast"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"

static DaveGlobals *davesSingleton = nil;


@implementation DaveGlobals {
        // variables would go here
    }


    + (DaveGlobals *)sharedDaveGlobals
        {
            if (davesSingleton == nil)
                davesSingleton = (DaveGlobals *) [[super allocWithZone:NULL] init];

            return davesSingleton;
        }



    + (id)allocWithZone:(NSZone *)zone
        {
            return [self sharedDaveGlobals];

        }



    - (id)copyWithZone:(NSZone *)zone
        {
            return self;
        }



//db Debug a dictionary by listing its keys and values
    + (NSString *)debugDictionary:(NSDictionary *)theDictionary
                 withTitleMessage:(NSString *)message
        {
            if (theDictionary == nil)
                {
                    NSLog(@"The dictionary to debug is NIL");
                    return @"The dictionary to debug is NIL";
                }

            NSEnumerator *keyEnumerator = [theDictionary keyEnumerator];
            id key;


            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];

            while ((key = [keyEnumerator nextObject]))
                {
                    [outputString appendFormat:@" %@ = %@\n", key, [theDictionary valueForKey:key]];
                }

            return outputString;
        }

// 0x0be4e8b0

    + (NSString *)debugCoreDataContainers:(NSArray *)containers
                         withTitleMessage:(NSString *)message
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** DEBUG CORE DATA CONTAINERS ***\n"];
            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];


            if (containers == nil || [containers count] == 0)
                {
                    [outputString appendString:@"\nThe containers array is NIL or has no items"];
                    return outputString;
                }


            for (Container *theContainer in containers)
                {
                    [outputString appendString:@"- - - - - - - - - - - - - - - - - - -\n"];
                    [outputString appendFormat:@"container name:           %@\n", theContainer.name];
                    [outputString appendFormat:@"container eTag:           %@\n", theContainer.eTag];
                    [outputString appendFormat:@"container lastModifDate:  %@\n", theContainer.lastModifiedDate];
                    [outputString appendFormat:@"container url:            %@\n", theContainer.url];
                    [outputString appendString:@"- - - - BLOBS IN CONTAINER - - - -\n"];
                    [outputString appendFormat:@"container.blobs.count     %i\n", [theContainer.blobs count]];
                }

            return outputString;
        }



    + (NSString *)debugCoreDataContainer:(Container *)theContainer
                        withTitleMessage:(NSString *)message
        {

            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** DEBUG CORE DATA CONTAINER ***\n"];
            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];

            if (theContainer == nil)
                {
                    [outputString appendString:@"\nThe container is NIL"];
                    return outputString;
                }


            [outputString appendString:@"- - - - - - - - - - - - - - - - - - -\n"];
            [outputString appendFormat:@"container name:           %@\n", theContainer.name];
            [outputString appendFormat:@"container eTag:           %@\n", theContainer.eTag];
            [outputString appendFormat:@"container lastModifDate:  %@\n", theContainer.lastModifiedDate];
            [outputString appendFormat:@"container url:            %@\n", theContainer.url];
            [outputString appendString:@"- - - - BLOBS IN CONTAINER - - - -\n"];
            [outputString appendFormat:@"container.blobs.count     %i\n", [theContainer.blobs count]];

            return outputString;
        }



    + (NSString *)debugAzureContainers:(NSArray *)containers
                      withTitleMessage:(NSString *)message
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** DEBUG AZURE CONTAINERS ***\n"];
            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];


            if (containers == nil || [containers count] == 0)
                {
                    [outputString appendString:@"\nThe containers array is NIL or has no items"];
                    return outputString;
                }


            for (AzureContainer *theContainer in containers)
                {
                    [outputString appendString:@"- - - - - - - - - - - - - - - - - - -\n"];
                    [outputString appendFormat:@"container name:           %@\n", theContainer.name];
                    [outputString appendFormat:@"container eTag:           %@\n", theContainer.etag];
                    [outputString appendFormat:@"container lastModifDate:  %@\n", theContainer.lastModifiedDate];
                    [outputString appendFormat:@"container url:            %@\n", theContainer.url];
                    [outputString appendString:@"- - - - BLOBS IN CONTAINER - - - -\n"];
                    [outputString appendString:[DaveGlobals debugAzureBlobs:theContainer.blobs withTitleMessage:@""]];
                }

            return outputString;
        }



    + (NSString *)debugAzureContainer:(AzureContainer *)theContainer
                     withTitleMessage:(NSString *)message
        {

            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** DEBUG AZURE CONTAINER ***\n"];
            //[outputString appendString:[DaveGlobals printStackWithMessage:@""]];
            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];

            if (theContainer == nil)
                {
                    [outputString appendString:@"\nThe container is NIL"];
                    return outputString;
                }


            [outputString appendString:@"- - - - - - - - - - - - - - - - - - -\n"];
            [outputString appendFormat:@"container name:           %@\n", theContainer.name];
            [outputString appendFormat:@"container eTag:           %@\n", theContainer.etag];
            [outputString appendFormat:@"container lastModifDate:  %@\n", theContainer.lastModifiedDate];
            [outputString appendFormat:@"container url:            %@\n", theContainer.url];
            [outputString appendString:@"- - - - BLOBS IN CONTAINER - - - -\n"];
            [outputString appendString:[DaveGlobals debugAzureBlobs:theContainer.blobs withTitleMessage:@""]];

            return outputString;
        }



    + (NSString *)debugAzureBlobs:(NSArray *)blobs
                 withTitleMessage:(NSString *)message
        {

            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** DEBUG AZURE BLOBS ***\n"];
            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];


            if (blobs == nil || [blobs count] == 0)
                {
                    [outputString appendString:@"\nThe blobs array is NIL or has no items."];
                    return outputString;
                }


            for (AzureBlob *blob in blobs)
                {
                    [outputString appendString:@"- - - - - - - - - - - - - - - - - - -\n"];
                    [outputString appendFormat:@"blob name:           %@\n", blob.name];
                    [outputString appendFormat:@"blob type:           %@\n", blob.type];
                    [outputString appendFormat:@"blob length          %@\n", [NSNumber numberWithLongLong:blob.length]];
                    [outputString appendFormat:@"blob eTag:           %@\n", blob.eTag];
                    [outputString appendFormat:@"blob lastModifDate:  %@\n", blob.lastModifiedDate];
                    [outputString appendFormat:@"blob url:            %@\n", blob.url];
                }

            return outputString;
        }



    + (NSString *)debugConfiguration:(Configuration *)config
                    withTitleMessage:(NSString *)message
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"*** DEBUG CONFIGURATION ***\n"];
            //[outputString appendString:[DaveGlobals printStackWithMessage:@""]];
            if ([message length] > 0)
                [outputString appendFormat:@"\n%@\n", message];

            if (config == nil)
                {
                    [outputString appendString:@"\nThe configuration is NIL"];
                }
            else
                {
                    [outputString appendFormat:@" checkAzureFile:         %@\n", config.checkAzureFile ? @"YES" : @"NO"];
                    [outputString appendFormat:@" lastCheckinAzureTime:   %@\n", [NSString stringWithFormat:@"%f", config.lastCheckinAzureTime]];
                    [outputString appendFormat:@" currentArea:            %@\n", config.currentArea];
                    [outputString appendFormat:@" guid:                   %@\n", config.guid];
                    [outputString appendFormat:@" downloading             %i\n", config.downloading];
                    [outputString appendFormat:@" simpleToken             %@\n", config.simpleToken];
                    [outputString appendString:@"\n"];
                }

            return outputString;
        }



    + (NSString *)debugConnectionFinishedLoading:(NSURLConnection *)connection
                            withRequestTypeValue:(RequestTypeValue)requestTypeValue
        {
            NSArray *enumItems = [[NSArray alloc] initWithObjects:
                                                          @"typeUserLogin",
                                                          @"typeGetEntities",
                                                          @"typeGetAuthorizationForContainerList",
                                                          @"typeGetAzureContainerList",
                                                          @"typeGetAuthorizationForBlobList",
                                                          @"typeGetAzureBlobList",
                                                          @"typeUploadNewEntities",
                                                          @"typeMoveDataToPrepTables",
                                                          @"typeGetEstArea",
                                                          @"typeCalculateEstimates", nil];


            NSURL *theURL = [[connection originalRequest] URL];

            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** DEBUG CONNECTION FINISHED LOADING ***\n"];
            //[outputString appendString:[DaveGlobals printStackWithMessage:@""]];
            [outputString appendFormat:@"\nCompleted: %@", [enumItems objectAtIndex:requestTypeValue]];
            [outputString appendFormat:@"\nUsing URL: %@\n", theURL];
            [outputString appendString:@"\n"];

            return outputString;

        }



    + (NSString *)debugConnection:(NSURLConnection *)connection
                 withTitleMessage:(NSString *)message
        {
            NSURL           *theURL         = [[connection originalRequest] URL];
//          NSDictionary    *requestHeaders = [[connection originalRequest] allHTTPHeaderFields];
            NSMutableString *outputString;

            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"\n*** START DEBUG CONNECTION ***\n"];
//          [outputString appendString:[DaveGlobals printStackWithMessage:@""]];

            if ([message length] > 0)
                [outputString appendFormat:@"%@\n", message];
            [outputString appendFormat:@" >-> USING URL: %@\n", theURL];
//          [outputString appendFormat:[DaveGlobals debugDictionary:(NSDictionary *) requestHeaders withTitleMessage:@"...The URL has the following headers..."]];
            [outputString appendString:@"--- END DEBUG CONNECTION ---\n"];


            return outputString;
        }



    + (NSString *)debugParameters:(NSDictionary *)theParameters
                 withTitleMessage:(NSString *)message
        {
            NSString *theReturnValue;
            NSString *theTitleMessage = [NSString stringWithFormat:@"\n%@\nThe parameters to this method are...\n", message];
            theReturnValue = [DaveGlobals debugDictionary:theParameters withTitleMessage:theTitleMessage];
            return theReturnValue;
        }



    + (NSString *)debugPersonalNotesSqlite:(NSString *)titleMessage
        {

            NSManagedObjectContext *personalNotesSqlite;
            NSArray                *filesSyncRecords;
            NSArray                *containerRecords;
            NSArray                *blobRecords;
            NSMutableString        *outputString;


            personalNotesSqlite = [AxDataManager noteContext];

            filesSyncRecords = [AxDataManager dataListEntity:@"FilesSync" andSortBy:@"name" andPredicate:nil withContext:personalNotesSqlite];
            containerRecords = [AxDataManager dataListEntity:@"Container" andSortBy:@"name" andPredicate:nil withContext:personalNotesSqlite];
            blobRecords      = [AxDataManager dataListEntity:@"Blob" andSortBy:@"name" andPredicate:nil withContext:personalNotesSqlite];

            outputString = [[NSMutableString alloc] initWithCapacity:250];

            if (titleMessage)
            [outputString appendFormat:@"\n%@",titleMessage];
            [outputString appendString:@"\n*** FilesSync Table ***\n"];
            [outputString appendFormat:@" Record Count:   %i \n", [filesSyncRecords count]];

            for (FilesSync *fileSyncRecord in filesSyncRecords)
                {
                    [outputString appendFormat:@"(AREA) %-12s   (ETAG) %-20s   (NAME) %@ \n", [fileSyncRecord.area UTF8String], [fileSyncRecord.eTag UTF8String], fileSyncRecord.name];
                }

            [outputString appendString:@"\n*** Container Table ***\n"];
            [outputString appendFormat:@" Record Count:   %i \n", [containerRecords count]];

            for (Container *container in containerRecords)
                {
                    [outputString appendFormat:@"   (ETAG) %-20s   (NAME) %@    (BLOBS) %i \n", [container.eTag UTF8String], container.name, [container.blobs count]];
                }

            [outputString appendString:@"\n*** Blob Table ***\n"];
            [outputString appendFormat:@" Record Count:  %i \n", [blobRecords count]];

            for (Blob *blob in blobRecords)
                {
                    [outputString appendFormat:@"   (ETAG) %-20s   (NAME) %@ \n", [blob.eTag UTF8String], blob.name];
                }

            return outputString;

        }



    + (NSString *)printStackWithMessage:(NSString *)message
        {
            NSMutableString *outputString;
            NSArray         *theCallStack;

            theCallStack = [NSThread callStackSymbols];
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            if ([message length] > 0)
                [outputString appendFormat:@"%@\n", message];
            [outputString appendString:@""];


            for (int j = 1; j < MIN(4, [theCallStack count]); j++)
                {
                    [outputString appendFormat:@"\n%@", [theCallStack objectAtIndex:j]];
                }
            [outputString appendString:@""];

            return outputString;
        }

@end



#pragma clang diagnostic pop