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



@end
