//
//  ZWDefaultOperationReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseRequestModel.h"
//使用operation的基础类，实现功能，一组网络请求调用
//内部使用ZWSessionReqOperation
@class VPNProxyModel;
@interface ZWDefaultOperationReqModel : BaseRequestModel
{
    NSOperationQueue * defaultQueue;
    
}
@property (nonatomic, strong, readonly) NSArray * webReqArr;

@property (nonatomic, strong) NSArray * proxyArr;
@property (nonatomic, assign) NSInteger timeOutNum;
@property (nonatomic, strong) NSArray * baseUrls;
@property (nonatomic, assign) BOOL executing;
@prop_strong( NSArray *,		listArray	OUT )
@prop_strong( NSArray *,		errorProxy	OUT )
-(void)refreshWebRequestWithArray:(NSArray *)list;

//cookie相关
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)dic andStartUrl:(NSString *)url;
-(NSDictionary *)cookieStateWithStartWebRequestWithUrl:(NSString *)url;
-(VPNProxyModel *)proxyModelWithStartWebRequestWithUrl:(NSString *)url;

-(NSArray *)webRequestDataList;
//提供解析方法，需要能满足多线程操作
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic;

//取消请求，结束回调
-(void)cancel;


@end
