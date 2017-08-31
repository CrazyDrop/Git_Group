//
//  ZWOperationEquipListCircleReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/11.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWOperationEquipListCircleReqModel.h"
#import "RoleDataModel.h"
#import "VPNProxyModel.h"
@interface ZWOperationEquipListCircleReqModel ()
@property (nonatomic, strong) NSMutableDictionary * cookieDic;
@end
@implementation ZWOperationEquipListCircleReqModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        
//        self.timeOutNum = 5;
        self.saveCookie = NO;
        self.cookieDic = [NSMutableDictionary dictionary];

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
    NSInteger randBad = arc4random() % 10 + 1;
    NSInteger randChengjiu = arc4random() % 200 + 1;
    appendStr = [appendStr stringByAppendingFormat:@"&sum_exp_min=%ld&qian_neng_guo=%ld&skill_qiang_shen=%ld",randMinExp,randQianneng,skill_qiang_shen];
    appendStr = [appendStr stringByAppendingFormat:@"&badness=%ld&cheng_jiu=%ld",randBad,randChengjiu];
    
    appendStr = [appendStr stringByAppendingString:@"&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1"];
    
    NSString * result = [replaceStr stringByAppendingString:appendStr];

    
    return result;
}


-(NSArray *)webRequestDataList
{
    NSString * baseUrl = MobileRefresh_ListRequest_Default_URLString;
    
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSInteger totalNum = self.repeatNum;
    
    for (NSInteger index = 1; index <= totalNum; index ++)
    {
        NSInteger pageNum = 3;
        for(NSInteger evePage = 1 ;evePage <= pageNum ;evePage ++)
        {
            NSString * pageUrl = [self replaceStringWithLatestWebString:baseUrl];
            
            //增加设备号
            //        &device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8
            NSString * replaceDeviceId = [self replaceDeviceIdWithPageIndex:index];
            NSString * eve = [NSString stringWithFormat:@"%@&page=%ld",pageUrl,(long)evePage];
            
            //        if(self.selectSchool > 0)
            //        {
            //            eve = [eve stringByAppendingFormat:@"&school=%ld",self.selectSchool];
            //        }
            //        if(self.priceStatus == 1){
            //            eve = [eve stringByAppendingString:@"&price_min=300000&price_max=850000"];
            //        }else if(self.priceStatus == 2){
            //            eve = [eve stringByAppendingString:@"&price_min=850000&price_max=1000000"];
            //        }else if(self.priceStatus == 3){
            //            eve = [eve stringByAppendingString:@"&price_min=1000000&price_max=2500000"];
            //        }
            eve = [NSString stringWithFormat:@"%@&device_id=%@",eve,replaceDeviceId];
            [urls addObject:eve];
        }
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
    //    if([listData.num_per_page integerValue] == 1)
    //    {
    //        Equip_listModel * eve = [array firstObject];
    //        NSLog(@"role %@ %@",eve.game_ordersn,eve.sell_expire_time_desc);
    //    }
    
    return array;
}


@end
