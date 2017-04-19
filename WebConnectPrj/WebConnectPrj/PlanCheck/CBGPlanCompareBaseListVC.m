//
//  CBGPlanCompareBaseListVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanCompareBaseListVC.h"
#import "RefreshListCell.h"
#import "ZACBGDetailWebVC.h"
#define  CBGPlanCompareHistoryAddTAG  100

@interface CBGPlanCompareBaseListVC ()
@property (nonatomic, strong)NSArray * sortArr;
@property (nonatomic, strong) NSArray * tagArr;
@property (nonatomic, assign )CBGStaticSortShowStyle  sortStyle;
@end

@implementation CBGPlanCompareBaseListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_None;
    //分组  门派  rate
    //排序  rate  价格
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"起售",@"结束",@"全部"];//按钮点击时，从全部库表选取
    
    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(index * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        btn.tag = CBGPlanCompareHistoryAddTAG + index;
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //控制起始数据源，db筛选规则
    [self startShowedLatestHistoryDBList];
}
-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice{
    [self startShowedLatestHistoryDBList];
}

-(void)startShowedLatestHistoryDBList
{
    if(!self.dbHistoryArr) return;
    
    NSArray * sortArr = [self selectDBHistoryListWithDataSelectedStyleStarted:YES];
    
    //启动时的数据，屏蔽寄售取回的情况
    NSMutableArray * soldArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++) {
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
//        if([eveModel.sell_sold_time length] > 0)
        {
            [soldArr addObject:eveModel];
        }
    }
    
//    sortArr = [self sortSelectedHistoryListWithFinishStyle:YES andArray:soldArr];
    [self showLatestDBHistoryListArrayWithLatestSortStyleAndArray:sortArr];
}

-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanCompareHistoryAddTAG;
    NSArray * sortArr = nil;
    switch (tagIndex) {
        case 0:
        {
            sortArr = [self selectDBHistoryListWithDataSelectedStyleStarted:YES];
            
        }
            break;
        case 1:
        {
            sortArr = [self selectDBHistoryListWithDataSelectedStyleStarted:NO];
            
        }
            break;
            
        case 2:
        {
            sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
            
        }
            break;
            
        default:
            break;
    }
    
    [self showLatestDBHistoryListArrayWithLatestSortStyleAndArray:sortArr];
    
}
-(NSArray *)latestTotalShowedHistoryList
{
    NSMutableArray * total = [NSMutableArray array];
    NSArray * arr = self.sortArr;
    for (NSInteger index = 0; index < [arr count];index ++ ) {
        NSArray * subArr = [arr objectAtIndex:index];
        [total addObjectsFromArray:subArr];
    }
    return total;
}

-(void)showLatestDBHistoryListArrayWithLatestSortStyleAndArray:(NSArray *)resultArr
{
    [self refreshNumberLblWithLatestNum:[resultArr count]];
    
    CBGStaticSortShowStyle style = self.sortStyle;
    switch (style) {
        case CBGStaticSortShowStyle_None:
        {
            
        }
            break;
        case CBGStaticSortShowStyle_School:
        case CBGStaticSortShowStyle_Rate:
        {
            resultArr = [resultArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve1.equip_price] compare:[NSNumber numberWithInteger:eve2.equip_price]];
            }];
            
        }
            break;
            
        case CBGStaticSortShowStyle_Space:
        {
            resultArr = [resultArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                
                NSComparisonResult result = NSOrderedSame;
                //结束时间
                result = [[NSNumber numberWithInteger:eve1.sell_space] compare:[NSNumber numberWithInteger:eve2.sell_space]];
                
                return result;
            }];
        }
            break;
            
        default:
            break;
    }
    
    
    //分组方式
    BOOL sortSchool = self.sortStyle != CBGStaticSortShowStyle_Rate;
    NSMutableDictionary * totalDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0;index < [resultArr count] ;index ++ )
    {
        CBGListModel * eve = [resultArr objectAtIndex:index];
        NSString * keyStr = nil;
        if(sortSchool){
            keyStr = [[NSNumber numberWithInteger:eve.equip_school] stringValue];
        }else{
            keyStr = [[NSNumber numberWithInteger:eve.plan_rate] stringValue];
        }
        
        NSMutableArray * subArr = nil;
        if(![totalDic objectForKey:keyStr]){
            subArr = [NSMutableArray array];
            [totalDic setObject:subArr forKey:keyStr];
        }else{
            subArr = [totalDic objectForKey:keyStr];
        }
        
        [subArr addObject:eve];
    }
    
    NSArray * keys = [totalDic allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber * num1 = [NSNumber numberWithInteger:[obj1 integerValue]];
        NSNumber * num2 = [NSNumber numberWithInteger:[obj2 integerValue]];
        return [num1 compare:num2];
    }];
    
    NSMutableArray * total = [NSMutableArray array];
    NSMutableArray * schoolNames = [NSMutableArray array];
    for (NSInteger index = 0;index < [keys count] ;index ++ )
    {
        NSNumber * num = [keys objectAtIndex:index];
        
        NSArray * subArr = [totalDic objectForKey:num];
        [total addObject:subArr];
        
        NSString *eveName = [CBGListModel schoolNameFromSchoolNumber:[num integerValue]];
        eveName = [eveName substringWithRange:NSMakeRange(0,2)];
        eveName = [eveName stringByAppendingFormat:@"(%ld)",[subArr count]];
        [schoolNames addObject:eveName];
    }
    
    if(sortSchool)
    {
        keys = schoolNames;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sortArr = total;
        self.tagArr = keys;
        [self.listTable reloadData];;
    });
    
}

-(NSArray * )selectDBHistoryListWithDataSelectedStyleStarted:(BOOL)finish
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
//        if(finish && [eveModel.sell_create_time hasPrefix:self.selectedDate]){
//            [resultArr addObject:eveModel];
//        }else if(!finish && ([eveModel.sell_sold_time hasPrefix:self.selectedDate] || [eveModel.sell_back_time hasPrefix:self.selectedDate])){
//            [resultArr addObject:eveModel];
//        }
        [resultArr addObject:eveModel];
    }
    
    return resultArr;
}

-(NSArray *)sortSelectedHistoryListWithFinishStyle:(BOOL)finish andArray:(NSArray *)sortArr
{
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //筛选有结束时间的
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(finish && ([eveModel.sell_sold_time length]>0 || [eveModel.sell_back_time length] > 0))
        {
            [resultArr addObject:eveModel];
        }else if(!finish && ([eveModel.sell_sold_time length]==0 && [eveModel.sell_back_time length] == 0)){
            [resultArr addObject:eveModel];
        }
        
        
    }
    return resultArr;
}

//结束与否筛选
-(void)detailSortSelectedForLatestShowHistoryListWithFinish:(BOOL)finish
{
    NSArray * sortArr = [self latestTotalShowedHistoryList];
    
    sortArr = [self sortSelectedHistoryListWithFinishStyle:finish andArray:sortArr];
    
    [self showLatestDBHistoryListArrayWithLatestSortStyleAndArray:sortArr];
}
//-(void)showDetailChartViewForLatestShowData
//{
//    NSArray * dbArray = [self latestTotalShowedHistoryList];
//    
//    NSString * todayDate = self.selectedDate;
//    NSMutableArray * startArr = [NSMutableArray array];
//    for (NSInteger index = 0; index < [dbArray count]; index ++) {
//        CBGListModel * eve = [dbArray objectAtIndex:index];
//        if([eve.sell_create_time hasPrefix:todayDate])
//        {
//            [startArr addObject:eve];
//        }
//    }
//    
//    CBGDepthStudyVC * study = [[CBGDepthStudyVC alloc] init];
//    study.selectedDate = self.selectedDate;
//    study.dbHistoryArr = startArr;
//    [[self rootNavigationController] pushViewController:study animated:YES];
//}

-(void)showDetailChooseForHistory
{//纵横两个维度看
    //    1、通过进入数据，控制数据的相关程度
    //    2、估价情况  1、有利  2、值得  3、不值  4、全部
    //    3、列表筛选  筛选  已售出  未售出 全部
    NSString * log = [NSString stringWithFormat:@"对统计数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    
    
    action = [MSAlertAction actionWithTitle:@"时差排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.sortStyle = CBGStaticSortShowStyle_Space;
                  [weakSelf showLatestDBHistoryListArrayWithLatestSortStyleAndArray:[weakSelf latestTotalShowedHistoryList]];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"利差分组" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.sortStyle = CBGStaticSortShowStyle_Rate;
                  [weakSelf showLatestDBHistoryListArrayWithLatestSortStyleAndArray:[weakSelf latestTotalShowedHistoryList]];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"门派排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.sortStyle = CBGStaticSortShowStyle_School;
                  [weakSelf showLatestDBHistoryListArrayWithLatestSortStyleAndArray:[weakSelf latestTotalShowedHistoryList]];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"筛选已结束" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf detailSortSelectedForLatestShowHistoryListWithFinish:YES];
              }];
    
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"筛选未结束" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf detailSortSelectedForLatestShowHistoryListWithFinish:NO];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"WEB刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:[weakSelf latestTotalShowedHistoryList]];
              }];
    [alertController addAction:action];
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    [self showLatestDBHistoryListArrayWithLatestSortStyleAndArray:array];
}


-(void)submit
{
    //    [self showDialogForNoContactsError];
    [self showDetailChooseForHistory];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray * arr = self.tagArr;
    return arr;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSArray * arr = self.tagArr;
    NSInteger secIndex = [arr indexOfObject:title];
    return secIndex;
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * subArr = [self.sortArr objectAtIndex:section];
    return [subArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * eve = [self.tagArr objectAtIndex:section];
    //    NSArray * subArr = [self.sortArr objectAtIndex:section];
    //    eve = [eve stringByAppendingFormat:@"(%ld)",[subArr count]];
    return eve;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.sortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    CBGEquipRoleState state = contact.latestEquipListStatus;
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier_CBG";
    RefreshListCell *cell = (RefreshListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        //            cell = [[ZAContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andTableView:tableView];
        //            cell.delegate = self;
        
        
        RefreshListCell * swipeCell = [[[NSBundle mainBundle] loadNibNamed:@"RefreshListCell"
                                                                     owner:nil
                                                                   options:nil] lastObject];
        
        //        [[RefreshListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [swipeCell setValue:cellIdentifier forKey:@"reuseIdentifier"];
        
        cell = swipeCell;
    }
    
    //用来标识是否最新一波数据
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serNameDic = total.serverNameDic;
    
    
    NSString * centerDetailTxt = contact.plan_des;
    UIColor * numcolor = [UIColor lightGrayColor];
    UIColor * color = [UIColor lightGrayColor];
    NSString * leftRateTxt = nil;
    //[NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
    NSString * leftPriceTxt = [NSString stringWithFormat:@"%.2f",contact.equip_price/100.0];
    NSNumber * serId = [NSNumber numberWithInteger:contact.server_id];
    NSString * serverName = [serNameDic objectForKey:serId];
    
    if(!contact)
    {
        leftRateTxt = nil;
        equipName = nil;
        centerDetailTxt = nil;
    }
    
    cell.latestMoneyLbl.textColor = color;
    
    //列表剩余时间
    //    @"dd天HH小时mm分钟"
    NSString * rightTimeTxt =  nil;
    NSString * rightStatusTxt = nil;
    UIColor * rightStatusColor = [UIColor lightGrayColor];
    UIColor * earnColor = [UIColor lightGrayColor];
    UIColor * equipBuyColor = [UIColor lightGrayColor];
    UIColor * leftRateColor = [UIColor lightGrayColor];
    //区分状态，
    if( state == CBGEquipRoleState_InSelling)
    {//主要展示上下架时间
        NSDate * date = [NSDate fromString:contact.sell_start_time];
        rightTimeTxt =  [date toString:@"(MM-dd)HH:mm"];
        leftRateTxt  = @"上架";
        leftRateColor = [UIColor orangeColor];
        equipName =  [NSString stringWithFormat:@"ID:%@",contact.owner_roleid];
        centerDetailTxt = [contact.game_ordersn substringToIndex:15];
        
    }else if(state == CBGEquipRoleState_InOrdering)
    {//主要展示  下单信息  取消,金额
        NSDate * date = [NSDate fromString:contact.sell_order_time];
        rightTimeTxt =  [date toString:@"MM-dd HH点"];
        
        date = [NSDate fromString:contact.sell_cancel_time];
        rightStatusTxt =  [date toString:@"MM-dd HH点"];
        
        leftRateTxt =  @"下单";
        leftRateColor = [UIColor orangeColor];
        equipName =  [NSString stringWithFormat:@"ID:%@",contact.owner_roleid];
        centerDetailTxt = [contact.game_ordersn substringToIndex:15];
        
    }
    else if(state == CBGEquipRoleState_PayFinish)
    {//主要展示  账号基础信息
        NSDate * startDate = [NSDate fromString:contact.sell_create_time];
        rightTimeTxt =  [startDate toString:@"MM-dd HH点"];
        
        rightStatusColor = [UIColor redColor];
        NSString * finishTime = contact.sell_sold_time;
        if([finishTime length] == 0)
        {//取消时间
            finishTime = contact.sell_back_time;
            rightStatusColor = [UIColor grayColor];
        }
        
        if([finishTime length] > 0)
        {
            NSDate *  finishDate = [NSDate fromString:finishTime];
            NSTimeInterval count = [finishDate timeIntervalSinceDate:startDate];
            
            if(count < 0)
            {
                count = 0;
            }
            
            BOOL showSpace = NO;
            NSInteger space = contact.sell_space;
            if(space > 0 && space < 10*MINUTE)
            {
                showSpace = YES;
                earnColor = [UIColor blueColor];
            }
            
            //时差秒数
            NSTimeInterval minuteNum = count/60;
            int minute = ((int)minuteNum)%60;
            NSTimeInterval hour = minuteNum/60;
            if(hour > 1){
                rightStatusTxt =  [NSString stringWithFormat:@"隔%02d:%02d",(int)hour,minute];
                if(showSpace){
                    rightStatusTxt =  [NSString stringWithFormat:@"%02d:%02d(%ld)",(int)hour,minute,space/60];
                }
            }else{
                rightStatusTxt =  [NSString stringWithFormat:@"隔%02d分",minute];
                if(showSpace){
                    rightStatusTxt =  [NSString stringWithFormat:@"%02d分(%ld)",minute,space/60];
                }
            }
            
        }else{
            startDate = [NSDate fromString:finishTime];
            rightStatusTxt =  [startDate toString:@"dd HH:mm"];
            
        }
        
        //计算时间差
        
        {
            centerDetailTxt = [NSString stringWithFormat:@"%ld%@",contact.plan_total_price,contact.plan_des];
        }
        
        
        if(serverName){
            leftRateTxt = serverName;
        }else{
            leftRateTxt = [NSString stringWithFormat:@"%@:%ld",contact.equip_name,contact.server_id];
        }
        
        NSInteger priceChange = contact.equip_start_price - contact.equip_price/100;
        if(priceChange != 0)
        {
            if(priceChange >0)
            {
                leftRateColor = [UIColor orangeColor];
            }
            leftRateTxt = [NSString stringWithFormat:@"%ld%@",contact.equip_start_price,leftRateTxt];
        }
        
        NSInteger rate = contact.price_rate_latest_plan;
        if(rate > 0 && contact.server_id != 45)
        {
            equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
            equipName = [NSString stringWithFormat:@"%ld%% %@",rate,equipName];
            equipBuyColor = [UIColor greenColor];
        }
        //leftPriceTxt = [NSString stringWithFormat:@"%@",leftPriceTxt];
    }
    
    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = centerDetailTxt;
    cell.rateLbl.text = leftPriceTxt;
    
    cell.sellTimeLbl.text = rightStatusTxt;
    cell.sellTimeLbl.textColor = rightStatusColor;
    
    cell.timeLbl.text = rightTimeTxt;
    cell.timeLbl.textColor = earnColor;
    
    UIFont * font = cell.totalNumLbl.font;
    cell.latestMoneyLbl.text = leftRateTxt;
    cell.latestMoneyLbl.textColor = leftRateColor;
    cell.latestMoneyLbl.font = font;
    
    cell.sellRateLbl.font = font;
    cell.sellRateLbl.text = equipName;
    cell.sellRateLbl.textColor = equipBuyColor;
    cell.sellDateLbl.hidden = YES;
    
    return cell;
}
#pragma mark -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.sortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    CBGEquipRoleState state = contact.latestEquipListStatus;
    
    //跳转条件  1详情页面时，非自己id   2非详情页面、仅历史库表取出数据
    //    BOOL detailSelect = (self.selectedRoleId > 0 && self.selectedRoleId != [contact.owner_roleid integerValue]);
    //    BOOL nearSelect = (self.selectedRoleId == 0 && state == CBGEquipRoleState_PayFinish);
    
    //    if(detailSelect || nearSelect)
    {
        ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
        detail.cbgList = contact;
        [[self rootNavigationController] pushViewController:detail animated:YES];
    }
    
    
}
-(NSTimeInterval)timeIntervalWithCreateTime:(NSString *)create andSellTime:(NSString *)selltime
{
    NSDate * createDate = [NSDate fromString:create];
    NSDate * sellDate = [NSDate fromString:selltime];
    
    NSTimeInterval interval = [sellDate timeIntervalSinceDate:createDate];
    //    NSLog(@"interval %f",interval);
    return interval;
    
}

#pragma mark -

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
