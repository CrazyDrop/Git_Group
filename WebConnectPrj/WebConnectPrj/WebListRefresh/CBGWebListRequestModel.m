//
//  CBGWebListRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebListRequestModel.h"
#import "CreateModel.h"
#import "RoleSearch.h"
@interface CBGWebListRequestModel()
{
    
}
@property (nonatomic, strong) NSMutableDictionary * orderSNDic;
@property (nonatomic, strong) NSMutableDictionary * cookieDic;
@property (nonatomic, assign) NSInteger pageIndex;
//页码序列号，鉴于当前的服务器数据刷新频率低，
//进行循环，每次请求后更换url  0、1、2、3  数据相当于12s刷新一次
@property (nonatomic, assign) NSInteger maxPageNum; //并发请求数量控制
@end
@implementation CBGWebListRequestModel

-(id)init
{
    self = [super init];
    if(self)
    {
        self.cookieDic = [NSMutableDictionary dictionary];
//        self.orderSNDic = [NSMutableDictionary dictionary];
        self.maxPageNum = 3;
    }
    return self;
}
-(void)doneWebRequestWithBackHeaderDic:(NSDictionary *)dic andStartUrl:(NSString *)url
{
    //有，则先保存
    if([dic objectForKey:@"Set-Cookie"])
    {
        [self.cookieDic setObject:dic forKey:url];
    }
    
}

-(void)setCookitWithLatestUrl:(NSString *)url
{
    NSDictionary * dic = [self.cookieDic objectForKey:url];
    NSHTTPCookie * cookie = [[NSHTTPCookie alloc] initWithProperties:dic];
    NSHTTPCookieStorage * store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [store setCookie:cookie];
}
-(void)clearTotalSearchCookie
{
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesArray)
    {
        if([cookie.name isEqualToString:@"overall_sid"]){
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

-(BOOL)cookieStateWithStartWebRequestWithUrl:(NSString *)url
{
    NSDictionary * dic = [self.cookieDic objectForKey:url];
    if(dic)
    {
        [self setCookitWithLatestUrl:url];
        return YES;
    }else{
        [self clearTotalSearchCookie];
        return NO;
    }
    return YES;
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
    NSString * appendStr = @"&limit_clothes_logic=or";
    appendStr = @"";
    
    //增加随机参数，尽可能防止屏蔽
    //        &sum_exp_min=111
    //        &qian_neng_guo=33
    //        &skill_qiang_shen=22
    NSInteger randMinExp = arc4random() % 111 + 1;
    NSInteger randQianneng = arc4random() % 50 + 1;
    NSInteger skill_qiang_shen = arc4random() % 50 + 1;
    appendStr = [appendStr stringByAppendingFormat:@"&sum_exp_min=%ld&qian_neng_guo=%ld&skill_qiang_shen=%ld&limit_clothes_logic=or",randMinExp,randQianneng,skill_qiang_shen];
    
    //去掉设备号
    NSString * result = [replaceStr stringByAppendingString:appendStr];
    
    
    return result;
}
-(NSArray *)webRequestDataList
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * pageUrl = WebRefresh_ListRequest_Default_URLString;
    
    if(total.localURL1)
    {
        pageUrl = total.localURL1 ;
    }

    pageUrl = [self replaceStringWithLatestWebString:pageUrl];
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSInteger totalNum = self.pageNum;
    
    for (NSInteger index = 1; index <= totalNum; index ++)
    {
        //增加设备号
        //        &device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8
//        NSString * replaceDeviceId = [self replaceDeviceIdWithPageIndex:index];
        
        NSString * subStr = [self replaceAutoNumberForRandomReplaceIndex:index andBaseString:pageUrl];
    
//        NSInteger inUse = index%2 ;
        NSString * eve = [NSString stringWithFormat:@"%@&page=%ld",subStr,(long)index];
        [urls addObject:eve];
    }
    return urls;
}
-(NSString *)replaceAutoNumberForRandomReplaceIndex:(NSInteger)index andBaseString:(NSString *)baseString
{
    NSString * pageUrl = baseString;
    NSString * comparePre = @"fsdafsdafsdafawfsdflkjl23jrur394rfnndvnc23rjsoffljda";
    comparePre = [comparePre stringByAppendingFormat:@"%@ %ld",[NSDate unixDate],index];
    comparePre = [comparePre MD5String];

    NSString * compareStr = @"j0orjdhr";
    NSString * replaceStr = [[comparePre substringToIndex:[compareStr length]] lowercaseString];
    
    pageUrl = [pageUrl stringByReplacingOccurrencesOfString:compareStr withString:replaceStr];
    return pageUrl;
    
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
-(void)sendRequest
{
    //每次开启前，
    
    if(!self.executing)
    {
//        NSInteger lineNum = 55;
        if(self.autoRefresh){
            //自动递增  1、2、3页独立请求
            self.pageNum = 1;
            self.pageIndex ++;
            [self refreshPageIndexForLatestWebReqeust];
        }else{
            self.pageNum = 3;
        }
        self.maxTimeNum = 0;
    }
    [super sendRequest];
}
-(void)refreshPageIndexForLatestWebReqeust
{
    NSArray * urls = [self webRequestDataList];
    NSMutableArray * replaceArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [urls count]; index ++)
    {
        NSString * preStr = [urls objectAtIndex:index];
        NSString * subStr = @"page=";
        NSRange range = [preStr rangeOfString:subStr];
//        NSString * preIndex = [preStr substringWithRange:NSMakeRange(range.length + range.location, 1)];
        NSInteger pageNum =  (self.pageIndex + 2) % self.maxPageNum + 1;//数值  123  pageindex为1pageNum为1
        self.latestIndex = pageNum;
        NSString * refreshStr = [subStr stringByAppendingFormat:@"%ld",pageNum];
        
        range.length += 1;
        NSString * result = [preStr stringByReplacingCharactersInRange:range withString:refreshStr];
        [replaceArr addObject:result];
    }
    
    [self refreshWebRequestWithArray:replaceArr];
}
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    //    [CreateModel createModelWithJsonData:aDic rootModelName:@"RoleSearch"];
    RoleSearch * search = [[RoleSearch alloc] initWithDictionary:aDic];
    if([search.status integerValue] == 2 || search.msg)
    {//需要更换网络才行，暂未实现
        NSLog(@"%s %@",__FUNCTION__,search.msg);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_REFRESH_WEB_ERROR_STATE object:[NSNumber numberWithBool:YES]];
        return nil;
    }
    
    NSArray * array = search.equip_list;
    if(!array || ![array isKindOfClass:[NSArray class]])
    {
        //        NSLog(@"error %@ %@",NSStringFromClass([self class]),[aDic allKeys]);
        return nil;
    }
//    if([search.pager.cur_page integerValue] == 1)
    {
        //希望能够不重复
        WebEquip_listModel * eve = [array firstObject];
//        NSString * orderSN = eve.game_ordersn;
//        NSString * url = self.requestUrl;
//        NSArray * preArr = [self.orderSNDic allValues];
//        NSString * compare = @"13天23小时51分钟";//取出分钟数，最大的保留，其他的删除
        NSString * timeLeft = [eve time_left];
        NSInteger comNum = 0;
        NSArray * arr = [timeLeft componentsSeparatedByString:@"小时"];
        if([arr count]>0)
        {
            comNum = [[arr lastObject] intValue];
        }
        if(self.maxTimeNum < comNum)
        {
            self.maxTimeNum = comNum;
        }
        
//        NSLog(@"WebEquip_listModel %@ %ld %@ %ld",orderSN,self.maxTimeNum,timeLeft,self.latestIndex);
    }
    
    return array;
}


@end
