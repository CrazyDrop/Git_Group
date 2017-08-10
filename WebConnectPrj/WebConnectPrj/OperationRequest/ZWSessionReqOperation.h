//
//  ZWSessionReqOperation.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
//网络请求session的operation
@class VPNProxyModel;
@class ZWSessionReqOperation;
@protocol ZWSessionReqDelegate <NSObject>

-(void)sessionRequestOperation:(ZWSessionReqOperation *)session
                     finishReq:(NSDictionary *)backDic
                      errorDic:(NSDictionary *)errDic;

@optional
-(void)sessionRequestOperation:(ZWSessionReqOperation *)session
   doneWebRequestBackHeaderDic:(NSDictionary *)dic
                   andStartUrl:(NSString *)url;

@end

//处理单一网络请求，结果通过代理回调
@interface ZWSessionReqOperation : NSOperation

@property (nonatomic, assign) NSInteger timeOutNum;
@property (nonatomic, copy) NSString * reqUrl;
@property (nonatomic, copy) NSDictionary * cookieDic;
@property (nonatomic, copy) NSDictionary * proxyDic;
@property (nonatomic, strong) VPNProxyModel * proxyModel;

@property (nonatomic, assign) id<ZWSessionReqDelegate> dataDelegate;

@property (nonatomic, assign) BOOL saveKookie;


@end
