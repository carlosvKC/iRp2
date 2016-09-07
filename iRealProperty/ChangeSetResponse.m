//
//  ChangeSetResponse.m
//  iRealProperty
//
//  Created by George on 6/8/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import "ChangeSetResponse.h"
#import "NSDataBase64.h"
#import "SBJSON.h"

@implementation ChangeSetResponse

@synthesize httpResponse;
@synthesize contentId;
@synthesize jsonResponse;

-(id)initWithResponse:(NSString *)requestHttpResponse andContentId:(int)requestContentId andResponseJsonContent:(NSString *)requestJsonResponse
{
    self= [super init];
    if (self)
    {
        self.httpResponse = requestHttpResponse;
        self.contentId = requestContentId;
        self.jsonResponse = requestJsonResponse;
    }
    return self;
}

-(BOOL)isChangeSetOk
{
    if (httpResponse != nil) 
    {
        if ([httpResponse characterAtIndex:0] == '2') 
            return YES;
        else
            return NO;
    }
    return NO;
}

-(NSDictionary *)getJsonResponseAsDictionary
{
    if (jsonResponse != nil) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary* parsedData = [parser objectWithString:jsonResponse error:nil];
        return parsedData;
    }
    return nil;
}

-(NSString *)getErrorMsg
{
    NSString *errMsg;
    if (![self isChangeSetOk]) {
        NSDictionary *errObj = [[self getJsonResponseAsDictionary] objectForKey:@"error"];
        if (errObj != nil) 
        {
            NSDictionary *errMsgDic = [errObj objectForKey:@"message"];
            errMsg = [errMsgDic objectForKey:@"value"];
        }
    }
    
    return errMsg;
}

@end
