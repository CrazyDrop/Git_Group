//
//  ZWDetailCheckManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDetailCheckManager.h"
#import "Equip_listModel.h"
#import "EquipModel.h"
#import "ZALocationLocalModel.h"
#import "YYCache.h"
@interface ZWDetailCheckManager()<NSCacheDelegate>
{
    YYCache * modelCache;
}
@property (nonatomic,strong) NSMutableDictionary * checkDic;
@end

@implementation ZWDetailCheckManager
+(instancetype)sharedInstance
{
    static ZWDetailCheckManager *shareZWDetailCheckManagerInstance = nil;
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
        self.checkDic = [NSMutableDictionary dictionary];
        
        //缓存当前已经存储的数据
        modelCache = [YYCache cacheWithName:@"list_ordersn_cache"];
        
    }
    return self;
}

-(NSArray *)latestRequestDetailModelsWithCurrentBackModelArray:(NSArray *)array
{
    if(!array)
    {
        self.urlsArray = nil;
        return nil;
    }
    
    
    NSMutableArray * urlArr = [NSMutableArray array];
    NSMutableArray * backArray = [NSMutableArray array];
    
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
//        backIndex = index;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        NSString * url = eveModel.detailDataUrl;
        NSString * identifier = eveModel.detailCheckIdentifier;
        NSNumber * status = eveModel.equip_status;
        
        //如果没缓存，则进行存储，有缓存，则进行判定，状态判定不一致即处理
        NSNumber * cacheStatus = (NSNumber *) [modelCache objectForKey:identifier];
        if(!cacheStatus)
        {//没有缓存过
            
        }else if(![status isEqual:cacheStatus])
        {//缓存状态和当前不一致
            
        }else{
        //缓存状态和当前一致,不需要重新请求
            continue;
        }
        
        if(url)
        {
            if(![urlArr containsObject:url])
            {
                [urlArr insertObject:url atIndex:0];
                [backArray insertObject:eveModel atIndex:0];
            }
            [modelCache setObject:status forKey:identifier];
        }

    }
    
    
    self.urlsArray = urlArr;
    return backArray;
}




@end
