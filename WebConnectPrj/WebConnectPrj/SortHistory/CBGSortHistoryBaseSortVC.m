//
//  CBGSortHistoryBaseSortVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseSortVC.h"

@interface CBGSortHistoryBaseSortVC ()
@property (nonatomic, strong) NSArray * spaceTagArr;
@property (nonatomic, strong) NSArray * rateTagArr;
//@property (nonatomic, strong) NSArray * rateTagArr;
@end

@implementation CBGSortHistoryBaseSortVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray *)spaceTagArr
{
    if(!_spaceTagArr)
    {
        //0 1分钟  3分钟  10分钟 30分钟  1天  更多
        NSArray * arr = @[@0,@60,@180,@600,@1800,@86400,@259200];
        _spaceTagArr = arr;
    }
    return _spaceTagArr;
}
-(NSNumber *)spaceSeperateTagSpaceFromSellSpace:(NSNumber *)num
{
    NSArray * keyArr = self.spaceTagArr;
    
    NSNumber * selectedNum = [keyArr lastObject];
    for (NSInteger index = 0; index < [keyArr count]; index ++) {
        NSNumber * lineNum = [keyArr objectAtIndex:index];
        if([num integerValue] < [lineNum integerValue])
        {
            break;
        }
        selectedNum = lineNum;
    }
    return  selectedNum;
}
-(NSString *)spaceSeperateTagNameFromSellSpace:(NSNumber *)num
{
    NSArray * keyArr = self.spaceTagArr;
    NSInteger index = [keyArr indexOfObject:num];
    
    NSString * name = @"未知";
    if(index == [keyArr count] - 1){
        name = @"更多";
    }else{
        NSNumber * nexNum = [keyArr objectAtIndex:index + 1];

        NSInteger minute = [nexNum integerValue]/60;
        NSInteger days = [nexNum integerValue]/3600/24;
        if(days == 0)
        {
            name = [NSString stringWithFormat:@"%ld分",minute];
            if(minute > 60)
            {
                name = [NSString stringWithFormat:@"%ld时",minute/60];
            }
        }else
        {
            name = [NSString stringWithFormat:@"%ld天",days];
        }
    }
    return name;
}
-(NSArray *)rateTagArr
{
    if(!_rateTagArr)
    {
        //0 0-5 5-8 8-12  12-15  15-20 20-30  30+
        NSArray * arr = @[@0,@5,@8,@12,@15,@20,@30,@40];
        _rateTagArr = arr;
    }
    return _rateTagArr;
}
-(NSNumber *)rateSeperateTagRateFromSellPlanRate:(NSNumber *)num
{
    NSArray * keyArr = self.rateTagArr;
    
    NSNumber * selectedNum = [keyArr lastObject];
    for (NSInteger index = 0; index < [keyArr count]; index ++) {
        NSNumber * lineNum = [keyArr objectAtIndex:index];
        if([num integerValue] < [lineNum integerValue])
        {
            break;
        }
        selectedNum = lineNum;
    }
    return  selectedNum;
}
-(NSString *)rateSeperateTagNameFromSellPlanRate:(NSNumber *)num
{
    NSArray * keyArr = self.rateTagArr;
    NSInteger index = [keyArr indexOfObject:num];
    
    NSString * name = @"未知";
    if(index == [keyArr count] - 1){
        name = @"MAX";
    }else{
        NSNumber * nexNum = [keyArr objectAtIndex:index + 1];
        name = [NSString stringWithFormat:@"%ld-%ld",[num integerValue],[nexNum integerValue]];
    }
    return name;
}

-(void)refreshLatestShowTableView
{
    NSArray * baseArr = self.dbHistoryArr;
    //1、数据筛选
    NSArray * selectedArr = [self selectedShowArrayFrom:baseArr
                                        withFinishStyle:self.finishStyle];
    
    //2、数据排序，排序为分组内排序
    NSArray * orderArr = [self orderShowArrayFrom:selectedArr withOrderStyle:self.orderStyle];
    
    NSArray * tagArr = nil;
    //3、数据分组
    NSArray * sortArr = [self sortShowArrayFrom:orderArr
                                  withSortStyle:self.sortStyle
                                      andTagArr:&tagArr];
    
    
    //数据展示
    
    [self refreshNumberLblWithLatestNum:[orderArr count]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showTagArr = tagArr;
        self.showSortArr = sortArr;
        [self.listTable reloadData];
    });
    
}

-(NSArray *)sortShowArrayFrom:(NSArray *)resultArr withSortStyle:(CBGStaticSortShowStyle)sort andTagArr:(NSArray **)showTags
{
    if(sort == CBGStaticSortShowStyle_None)
    {
        if(resultArr && [resultArr count] > 0 )
        {
            return  @[resultArr];
        }else
        {
            return  @[];
        }
    }
    
    NSArray * keys = nil;
    NSMutableArray * total = [NSMutableArray array];
    NSMutableDictionary * totalDic = [NSMutableDictionary dictionary];
    NSMutableDictionary * countDic = [NSMutableDictionary dictionary];

    for (NSInteger index = 0;index < [resultArr count] ;index ++ )
    {
        CBGListModel * eve = [resultArr objectAtIndex:index];
        NSNumber * keyStr = nil;

        switch (sort)
        {
            case CBGStaticSortShowStyle_School:
            {
                keyStr = [NSNumber numberWithInteger:eve.equip_school];
            }
                break;
            case CBGStaticSortShowStyle_Rate:
            {
                keyStr = [self rateSeperateTagRateFromSellPlanRate:[NSNumber numberWithInteger:eve.plan_rate]];
            }
                break;
            case CBGStaticSortShowStyle_Space:
            {
                keyStr = [self spaceSeperateTagSpaceFromSellSpace:[NSNumber numberWithInteger:eve.sell_space]];
            }
                break;
            case CBGStaticSortShowStyle_Server:
            {
                keyStr = [NSNumber numberWithInteger:eve.server_id];
            }
                break;
                
            default:
                break;
        }
        
        NSMutableArray * subArr = nil;
        if(![totalDic objectForKey:keyStr]){
            subArr = [NSMutableArray array];
            [totalDic setObject:subArr forKey:keyStr];
        }else{
            subArr = [totalDic objectForKey:keyStr];
        }
        
        [subArr addObject:eve];
        [countDic setObject:[NSNumber numberWithInteger:[subArr count]] forKey:keyStr];
    }
    
    keys = [totalDic allKeys];
    //以服务器数据排序的，keys过多，进行筛选
    BOOL combineServer = (sort == CBGStaticSortShowStyle_Server && [keys count] > 18);
    if(combineServer)
    {
        //颠倒数量和服务器的字典
        NSMutableDictionary * numKeyDic = [NSMutableDictionary dictionary];
        for (NSString * key in countDic )
        {
            NSNumber * eveVal = [countDic objectForKey:key];
            NSString * preKey = [numKeyDic objectForKey:eveVal];
            
            if(!preKey)
            {
                [numKeyDic setObject:key forKey:eveVal];
            }else
            {
                preKey = [preKey stringByAppendingFormat:@"|%@",key];
                [numKeyDic setObject:preKey forKey:eveVal];
            }
        }
        
        NSArray * allNums = [numKeyDic allKeys];
        
        //以数量顺序进行排序
        allNums = [allNums sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber * num1 = [NSNumber numberWithInteger:[obj1 integerValue]];
            NSNumber * num2 = [NSNumber numberWithInteger:[obj2 integerValue]];
            return [num2 compare:num1];
        }];

        //倒序排列
        NSMutableArray * serverArr = [NSMutableArray array];
        for (NSInteger index = 0;index < 10 ; index ++)
        {
            NSNumber * num = nil;
            if([allNums count] > index)
            {
                num = [allNums objectAtIndex:index];
            }
            
            if(num)
            {
                NSString * serverStr = [numKeyDic objectForKey:num];
                NSArray * subArr = [serverStr componentsSeparatedByString:@"|"];
                if([subArr count] > 0){
                    [serverArr addObjectsFromArray:subArr];
                }
            }
        }
        
        keys = serverArr;

    }else if(sort == CBGStaticSortShowStyle_Rate)
    {
        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber * num1 = [NSNumber numberWithInteger:[obj1 integerValue]];
            NSNumber * num2 = [NSNumber numberWithInteger:[obj2 integerValue]];
            return [num2 compare:num1];
        }];
    }else
    {
        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber * num1 = [NSNumber numberWithInteger:[obj1 integerValue]];
            NSNumber * num2 = [NSNumber numberWithInteger:[obj2 integerValue]];
            return [num1 compare:num2];
        }];
    }

    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serDic = local.serverNameDic;

    //生成展示tag数组
    NSMutableArray * schoolNames = [NSMutableArray array];
    for (NSInteger index = 0;index < [keys count] ;index ++ )
    {
        NSNumber * num = [keys objectAtIndex:index];
        
        NSArray * subArr = [totalDic objectForKey:num];
        [total addObject:subArr];
        
        NSString *eveName = nil;
        switch (sort) {
            case CBGStaticSortShowStyle_Rate:
            {
                eveName = [self rateSeperateTagNameFromSellPlanRate:num];
            }
                break;

            case CBGStaticSortShowStyle_Server:
            {
                NSString *eveName = [serDic objectForKey:num];
                if(!eveName)
                {
                    eveName = @"未知";
                }
                NSRange range = [eveName rangeOfString:@"-"];
                if(range.length > 0)
                {
                    NSInteger startIndex = range.length + range.location;
                    NSInteger length = 4;
                    if(startIndex + length > [eveName length])
                    {
                        length = [eveName length] - startIndex;
                    }
                    eveName = [eveName substringWithRange:NSMakeRange(startIndex,length)];
                }
            }
                break;

            case CBGStaticSortShowStyle_Space:
            {
                eveName = [self spaceSeperateTagNameFromSellSpace:num];
            }
                break;
                
            case CBGStaticSortShowStyle_School:
            {
                eveName = [CBGListModel schoolNameFromSchoolNumber:[num integerValue]];
                eveName = [eveName substringWithRange:NSMakeRange(0,2)];
                eveName = [eveName stringByAppendingFormat:@"(%ld)",[subArr count]];
                
            }
                break;


            default:
                break;
        }
        
        [schoolNames addObject:eveName];
    }
    
    if(combineServer)
    {
        //增加其他分类
        NSMutableArray * others = [NSMutableArray array];
        for (NSString * key in totalDic)
        {
            if(![keys containsObject:key])
            {
                NSArray * eveArr = [totalDic objectForKey:key];
                [others addObjectsFromArray:eveArr];
            }
        }
        
        if([others count] > 0)
        {
            [schoolNames addObject:@"其他"];
            [total addObject:others];
        }
    }
    
    keys = schoolNames;
    *showTags = keys;
    
    return total;
}

-(NSArray *)orderShowArrayFrom:(NSArray *)arr withOrderStyle:(CBGStaticOrderShowStyle)order
{
    if(order == CBGStaticOrderShowStyle_None)
    {
        return arr;
    }
    NSArray * result = nil;
    
    switch (order) {
        case CBGStaticOrderShowStyle_None:
        {
        }
            break;
        case CBGStaticOrderShowStyle_Rate:
        {
            result = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve2.plan_rate] compare:[NSNumber numberWithInteger:eve1.plan_rate]];
            }];
        }
            break;

        case CBGStaticOrderShowStyle_Price:
        {
            result = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve1.equip_price] compare:[NSNumber numberWithInteger:eve2.equip_price]];
            }];

        }
            break;

        case CBGStaticOrderShowStyle_Space:
        {
            result = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve1.sell_space] compare:[NSNumber numberWithInteger:eve2.sell_space]];
            }];

        }
            break;

        case CBGStaticOrderShowStyle_School:
        {
            result = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve1.equip_school] compare:[NSNumber numberWithInteger:eve2.equip_school]];
            }];

        }
            break;
        case CBGStaticOrderShowStyle_Create:
        {
            result = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [eve2.sell_create_time compare:eve1.sell_create_time];
            }];
            
        }
            break;


        default:
            break;
    }
    
    return result;
}

-(NSArray *)selectedShowArrayFrom:(NSArray *)arr withFinishStyle:(CBGSortShowFinishStyle)finish
{
    if(finish == CBGSortShowFinishStyle_Total || finish == CBGSortShowFinishStyle_None)
    {
        return arr;
    }
    
    NSMutableArray * result = [NSMutableArray array];
    
    for (NSInteger index = 0; index < [arr count] ;index ++ )
    {
        CBGListModel * eveList = [arr objectAtIndex:index];
        BOOL checkEffective = NO;
        switch (finish)
        {
            case CBGSortShowFinishStyle_UnFinish:
            {
                if([eveList.sell_sold_time length] == 0 && [eveList.sell_back_time length] == 0)
                {
                    checkEffective = YES;
                }
            }
                break;
            case CBGSortShowFinishStyle_Sold:
            {
                if([eveList.sell_sold_time length] > 0){
                    checkEffective = YES;
                }

            }
                break;
            case CBGSortShowFinishStyle_Back:
            {
                if([eveList.sell_back_time length] > 0){
                    checkEffective = YES;
                }
            }
                break;
            case CBGSortShowFinishStyle_Finished:
            {
                if([eveList.sell_back_time length] > 0 || [eveList.sell_sold_time length] > 0){
                    checkEffective = YES;
                }
            }
                break;
                
            default:
                break;
        }
        
        
        if(checkEffective)
        {
            [result addObject:eveList];
        }
        
    }
    
    return result;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
