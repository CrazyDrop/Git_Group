//
//  CBGZhaohuanListRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGZhaohuanListRequestModel.h"
#import "RoleDataModel.h"
#import "CreateModel.h"
@interface CBGZhaohuanListRequestModel ()
@property (nonatomic, assign) BOOL needUpdate;
@end
@implementation CBGZhaohuanListRequestModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        //        &sum_exp_min=111
        //        &qian_neng_guo=33
        //        &skill_qiang_shen=22
        
    }
    return self;
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
    NSString * appendStr = @"&sum_exp_max=2000";
    //去掉设备号
    
    //增加随机参数，尽可能防止屏蔽
    //        &sum_exp_min=111
    //        &qian_neng_guo=33
    //        &skill_qiang_shen=22
    NSInteger randMinExp = arc4random() % 111 + 1;
    NSInteger randQianneng = arc4random() % 50 + 1;
    NSInteger skill_qiang_shen = arc4random() % 50 + 1;
    appendStr = [appendStr stringByAppendingFormat:@"&sum_exp_min=%ld&qian_neng_guo=%ld&skill_qiang_shen=%ld",randMinExp,randQianneng,skill_qiang_shen];
    appendStr = [appendStr stringByAppendingString:@"&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1"];
    appendStr = [appendStr stringByAppendingFormat:@"&act=super_query&search_type=overall_role_search&app_version=2.2.9"];
    appendStr = [appendStr stringByAppendingString:@"&page=1"];
    
//    &serverid=%@
    
    NSString * result = [replaceStr stringByAppendingString:appendStr];
    
    
    return result;
}
-(void)sendRequest
{
    if(!self.executing && self.needUpdate)
    {
        self.needUpdate = NO;
        [self refreshWebRequestWithArray:[self webRequestDataList]];
    }
    
    [super sendRequest];
}

//&act=super_query&search_type=overall_pet_search

-(NSArray *)webRequestDataList
{
    NSString * pageUrl = MobileRefresh_ListRequest_Default_URLString;
    
    pageUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin//xyq_search.py?orderby=selling_time%20DESC&act=super_query&search_type=overall_pet_search&kindid=69%2C70%2C75%2C68%2C67%2C71&skill=405%2C416&serverid=625&page=1&platform=ios&app_version=2.2.9&device_name=%20iPhone&os_name=iOS&os_version=10.3.1&device_id=2E6FD69B-5EAC-48A7-BFEB-86ADD1F018C9";
    
    pageUrl =@"http://xyq-ios2.cbg.163.com/app2-cgi-bin//query.py?serverid=84&game_ordersn=443_1500799216_444795440&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.9&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iOS&os_version=10.3.1&device_id=2E6FD69B-5EAC-48A7-BFEB-86ADD1F018C9";
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSInteger totalNum = self.pageNum;
    
    for (NSInteger index = 1; index < totalNum; index ++)
    {
//        NSString * deviceId = [self replaceDeviceIdWithPageIndex:index];
//        NSString * requestUrl = [self replaceStringWithLatestWebString:pageUrl];
//        requestUrl = [requestUrl stringByAppendingFormat:@"&device_id=%@&page=%ld",deviceId,index];
        NSString * requestUrl = pageUrl;
        [urls addObject:requestUrl];
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
    if(aDic){
     [CreateModel createModelWithJsonData:aDic rootModelName:@"BBListModel"];   
    }
    
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
