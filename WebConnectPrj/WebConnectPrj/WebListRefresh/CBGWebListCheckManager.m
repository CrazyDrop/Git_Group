//
//  CBGWebListCheckManager.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebListCheckManager.h"
#import "YYCache.h"
#import "WebEquip_listModel.h"
#import "ZALocationLocalModel.h"
@interface CBGWebListCheckManager()
{
    YYCache * historyCache;

}
@end
@implementation CBGWebListCheckManager
+(instancetype)sharedInstance
{
    static CBGWebListCheckManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self){
        //缓存当前已经存储的数据
        historyCache = [YYCache cacheWithName:@"web_ordersn_cache"];

    }
    return self;
}
//返回需要详情刷新的列表
-(void)checkLatestBackListDataModelsWithBackModelArray:(NSArray *)array
{
    //缓存
    if(!array)
    {
        self.urlsArray = nil;
        self.modelsArray = nil;
        return;
    }
     
    NSMutableArray * requestUrlsArr = [NSMutableArray array];
    NSMutableArray * requestArr = [NSMutableArray array];
    
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        WebEquip_listModel * eveModel = [array objectAtIndex:backIndex];
        NSString * url = eveModel.detailDataUrl;
        NSString * identifier = eveModel.detailCheckIdentifier;
        
        //如果没缓存，则进行存储，有缓存，则进行判定，状态判定不一致即处理
        NSNumber * cacheNum = (NSNumber *) [historyCache objectForKey:identifier];
        if(!cacheNum || [cacheNum intValue] == 2)
        {//没有缓存过或缓存失败，进行详情请求
            
        }else{
            continue;
        }
        
        if(url)
        {
            if(![requestUrlsArr containsObject:url])
            {
                [requestUrlsArr insertObject:url atIndex:0];
                [requestArr insertObject:eveModel atIndex:0];
            }
            
            //0为有启动过1为成功2为失败
            [historyCache setObject:[NSNumber numberWithInt:0] forKey:identifier];
        }
    }
    
    self.modelsArray = requestArr;
    self.urlsArray = requestUrlsArr;
}
//
-(void)refreshDiskCacheWithDetailRequestFinishedArray:(NSArray *)array
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    
    //统计进行修改   缓存数据增加DetailFinishAddNumber
    NSMutableArray * updateArr = [NSMutableArray array];
    NSMutableArray * editArr = [NSMutableArray array];
    NSMutableArray * compareArr = [NSMutableArray array];
    
    NSDate * latestDate = nil;
    //详情数据请求成功的，新增数据，筛选首次的进行展示
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        WebEquip_listModel * list = [array objectAtIndex:index];
        NSString * idenfifier = list.detailCheckIdentifier;
        if(list.equipModel && ![compareArr containsObject:idenfifier])
        {
            [compareArr addObject:idenfifier];
//            if([list isFirstInSelling])
            {
                [editArr addObject:list];
                
                NSDate * startDate = [NSDate fromString:list.equipModel.selling_time];
                NSTimeInterval count = [latestDate timeIntervalSinceDate:startDate];
                if(!latestDate || count < 0)
                {
                    latestDate = startDate;
                }
            }
            CBGListModel * cbgList = [list listSaveModel];
            cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshEval;
            [updateArr addObject:cbgList];
        }else{
            [historyCache removeObjectForKey:idenfifier];
        }
    }
    
    if(latestDate)
    {
        NSDate * nowDate = [NSDate date];
        NSTimeInterval count = [nowDate timeIntervalSinceDate:latestDate];
        [DZUtils noticeCustomerWithShowText:[NSString stringWithFormat:@"%.0f",count]];
    }
    
    
    //    NSLog(@"finishArr %ld filterArray %ld refresh %ld",[array count],[editArr count],[self.show_Models count]);
    NSLog(@"filterArray %ld ",[editArr count]);
    self.filterArray = editArr;
    
    //根据updateArr  更新主表
    if([updateArr count] > 0)
    {
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateArr];
    }
    
}


    
    
@end
