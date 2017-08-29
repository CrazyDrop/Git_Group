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
@property (nonatomic, strong) NSMutableDictionary * cookieDic;
@end
@implementation EquipListRequestModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.saveCookie = NO;
        self.cookieDic = [NSMutableDictionary dictionary];
//        &sum_exp_min=111
//        &qian_neng_guo=33
//        &skill_qiang_shen=22
//        self.withHost = YES;
    }
    return self;
}
-(NSDictionary *)cookieStateWithStartWebRequestWithUrl:(NSString *)url
{
    if(!self.saveCookie){
        return nil;
    }
//    NSRange range = [url rangeOfString:@"server_id="];
//    if(range.location != NSNotFound)
//    {
//        NSInteger startIndex = range.location + range.length;
//        NSString * subStr = [url substringWithRange:NSMakeRange(startIndex,[url length] - startIndex)];
    
        NSString * subStr = @"shareCookie";

        NSDictionary * serverDic = [self.cookieDic objectForKey:subStr];
        //内含cookie
        if([serverDic count] > 0){
            NSArray * arrCookies = [serverDic allValues];
            NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:arrCookies];
            return dictCookies;
        }
//    }
    return nil;
}
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)fields andStartUrl:(NSString *)urlStr{
    //    NSLog(@"NSDictionary %@",fields);
    if(!self.saveCookie)
    {
        return ;
    }
    
    NSURL * url = [NSURL URLWithString:urlStr];
    NSArray * normalArr = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:url];
    NSArray *  cookies= normalArr;
//    [self checkAndRefreshLocalWebCookieArray:normalArr];
    
//    NSRange range = [urlStr rangeOfString:@"server_id="];
//    if(range.location != NSNotFound)
    {
//        NSInteger startIndex = range.location + range.length;
//        NSString * subStr = [urlStr substringWithRange:NSMakeRange(startIndex,[urlStr length] - startIndex)];
        NSString * subStr = @"shareCookie";
        
        NSDictionary * serverDic = [self.cookieDic objectForKey:subStr];
        NSMutableDictionary * editDic = [NSMutableDictionary dictionaryWithDictionary:serverDic];
        for (NSInteger index = 0;index < [cookies count] ;index ++ )
        {
            NSHTTPCookie * cookie = [cookies objectAtIndex:index];
            [editDic setObject:cookie forKey:cookie.name];
        }
        
        [self.cookieDic setObject:editDic forKey:subStr];
    }
}


-(void)setPageNum:(NSInteger)pageNum
{
    if(_pageNum != pageNum)
    {
        self.needUpdate = YES;
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


-(NSArray *)webRequestDataList
{
    NSString * baseUrl = MobileRefresh_ListRequest_Default_URLString;

    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSInteger totalNum = self.pageNum;
    if(totalNum == 0)
    {
        totalNum = RefreshListMaxPageNum;
    }
    
    
    for (NSInteger index = 1; index <= totalNum; index ++)
    {
        NSString * pageUrl = [self replaceStringWithLatestWebString:baseUrl];

        //增加设备号
//        &device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8
        NSString * replaceDeviceId = [self replaceDeviceIdWithPageIndex:index];
        NSString * eve = [NSString stringWithFormat:@"%@&device_id=%@&page=%ld",pageUrl,replaceDeviceId,(long)index];
//        if(self.selectSchool > 0)
//        {
//            eve = [eve stringByAppendingFormat:@"&school=%ld",self.selectSchool];
//        }
//        if(self.priceStatus == 1){
//            eve = [eve stringByAppendingString:@"&price_min=0&price_max=650000"];
//        }else if(self.priceStatus == 2){
//            eve = [eve stringByAppendingString:@"&price_min=650000&price_max=900000"];
//        }else if(self.priceStatus == 3){
//            eve = [eve stringByAppendingString:@"&price_min=900000&price_max=50000000"];
//        }

        
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
