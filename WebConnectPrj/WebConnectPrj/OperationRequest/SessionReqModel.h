//
//  SessionReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
@class VPNProxyModel;
@interface SessionReqModel : BaseDataModel

@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSDictionary * cookieDic;
@property (nonatomic, strong) NSDictionary * proxyDic;
@property (nonatomic, strong) VPNProxyModel * proxyModel;

@end
