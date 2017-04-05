//
//  EquipListRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/4.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "EquipListRequestModel.h"
#import "RoleDataModel.h"
@interface EquipListRequestModel ()
@property (nonatomic, assign) BOOL needUpdate;
@end
@implementation EquipListRequestModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}
-(void)setPageNum:(NSInteger)pageNum
{
    if(_pageNum != pageNum)
    {
        self.needUpdate = YES;
        if(pageNum < 5)
        {
            self.listSession.configuration.timeoutIntervalForRequest = 60;
        }
    }
    _pageNum = pageNum;
}
-(void)setTimerState:(BOOL)timerState
{
    if(_timerState != timerState)
    {
        self.needUpdate = YES;
    }
    _timerState = timerState;
}

-(NSString *)replaceStringWithLatestWebString:(NSString *)webStr
{
    if(!webStr) return nil;
    //文本替换，移除 page 替换 device_id device_name os_name os_version
    NSArray * removeArr = @[@"page",
                            @"device_id",
                            @"device_name",
                            @"os_version"];
    
    NSString * sepStr = @"&";
    NSArray * sepArr = [webStr componentsSeparatedByString:sepStr];
    NSMutableArray * replaceArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sepArr count];index ++)
    {
        NSString * eveStr = [sepArr objectAtIndex:index];
//        device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8;
        NSArray * eveArr = [eveStr componentsSeparatedByString:@"="];
        NSString * eveSubStr = [eveArr firstObject];
        
        if([removeArr containsObject:eveSubStr])
        {
            continue;
        }
        [replaceArr addObject:eveStr];
    }
    
    NSString * replaceStr = [replaceArr componentsJoinedByString:sepStr];
    NSString * appendStr = @"&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1";
    //去掉设备号
    
    NSString * result = [replaceStr stringByAppendingString:appendStr];
    
    
    return result;
}
-(void)sendRequest
{
    if(!self.executing && self.needUpdate)
    {
        [self refreshWebRequestWithArray:[self webRequestDataList]];
    }
    
    [super sendRequest];
}


-(NSArray *)webRequestDataList
{
    NSString * pageUrl = MobileRefresh_ListRequest_Default_URLString;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.localURL2)
    {
        pageUrl = [NSString stringWithFormat:@"%@%@",HeaderUrl_MobileRefresh_URLString,total.localURL2] ;
    }

    pageUrl = [self replaceStringWithLatestWebString:pageUrl];
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSInteger totalNum = self.pageNum;
    if(totalNum == 0)
    {
        totalNum = RefreshListMaxPageNum;
    }
    
    
    for (NSInteger index = 1; index <= totalNum; index ++)
    {
        //增加设备号
//        &device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8
        NSString * replaceDeviceId = [self replaceDeviceIdWithPageIndex:index];
        NSString * eve = [NSString stringWithFormat:@"%@&device_id=%@&page=%ld",pageUrl,replaceDeviceId,(long)index];
        [urls addObject:eve];
    }
    return urls;
}
-(NSString *)replaceDeviceIdWithPageIndex:(NSInteger)index
{
    NSString * orderString = [NSString stringWithFormat:@"DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8%@%ld",[NSDate unixDate],index];
    NSString * md5Str = [orderString MD5String];
    
    orderString = [orderString stringByAppendingString:@"再来"];
    NSString * nexMd5 = [orderString MD5String];
    
    NSMutableString * total = [NSMutableString string];
    [total appendString:md5Str];
    [total appendString:nexMd5];
    
    NSString * compareStr = @"DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
    NSArray * arr = [compareStr componentsSeparatedByString:@"-"];
    
    NSInteger startIndex = 0;
    for (NSInteger index = 0; index < [arr count] ;index ++ )
    {
        NSInteger eveIndex = [[arr objectAtIndex:index] length];
        startIndex += eveIndex;
        [total insertString:@"-" atIndex:startIndex];
        startIndex += 1;
    }
    NSString * result = [total substringWithRange:NSMakeRange(0, [compareStr length])];
    return result;
}

-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    RoleDataModel * listData = [[RoleDataModel alloc] initWithDictionary:aDic];
    NSArray * array = listData.equip_list;
    if(!array || ![array isKindOfClass:[NSArray class]])
    {
//        NSLog(@"error %@ %@",NSStringFromClass([self class]),[aDic allKeys]);
        return nil;
    }
    if([listData.num_per_page integerValue] == 1)
    {
        Equip_listModel * eve = [array firstObject];
        NSLog(@"role %@ %@",eve.game_ordersn,eve.sell_expire_time_desc);
    }
    
    return array;
}


@end
