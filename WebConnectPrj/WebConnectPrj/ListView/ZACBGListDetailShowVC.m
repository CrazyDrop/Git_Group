//
//  ZACBGListDetailShowVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZACBGListDetailShowVC.h"
#import "CBGListModel.h"
#import "RefreshListCell.h"
#import "ZACBGDetailWebVC.h"
#define  CBGPlanSortHistoryShowDetailAddTAG  100

@interface ZACBGListDetailShowVC ()<UITableViewDelegate,UITableViewDataSource>
//@property (nonatomic,strong) UITableView * listTable;

@end

@implementation ZACBGListDetailShowVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.viewTtle = @"数据";
        self.rightTitle = nil;
        self.showRightBtn = NO;
    }
    return self;
}
-(void)setDataArr:(NSArray *)dataArr
{
    _dataArr = [dataArr copy];
    self.dbHistoryArr = dataArr;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.sortStyle = CBGStaticSortShowStyle_None;
    self.orderStyle = CBGStaticOrderShowStyle_None;

    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"未结束",@"已结束",@"全部"];//按钮点击时，从全部库表选取
    
    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat startY = btnStartY - (index) * (btnHeight + 2);
        btn.frame = CGRectMake(0  , startY, btnWidth, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        btn.tag = CBGPlanSortHistoryShowDetailAddTAG + index;
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }

    
}
-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    self.sortStyle = CBGStaticSortShowStyle_Rate;
    //从全部中选取
    self.dbHistoryArr = [NSArray arrayWithArray:self.dataArr];
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanSortHistoryShowDetailAddTAG;
    
    switch (tagIndex) {
        case 0:
        {
            self.finishStyle = CBGSortShowFinishStyle_UnFinish;
        }
            break;
        case 1:
        {
            self.finishStyle = CBGSortShowFinishStyle_Finished;
            
        }
            break;
            
        case 2:
        {
            self.finishStyle = CBGSortShowFinishStyle_Total;
        }
            break;
            
        default:
            break;
    }
    
    [self refreshLatestShowTableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSInteger rowNum = indexPath.row;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
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
    
    NSString * centerDetailTxt = contact.plan_des;
    UIColor * numcolor = [UIColor lightGrayColor];
    UIColor * color = [UIColor lightGrayColor];
    NSString * leftRateTxt = nil;
    //[NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%ld%@ %ld",contact.server_id,contact.equip_school_name,contact.equip_level];
    NSString * leftPriceTxt = [NSString stringWithFormat:@"%.2f",contact.equip_price/100.0];
    
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
        NSDate * date = [NSDate fromString:contact.sell_create_time];
        rightTimeTxt =  [date toString:@"MM-dd HH点"];
        
        rightStatusColor = [UIColor redColor];
        NSString * finishTime = contact.sell_sold_time;
    
        if([finishTime length] == 0)
        {//取消时间
            finishTime = contact.sell_back_time;
            rightStatusColor = [UIColor grayColor];
        }
        
        date = [NSDate fromString:finishTime];
        rightStatusTxt =  [date toString:@"MM-dd HH点"];
        
        
        if(self.selectedRoleId >0)
        {//展示空号价格  系统价格
            if(contact.equip_eval_price > 0)
            {
                centerDetailTxt = [NSString stringWithFormat:@"%ld号:%.0f(%ld)",contact.plan_total_price,contact.price_base_equip,contact.equip_eval_price/100];
            }else{
                centerDetailTxt = [NSString stringWithFormat:@"%ld号:%.0f %@",contact.plan_total_price,contact.price_base_equip,contact.plan_des];
            }
        }else{
            centerDetailTxt = [NSString stringWithFormat:@"%ld%@",contact.plan_total_price,contact.plan_des];
        }
        
        
        leftRateTxt = contact.equip_name;
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
            
            if(contact.plan_zhuangbei_price > 0)
            {
                equipName = [NSString stringWithFormat:@"%ld %@",contact.plan_zhuangbei_price,equipName];
            }

        }else
        {
            if(contact.plan_zhuangbei_price > 0)
            {
                equipBuyColor = [UIColor redColor];
                equipName = [NSString stringWithFormat:@"%ld %@",contact.plan_zhuangbei_price,equipName];
            }

        }
        
        //leftPriceTxt = [NSString stringWithFormat:@"%@",leftPriceTxt];
    }
    if([contact.owner_roleid intValue] == self.selectedRoleId)
    {
        centerDetailTxt = [NSString stringWithFormat:@"(同)%@",centerDetailTxt];
        numcolor = [UIColor redColor];
    }
    
    /**
    NSTimeInterval interval = [self timeIntervalWithCreateTime:detail.create_time andSellTime:detail.selling_time];
    if(interval < 60 * 60 * 24 )
    {
        earnColor = [UIColor orangeColor];
    }
    if(interval < 60){
        earnColor = [UIColor redColor];
    }
    **/
    
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
    NSInteger secNum = indexPath.section;
    NSInteger rowNum = indexPath.row;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    CBGEquipRoleState state = contact.latestEquipListStatus;
    
    //跳转条件  1详情页面时，非自己OrderSN   2非详情页面、仅历史库表取出数据
    BOOL detailSelect = (self.selectedOrderSN && ![self.selectedOrderSN isEqualToString:contact.game_ordersn]);
    BOOL nearSelect = NO;
//    (self.selectedRoleId == 0 && state == CBGEquipRoleState_PayFinish);
    
    if(detailSelect || nearSelect)
    {
        ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
        detail.cbgList = contact;
        [[self rootNavigationController] pushViewController:detail animated:YES];
    }
    
    
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
#pragma mark -
-(NSTimeInterval)timeIntervalWithCreateTime:(NSString *)create andSellTime:(NSString *)selltime
{
    NSDate * createDate = [NSDate fromString:create];
    NSDate * sellDate = [NSDate fromString:selltime];
    
    NSTimeInterval interval = [sellDate timeIntervalSinceDate:createDate];
    //    NSLog(@"interval %f",interval);
    return interval;
    
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
