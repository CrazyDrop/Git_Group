//
//  EquipDetailArrayRequestModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/5.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "EquipDetailArrayRequestModel.h"
#import "RoleDetailDataModel.h"
#import "JSONKit.h"
@implementation EquipDetailArrayRequestModel

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.listSession.configuration.timeoutIntervalForRequest = 60;
    }
    return self;
}
+(instancetype)sharedInstance
{
    static EquipDetailArrayRequestModel *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}


-(NSArray *)webRequestDataList
{
    NSString * pageUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/xyq_search.py?act=super_query&search_type=overall_role_search&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
    //    &page=1
    
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < 15; index ++)
    {
        NSString * eve = [NSString stringWithFormat:@"%@&page=%ld",pageUrl,(long)index];
        [urls addObject:eve];
    }
    return urls;
}
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic
{
    RoleDetailDataModel * listData = [[RoleDetailDataModel alloc] initWithDictionary:aDic];
    EquipModel * model = listData.equip;
    
    EquipExtraModel * extra = nil;
    extra = [self extraModelFromLatestEquipDESC:model];
    model.equipExtra = extra;
    model.finishDate = [NSDate unixDate];
    extra.buyPrice = [extra createExtraPrice];
    model.extraEarnRate = [model createEquipExtraEarnRate];
    
    if(!model || ![model isKindOfClass:[EquipModel class]])
    {
//        NSLog(@"error %@ %@",NSStringFromClass([self class]),[aDic allKeys]);
        return nil;
    }
    return [NSArray arrayWithObject:model];
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
    
    //由后向前，取到非数字字符截止
    for (NSInteger index = 0; index < [shortString length]; index ++ )
    {
        NSInteger number = [shortString length] - index - 1;
        NSString * eve = [replace substringWithRange:NSMakeRange(number, 1)];
        BOOL realNumber = [DZUtils checkSubCharacterIsNumberString:eve];
        if(realNumber)
        {
            [checkStr insertString:eve atIndex:0];
        }else{
            break;
        }
    }
    NSRange  range = NSMakeRange([shortString length] - [checkStr length] , [checkStr length]);
    replace = [replace stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"\"%@\"",checkStr]];
    return replace;
}


@end
