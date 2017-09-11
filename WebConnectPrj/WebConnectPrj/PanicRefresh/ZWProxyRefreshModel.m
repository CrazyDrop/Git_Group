//
//  ZWProxyRefreshModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/9/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWProxyRefreshModel.h"
#import "ZWDetailVPNTestReqModel.h"
#import "ZWGroupVPNTestReqModel.h"
#import "VPNProxyModel.h"
#import "SessionReqModel.h"
@interface ZWProxyRefreshModel()
{
    BaseRequestModel * _detailModel;
    BaseRequestModel * _dpModel;
    
    NSMutableArray * finishArr;
    NSMutableArray * failArr;
}

@property (nonatomic, assign) NSInteger subNum;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) BOOL subFinish;

@property (nonatomic, strong) NSArray * sessionArr;
@property (nonatomic, strong) NSArray * subVpnArr;

@property (nonatomic, copy) NSArray * startVPNArr;
@property (nonatomic, assign) BOOL isFinished;
@end

@implementation ZWProxyRefreshModel
-(id)init
{
    self =[super init];
    if(self)
    {
        self.subNum = 10;
        self.startIndex = 0;
        self.isFinished = YES;
        
        finishArr = [NSMutableArray array];
        failArr = [NSMutableArray array];
    }
    return self;
}
-(void)startProxyRefreshCheck
{
    //根据checkarr创建sessionarr
    
    NSArray * vpnArr = self.checkArr;
    if([vpnArr count] == 0)
    {
        [self finishWebRequestWithSuccessArr:nil andFailArr:nil];
        return;
    }
    
    self.isFinished = NO;
    self.startVPNArr = vpnArr;
    self.startIndex = 0;
    NSMutableArray * arr = [NSMutableArray array];
    for (NSInteger index = 0;index < [vpnArr count] ;index ++ )
    {
        VPNProxyModel * proxy = [vpnArr objectAtIndex:index];
        proxy.checked = NO;
        
        SessionReqModel * req =[[SessionReqModel alloc] initWithProxyModel:proxy];
        [arr addObject:req];
    }
    self.sessionArr = arr;
    
    //触发请求
    if(self.maxSubNum > 0)
    {
        self.subNum = self.maxSubNum;
    }
    
    self.subFinish = YES;
    [self startCheckAndRefreshDetailSubSessionArray];
}

-(void)startCheckAndRefreshDetailSubSessionArray
{
    ZWGroupVPNTestReqModel * model = (ZWGroupVPNTestReqModel *)_dpModel;
    if(model.executing) return;
    
    if(!self.subFinish) return;
    
    
    NSArray * subSession = nil;
    NSArray * totalArr = self.sessionArr;
    if(self.startIndex == [totalArr count])
    {
        self.isFinished = YES;
        //结束、刷新
        [self finishWebRequestWithSuccessArr:finishArr
                                  andFailArr:failArr];
        return;
    }
    
    NSInteger sepNumber = self.subNum;
    
    NSRange range = NSMakeRange(self.startIndex, sepNumber);
    if(range.location + range.length > [totalArr count])
    {
        range.length = [totalArr count] - range.location;
    }
    
    subSession = [totalArr subarrayWithRange:range];
    self.subVpnArr = [self.startVPNArr subarrayWithRange:range];

    [self startRefreshDataModelRequestWithSubArr:subSession];
}

-(void)cancelLatestProxyRefreshCheck
{
    ZWGroupVPNTestReqModel * refresh = (ZWGroupVPNTestReqModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    _dpModel = nil;

}
-(void)startRefreshDataModelRequestWithSubArr:(NSArray *)subArr
{

    NSLog(@"%s",__FUNCTION__);
    //    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    ZWGroupVPNTestReqModel * model = (ZWGroupVPNTestReqModel *)_dpModel;
    
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        //        model = [[EquipListRequestModel alloc] init];
        model = [[ZWGroupVPNTestReqModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    
    model.pageNum = [subArr count];
    model.sessionArr = subArr;
    model.timerState = !model.timerState;
    [model sendRequest];
}
#pragma mark ZWGroupVPNTestReqModel
handleSignal( ZWGroupVPNTestReqModel, requestError )
{
}
handleSignal( ZWGroupVPNTestReqModel, requestLoading )
{
}
handleSignal( ZWGroupVPNTestReqModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    ZWGroupVPNTestReqModel * model = (ZWGroupVPNTestReqModel *) _dpModel;
    NSArray * total  = model.listArray;
    NSArray * vpn = self.subVpnArr;
    
    //正常序列
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = index;
        VPNProxyModel * vpnModel = [vpn objectAtIndex:backIndex];
        vpnModel.checked = YES;
        
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            vpnModel.success = YES;
            [finishArr addObject:vpnModel];
        }else
        {
            [failArr addObject:vpnModel];
        }
    }
    
    self.startIndex += [vpn count];
    self.subFinish = YES;
    
    [self performSelector:@selector(startCheckAndRefreshDetailSubSessionArray) withObject:nil afterDelay:1];
}

-(void)finishWebRequestWithSuccessArr:(NSArray *)success andFailArr:(NSArray *)fail
{
    if(self.resultDelegate && [self.resultDelegate respondsToSelector:@selector(proxyCheckRefreshModel:finishedCheckWithSuccess:andFail:)])
    {
        [self.resultDelegate proxyCheckRefreshModel:self
                           finishedCheckWithSuccess:success
                                            andFail:fail];
    }
}


@end
