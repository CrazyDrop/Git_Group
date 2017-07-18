//
//  CBGSortHistoryBaseTableVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseTableVC.h"
#import "CBGListModel.h"
#import "EquipModel.h"
#import "ZALocationLocalModel.h"
#import "ZACBGDetailWebVC.h"
#import "RefreshListCell.h"

@interface CBGSortHistoryBaseTableVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * listTable;
//@property (nonatomic,strong) NSDictionary * serNameDic;
@end

@implementation CBGSortHistoryBaseTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serNameDic = total.serverNameDic;
    self.serNameDic = serNameDic;

    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    self.listTable = table;
    [self.view addSubview:table];
    
}

#pragma mark - TotalshowSortArray
-(NSArray *)latestTotalShowedHistoryList
{
    NSMutableArray * total = [NSMutableArray array];
    NSArray * arr = self.showSortArr;
    for (NSInteger index = 0; index < [arr count];index ++ ) {
        NSArray * subArr = [arr objectAtIndex:index];
        [total addObjectsFromArray:subArr];
    }
    return total;
}

#pragma mark - UITableViewDelegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray * arr = self.showTagArr;
    return arr;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSArray * arr = self.showTagArr;
    NSInteger secIndex = [arr indexOfObject:title];
    return secIndex;
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.showSortArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * subArr = [self.showSortArr objectAtIndex:section];
    return [subArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * eve = [self.showTagArr objectAtIndex:section];
    NSArray * subArr = [self.showSortArr objectAtIndex:section];
    NSString * endStr = [NSString stringWithFormat:@"(%ld)",[subArr count]];
    if(eve && ![eve hasSuffix:endStr])
    {
        eve = [eve stringByAppendingFormat:@"(%ld)",[subArr count]];
    }
    return eve;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    
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
    
    CBGEquipRoleState state = contact.latestEquipListStatus;
    
    
    NSString * centerDetailTxt = contact.plan_des;
    UIColor * numcolor = [UIColor lightGrayColor];
    UIColor * color = [UIColor lightGrayColor];
    NSString * leftRateTxt = nil;
    //[NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
    NSString * leftPriceTxt = [NSString stringWithFormat:@"%.2f",contact.equip_price/100.0];
    NSNumber * serId = [NSNumber numberWithInteger:contact.server_id];
    NSString * serverName = [self.serNameDic objectForKey:serId];
    
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
    UIColor * leftPriceColor = [UIColor redColor];
    
//    //区分状态，
//    if( state == CBGEquipRoleState_InSelling)
//    {//主要展示上下架时间
//        NSDate * date = [NSDate fromString:contact.sell_start_time];
//        rightTimeTxt =  [date toString:@"(MM-dd)HH:mm"];
//        leftRateTxt  = @"上架";
//        leftRateColor = [UIColor orangeColor];
//        equipName =  [NSString stringWithFormat:@"ID:%@",contact.owner_roleid];
//        centerDetailTxt = [contact.game_ordersn substringToIndex:15];
//        
//    }else if(state == CBGEquipRoleState_InOrdering)
//    {//主要展示  下单信息  取消,金额
//        NSDate * date = [NSDate fromString:contact.sell_order_time];
//        rightTimeTxt =  [date toString:@"MM-dd HH点"];
//        
//        date = [NSDate fromString:contact.sell_cancel_time];
//        rightStatusTxt =  [date toString:@"MM-dd HH点"];
//        
//        leftRateTxt =  @"下单";
//        leftRateColor = [UIColor orangeColor];
//        equipName =  [NSString stringWithFormat:@"ID:%@",contact.owner_roleid];
//        centerDetailTxt = [contact.game_ordersn substringToIndex:15];
//        
//    }
//    else if(state == CBGEquipRoleState_PayFinish)
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
            centerDetailTxt = [NSString stringWithFormat:@"%ld(%ld)号:%d",contact.plan_total_price,contact.plan_zhuangbei_price + contact.plan_zhaohuanshou_price,(int)contact.price_base_equip];
        }
        
        
        if(serverName){
            leftRateTxt = serverName;
        }else{
            leftRateTxt = [NSString stringWithFormat:@"%@:%ld",contact.equip_name,contact.server_id];
        }
        
        NSInteger priceChange = contact.equip_start_price - contact.equip_price/100;

        if(priceChange != 0)
        {//价格有变更
            if(priceChange >0)
            {
                leftRateColor = [UIColor orangeColor];
            }
            
            //价格不同，认为是还价购买的，展示还价前价格
            if(contact.equip_price_common != contact.equip_price/100.0)
            {
                leftRateColor = Custom_Blue_Button_BGColor;
                if(contact.equip_start_price == contact.equip_price_common){
                  //初始价格和外部价格一致
                    leftRateTxt = [NSString stringWithFormat:@"%ld %@",contact.equip_price_common,leftRateTxt];
                }else
                {
                    leftRateTxt = [NSString stringWithFormat:@"%ld %ld %@",contact.equip_start_price,contact.equip_price_common,leftRateTxt];
                }
            }else
            {
                leftRateTxt = [NSString stringWithFormat:@"%ld%@",contact.equip_start_price,leftRateTxt];
            }
        }
        
        NSInteger rate = contact.price_rate_latest_plan;
        if(rate > 0 && contact.server_id != 45)
        {
            equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
            equipName = [NSString stringWithFormat:@"%ld%% %@",rate,equipName];
            equipBuyColor = [UIColor greenColor];
        }
        //leftPriceTxt = [NSString stringWithFormat:@"%@",leftPriceTxt];
        
        if(contact.planMore_zhaohuan || contact.planMore_Equip)
        {
            numcolor = [UIColor redColor];
        }
    }
    
    if(contact.equip_accept > 0)
    {
        leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
    }
    if(contact.errored){
        leftPriceTxt = [NSString stringWithFormat:@"!%@",leftPriceTxt];
    }
    if(contact.appointed)
    {
        leftPriceColor = Custom_Blue_Button_BGColor;
    }


    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = centerDetailTxt;
    cell.rateLbl.text = leftPriceTxt;
    cell.rateLbl.textColor = leftPriceColor;
    
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
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    NSString * selectId = contact.owner_roleid;
    
    
//    CBGEquipRoleState state = contact.latestEquipListStatus;
//    NSMutableArray * showArr = [NSMutableArray array];
    
    ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
    detail.cbgList = contact;
    [[self rootNavigationController] pushViewController:detail animated:YES];

    
    
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
