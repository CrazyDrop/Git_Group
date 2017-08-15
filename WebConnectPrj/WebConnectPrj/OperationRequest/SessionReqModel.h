//
//  SessionReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
//单一网络请求对应的数据model
//   url   cookie   session   proxyModel

@class VPNProxyModel;
@interface SessionReqModel : BaseDataModel

@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSDictionary * cookieDic;
@property (nonatomic, strong) VPNProxyModel * proxyModel;
@property (nonatomic, strong, readonly) NSDictionary * proxyDic;
@property (nonatomic, strong, readonly) NSURLSession * session;

-(id)initWithProxyModel:(VPNProxyModel *)model;




@end
