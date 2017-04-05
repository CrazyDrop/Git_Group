//
//  OLBasicRequest.h
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "NTBasicRequest.h"
typedef enum {
    OL_Connection_URL_Type_NONE = 0,//无请求类型
    OL_Connection_URL_Type_COMMON = 1,//默认的请求地址
    OL_Connection_URL_Type_CMS = 2,//CMS相关的
    OL_Connection_URL_Type_PRODUCT = 3,//产品库
}OL_Connection_URL_Type;


@interface OLBasicRequest : NTBasicRequest

/**
 *	@brief	设置此变量后，可以不设置requestStr，此值将设置默认地址
 */
@property (nonatomic,assign) OL_Connection_URL_Type urlType;



@end
