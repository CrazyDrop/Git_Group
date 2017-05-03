//
//  CBGDepthStudyVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/13.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGDepthStudyVC.h"
#import "AAChartView.h"
#import "CBGListModel.h"
@interface CBGDepthStudyVC ()
@property (nonatomic, strong) AAChartModel * planModel;//估价概况表
@property (nonatomic, strong) AAChartModel * priceModel;//展示价格分布
@property (nonatomic, strong) AAChartModel * schoolModel;//展示门派区分
@property (nonatomic, strong) AAChartModel * soldModel;//展示售出数据

//走势图model，以时间为区分
@property (nonatomic, strong) AAChartModel * soldTimeModel;//售出明细时间走势
@property (nonatomic, strong) AAChartModel * soldWeekModel;//售出星期划分
@property (nonatomic, strong) AAChartModel * priceTimeModel;//售出价格划分

@property (nonatomic, strong) AAChartView * planChartView;
@property (nonatomic, strong) AAChartView * priceChartView;
@property (nonatomic, strong) AAChartView * schoolChartView;
@property (nonatomic, strong) AAChartView * soldChartView;

@property (nonatomic, strong) AAChartView * soldTimeChartView;
@property (nonatomic, strong) AAChartView * soldWeekChartView;
@property (nonatomic, strong) AAChartView * priceTimeChartView;

@property (nonatomic, strong) NSArray * priceSortArr;
@property (nonatomic, strong) NSArray * countRateArray;
@property (nonatomic, strong) UIScrollView * chartScroll;

@property (nonatomic, strong) NSString * preDate;
@end

@implementation CBGDepthStudyVC
-(void)setSelectedDate:(NSString *)selectedDate
{
    self.preDate = [_selectedDate copy];
    _selectedDate = selectedDate;
}


-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice
{
    if(self.preDate && [self.preDate isEqualToString:self.selectedDate]){
        return;
    }
    self.planModel = nil;
    self.priceModel = nil;
    self.schoolModel = nil;
    self.soldModel = nil;
    self.soldTimeModel = nil;
    self.soldWeekModel = nil;
    self.priceTimeModel = nil;
    [self refreshChartModelWithLatestListAndStyle];
}

- (void)viewDidLoad {
    self.viewTtle = @"数据分析";
    self.rightTitle = @"切换";
    self.showRightBtn = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listTable.hidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = startY;
    rect.size.height -= startY;
    
    CGSize chartSize = CGSizeMake(SCREEN_WIDTH - 30, FLoatChange(400));
    UIScrollView * bgView = [[UIScrollView alloc] initWithFrame:rect];
    [self.view addSubview:bgView];
    bgView.scrollEnabled = YES;
    bgView.contentSize = CGSizeMake(SCREEN_WIDTH, chartSize.height * 7);
    self.chartScroll = bgView;
    
    AAChartView * aChart = nil;
    rect.origin = CGPointZero;
    rect.size = chartSize;
    
//    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
    //    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.planChartView = aChart;

    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
//    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.priceChartView = aChart;
    
    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
//    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.schoolChartView = aChart;

    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
//    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.soldChartView = aChart;

    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
    //    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.soldTimeChartView = aChart;

    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
    //    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.soldWeekChartView = aChart;
    
    rect.origin.y = CGRectGetMaxY(aChart.frame);
    aChart = [[AAChartView alloc] initWithFrame:rect];
    [bgView addSubview:aChart];
    //    aChart.center = CGPointMake(SCREEN_WIDTH/2.0, chartSize.height/2.0);
    aChart.contentWidth = chartSize.width;
    aChart.contentHeight = chartSize.height;
    aChart.scrollView.scrollEnabled = NO;
    aChart.scrollView.scrollsToTop = NO;
    self.priceTimeChartView = aChart;
    
//    [self refreshChartModelWithLatestListAndStyle];
}
-(NSArray *)priceSortArr
{
    if(!_priceSortArr)
    {
        NSMutableArray * keyArray = [NSMutableArray array];
        //    2000为一个区间   共12个区间  2000以内   2W以外
        NSInteger spaceNum = 2000;
        for (NSInteger index = 0; index <= 14; index ++)
        {
            NSNumber * num = [NSNumber numberWithInteger:index * spaceNum];
            [keyArray addObject:num];
        }
        _priceSortArr = keyArray;
    }
    return _priceSortArr;
}
-(NSNumber *)selectedKeyNumFroLatestPriceString:(NSInteger)equipPrice
{
    NSInteger realPrice = equipPrice/100;
    NSArray * keyArr = self.priceSortArr;
    
    NSNumber * selectedNum = [keyArr firstObject];
    for (NSInteger index = 1; index < [keyArr count]; index ++) {
        NSNumber * lineNum = [keyArr objectAtIndex:index];
        if([lineNum integerValue] > realPrice)
        {
            break;
        }
        selectedNum = lineNum;
    }

    return  selectedNum;
}
-(NSInteger)totalCountNumberForSubDic:(NSDictionary *)dic
{
    NSInteger sumNum = 0;
    for (NSString * key in dic)
    {
        NSNumber * eveNum = [dic objectForKey:key];
        sumNum += [eveNum integerValue];
    }
    return sumNum;
}
-(NSArray *)countRateArray
{
    if(!_countRateArray)
    {
        NSArray * keyArray = @[@0.6,@0.7,@0.8,@0.9,@1.0,@1.1,@1.15,@1.2,@1.3];
        
        _countRateArray = keyArray;
    }
    return _countRateArray;
}
-(NSNumber *)planTotalCountEquipPriceForEquipModel:(CBGListModel *)model;
{//4、0  0.8范围内数据总数 0.9范围内数据总数  1.1范围内数据总数  1.2范围内数据总数 2
    NSNumber* selectRate = nil;
    
    //分段  数据分段标识
    CGFloat planPrice = model.plan_total_price + 0.0;
    CGFloat finishPrice = planPrice * 0.95;
    CGFloat equipPrice = model.equip_price/100.0;
    
    CGFloat realRate = 0;
    if(finishPrice > equipPrice)
    {
        realRate = (finishPrice - equipPrice)/planPrice + 1.0;
    }else if(planPrice > equipPrice){
        realRate = 0.95;//放到1.1挡内，展示为100%
    }else{
        realRate = planPrice/equipPrice;
    }
    NSArray * rateArr = self.countRateArray;
    
    for (NSInteger index = 0;index < [rateArr count] ; index ++ )
    {
        NSNumber * num = [rateArr objectAtIndex:index];
        if(realRate < [num floatValue])
        {
            selectRate = num;
            break;
        }
    }
    //数据存放在最接近的，稍大一点的分段数值内
    if(!selectRate)
    {
        selectRate = [rateArr lastObject];
    }
//    NSLog(@"selectRate %@ %.2f",selectRate,realRate);
    return selectRate;
}
-(AAChartModel *)planModel
{
    if(!_planModel)
    {
        //1、数据筛选   选取无装备的数据
        //需要数据
        //1、所有无装备数据总数
        //2、无装备中售出总数
        //3、无装备中在售总数
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSInteger minServerId = total.minServerId;
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableArray * totalArr = [NSMutableArray array];
        for (CBGListModel * eveModel in dbArr) {
            if(eveModel.plan_rate < 30 && eveModel.plan_zhuangbei_price == 0 && eveModel.plan_total_price > 4000 && eveModel.server_id != 45 && eveModel.server_id < minServerId)
            {
                [totalArr addObject:eveModel];
            }
        }
        
        if(totalArr > 0){
//            totalArr = [totalArr subarrayWithRange:NSMakeRange(0, 3)];
        }
        
        NSMutableDictionary * countDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * sellingDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * soldDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * backDic = [NSMutableDictionary dictionary];
       
        for (NSInteger index = 0; index < [totalArr count]; index ++)
        {
            CBGListModel * list = [totalArr objectAtIndex:index];
            NSNumber * numKey = [self planTotalCountEquipPriceForEquipModel:list];
            
            NSNumber * preNum = nil;
            
//            if([list.sell_sold_time length] > 0)
            {
                preNum = [countDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [countDic setObject:preNum forKey:numKey];
            }
            
            if([list.sell_back_time length] == 0 && [list.sell_sold_time length] == 0)
            {
                preNum =[sellingDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [sellingDic setObject:preNum forKey:numKey];
                
            }
            
            if([list.sell_sold_time length] > 0)
            {
                preNum = [soldDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [soldDic setObject:preNum forKey:numKey];
            }
            
            if([list.sell_back_time length] > 0)
            {
                preNum = [backDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [backDic setObject:preNum forKey:numKey];
            }
            
        }
        
        NSArray * keyArr = self.countRateArray;
        //数据统计
        NSMutableArray * countArr = [NSMutableArray array];
        NSMutableArray * sellingArr = [NSMutableArray array];
        NSMutableArray * soldArr = [NSMutableArray array];
        NSMutableArray * backArr = [NSMutableArray array];
        NSMutableArray * keyNameArr = [NSMutableArray array];
        
        NSInteger planEffective = 0;
        CGFloat startNum = 0;
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSNumber * keyNum = [keyArr objectAtIndex:index];
            NSString * keyName = [NSString stringWithFormat:@"%.0f%%",startNum*100];
            
            NSNumber * countNum = [countDic objectForKey:keyNum]?:@0;
            [countArr addObject:countNum];
            NSNumber * sellingNum = [sellingDic objectForKey:keyNum]?:@0;
            [sellingArr addObject:sellingNum];
            NSNumber * soldNum = [soldDic objectForKey:keyNum]?:@0;
            [soldArr addObject:soldNum];
            NSNumber * backNum = [backDic objectForKey:keyNum]?:@0;
            [backArr addObject:backNum];
        
            
            if(index == 0){
                keyName = @"更低";
            }else if(index == [keyArr count] - 1){
                keyName = @"更高";
            }else
            {
                //大范围估值区间
                if(startNum >= 0.7 && startNum <= 1.2)
                {
                    planEffective += [countNum integerValue];
                }
            }
            
            [keyNameArr addObject:keyName];
            startNum = keyNum.floatValue;//为下一阶段提供初始值
        }
        
        //底部比率，数量是，每个比率对应的数量
        
        NSInteger totalCountNum = [self totalCountNumberForSubDic:countDic];
        NSString * subTitle = [NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,[totalArr count]];
        subTitle = [subTitle stringByAppendingFormat:@" 统计 (%ld %ld %.0f%%)",totalCountNum,planEffective,planEffective/(totalCountNum + 0.0)* 100];
        subTitle = [subTitle stringByAppendingFormat:@" 售出 (%ld)",[self totalCountNumberForSubDic:soldDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 在售 (%ld)",[self totalCountNumberForSubDic:sellingDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 取回 (%ld)",[self totalCountNumberForSubDic:backDic]];

        
        NSString * chartType = AAChartTypeColumn;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(@"估价准确分布(4K+无装备)")
        .subtitleSet(subTitle)
        .yAxisTitleSet(@"数量")
        .categoriesSet(keyNameArr)
        .seriesSet(@[
                     AAObject(AASeriesElement)
                     .nameSet(@"统计")
                     .dataSet(countArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"售出")
                     .dataSet(soldArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"在售")
                     .dataSet(sellingArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"取回")
                     .dataSet(backArr),
                     
                     ]
                   )
        ;
        _planModel = model;
    }
    return _planModel;
}

-(AAChartModel *)priceModel
{
    if(!_priceModel)
    {
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableDictionary * sellingDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * soldDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * backDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * planDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * spaceDic = [NSMutableDictionary dictionary];

        for (NSInteger index = 0; index < [dbArr count]; index ++)
        {
            CBGListModel * list = [dbArr objectAtIndex:index];
            NSNumber * numKey = [self selectedKeyNumFroLatestPriceString:list.equip_price];
            
            NSNumber * preNum = nil;
            if(list.sell_space > 0 && list.sell_space < 10 * MINUTE)
            {
                preNum =[spaceDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [spaceDic setObject:preNum forKey:numKey];
                
            }
            if([list.sell_back_time length] == 0 && [list.sell_sold_time length] == 0)
            {
                preNum =[sellingDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [sellingDic setObject:preNum forKey:numKey];

            }
            if([list.sell_sold_time length] > 0)
            {
                preNum = [soldDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [soldDic setObject:preNum forKey:numKey];
            }
            
            if([list.sell_back_time length] > 0)
            {
                preNum = [backDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [backDic setObject:preNum forKey:numKey];
            }

            if(list.style == CBGEquipPlanStyle_Worth || list.style == CBGEquipPlanStyle_PlanBuy)
            {
                preNum = [planDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [planDic setObject:preNum forKey:numKey];

            }
        }
        
        NSArray * keyArr = self.priceSortArr;
        //数据统计
        NSMutableArray * sellingArr = [NSMutableArray array];
        NSMutableArray * soldArr = [NSMutableArray array];
        NSMutableArray * backArr = [NSMutableArray array];
        NSMutableArray * planArr = [NSMutableArray array];
        NSMutableArray * spaceArr = [NSMutableArray array];
        NSMutableArray * keyNameArr = [NSMutableArray array];
        
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSNumber * keyNum = [keyArr objectAtIndex:index];
            NSNumber * nexKeyNum = keyNum;
            if([keyArr count] > index + 1){
                nexKeyNum = [keyArr objectAtIndex:index + 1];
            }
            NSString * keyName = [NSString stringWithFormat:@"%ldK-%ldK",keyNum.integerValue/1000,nexKeyNum.integerValue/1000];
            
            NSNumber * spaceNum = [spaceDic objectForKey:keyNum]?:@0;
            [spaceArr addObject:spaceNum];
            NSNumber * sellingNum = [sellingDic objectForKey:keyNum]?:@0;
            [sellingArr addObject:sellingNum];
            NSNumber * soldNum = [soldDic objectForKey:keyNum]?:@0;
            [soldArr addObject:soldNum];
            NSNumber * backNum = [backDic objectForKey:keyNum]?:@0;
            [backArr addObject:backNum];
            NSNumber * planNum = [planDic objectForKey:keyNum]?:@0;
            [planArr addObject:planNum];
            
            if(index == 0){
                keyName = @"起始";
            }else if(index == [keyArr count] - 1){
                keyName = @"更高";
            }
            [keyNameArr addObject:keyName];
        }
        
        
        NSString * subTitle = [NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,[self.dbHistoryArr count]];
        subTitle = [subTitle stringByAppendingFormat:@" 售出 (%ld)",[self totalCountNumberForSubDic:soldDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 在售 (%ld)",[self totalCountNumberForSubDic:sellingDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 取回 (%ld)",[self totalCountNumberForSubDic:backDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 估价 (%ld)",[self totalCountNumberForSubDic:planDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 抢购 (%ld)",[self totalCountNumberForSubDic:spaceDic]];
        
        NSString * chartType = AAChartTypeBar;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(@"全部数据价格区间分布")
        .subtitleSet(subTitle)
        .yAxisTitleSet(@"数量")
        .categoriesSet(keyNameArr)
        .seriesSet(@[
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"售出")
                     .dataSet(soldArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"在售")
                     .dataSet(sellingArr),

                     AAObject(AASeriesElement)
                     .nameSet(@"取回")
                     .dataSet(backArr),

                     AAObject(AASeriesElement)
                     .nameSet(@"估价")
                     .dataSet(planArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"抢购")
                     .dataSet(spaceArr),

                     ]
                   )
        ;
        _priceModel = model;
    }
    return _priceModel;
}
-(AAChartModel *)schoolModel
{
    if(!_schoolModel)
    {
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableDictionary * sellingDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * soldDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * backDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * planDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * spaceDic = [NSMutableDictionary dictionary];
        
        for (NSInteger index = 0; index < [dbArr count]; index ++)
        {
            CBGListModel * list = [dbArr objectAtIndex:index];
            NSNumber * numKey = [NSNumber numberWithInteger:list.equip_school];
            
            NSNumber * preNum = nil;
            if(list.sell_space > 0 && list.sell_space < 10 * MINUTE)
            {
                preNum =[spaceDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [spaceDic setObject:preNum forKey:numKey];
                
            }
            if([list.sell_back_time length] == 0 && [list.sell_sold_time length] == 0)
            {
                preNum =[sellingDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [sellingDic setObject:preNum forKey:numKey];
                
            }
            if([list.sell_sold_time length] > 0)
            {
                preNum = [soldDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [soldDic setObject:preNum forKey:numKey];
            }
            
            if([list.sell_back_time length] > 0)
            {
                preNum = [backDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [backDic setObject:preNum forKey:numKey];
            }
            
            if(list.style == CBGEquipPlanStyle_Worth || list.style == CBGEquipPlanStyle_PlanBuy)
            {
                preNum = [planDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [planDic setObject:preNum forKey:numKey];
                
            }
        }
        
        NSArray * keyArr = [sellingDic allKeys];
        keyArr = [keyArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        //数据统计
        NSMutableArray * sellingArr = [NSMutableArray array];
        NSMutableArray * soldArr = [NSMutableArray array];
        NSMutableArray * backArr = [NSMutableArray array];
        NSMutableArray * planArr = [NSMutableArray array];
        NSMutableArray * spaceArr = [NSMutableArray array];
        NSMutableArray * keyNameArr = [NSMutableArray array];
        
        
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSNumber * keyNum = [keyArr objectAtIndex:index];
            NSString * keyName = [CBGListModel schoolNameFromSchoolNumber:[keyNum integerValue]];
            keyName = [keyName substringToIndex:2];
            
            NSNumber * spaceNum = [spaceDic objectForKey:keyNum]?:@0;
            [spaceArr addObject:spaceNum];
            NSNumber * sellingNum = [sellingDic objectForKey:keyNum]?:@0;
            [sellingArr addObject:sellingNum];
            NSNumber * soldNum = [soldDic objectForKey:keyNum]?:@0;
            [soldArr addObject:soldNum];
            NSNumber * backNum = [backDic objectForKey:keyNum]?:@0;
            [backArr addObject:backNum];
            NSNumber * planNum = [planDic objectForKey:keyNum]?:@0;
            [planArr addObject:planNum];
            
            [keyNameArr addObject:keyName];
        }
        
        
        NSString * subTitle = [NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,[self.dbHistoryArr count]];
        subTitle = [subTitle stringByAppendingFormat:@" 售出 (%ld)",[self totalCountNumberForSubDic:soldDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 在售 (%ld)",[self totalCountNumberForSubDic:sellingDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 取回 (%ld)",[self totalCountNumberForSubDic:backDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 估价 (%ld)",[self totalCountNumberForSubDic:planDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 抢购 (%ld)",[self totalCountNumberForSubDic:spaceDic]];
        
        NSString * chartType = AAChartTypeBar;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(@"全部数据门派分布")
        .subtitleSet(subTitle)
        .yAxisTitleSet(@"数量")
        .categoriesSet(keyNameArr)
        .seriesSet(@[
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"售出")
                     .dataSet(soldArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"在售")
                     .dataSet(sellingArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"取回")
                     .dataSet(backArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"估价")
                     .dataSet(planArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"抢购")
                     .dataSet(spaceArr),
                     
                     ]
                   )
        ;
        _schoolModel = model;
    }
    return _schoolModel;
}
-(AAChartModel *)soldModel
{
    if(!_soldModel)
    {
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableDictionary * soldDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * spaceDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * planDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * bothDic = [NSMutableDictionary dictionary];
        NSInteger totalSoldNum = 0;
        
        for (NSInteger index = 0; index < [dbArr count]; index ++)
        {
            CBGListModel * list = [dbArr objectAtIndex:index];
            NSNumber * numKey = [NSNumber numberWithInteger:list.equip_school];
            
            NSNumber * preNum = nil;
            if([list.sell_sold_time length] == 0)
            {
                continue;
            }
            //已经售出
//            if([list.sell_sold_time length] > 0)
            {
                totalSoldNum ++;
                preNum = [soldDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [soldDic setObject:preNum forKey:numKey];
            }
            
            if(list.sell_space > 0 && list.sell_space < 10 * MINUTE)
            {
                preNum = [spaceDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [spaceDic setObject:preNum forKey:numKey];
            }

            
            if(list.style == CBGEquipPlanStyle_Worth || list.style == CBGEquipPlanStyle_PlanBuy)
            {
                preNum = [planDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [planDic setObject:preNum forKey:numKey];
                
            }
            
            if((list.style == CBGEquipPlanStyle_Worth || list.style == CBGEquipPlanStyle_PlanBuy) && (list.sell_space > 0 && list.sell_space < 10 * MINUTE))
            {
                preNum = [bothDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [bothDic setObject:preNum forKey:numKey];
            }
        }
        
        NSArray * keyArr = [soldDic allKeys];
        keyArr = [keyArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        //数据统计
        NSMutableArray * soldArr = [NSMutableArray array];
        NSMutableArray * spaceArr = [NSMutableArray array];
        NSMutableArray * planArr = [NSMutableArray array];
        NSMutableArray * bothArr = [NSMutableArray array];
        NSMutableArray * keyNameArr = [NSMutableArray array];
        
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSNumber * keyNum = [keyArr objectAtIndex:index];
            NSString * keyName = [CBGListModel schoolNameFromSchoolNumber:[keyNum integerValue]];
            keyName = [keyName substringToIndex:2];
            
            NSNumber * soldNum = [soldDic objectForKey:keyNum]?:@0;
            [soldArr addObject:soldNum];
            NSNumber * spaceNum = [spaceDic objectForKey:keyNum]?:@0;
            [spaceArr addObject:spaceNum];
            NSNumber * planNum = [planDic objectForKey:keyNum]?:@0;
            [planArr addObject:planNum];
            NSNumber * bothNum = [bothDic objectForKey:keyNum]?:@0;
            [bothArr addObject:bothNum];
            
            [keyNameArr addObject:keyName];
        }
        
        NSString * subTitle = [NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,totalSoldNum];
        subTitle = [subTitle stringByAppendingFormat:@" 售出 (%ld)",[self totalCountNumberForSubDic:soldDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 估价 (%ld)",[self totalCountNumberForSubDic:planDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 抢购 (%ld)",[self totalCountNumberForSubDic:spaceDic]];
        subTitle = [subTitle stringByAppendingFormat:@" 估价&抢购 (%ld)",[self totalCountNumberForSubDic:bothDic]];

        
        NSString * chartType = AAChartTypeBar;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(@"售出数据门派估价抢购表")
        .yAxisTitleSet(@"数量")
        .subtitleSet(subTitle)
        .categoriesSet(keyNameArr)
        .seriesSet(@[
                     AAObject(AASeriesElement)
                     .nameSet(@"售出")
                     .dataSet(soldArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"估价")
                     .dataSet(planArr),

                     AAObject(AASeriesElement)
                     .nameSet(@"抢购")
                     .dataSet(spaceArr),

                     AAObject(AASeriesElement)
                     .nameSet(@"估价&抢购")
                     .dataSet(bothArr),

                     ]
                   )
        ;
        _soldModel = model;
    }
    return _soldModel;
}

-(NSInteger)sepTimeLengthForLatestSelectedDate
{
    //传入的年，以月份区分
    //传入的月，以天数区分
    //传入的天，以小时区分
    NSString * formatStr = @"yyyy-MM-dd HH:mm:ss";
    NSString * yearStr = [formatStr substringToIndex:4];
    NSString * monthStr = [formatStr substringToIndex:7];
    NSString * daysStr = [formatStr substringToIndex:10];
    NSString * hourStr = [formatStr substringToIndex:13];
    
    
    NSArray * selectedArr = @[@"",yearStr,monthStr,daysStr,hourStr];
    NSInteger cutLength = 0;
    NSInteger inputLength = [self.selectedDate length];
    
    if(inputLength > [hourStr length]){
        return 0;
    }
    
    for (NSInteger index = 0;index < [selectedArr count] ;index ++ )
    {
        NSString * eveCom = [selectedArr objectAtIndex:index];
        if(inputLength == [eveCom length]){
            //取下一个
            cutLength = [[selectedArr objectAtIndex:index + 1] length];
        }
    }
    
    return cutLength;
}
-(NSString *)sepWeekTimeForSoldTime:(NSString *)soldTime
{
    NSString * weekStr = nil;
    if(soldTime && [soldTime length] > 0)
    {
        NSDate * date = [NSDate fromString:soldTime];
        WeekdayType week =  date.weekday;
        NSInteger index = week - 1;
//        NSArray * weekNames = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
//        weekStr = [weekNames objectAtIndex:index];
        weekStr = [[NSNumber numberWithInteger:index] stringValue];
    }
    return weekStr;
}

-(AAChartModel *)soldTimeModel
{
    if(!_soldTimeModel)
    {
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableDictionary * totalDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * sellingDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * soldDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * backDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * planDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * spaceDic = [NSMutableDictionary dictionary];

        NSInteger compareLength = [self sepTimeLengthForLatestSelectedDate];
        
        for (NSInteger index = 0; index < [dbArr count]; index ++)
        {
            CBGListModel * list = [dbArr objectAtIndex:index];
            NSString * numKey = [list.sell_create_time substringToIndex:compareLength];
            
            NSNumber * preNum = nil;
            
//            if([list.sell_back_time length] == 0 && [list.sell_sold_time length] == 0)
            {
                preNum =[totalDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [totalDic setObject:preNum forKey:numKey];
                
            }
            
            if([list.sell_back_time length] == 0 && [list.sell_sold_time length] == 0)
            {
                preNum =[sellingDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [sellingDic setObject:preNum forKey:numKey];
                
            }
            if([list.sell_sold_time length] > 0)
            {
                preNum = [soldDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [soldDic setObject:preNum forKey:numKey];
            }
            
            if(list.sell_space > 0 && list.sell_space < 10 * MINUTE)
            {
                preNum = [spaceDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [spaceDic setObject:preNum forKey:numKey];
            }
            
            if([list.sell_back_time length] > 0)
            {
                preNum = [backDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [backDic setObject:preNum forKey:numKey];
            }
            
            if(list.style == CBGEquipPlanStyle_Worth || list.style == CBGEquipPlanStyle_PlanBuy)
            {
                preNum = [planDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [planDic setObject:preNum forKey:numKey];
                
            }
        }
        
        NSArray * keyArr = [totalDic allKeys];
        keyArr = [keyArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        //数据统计
        NSMutableArray * sellingArr = [NSMutableArray array];
        NSMutableArray * soldArr = [NSMutableArray array];
        NSMutableArray * backArr = [NSMutableArray array];
        NSMutableArray * planArr = [NSMutableArray array];
        NSMutableArray * spaceArr = [NSMutableArray array];
        NSMutableArray * totalArr = [NSMutableArray array];
        NSMutableArray * keyNameArr = [NSMutableArray array];
        
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSString * keyNum = [keyArr objectAtIndex:index];
            
            NSNumber * totalNum = [totalDic objectForKey:keyNum]?:@0;
            [totalArr addObject:totalNum];
            NSNumber * sellingNum = [sellingDic objectForKey:keyNum]?:@0;
            [sellingArr addObject:sellingNum];
            NSNumber * soldNum = [soldDic objectForKey:keyNum]?:@0;
            [soldArr addObject:soldNum];
            NSNumber * backNum = [backDic objectForKey:keyNum]?:@0;
            [backArr addObject:backNum];
            NSNumber * planNum = [planDic objectForKey:keyNum]?:@0;
            [planArr addObject:planNum];
            NSNumber * spaceNum = [spaceDic objectForKey:keyNum]?:@0;
            [spaceArr addObject:spaceNum];
            
            NSString * keyName = [keyNum substringWithRange:NSMakeRange([keyNum length] - 2, 2)];
            [keyNameArr addObject:keyName];
        }
        
        
        
        NSString * chartType = AAChartTypeLine;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(@"售出趋势表")
        .yAxisTitleSet(@"数量")
        .subtitleSet([NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,[self.dbHistoryArr count]])
        .categoriesSet(keyNameArr)
        .seriesSet(@[
                     AAObject(AASeriesElement)
                     .nameSet(@"起售")
                     .dataSet(totalArr),

                     AAObject(AASeriesElement)
                     .nameSet(@"在售")
                     .dataSet(sellingArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"售出")
                     .dataSet(soldArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"抢购")
                     .dataSet(spaceArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"估价")
                     .dataSet(planArr),
                     ]
                   )
        ;
        model.symbol = AAChartSymbolTypeCircle;

        _soldTimeModel = model;
    }
    return _soldTimeModel;
}
-(AAChartModel *)soldWeekModel
{
    if(!_soldWeekModel)
    {
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableDictionary * soldDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * planDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * spaceDic = [NSMutableDictionary dictionary];
        
        
        for (NSInteger index = 0; index < [dbArr count]; index ++)
        {
            CBGListModel * list = [dbArr objectAtIndex:index];
            
            if([list.sell_sold_time length] == 0)
            {
                continue;
            }
            NSString * week = [self sepWeekTimeForSoldTime:list.sell_sold_time];
            NSString * numKey = week;
            
            NSNumber * preNum = nil;
            
            //            if([list.sell_back_time length] == 0 && [list.sell_sold_time length] == 0)
            if([list.sell_sold_time length] > 0)
            {
                preNum = [soldDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [soldDic setObject:preNum forKey:numKey];
            }
            
            if(list.sell_space > 0 && list.sell_space < 10 * MINUTE)
            {
                preNum = [spaceDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [spaceDic setObject:preNum forKey:numKey];
            }
            
           
            if(list.style == CBGEquipPlanStyle_Worth || list.style == CBGEquipPlanStyle_PlanBuy)
            {
                preNum = [planDic objectForKey:numKey];
                if(!preNum){
                    preNum  = [NSNumber numberWithInt:1];
                }else{
                    int number = preNum.intValue + 1;
                    preNum = [NSNumber numberWithInt:number];
                }
                [planDic setObject:preNum forKey:numKey];
                
            }
        }
        
        NSArray * keyArr = [soldDic allKeys];
        keyArr = [keyArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        //数据统计
        NSMutableArray * soldArr = [NSMutableArray array];
        NSMutableArray * planArr = [NSMutableArray array];
        NSMutableArray * spaceArr = [NSMutableArray array];
        NSMutableArray * keyNameArr = [NSMutableArray array];
        NSArray * weekNames = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
        NSInteger totalNum = 0;
        
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSString * keyNum = [keyArr objectAtIndex:index];
            
            NSNumber * soldNum = [soldDic objectForKey:keyNum]?:@0;
            [soldArr addObject:soldNum];
            NSNumber * planNum = [planDic objectForKey:keyNum]?:@0;
            [planArr addObject:planNum];
            NSNumber * spaceNum = [spaceDic objectForKey:keyNum]?:@0;
            [spaceArr addObject:spaceNum];
            totalNum += [soldNum integerValue];
            
            NSString * keyName = [weekNames objectAtIndex:[keyNum integerValue]];
            [keyNameArr addObject:keyName];
        }
        
        
        NSString * titleName = [NSString stringWithFormat:@"售出星期趋势表(%ld)",totalNum];
        NSString * chartType = AAChartTypeLine;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(titleName)
        .yAxisTitleSet(@"数量")
        .subtitleSet([NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,[self.dbHistoryArr count]])
        .categoriesSet(keyNameArr)
        .seriesSet(@[
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"售出")
                     .dataSet(soldArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"抢购")
                     .dataSet(spaceArr),
                     
                     AAObject(AASeriesElement)
                     .nameSet(@"估价")
                     .dataSet(planArr),
                     ]
                   )
        ;
        model.symbol = AAChartSymbolTypeCircle;
        
        _soldWeekModel = model;
    }
    return _soldWeekModel;
}


-(AAChartModel *)priceTimeModel
{
    if(!_priceTimeModel)
    {
        NSArray * dbArr = self.dbHistoryArr;
        NSMutableDictionary * schoolTotalDic = [NSMutableDictionary dictionary];
        //字典中存放字典
        
        for (NSInteger index = 0; index < [dbArr count]; index ++)
        {
            CBGListModel * list = [dbArr objectAtIndex:index];
            NSNumber * numKey = [self selectedKeyNumFroLatestPriceString:list.equip_price];
            NSNumber * schoolNum = [NSNumber numberWithInteger:list.equip_school];
            
            //找到门派字典
            NSMutableDictionary * schoolDic = [schoolTotalDic objectForKey:schoolNum];
            if(!schoolDic){
                schoolDic = [NSMutableDictionary dictionary];
                [schoolTotalDic setObject:schoolDic forKey:schoolNum];
            }
            
            //筛选数据，存放对应的字典中
            NSNumber * preNum = [schoolDic objectForKey:numKey];
            if(!preNum){
                preNum  = [NSNumber numberWithInt:1];
            }else{
                int number = preNum.intValue + 1;
                preNum = [NSNumber numberWithInt:number];
            }
            [schoolDic setObject:preNum forKey:numKey];
        }
        
        NSArray * keyArr = self.priceSortArr;
        //数据统计
        
        NSMutableArray * keyNameArr = [NSMutableArray array];
        NSMutableArray * schoolTotalArr = [NSMutableArray array];
        //大数组  数组内包含数组,包含15个小数组，每个数组内对应不同价位的数量
        NSInteger schoolCount = 15;
        for (NSInteger index = 0 ;index < schoolCount ;index ++){
            NSMutableArray * subArr = [NSMutableArray array];
            [schoolTotalArr addObject:subArr];
        }
        
        for (NSInteger index = 0;index < [keyArr count] ;index ++) {
            NSNumber * keyNum = [keyArr objectAtIndex:index];
            NSNumber * nexKeyNum = keyNum;
            if([keyArr count] > index + 1){
                nexKeyNum = [keyArr objectAtIndex:index + 1];
            }
            NSString * keyName = [NSString stringWithFormat:@"%ldK-%ldK",keyNum.integerValue/1000,nexKeyNum.integerValue/1000];
            
            for (NSInteger index = 0 ;index < schoolCount ;index ++)
            {
                NSNumber * schoolNum = [NSNumber numberWithInteger:index + 1];
                NSDictionary * schoolDic = [schoolTotalDic objectForKey:schoolNum];
                if(schoolDic)
                {
                    NSMutableArray * schoolSubArr = [schoolTotalArr objectAtIndex:index];
                    NSNumber * totalNum = [schoolDic objectForKey:keyNum]?:@0;
                    [schoolSubArr addObject:totalNum];
                }
            }
            
            if(index == 0){
                keyName = @"起始";
            }else if(index == [keyArr count] - 1){
                keyName = @"更高";
            }
            [keyNameArr addObject:keyName];
        }
        
        NSMutableArray * seriesArr = [NSMutableArray array];
        for (NSInteger index = 0 ;index < schoolCount ;index ++){
            NSNumber * schoolNum = [NSNumber numberWithInteger:index + 1];
            NSString * schoolName = [CBGListModel schoolNameFromSchoolNumber:[schoolNum integerValue]];
            schoolName = [schoolName substringToIndex:2];
            NSArray * subArr = [schoolTotalArr objectAtIndex:index];
            
            AASeriesElement * eve = AAObject(AASeriesElement)
            .nameSet(schoolName)
            .dataSet(subArr);
            
            [seriesArr addObject:eve];
        }
        
        
        NSString * subTitle = [NSString stringWithFormat:@"%@ (%ld)",self.selectedDate,[self.dbHistoryArr count]];
        
        NSString * chartType = AAChartTypeLine;
        AAChartModel * model= AAObject(AAChartModel)
        .chartTypeSet(chartType)
        .titleSet(@"全部数据价格区间分布")
        .subtitleSet(subTitle)
        .yAxisTitleSet(@"数量")
        .categoriesSet(keyNameArr)
        .seriesSet(seriesArr)
        ;
        model.symbol = AAChartSymbolTypeCircle;
        _priceTimeModel = model;
    }
    return _priceTimeModel;
}


-(void)refreshChartModelWithLatestListAndStyle
{
    //重新创建model
    if(!self.dbHistoryArr || [self.dbHistoryArr count] == 0){
        return;
    }
    
    //估值概况表
    [self.planChartView aa_drawChartWithChartModel:self.planModel];
    
    //价格分段
    [self.priceChartView aa_drawChartWithChartModel:self.priceModel];

    //门派分段
    [self.schoolChartView aa_drawChartWithChartModel:self.schoolModel];
    
    //售出数据
    [self.soldChartView aa_drawChartWithChartModel:self.soldModel];
    
    
    //销量走势图 AAChartSymbolTypeCircle
    [self.soldTimeChartView aa_drawChartWithChartModel:self.soldTimeModel];
    
    //价格走势图 AAChartSymbolTypeCircle
    [self.priceTimeChartView aa_drawChartWithChartModel:self.priceTimeModel];

    //时间走势图 AAChartSymbolTypeCircle
    [self.soldWeekChartView aa_drawChartWithChartModel:self.soldWeekModel];

    
}


-(void)submit{//纵横两个维度看
    //    1、通过进入数据，控制数据的相关程度
    //    2、估价情况  1、有利  2、值得  3、不值  4、全部
    //    3、列表筛选  筛选  已售出  未售出 全部
    NSString * log = [NSString stringWithFormat:@"对估价数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    
    if(self.exchangeDelegate)
    {
        action =[MSAlertAction actionWithTitle:@"切换统计历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                 {
                     if(weakSelf.exchangeDelegate && [weakSelf.exchangeDelegate respondsToSelector:@selector(historyHandelExchangeHistoryShowWithPlanShow:)]){
                         [weakSelf.exchangeDelegate historyHandelExchangeHistoryShowWithPlanShow:CBGCombinedHandleVCStyle_Statist];
                     }
                 }];
        [alertController addAction:action];
        
        action = [MSAlertAction actionWithTitle:@"切换估价历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                  {
                      if(weakSelf.exchangeDelegate && [weakSelf.exchangeDelegate respondsToSelector:@selector(historyHandelExchangeHistoryShowWithPlanShow:)]){
                          [weakSelf.exchangeDelegate historyHandelExchangeHistoryShowWithPlanShow:CBGCombinedHandleVCStyle_Plan];
                      }
                  }];
        [alertController addAction:action];
        
    }

    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
