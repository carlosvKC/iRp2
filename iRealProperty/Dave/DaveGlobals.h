//
// Created by David Baun on 8/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "Requester.h"


@class AzureContainer;
@class Container;


@interface DaveGlobals : NSObject

    + (NSString *)debugDictionary:(NSDictionary *)theDictionary
                 withTitleMessage:(NSString *)message;

    + (NSString *)debugAzureBlobs:(NSArray *)blobs
                 withTitleMessage:(NSString *)message;

    + (NSString *)debugAzureContainers:(NSArray *)containers
                      withTitleMessage:(NSString *)message;

    + (NSString *)debugAzureContainer:(AzureContainer *)theContainer
                     withTitleMessage:(NSString *)message;

    + (NSString *)debugCoreDataContainers:(NSArray *)containers
                         withTitleMessage:(NSString *)message;

    + (NSString *)debugCoreDataContainer:(Container *)theContainer
                        withTitleMessage:(NSString *)message;


    + (NSString *)debugConfiguration:(Configuration *)config
                    withTitleMessage:(NSString *)message;

    + (NSString *)debugConnectionFinishedLoading:(NSURLConnection *)connection
                            withRequestTypeValue:(RequestTypeValue)requestTypeValue;

    + (NSString *)debugConnection:(NSURLConnection *)connection
                 withTitleMessage:(NSString *)message;

    + (NSString *)debugParameters:(NSDictionary *)theParameters withTitleMessage:(NSString *)message;

    + (NSString *)debugPersonalNotesSqlite:(NSString *)titleMessage;

    + (NSString *)printStackWithMessage:(NSString *)message;
@end


