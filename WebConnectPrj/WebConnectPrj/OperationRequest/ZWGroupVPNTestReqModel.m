//
//  ZWGroupVPNTestReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWGroupVPNTestReqModel.h"
#import "RoleDataModel.h"
#import "CBGListModel.h"
@interface ZWGroupVPNTestReqModel()
@property (nonatomic,assign) NSInteger schoolIndex;
@property (nonatomic,strong) NSString * reqName;
@end
@implementation ZWGroupVPNTestReqModel
-(id)init
{
    self =[super init];
    if(self)
    {
        self.timeOutNum = 5;
        self.schoolIndex = arc4random()%12 + 1;
        self.reqName = [CBGListModel schoolNameFromSchoolNumber:self.schoolIndex];
        self.ingoreRandom = YES;
    }
    return self;
}
-(void)setPageNum:(NSInteger)pageNum
{
    if(_pageNum != pageNum)
    {
        self.timerState = !self.timerState;
    }
    _pageNum = pageNum;
}

+(NSString *)replaceStringWithLatestWebString:(NSString *)webStr
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
+(NSString *)replaceDeviceIdWithPageIndex:(NSInteger)index
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

+(NSString *)randomTestFirstWebRequestWithIndex:(NSInteger)randNum
{
    NSString * baseUrl = MobileRefresh_ListRequest_Default_URLString;
    NSString * pageUrl = [[self class] replaceStringWithLatestWebString:baseUrl];
    
    //增加设备号
    //        &device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8
    NSInteger index = arc4random()%10000 + randNum;
    NSString * replaceDeviceId = [[self class] replaceDeviceIdWithPageIndex:index];
    NSString * eve = [NSString stringWithFormat:@"%@&device_id=%@&page=%ld",pageUrl,replaceDeviceId,(long)1];
    return eve;
}


-(NSArray *)webRequestDataList
{
    NSMutableArray * arr = [NSMutableArray array];
    for (NSInteger index = 0;index < self.pageNum ; index ++)
    {
        NSString * url = [ZWGroupVPNTestReqModel randomTestFirstWebRequestWithIndex:index];
        url = [url stringByAppendingFormat:@"&school=%ld",self.schoolIndex];
        [arr addObject:url];
    }
    return arr;
//    NSString * baseUrl = MobileRefresh_ListRequest_Default_URLString;
//    NSString * pageUrl = [[self class] replaceStringWithLatestWebString:baseUrl];
//    
//    //增加设备号
//    //        &device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8
//    NSInteger index = arc4random()%10000;
//    NSString * replaceDeviceId = [[self class] replaceDeviceIdWithPageIndex:index];
//    NSString * eve = [NSString stringWithFormat:@"%@&device_id=%@&page=%ld",pageUrl,replaceDeviceId,(long)1];
//    return @[eve];
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
    
    Equip_listModel * listModel = nil;
    if([array count] > 0){
        listModel = [array lastObject];
    }
    
    if(![listModel.equip_name isEqualToString:self.reqName])
    {
        return nil;
    }
    
    return array;
}

@end
