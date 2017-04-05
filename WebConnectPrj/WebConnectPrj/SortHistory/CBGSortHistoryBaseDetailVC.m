//
//  CBGSortHistoryBaseDetailVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseDetailVC.h"
#import "EquipDetailArrayRequestModel.h"
#import "CBGListModel.h"
#import "EquipModel.h"
#import "ZALocationLocalModel.h"
#import "ZACBGDetailWebVC.h"
#import "RefreshListCell.h"
#import "CBGMaxHistoryListRefreshVC.h"
@interface CBGSortHistoryBaseDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
}
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic, strong) NSArray * requestModels;
@property (nonatomic, strong) UILabel * numLbl;
@end

@implementation CBGSortHistoryBaseDetailVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.viewTtle = @"历史";
        self.rightTitle = @"筛选";
        self.showRightBtn = NO;
    }
    return self;
}


- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    self.listTable = table;
    [self.view addSubview:table];
    
    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UILabel * aLbl = nil;
    CGFloat btnStartY = aHeight;
    
    NSString * name = @"数量";
    aLbl = [[UILabel alloc] init];
    aLbl.text = name;
    aLbl.frame = CGRectMake(1 * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
    aLbl.textColor = [UIColor redColor];
    aLbl.backgroundColor = [UIColor clearColor];
    [bgView addSubview:aLbl];
    aLbl.textAlignment = NSTextAlignmentCenter;
    self.numLbl = aLbl;
    aLbl.hidden = YES;
}
-(void)refreshNumberLblWithLatestNum:(NSInteger)number
{
    self.numLbl.hidden = NO;
    self.numLbl.text = [NSString stringWithFormat:@"数量:%ld",number];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailModel;
    [model cancel];
    [model removeSignalResponder:self];
    _detailModel = nil;
}
#pragma mark - DetailArrayRequest
//刷新最新的数据，补全是否售出   更新主表
-(void)startLatestDetailListRequestForShowedCBGListArr:(NSArray *)array
{
    //启动批量网络请求，刷新回传数据，补充库表
    //缓存当前数据，触发对应请求
    if([array count] > 300)
    {
        CBGMaxHistoryListRefreshVC * max  = [[CBGMaxHistoryListRefreshVC alloc] init];
        max.startArr = [NSArray arrayWithArray:array];
        [[self rootNavigationController] pushViewController:max animated:YES];
        return;
    }
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailModel;
    if(model.executing)
    {
        return;
    }
    NSArray * models = [NSArray arrayWithArray:array];
    self.requestModels = models;
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0;index <[models count] ;index ++) {
        CBGListModel * eveModel = [models objectAtIndex:index];
        NSString * eveUrl = eveModel.detailDataUrl;
        [urls addObject:eveUrl];
    }
    
    [self startEquipDetailAllRequestWithUrls:urls];
}
-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _detailModel = model;
    }
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}

#pragma mark EquipDetailArrayRequestModel
handleSignal( EquipDetailArrayRequestModel, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
    [self showLoading];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //进行存储操作、展示
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            [detailModels addObject:[NSNull null]];
        }
    }
    
    
    NSMutableArray * updateModels = [NSMutableArray array];
    NSMutableArray * errorModels = [NSMutableArray array];
    NSArray * models = self.requestModels;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }
        CBGListModel * obj = [models objectAtIndex:index];
        obj.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            [obj refreshCBGListDataModelWithDetaiEquipModel:detailEve];
            [updateModels addObject:obj];
        }else{
            [errorModels addObject:obj];
        }
    }
    
    NSLog(@"历史列表刷新 %lu error%ld",(unsigned long)[updateModels count],[errorModels count]);
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    [manager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateModels];
    
    [self finishDetailListRequestWithFinishedCBGListArray:updateModels];
    [self finishDetailListRequestWithErrorCBGListArray:errorModels];
}

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    
}
-(void)finishDetailListRequestWithErrorCBGListArray:(NSArray *)array
{
    
}
#pragma mark -
#pragma mark HistoryTableDelegate
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    CBGListModel * contact = [self.dataArr objectAtIndex:secNum];
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
            
            //时差秒数
            NSTimeInterval minuteNum = count/60;
            int minute = ((int)minuteNum)%60;
            NSTimeInterval hour = minuteNum/60;
            if(hour > 1){
                rightStatusTxt =  [NSString stringWithFormat:@"隔%02d:%02d",(int)hour,minute];
            }else{
                rightStatusTxt =  [NSString stringWithFormat:@"隔%02d分",minute];
            }

        }else{
            startDate = [NSDate fromString:finishTime];
            rightStatusTxt =  [startDate toString:@"dd HH:mm"];

        }
        
        //计算时间差
        
        
        
        {
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
        if(rate > 0)
        {
            equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
            equipName = [NSString stringWithFormat:@"%ld%% %@",rate,equipName];
            equipBuyColor = [UIColor greenColor];
        }
        //leftPriceTxt = [NSString stringWithFormat:@"%@",leftPriceTxt];
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
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    CBGListModel * contact = [self.dataArr objectAtIndex:secNum];
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
