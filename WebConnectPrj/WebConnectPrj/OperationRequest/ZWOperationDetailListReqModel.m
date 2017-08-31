//
//  ZWOperationDetailListReqModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWOperationDetailListReqModel.h"
#import "RoleDetailDataModel.h"
#import "JSONKit.h"

@implementation ZWOperationDetailListReqModel

-(NSArray *)webRequestDataList
{
    NSString * pageUrl = @"http://xyq-ios2.cbg.163.com/app2-cgi-bin/xyq_search.py?act=super_query&search_type=overall_role_search&platform=ios&app_version=2.2.9&device_name=iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8";
    //    &page=1
    
    NSMutableArray * urls = [NSMutableArray array];
    NSInteger maxNum = 0;
    for (NSInteger index = 0; index < maxNum; index ++)
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
    
    if(!self.ingoreExtra && model)
    {
        EquipExtraModel * extra = nil;
        extra = [self extraModelFromLatestEquipDESC:model];
        model.equipExtra = extra;
        model.finishDate = [NSDate unixDate];
    }
    
    if([listData.msg isEqualToString:@"该商品不存在"]){
        model = [[EquipModel alloc] init];
    }
    
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
    
    //    ,26:(["iType":2752,"cDesc":"#r等级 100  五行 火#r#r敏捷 +36 防御 +63#r耐久度 350#r锻炼等级 7  镶嵌宝石 黑宝石#r#G#G速度 +56#Y#r#G临时法伤结果 31 03/29 13:06#Y#r#c4DBAF4特效：#c4DBAF4永不磨损#Y#r#G开运孔数：4孔/4孔#b#G#r符石: 法伤 +1#n#G#r符石: 命中 +4#n#b#G#r符石: 魔力 +1#n#r#cEE82EE符石组合: 索命无常#r门派条件：阴曹地府 #r部位条件：无#r使用阎罗令时增加人物等级/1.5的伤害，装备该组合时降低5%的防御，同时降低5%的气血，仅对NPC使用时有效#Y#r#W制造者：娃灬│哈哈强化打造#Y#r#Y熔炼效果：#r#Y#r+1防御#Y  ",])
    
    //    "26":{"iType":2752,"cDesc":"#r等级 100  五行 火#r#r敏捷 +36 防御 +63#r耐久度 350#r锻炼等级 7  镶嵌宝石 黑宝石#r#G#G速度 +56#Y#r#G临时法伤结果 31 03/29 13:06#Y#r#c4DBAF4特效：#c4DBAF4永不磨损#Y#r#G开运孔数：4孔/4孔#b#G#r符石: 法伤 +1#n#G#r符石: 命中 +4#n#b#G#r符石: 魔力 +1#n#r#cEE82EE符石组合: 索命无常#r门派条件：阴曹地府 #r部位条件：无#r使用阎罗令时增加人物等级/1.5的伤害，装备该组合时降低5%的防御，同时降低5%的气血，仅对NPC使用时有效#Y#r#W制造者：娃灬│哈哈强化打造#Y#r#Y熔炼效果：#r#Y#r+1防御#Y  "}
    
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
    
    BOOL ingoreReplace = NO;
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
            ingoreReplace = YES;
            //为空
            break;
        }else
        {
            break;
        }
    }
    if(ingoreReplace)
    {
        return replace;
    }
    
    NSRange  range = NSMakeRange([shortString length] - [checkStr length] , [checkStr length]);
    replace = [replace stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"\"%@\"",checkStr]];
    return replace;
}

@end
