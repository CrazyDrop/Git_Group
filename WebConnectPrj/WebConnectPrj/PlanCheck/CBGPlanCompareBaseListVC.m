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
#import "CBGCompareSameRoleVC.h"
#import "ZALocalStateTotalModel.h"
#define  CBGPlanCompareHistoryAddTAG  100

@interface CBGPlanCompareBaseListVC ()
@property (nonatomic, strong)NSArray * sortArr;
@property (nonatomic, strong) NSArray * tagArr;
@property (nonatomic, assign )CBGStaticSortShowStyle  sortStyle;
@end

@implementation CBGPlanCompareBaseListVC

- (void)viewDidLoad {
    
    self.showRightBtn = YES;
    self.rightTitle = @"筛选";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_School;
    //分组  门派  rate
    //排序  rate  价格
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"未结束",@"结束",@"全部"];//按钮点击时，从全部库表选取
    
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
    
    [self showLatestDBHistoryListArrayWithLatestSortStyleAndArray:sortArr];
}

-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanCompareHistoryAddTAG;
    
    NSMutableArray * sortArr = [NSMutableArray array];
    NSArray * latestArr = [NSArray arrayWithArray:self.dbHistoryArr];
    
    NSMutableDictionary * objDic = [NSMutableDictionary dictionary];
    
    switch (tagIndex) {
        case 0:
        {
            for (NSInteger index = 0; index < [latestArr count]; index ++)
            {
                CBGListModel * eveModel  =[latestArr objectAtIndex:index];
                NSString * keySn = eveModel.owner_roleid;
                NSString * finish = eveModel.sell_sold_time;
                
                CBGListModel * preModel = [objDic objectForKey:keySn];
                if(preModel)
                {//之前有过存储
                    
                    if([finish length] == 0)
                    {
                        if(![sortArr containsObject:preModel]){
                            [sortArr addObject:preModel];
                        }
                        [sortArr addObject:eveModel];
                    }
                }else
                {
                    [objDic setObject:eveModel forKey:keySn];
                }
            }
        }
            break;
        case 1:
        {
            for (NSInteger index = 0; index < [latestArr count]; index ++)
            {
                CBGListModel * eveModel  =[latestArr objectAtIndex:index];
                NSString * keySn = eveModel.owner_roleid;
                NSString * finish = eveModel.sell_sold_time;
                
                CBGListModel * preModel = [objDic objectForKey:keySn];
                if(preModel)
                {//之前有过存储
                    
                    if([finish length] > 0)
                    {
                        if(![sortArr containsObject:preModel]){
                            [sortArr addObject:preModel];
                        }
                        [sortArr addObject:eveModel];
                    }
                }else
                {
                    [objDic setObject:eveModel forKey:keySn];
                }
            }
            
        }
            break;
            
        case 2:
        {
            [sortArr addObjectsFromArray:latestArr];
            
        }
            break;
            
        default:
            break;
    }
    [self refreshNumberLblWithLatestNum:[sortArr count]];
    
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
        case CBGStaticSortShowStyle_School:
        {//以学校分组，以服务器排序
            resultArr = [resultArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve1.server_id] compare:[NSNumber numberWithInteger:eve2.server_id]];
            }];
        }
            break;
        case CBGStaticSortShowStyle_Server:
        {//以服务器分组，以门派排序
            resultArr = [resultArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBGListModel * eve1 = (CBGListModel *)obj1;
                CBGListModel * eve2 = (CBGListModel *)obj2;
                return [[NSNumber numberWithInteger:eve1.equip_school] compare:[NSNumber numberWithInteger:eve2.equip_school]];
            }];
            
        }
            break;
            
        default:
            break;
    }
    
    
    //分组方式
    BOOL sortSchool = self.sortStyle != CBGStaticSortShowStyle_Server;
    
    
    NSMutableArray * total = [NSMutableArray array];
    NSMutableDictionary * totalDic = [NSMutableDictionary dictionary];
    NSArray * keys = nil;
    if(sortSchool)
    {
        for (NSInteger index = 0;index < [resultArr count] ;index ++ )
        {
            CBGListModel * eve = [resultArr objectAtIndex:index];
            NSString * keyStr = nil;
            keyStr = [[NSNumber numberWithInteger:eve.equip_school] stringValue];
            
            NSMutableArray * subArr = nil;
            if(![totalDic objectForKey:keyStr]){
                subArr = [NSMutableArray array];
                [totalDic setObject:subArr forKey:keyStr];
            }else{
                subArr = [totalDic objectForKey:keyStr];
            }
            
            [subArr addObject:eve];
        }
        
        keys = [totalDic allKeys];
        if(sortSchool)
        {
            keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSNumber * num1 = [NSNumber numberWithInteger:[obj1 integerValue]];
                NSNumber * num2 = [NSNumber numberWithInteger:[obj2 integerValue]];
                return [num1 compare:num2];
            }];
        }
        
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
        
        keys = schoolNames;
        
    }else
    {
        NSMutableDictionary * countDic = [NSMutableDictionary dictionary];
        for (NSInteger index = 0;index < [resultArr count] ;index ++ )
        {
            CBGListModel * eve = [resultArr objectAtIndex:index];
            NSString * keyStr = nil;
            keyStr = [[NSNumber numberWithInteger:eve.server_id] stringValue];

            
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
        
        
        NSMutableArray * schoolNames = [NSMutableArray array];
        
        ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
        NSDictionary * serDic = local.serverNameDic;
        
        for (NSInteger index = 0;index < [keys count] ;index ++ )
        {
            NSString * num = [keys objectAtIndex:index];
            NSNumber * numNum = [NSNumber numberWithInt:[num intValue]];
            
            NSArray * subArr = [totalDic objectForKey:num];
            [total addObject:subArr];
            
            NSString *eveName = [serDic objectForKey:numNum];
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
            [schoolNames addObject:eveName];
        }
        
        NSMutableArray * others = [NSMutableArray array];
        //其他
        for (NSString * key in totalDic)
        {
            if(![serverArr containsObject:key])
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
    
    
    action = [MSAlertAction actionWithTitle:@"服务器排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.sortStyle = CBGStaticSortShowStyle_Server;
                  [weakSelf showLatestDBHistoryListArrayWithLatestSortStyleAndArray:[weakSelf latestTotalShowedHistoryList]];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"门派排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.sortStyle = CBGStaticSortShowStyle_School;
                  [weakSelf showLatestDBHistoryListArrayWithLatestSortStyleAndArray:[weakSelf latestTotalShowedHistoryList]];
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
    NSArray * subArr = [self.sortArr objectAtIndex:section];
    eve = [eve stringByAppendingFormat:@"(%ld)",[subArr count]];
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
    NSString * selectId = contact.owner_roleid;
    
    
    CBGEquipRoleState state = contact.latestEquipListStatus;
    NSMutableArray * showArr = [NSMutableArray array];
    
    for (NSInteger index = -2;index <= 2; index ++)
    {
        NSInteger eveIndex = rowNum + index;
        if(eveIndex >= 0 && [subArr count] > eveIndex)
        {
            CBGListModel * eveModel = [subArr objectAtIndex:eveIndex];
            if([selectId isEqualToString:eveModel.owner_roleid])
            {
                [showArr addObject:eveModel];
            }
        }
    }
    
    
    //跳转条件  1详情页面时，非自己id   2非详情页面、仅历史库表取出数据
    //    BOOL detailSelect = (self.selectedRoleId > 0 && self.selectedRoleId != [contact.owner_roleid integerValue]);
    //    BOOL nearSelect = (self.selectedRoleId == 0 && state == CBGEquipRoleState_PayFinish);
    CBGCompareSameRoleVC * compare = [[CBGCompareSameRoleVC alloc] init];
    compare.compareArr = showArr;
    [[self rootNavigationController] pushViewController:compare animated:YES];
    
    
    //    if(detailSelect || nearSelect)
    {
//        ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
//        detail.cbgList = contact;
//        [[self rootNavigationController] pushViewController:detail animated:YES];
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
