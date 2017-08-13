//
//  ZWOperationGroupReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/13.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseRequestModel.h"

@interface ZWOperationGroupReqModel : BaseRequestModel
{
    NSOperationQueue * defaultQueue;
}


@property (nonatomic, assign) BOOL saveCookie;
@property (nonatomic, strong, readonly) NSArray * baseUrls;
@property (nonatomic, strong, readonly) NSArray * baseReqModels;
@property (nonatomic, strong) NSArray * proxyArr;

@property (nonatomic, assign) NSInteger timeOutNum;
@property (nonatomic, assign) BOOL executing;
@prop_strong( NSArray *,		listArray	OUT )   //数组内嵌套数组
@prop_strong( NSArray *,		errorProxy	OUT )


-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic;
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)fields andStartUrl:(NSString *)urlStr;


-(void)refreshWebRequestWithArray:(NSArray *)list;
-(NSArray *)webRequestDataList;;

-(void)cancel;

@end
