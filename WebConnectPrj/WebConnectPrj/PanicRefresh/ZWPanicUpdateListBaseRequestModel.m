//
//  ZWPanicUpdateListBaseRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicUpdateListBaseRequestModel.h"
#import "Equip_listModel.h"

@interface ZWPanicUpdateListBaseRequestModel ()
{
    NSMutableArray * cacheArr;
}
@end

@implementation ZWPanicUpdateListBaseRequestModel
-(id)init
{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(detailRefreshFinishedLocalUpdateAndRemoveWithBackNoti:)
                                                     name:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                   object:nil];
    }
    return self;
}
-(void)detailRefreshFinishedLocalUpdateAndRemoveWithBackNoti:(NSNotification *)noti
{
    Equip_listModel * list = (Equip_listModel *)[noti object];
    NSString * keyStr = list.listCombineIdfa;
    
    //进行库表存储
    CBGListModel * cbgModel = [list listSaveModel];
    cbgModel.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:@[cbgModel]];

    
    @synchronized (cacheArr)
    {
        if([cacheArr containsObject:keyStr])
        {
            [cacheArr removeObject:keyStr];
        }
    }
}

//启动列表请求，检查数据状态、价格
//软件保存selltime，请求数据，仅对selltime之后的数据进行处理
//1、状态检查，未上架  发起消息通知
//否则：库表检查、价格变动、进行代理调用







@end
