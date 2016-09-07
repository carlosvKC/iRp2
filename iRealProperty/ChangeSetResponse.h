//
//  ChangeSetResponse.h
//  iRealProperty
//
//  Created by George on 6/8/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangeSetResponse : NSObject

@property (nonatomic, strong)NSString *httpResponse;
@property (nonatomic) int contentId;
@property (nonatomic, strong)NSString *jsonResponse;

-(id)initWithResponse:(NSString *)requestHttpResponse andContentId:(int)requestContentId andResponseJsonContent:(NSString *)requestJsonResponse;

-(BOOL)isChangeSetOk;

-(NSDictionary *)getJsonResponseAsDictionary;

-(NSString *)getErrorMsg;

@end
