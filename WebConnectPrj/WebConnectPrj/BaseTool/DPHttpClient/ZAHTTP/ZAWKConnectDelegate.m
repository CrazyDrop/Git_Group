//
//  ZAWKConnectDelegate.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/9/28.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAWKConnectDelegate.h"
@interface ZAWKConnectDelegate()
{
    BaseRequestModel * _dpModel;
    BaseRequestModel * _dpStartModel;
    BOOL isWorking;
    BOOL runForNow;
}
////请求参数
@property (nonatomic,strong) NSDictionary * requestDic;

//数据返回block
@property (nonatomic,copy) void (^replyBlockForAppleWatch)(NSDictionary * dic);

@property (nonatomic,copy) void (^localIphoneBlock)(void);

@end
@implementation ZAWKConnectDelegate
-(instancetype)init
{
    self =[super init];
    if(self)
    {
        runForNow = NO;
    }
    return self;
}

-(void)startWebRequestWithRequestDic:(NSDictionary *)info andReplyBlockForAppleWatch:(void (^)(NSDictionary * dic))replyBlock andLocalSuccessBlock:(void(^)(void))iphoneBlock
{
    if(isWorking)
    {
        NSLog(@"%s %@",__FUNCTION__,[NSNumber numberWithBool:isWorking]);
        return;
    }

    isWorking = YES;
    self.replyBlockForAppleWatch = replyBlock;
    self.localIphoneBlock = iphoneBlock;
    self.requestDic = info;
    
    
    //根据dic生成model，进行网络请求，等待返回
    NSString *type = info[@"type"];
    
    BOOL warningState = NO;
    if(![WKDZUITIL_KEY_TIME_STATE_TYPE_CANCELED isEqualToString:type] && ![WKDZUITIL_KEY_TIME_STATE_TYPE_WARNING isEqualToString:type])
    {
        warningState = [self checkLocalWarningModelWithPreWarningModel];
    }
    
    if([WKDZUITIL_KEY_TIME_STATE_TYPE_STARTED isEqualToString:type])
    {
        if(warningState) return;
        //启动倒计时
        NSString * total = info[@"total"];
        [self startWebStateRequestTimingidRequestWithMinute:[total intValue]];
        
    }else if ([WKDZUITIL_KEY_TIME_STATE_TYPE_WARNING isEqualToString:type])
    {
        //启动预警，有倒计时id的
//        WarnTimingModel * local = [WarnTimingModel warnTimingFromLocalSave];
//        //此处需要特殊处理，以保证timeid返回
//        if(!local)
//        {
//            NSString * errStr = kAppNone_Service_Error;
//            [self finishWebConnectWithErrorString:errStr];
//            return;
//        }
        [self startWebStateRunWarningRequest];
        
    }else if ([WKDZUITIL_KEY_TIME_STATE_TYPE_CANCELED isEqualToString:type]){
        //取消预警，有倒计时id的
//        WarnTimingModel * local = [WarnTimingModel warnTimingFromLocalSave];
//        //此处需要特殊处理，以保证timeid返回
//        if(!local||!local.timeId||[local.timeId length]==0)
//        {
//            NSString * errStr = kAppNone_Service_Error;
//            [self finishWebConnectWithErrorString:errStr];
//            return;
//        }
        [self startWebStateCancelRequest];
        
    }else if ([WKDZUITIL_KEY_QUICK_STATE_TYPE_WARNING isEqualToString:type])
    {
        if(warningState) return;

        runForNow = YES;
        //启动紧急预警，先获取id，之后启动预警
        NSInteger total = 60 * 24;
        [self startWebStateRequestTimingidRequestWithMinute:total];
    }



}

//请求倒计时id
-(void)startWebStateRequestTimingidRequestWithMinute:(NSInteger)total
{
//    //数据上传
//    WarnTimingModel * model = (WarnTimingModel *) _dpStartModel;
//    if(!model){
//        model = [[WarnTimingModel alloc] init];
//        [model addSignalResponder:self];
//        _dpStartModel = model;
//    }
//    model.duration = [NSString stringWithFormat:@"%ld",total*60];
//    model.scene = @"1";
//    if(runForNow) model.scene = @"2";
//    [model sendRequest];
}

-(BOOL)checkLocalWarningModelWithPreWarningModel
{
    BOOL hasModel = ![DZUtils localWarningStateCheckIsNone];
    
    if(hasModel)
    {
        [self doneWatchRequestForCustomErrorString];
    }

    return hasModel;
}
-(void)doneWatchRequestForCustomErrorString
{
    NSString * errorStr = @"已在iPhone上启动防护，请勿重复开启防护。";
    [self finishWebConnectWithErrorString:errorStr];
}
-(void)finishWebConnectWithErrorString:(NSString *)errorStr
{
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
    BOOL success = YES;
    if(errorStr&&[errorStr length]>0)
    {
        success = NO;
    }
    [resultDic setValue:[NSNumber numberWithBool:success] forKey:@"result"];
    [resultDic setValue:errorStr forKey:@"info"];
    
    if(success)
    {
        if(self.localIphoneBlock)
        {
            self.localIphoneBlock();
        }
    }
    
    NSLog(@"%s %@",__FUNCTION__,resultDic);
    if(self.replyBlockForAppleWatch)
    {
        self.replyBlockForAppleWatch(resultDic);
    }
    isWorking = NO;
}


#pragma mark WarnTimingModel
handleSignal( WarnTimingModel, requestError )
{
    if(runForNow) runForNow = NO;
    NSString * errStr = kAppNone_Service_Error;
    if([DZUtils deviceWebConnectEnableCheck])
    {
        errStr = kAppNone_Network_Error;
    }
    [self finishWebConnectWithErrorString:errStr];
}
handleSignal( WarnTimingModel, requestLoading )
{
}
handleSignal( WarnTimingModel, requestLoaded )
{
//    WarnTimingModel * model = (WarnTimingModel *) _dpStartModel;
//    NSString * warningId = model.timeId;
//    NSString * errStr = kAppNone_Service_Error;
//    if(warningId&&[warningId length]>0)
//    {
//        errStr = nil;
////        [model localSave];
//        
//        //分两部分储存，此处存储model
//        ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
//        local.timeModel = model;
//        local.warningId = [model.timeId copy];
//        [local localSave];
//        
//        //正常返回，并且立即预警
//        if(runForNow)
//        {
//            [self startWebStateRunWarningRequest];
//            return;
//        }
//    }
//    [self finishWebConnectWithErrorString:errStr];
    
}
#pragma mark -


//立即启动预警
-(void)startWebStateRunWarningRequest
{
    ZALocalStateTotalModel * localModel = [ZALocalStateTotalModel currentLocalStateModel];
//    WarnTimingModel * local = localModel.timeModel;
////    [WarnTimingModel warnTimingFromLocalSave];
//    //此处需要特殊处理，以保证timeid返回
////    if(!local||!local.timeId||[local.timeId length]==0) return;
//    
//    //数据上传，通知解除
//    WarningModel * model = (WarningModel *) _dpModel;
//    if(!model){
//        model = [[WarningModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    model.timingId = local.timeId;
//    model.scene = local.scene;
//    model.type = WarningModel_TYPE_START;
//    [model sendRequest];
}



//取消倒计时预警
-(void)startWebStateCancelRequest
{
    //网络请求，通知服务器,如果本地没有保存的倒计时数据,直接返回
    ZALocalStateTotalModel * localModel = [ZALocalStateTotalModel currentLocalStateModel];
//    WarnTimingModel * local = localModel.timeModel;
//    [WarnTimingModel warnTimingFromLocalSave];
    
    //数据上传，通知解除
//    WarningModel * model = (WarningModel *) _dpModel;
//    if(!model){
//        model = [[WarningModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    model.timingId = local.timeId;
//    model.scene = local.scene;
//    model.type = WarningModel_TYPE_STOP;
//    [model sendRequest];
}

#pragma mark WarningModel
handleSignal( WarningModel, requestError )
{
//    WarningModelTYPE type = [(WarningModel *)_dpModel type];
//    if(type==WarningModel_TYPE_START)
    if(runForNow) runForNow = NO;
    NSString * errStr = kAppNone_Service_Error;
    if([DZUtils deviceWebConnectEnableCheck])
    {
        errStr = kAppNone_Network_Error;
    }
    [self finishWebConnectWithErrorString:errStr];
    return;
}
handleSignal( WarningModel, requestLoading )
{
}
handleSignal( WarningModel, requestLoaded )
{
    if(runForNow) runForNow = NO;
    ZAHTTPResponse *resp = signal.object;
    NSString * errStr = kAppNone_Service_Error;
    if(resp&&[resp.returnCode intValue] == HTTPReturnSuccess)
    {
        errStr = nil;
    }
    [self finishWebConnectWithErrorString:errStr];

}
#pragma mark -


@end
