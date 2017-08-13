//
//  ServerEquipIdRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ServerEquipIdRequestModel.h"
#import "EquipModel.h"
#import "JSONKit.h"
#import "ZWServerEquipModel.h"
#import "ZWDetailCheckManager.h"
@interface ServerEquipIdRequestModel ()
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) NSMutableDictionary * cookieDic;
@end
@implementation ServerEquipIdRequestModel

-(id)init
{
   self = [super init];
    if(self){
        self.saveCookie = YES;
        self.cookieDic = [NSMutableDictionary dictionary];
        ZWDetailCheckManager * manager = [ZWDetailCheckManager sharedInstance];
        [self.cookieDic addEntriesFromDictionary:manager.cookieDic];
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
-(NSArray *)checkAndRefreshLocalWebCookieArray:(NSArray *)arr
{
    NSMutableArray * editArr = [NSMutableArray array];
    [editArr addObjectsFromArray:arr];
    
    NSString * cookieName = @"latest_views";
    NSHTTPCookie * editCookie = nil;
    NSArray *cookiesArray = arr;
    for (NSHTTPCookie *cookie in cookiesArray)
    {
        if([cookie.name isEqualToString:cookieName])
        {
            editCookie = cookie;
            break;
        }
    }
    
    if(editCookie)
    {
        NSString * editValue = editCookie.value;
        NSArray * arr = [editValue componentsSeparatedByString:@"-"];
        if([arr count] >1)
        {
            NSString * editRefresh = [arr lastObject];
            
            NSDictionary * preDic = [editCookie properties];
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties addEntriesFromDictionary:preDic];
            [cookieProperties setObject:editRefresh forKey:NSHTTPCookieValue];
            
            NSHTTPCookie *refreshCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:editCookie];
            //            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:refreshCookie];
            [editArr removeObject:editCookie];
            [editArr addObject:refreshCookie];
        }
        
    }
    return editArr;
}

-(NSDictionary *)cookieStateWithStartWebRequestWithUrl:(NSString *)url
{
    if(!self.saveCookie){
        return nil;
    }
    NSRange range = [url rangeOfString:@"server_id="];
    if(range.location != NSNotFound)
    {
        NSInteger startIndex = range.location + range.length;
        NSString * subStr = [url substringWithRange:NSMakeRange(startIndex,[url length] - startIndex)];
        
        NSDictionary * serverDic = [self.cookieDic objectForKey:subStr];
        //内含cookie
        if([serverDic count] > 0){
            NSArray * arrCookies = [serverDic allValues];
            NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:arrCookies];
            return dictCookies;
        }
    }
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
    NSArray *  cookies= [self checkAndRefreshLocalWebCookieArray:normalArr];
    
    NSRange range = [urlStr rangeOfString:@"server_id="];
    if(range.location != NSNotFound)
    {
        NSInteger startIndex = range.location + range.length;
        NSString * subStr = [urlStr substringWithRange:NSMakeRange(startIndex,[urlStr length] - startIndex)];
        
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


-(NSString *)replaceStringWithLatestWebString:(NSString *)webStr andServerId:(NSString *)server andEquipId:(NSString *)equipId
{
    if(!webStr) return nil;
    //文本替换，移除 page 替换 device_id device_name os_name os_version
    NSArray * removeArr = @[@"page",
                            @"device_id",
                            @"device_name",
                            @"os_version",
                            @"server_id",
                            @"equip_id"];
    
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
//    NSString * appendStr = @"&sum_exp_max=2000";
//    //去掉设备号
//    
//    //增加随机参数，尽可能防止屏蔽
//    //        &sum_exp_min=111
//    //        &qian_neng_guo=33
//    //        &skill_qiang_shen=22
//    NSInteger randMinExp = arc4random() % 111 + 1;
//    NSInteger randQianneng = arc4random() % 50 + 1;
//    NSInteger skill_qiang_shen = arc4random() % 50 + 1;
//    appendStr = [appendStr stringByAppendingFormat:@"&sum_exp_min=%ld&qian_neng_guo=%ld&skill_qiang_shen=%ld",randMinExp,randQianneng,skill_qiang_shen];
//    appendStr = [appendStr stringByAppendingString:@"&device_name=iPhone&os_name=iPhone%20OS&os_version=7.1"];
//    appendStr = [appendStr stringByAppendingFormat:@"&act=super_query&search_type=overall_role_search&serverid=%@&app_version=2.2.9",server];
//    appendStr = [appendStr stringByAppendingString:@"&page=1"];
    NSString * appendStr = [NSString stringWithFormat:@"&equip_id=%@&server_id=%@",equipId,server] ;
    
    NSString * result = [replaceStr stringByAppendingString:appendStr];
//    result = @"http://xyq.cbg.163.com/cgi-bin/login.py?next_url=%2Fcgi-bin%2Fequipquery.py%3Fact%3Dbuy_show_equip_info%26equip_id%3D2697218%26server_id%3D625%26from%3Dgame&server_id=625&act=do_anon_auth";
//    result = @"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=2027052&server_id=199&from=game";

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
    NSString * pageUrl = MobileRefresh_ListRequest_Default_URLString;
    pageUrl = @"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=2027052&server_id=199&from=game";
//    pageUrl = @"http://xyq.cbg.163.com/cgi-bin/login.py?next_url=%2Fcgi-bin%2Fequipquery.py%3Fact%3Dbuy_show_equip_info%26equip_id%3D2697218%26server_id%3D625%26from%3Dgame&server_id=625&act=do_anon_auth";
    
    //启动数据请求
    NSMutableArray * urls = [NSMutableArray array];
    NSArray * serverArr = self.serverArr;
    NSInteger totalNum = [serverArr count];
    
    for (NSInteger index = 0; index < totalNum; index ++)
    {
        ZWServerEquipModel * server = [serverArr objectAtIndex:index];
        
        NSString *  serverId = [NSString stringWithFormat:@"%ld",server.serverId];
        NSString * equipId = [NSString stringWithFormat:@"%ld",server.equipId];
        
        //清理cookie，需要刷新的
        if(server.cookieClear)
        {
            [self.cookieDic removeObjectForKey:serverId];
        }
        
        NSString * requestUrl = [self replaceStringWithLatestWebString:pageUrl andServerId:serverId andEquipId:equipId];
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

-(NSString *)replaceWebHtmlWithLatestBackHtmlDic:(NSDictionary *)dic
{//取出追加文本
    NSString * html = [dic objectForKey:@"html"];
    NSRange range = [html rangeOfString:@"<textarea id=\"equip_desc_value\" style=\"display:none\">\n"];
    
    NSString * subStr = nil;
    if(range.location != NSNotFound)
    {
        NSInteger startIndex = range.location + range.length;
        NSRange endRange = [html rangeOfString:@"</textarea>" options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex,[html length] - startIndex)];
        
        subStr = [html substringWithRange:NSMakeRange(startIndex, endRange.location - startIndex)];
    }
    return subStr;
}
-(NSString * )subDetailTagNameFromDetailHTMl:(NSDictionary *)dic withTagName:(NSString *)tagName
{
    NSString * html = [dic objectForKey:@"html"];
//    NSRange range1 = [html rangeOfString:@"\""];

    NSRange range = [html rangeOfString:[NSString stringWithFormat:@"\"%@\" : ",tagName]];
    if(range.location != NSNotFound)
    {
        NSInteger startIndex = range.location + range.length;
        NSRange endRange = [html rangeOfString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex,[html length] - startIndex)];
        
        NSString * subStr = [html substringWithRange:NSMakeRange(startIndex, endRange.location - startIndex)];
        subStr = [subStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//        subStr = [subStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        return subStr;

    }
    return nil;
}
-(NSString * )subDetailEquipNameFromDetailHTMl:(NSDictionary *)dic
{
    NSString * tagName = @"equip_name";
    NSString * html = [dic objectForKey:@"html"];
    //    NSRange range1 = [html rangeOfString:@"\""];
    
    NSRange range = [html rangeOfString:[NSString stringWithFormat:@"\"%@\": \"",tagName]];
    if(range.location != NSNotFound)
    {
        NSInteger startIndex = range.location + range.length;
        NSRange endRange = [html rangeOfString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex,[html length] - startIndex)];
        
        NSString * subStr = [html substringWithRange:NSMakeRange(startIndex, endRange.location - startIndex)];
        subStr = [subStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        return subStr;
        
    }
    return nil;
}
-(ServerResultCheckType)subDetailErroredFromDetailHTMl:(NSDictionary *)dic
{
    ServerResultCheckType checkType = ServerResultCheckType_None;
    NSString * html = [dic objectForKey:@"html"];
    
    NSArray * typeArray = @[
                            @"请输入验证码后继续访问",
                            @"如果您看到这个页面，说明您的网速缓慢或者浏览器阻止您在https和http页面间跳转。",
                            @"没有找到该物品",
                            @"\"equip_name\":",
                            ];
    for (NSInteger index = 0;index < [typeArray count] ;index++ )
    {
        NSString * sub = [typeArray objectAtIndex:index];
        NSRange range = [html rangeOfString:sub];
        if(range.location != NSNotFound)
        {
            checkType = index +1;
        }
    }
//    NSLog(@"checkType %ld",checkType);
    return checkType;
}
-(void)refreshEquipModelWithDetailBackDic:(NSDictionary *)aDic andEquipModel:(EquipModel *)detail
{
    NSArray * tagArr =  @[
                          @"equipid",@"equip_type",@"status",@"kindid",@"equip_name",@"owner_nickname",
                          @"owner_roleid",@"price",@"equip_level",@"appointed_roleid",@"expire_time_desc",@"create_time",
                          @"selling_time",@"game_ordersn",@"server_id",@"can_bargin"];
    NSMutableArray * dataArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [tagArr count] ;index++ )
    {
        NSString * tag = [tagArr objectAtIndex:index];
        NSString * obj = [self subDetailTagNameFromDetailHTMl:aDic withTagName:tag];
        if(!obj){
            obj = @"";
        }
        [dataArr addObject:obj];
    }
    
    if([dataArr count] == 16)
    {
        detail.equipid = [NSNumber numberWithInt:[[dataArr objectAtIndex:0] intValue]];
        detail.equip_type = [dataArr objectAtIndex:1];
        detail.status = [NSNumber numberWithInt:[[dataArr objectAtIndex:2] intValue]];
        detail.kindid = [NSNumber numberWithInt:[[dataArr objectAtIndex:3] intValue]];
//        detail.equip_name = [dataArr objectAtIndex:4];
        NSString * nickName = [dataArr objectAtIndex:5];
//        if([nickName length] > 0)
//        {
//            const char * nickCName =  [nickName cStringUsingEncoding:NSASCIIStringEncoding];
//            NSString * realName = [NSString stringWithUTF8String:nickCName];
//            detail.owner_nickname = realName;
//        }
        detail.owner_nickname = nickName;
        detail.owner_roleid = [dataArr objectAtIndex:6];
        detail.last_price_desc = [dataArr objectAtIndex:7];
        detail.price = [NSNumber numberWithInt:[detail.last_price_desc intValue] * 100];
        detail.equip_level = [NSNumber numberWithInt:[[dataArr objectAtIndex:8] intValue]];
        detail.appointed_roleid = [dataArr objectAtIndex:9];
        detail.sell_expire_time_desc = [dataArr objectAtIndex:10];
        detail.create_time = [dataArr objectAtIndex:11];
        
        detail.selling_time = [dataArr objectAtIndex:12];
        detail.game_ordersn = [dataArr objectAtIndex:13];
        detail.serverid = [NSNumber numberWithInt:[[dataArr objectAtIndex:14] intValue]];
        detail.allow_bargain = [NSNumber numberWithInt:[[dataArr objectAtIndex:15] intValue]];
    }
}

-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    ServerResultCheckType type = [self subDetailErroredFromDetailHTMl:aDic];
    NSArray * resultArr = nil;
    EquipModel * detail = [[EquipModel alloc] init];
    detail.resultType = type;
    
    switch (type)
    {
        case ServerResultCheckType_Success:
        {
            //请求成功
            NSString * equipName = [self subDetailEquipNameFromDetailHTMl:aDic];
            if([equipName integerValue] != 0)
            {
                detail.equip_name = equipName;
                [self refreshEquipModelWithDetailBackDic:aDic andEquipModel:detail];
                NSString * extra = [self replaceWebHtmlWithLatestBackHtmlDic:aDic];
                detail.equip_desc = extra;
                
                EquipExtraModel * model = [self extraModelFromLatestEquipDESC:detail];
                detail.equipExtra = model;
                
                
            }else
            {
                NSString * extra = [self replaceWebHtmlWithLatestBackHtmlDic:aDic];
                detail.equip_desc = extra;
            }

        }
            break;
         
        case ServerResultCheckType_Error:{
            //需要验证码
        }
            break;
        case ServerResultCheckType_Redirect:{
            //需要重定向
        }
            break;
        case ServerResultCheckType_NoneProduct:{
            //需要重定向
        }
            break;

        default:
            break;
    }

    resultArr = @[detail];
    
    return resultArr;
}
-(EquipExtraModel *)extraModelFromLatestEquipDESC:(EquipModel *)detail
{
    NSString * desStr = detail.equip_desc;
    desStr = [self equipExtraStringFromLatestString:desStr];
    
    NSDictionary * desDic = [desStr objectFromJSONString];
    if(!desDic)
    {
        return nil;
    }
    //    [CreateModel createModelWithJsonData:desDic rootModelName:@"EquipModelDESDetail"];
    
    //    NSLog(@"%s %@",__FUNCTION__,desStr);
    EquipExtraModel * extra = [[EquipExtraModel alloc] initWithDictionary:desDic];
    
    return extra;
}

-(NSString *)equipExtraStringFromLatestString:(NSString *)desString
{
    NSString * string = nil;
    string = [desString stringByReplacingOccurrencesOfString:@"])" withString:@"}"];
    string = [string stringByReplacingOccurrencesOfString:@"([" withString:@"{"];
    
    string = [string stringByReplacingOccurrencesOfString:@"})" withString:@"]"];
    string = [string stringByReplacingOccurrencesOfString:@"({" withString:@"["];
    
    string = [string stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    string = [string stringByReplacingOccurrencesOfString:@",}" withString:@"}"];
    
    string = [self completeStringFromLatest:string];
    
    return string;
}

-(NSString *)completeStringFromLatest:(NSString *)latest
{
    NSString * sepStr = @":";
    NSArray * array = [latest componentsSeparatedByString:sepStr];
    NSMutableArray * replaceArr = [NSMutableArray array];
    
    for (NSInteger index = 0; index < [array count]; index++)
    {
        NSString * eve = [array objectAtIndex:index];
        NSString * replace = [self eveCompareReplaceStringFrom:eve];
        [replaceArr addObject:replace];
    }
    
    NSString * total = [replaceArr componentsJoinedByString:sepStr];
    return total;
}
-(NSString *)eveCompareReplaceStringFrom:(NSString *)shortString
{
    NSString * last = [shortString substringFromIndex:[shortString length] - 1];
    BOOL isNumber =  [DZUtils checkSubCharacterIsNumberString:last];
    
    if(!isNumber)
    {
        return shortString;
    }
    //    18521,]),6:  这种数据，处理为     18521,]),"6"
    NSString * replace = [NSString stringWithString:shortString];
    NSMutableString * checkStr = [NSMutableString string];//数字字符
    BOOL temp = NO;
    //由后向前，取到非数字字符截止
    for (NSInteger index = 0; index < [shortString length]; index ++ )
    {
        NSInteger number = [shortString length] - index - 1;
        NSString * eve = [replace substringWithRange:NSMakeRange(number, 1)];
        BOOL realNumber = [DZUtils checkSubCharacterIsNumberString:eve];
        if(realNumber)
        {
            [checkStr insertString:eve atIndex:0];
        }else if([eve isEqualToString:@" "])
        {
            temp = YES;
            //临时属性判定，不需要截取拼装
        }else{
            //此时应该全是,
            break;
        }
    }
    
    if(temp)
    {
        return shortString;
    }
    NSRange  range = NSMakeRange([shortString length] - [checkStr length] , [checkStr length]);
    replace = [replace stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"\"%@\"",checkStr]];
    return replace;
}




@end
