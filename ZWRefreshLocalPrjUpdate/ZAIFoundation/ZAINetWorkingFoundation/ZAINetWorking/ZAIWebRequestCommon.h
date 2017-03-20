//
//  ZAIWebRequestCommon.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/10.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#ifndef ZAIWebRequestCommon_h
#define ZAIWebRequestCommon_h

#define ZAORequestInvalidID     -1

typedef unsigned long ZAIRequestID;

typedef enum _ZAOUrlType {
    ZAOUrlTypeTested,
    ZAOUrlTypeFormal
}ZAIUrlType;

typedef enum _ZAIWebRequestApiOutputType
{
    ZAOApiOutputTypeBlock,
    ZAOApiOutputTypeNotification,
    zAOApiOutputTypeCount
    
} ZAIWebRequestApiOutputType;

typedef enum _ZAIWebRequestMethod
{
    ZAOWebRequestMethodGET,
    ZAOWebRequestMethodPOST,
    ZAOWebRequestMethodPUT,
    ZAOWebRequestMethodPATCH,
    ZAOWebRequestMethodDELETE,
    ZAOWebRequestMethodMAX
    
}ZAIWebRequestMethod;


typedef void (^outputHandler)(NSDictionary *responseData);

#endif
