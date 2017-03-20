//
//  ZWRefreshListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWRefreshListController.h"
#import "RefreshListCell.h"
#import "ZWDataDetailModel.h"
#import "OpenTimesRefreshManager.h"
#import "RefreshDataModel.h"
#import "ZWHistoryListController.h"
#import "ZALocationLocalModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ZALocation.h"
#import "ZWDetailCheckManager.h"
#import "RefreshListDataManager.h"
#import "SFHFKeychainUtils.h"
#import "RefreshListDataManager.h"
#import "MSAlertController.h"
#import "Equip_listModel.h"
#import "RefreshEquipListDataManager.h"
#import "RefreshEquipDetailDataManager.h"
#import "CBGEquipDetailRequestManager.h"
#import "ZACBGDetailWebVC.h"
#import "RefreshEquipListAllDataManager.h"
#import "EquipListRequestModel.h"
#import "EquipDetailArrayRequestModel.h"
#define MonthTimeIntervalConstant 60*60*24*(30)
@interface ZWRefreshListController ()<UITableViewDataSource,UITableViewDelegate>
{
    BaseRequestModel * _detailModel;
    BOOL showTotal;
    
}
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,copy) NSArray * dataArr2;
@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) id latest;
@property (nonatomic,strong) UIView * tipsView;
@property (nonatomic,strong) NSArray * detailsArr;
@property (nonatomic,strong) NSArray * showArray;
@property (nonatomic,strong) NSArray * grayArray;
@end

@implementation ZWRefreshListController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
    }
    
    return self;
}
-(void)checkListInputForNoticeWithArray:(NSArray *)array
{
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        Equip_listModel * list = [array objectAtIndex:index];
        
        BOOL equipBuy = [list preBuyEquipStatusWithCurrentExtraEquip];
        if(equipBuy)
        {
            self.latest = list;
            self.latestContain = YES;
            [self startUserNotice];
        }

    }
    
}
//列表刷新，按照最新的返回数据,新增，还是替换
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  replace:(BOOL)replace
{
    if(!array || [array count] == 0) return;
    self.grayArray = array;
    
    if(replace)
    {
        [self checkListInputForNoticeWithArray:array];
    }
    
    NSMutableArray * refreshArray = [NSMutableArray array];
    [refreshArray addObjectsFromArray:self.showArray];
    
    if(replace)
    {
        
        NSInteger minNum = MIN([array count], [refreshArray count]);
        //替换
        for (NSInteger index = 0; index < minNum; index++)
        {
            id eveOjb = [array objectAtIndex:index];
            [refreshArray replaceObjectAtIndex:index withObject:eveOjb];
        }
    }else{
        //插入删除
        
        //最大
        NSInteger maxShowNum = RefreshListMaxShowNum;
        //当前
        NSInteger listNum = [self.showArray count];
        //新增
        NSInteger inputNum = [array count];
        
        if(inputNum >= maxShowNum)
        {
            [refreshArray removeAllObjects];
            [refreshArray addObjectsFromArray:array];
            [refreshArray removeObjectsInRange:NSMakeRange(maxShowNum,inputNum - maxShowNum)];
            
        }else{
            //需要移除的数量
            NSInteger removeNum = listNum - (maxShowNum - inputNum);
            
            if(removeNum > 0)
            {
                [refreshArray removeObjectsInRange:NSMakeRange(listNum - removeNum, removeNum)];
            }
            for (NSInteger index = 0;index < [array count]; index ++)
            {
                NSInteger backIndex = [array count] - index - 1;
                id eveOjb = [array objectAtIndex:backIndex];
                [refreshArray insertObject:eveOjb atIndex:0];
            }
        }
    }
    
    self.showArray = refreshArray;
    self.dataArr2 = refreshArray;
    [self.listTable reloadData];
}

- (void)viewDidLoad {
    NSDate * date = [NSDate date];
//    NSDate * date = [NSDate fromString:@"2016-02-05 17:54"];
    date = [date dateByAddingTimeInterval:MonthTimeIntervalConstant];
    NSString * select = [date toString:@"MM-dd"];
    showTotal = YES;
//    @"yyyy-MM-dd HH:mm:ss"
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = [NSString stringWithFormat:@"%ds",[total.refreshTime intValue]];
    
    self.viewTtle = [NSString stringWithFormat:@"当前(%@) %@",str,select];
    
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
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

    [self.view addSubview:self.tipsView];
    self.tipsView.hidden = YES;
    
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    if(check.refreshArray)
    {
        self.showArray = check.refreshArray;
        self.dataArr2 = check.refreshArray;
        [self.listTable reloadData];
    }

}
-(UIView *)tipsView{
    if(!_tipsView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"错误(刷新)";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshGesture:)];
        [aView addGestureRecognizer:tapGes];
        self.tipsView = aView;
    }
    return _tipsView;
}
-(void)tapedRefreshGesture:(id)sender
{
    [SFHFKeychainUtils exchangeLocalCreatedDeviceNum];

    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.randomAgent = [[DZUtils currentDeviceIdentifer] MD5String];
    [total localSave];
}

-(void)submit
{
    //提供选择
    NSString * log = [NSString stringWithFormat:@"对刷新数据筛选？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"查看历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf showForDetailHistory];
                             }];
    [alertController addAction:action];
    
    
//    action = [MSAlertAction actionWithTitle:@"展示全部售单" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  [weakSelf refreshForTotalRefreshList];
//              }];
//    [alertController addAction:action];
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}
-(void)refreshForLargeRefreshList
{
    //库表操作，进行数据替换
}
-(void)refreshForTotalRefreshList
{
    showTotal = YES;
    [self.listTable reloadData];
}
-(void)showForDetailHistory
{
    ZWHistoryListController * history = [[ZWHistoryListController alloc] init];
    [[self rootNavigationController] pushViewController:history animated:YES];
}

-(void)startLocationDataRequest
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
//    self.latest = [manager latestLocationModel];
    
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
//    NSLog(@"%s",__FUNCTION__);
    
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    _detailModel = nil;
    _dpModel = nil;
    [self startLocationDataRequest];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.refreshArray = self.showArray;
    
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
//    _detailModel = nil;
    
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
//    _dpModel = nil;

    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
}

-(void)startOpenTimesRefreshTimer
{
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 3;
//    if(total.refreshTime && [total.refreshTime intValue]>0){
//        time = [total.refreshTime intValue];
//    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        [weakSelf startRefreshDataModelRequest];
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)refreshCurrentTitleVLableWithTotal:(CGFloat)totalMoney andCountNum:(NSInteger)number
{
    NSString * total = [NSString stringWithFormat:@"总在售 %.1fW(%d)",totalMoney/10000,number];
    self.titleV.text = total;
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    


//    if(_dpModel) return;
    
    //数据上传，通知解除
//    RefreshEquipListDataManager * model = (RefreshEquipListDataManager *) _dpModel;
//    if(!model){
//        model = [[RefreshEquipListDataManager alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    
//    [model sendRequest];
    
    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailModel;
    if(detailArr.executing) return;
    
    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    
    if(!model){
        model = [[EquipListRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}
#pragma mark EquipListRequestModel
handleSignal( EquipListRequestModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( EquipListRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [self showLoading];
}


handleSignal( EquipListRequestModel, requestLoaded )
{
    [self hideLoading];
    //    refreshLatestTotalArray
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    EquipListRequestModel * model = (EquipListRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    //正常序列
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]])
        {
            [array addObjectsFromArray:obj];
        }
    }

    self.tipsView.hidden = [array count] != 0;
    
//    NSLog(@"EquipListRequestModel %lu %lu",(unsigned long)[array count],(unsigned long)[total count]);

    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailModel;
    if(detailArr.executing) return;
    
    //服务器数据排列顺序，最新出现的在最前面
    //服务器返回的列表数据，需要进行详情请求
    //详情请求需要检查，1、本地是否已有存储 2、是否存储于请求队列中
    //不检查本地存储、不检查队列是否存在，仅检查缓存数据
    ZWDetailCheckManager * checkManager = [ZWDetailCheckManager sharedInstance];
    NSArray * models = [checkManager latestRequestDetailModelsWithCurrentBackModelArray:array];
    if(!models || [models count] == 0)
    {
        //为空，标识没有新url
        return;
    }
    NSLog(@"EquipListRequestModel %lu %lu",(unsigned long)[array count],(unsigned long)[models count]);

    [self refreshTableViewWithInputLatestListArray:models replace:NO];
    
    NSArray * urls = checkManager.urlsArray;
    self.detailsArr = models;
    [self startEquipDetailAllRequestWithUrls:urls];
    
//    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
//    [dbManager localSaveEquipModelArray:models];//所有列表数据的缓存

}
-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _detailModel = model;
    }
    if(model.executing) return;
    
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
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
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
    
    NSLog(@"EquipDetailArrayRequestModel %lu",(unsigned long)[detailModels count]);
    
    NSMutableArray * soldArray = [NSMutableArray array];
    NSArray * models = self.detailsArr;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }
        Equip_listModel * obj = [models objectAtIndex:index];
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            obj.detaiModel = detailEve;
            obj.earnRate = detailEve.extraEarnRate;
            if(obj.earnRate > 0)
            {
                obj.earnPrice = [NSString stringWithFormat:@"%.0f",[detailEve.equipExtra.buyPrice floatValue] - [detailEve.price floatValue]/100.0 - [detailEve.equipExtra.buyPrice floatValue] * 0.05];
            }
        }
        
        NSInteger status = [obj.detaiModel.status intValue];
//        NSLog(@"status %lu",status);
        if(status == 4 || status == 6)
        {//已售出  暂不缓存被下单
            [soldArray addObject:obj];
        }else if(obj.earnRate > 5)
        {
            [soldArray addObject:obj];
        }
    }
    
    
    
    self.tipsView.hidden = [detailModels count] != 0;
    
    //刷新展示列表
    [self refreshTableViewWithInputLatestListArray:models replace:YES];

    //所有列表数据的缓存
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
//    [dbManager localSaveEquipModelArray:models];
    
    //筛选售出部分，进行其他库表缓存
    [dbManager localSaveSoldOutEquipModelArray:soldArray];
}

-(void)startRequestWithEquipModel:(Equip_listModel *)list
{
    CBGEquipDetailRequestManager * manager = [CBGEquipDetailRequestManager sharedInstance];
    [manager addDetailEquipRequestUrlWithEquipModel:list];
}


-(void)checkCurrentLatestContainState
{
    return;
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    ZWDataDetailModel * contact = [manager latestLocationModel];
//    self.latest = contact;
    
    if(!contact) return;
    
    __block BOOL contain = NO;
    NSMutableArray * array = [NSMutableArray arrayWithArray:self.dataArr];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel  * model = (ZWDataDetailModel *)obj;
        if([contact.product_id isEqualToString:model.product_id]){
            contain = YES;
            contact.left_money  = model.left_money;
        }
    }];

    NSIndexSet * set = [NSIndexSet indexSetWithIndex:0];
    [self.listTable reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)startUserNotice
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.isAlarm) return;
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state == UIApplicationStateBackground){
        [DZUtils localSoundTimeNotificationWithAfterSecond];
        return;
    }
    [self vibrate];
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(1320);
//    1327
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return [self.dataArr count];
    }else{
        return [self.dataArr2 count];
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
       contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
       contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier";
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
    UIColor * numcolor = [self.grayArray containsObject:contact]?[UIColor blackColor]:[UIColor lightGrayColor];
    
    cell.rateLbl.text = contact.price_desc;

    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = contact.desc_sumup;
    
//    NSString * rate = [contact.level stringValue];
    UIColor * color = [UIColor lightGrayColor];

    NSString * sellTxt = [NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
//    if([contact.annual_rate_str floatValue]>9)
//    cell.sellDateLbl.text = sellTxt;
    NSString * equipName = [NSString stringWithFormat:@"%@  -  %@",contact.equip_name,contact.subtitle];
    
    if(!contact)
    {
        sellTxt = nil;
        equipName = nil;
        cell.totalNumLbl.text = nil;
    }
    
    cell.latestMoneyLbl.textColor = color;
//    cell.timeLbl.text = sellTxt;
    
    //列表剩余时间
    NSString * dateStr = contact.sell_expire_time_desc;
//    @"dd天HH小时mm分钟"
    NSDateFormatter * format = [NSDate format:@"dd天HH小时mm分钟"];
    NSDate * date = [format dateFromString:dateStr];
    cell.timeLbl.text =  [date toString:@"HH:mm(余)"];
    
    //详情剩余时间
    EquipModel * detail = contact.detaiModel;
    cell.sellTimeLbl.text = detail.status_desc;
    UIColor * earnColor = [UIColor lightGrayColor];
    //用来标识账号是否最新一次销售
    if(detail)
    {
        cell.rateLbl.text = detail.last_price_desc;
        
        date = [NSDate fromString:detail.selling_time];
        cell.timeLbl.text =  [date toString:@"HH:mm"];
        
        NSTimeInterval interval = [self timeIntervalWithCreateTime:detail.create_time andSellTime:detail.selling_time];
        if(interval < 60 * 60 * 24 )
        {
            earnColor = [UIColor orangeColor];
        }
        if(interval < 60){
            earnColor = [UIColor redColor];
        }
        
    }
    
    UIColor * equipBuyColor = [UIColor lightGrayColor];
    UIColor * rateColor = [UIColor lightGrayColor];
    EquipExtraModel * extra = detail.equipExtra;
    if(extra)
    {
//        修炼、宝宝、法宝、祥瑞
        cell.totalNumLbl.text = [extra extraDes];
        
        UIColor * buyColor = [UIColor lightGrayColor];
        if([extra.buyPrice floatValue]>[detail.last_price_desc floatValue])
        {
            buyColor = [UIColor redColor];
        }
        cell.sellTimeLbl.textColor = buyColor;
        
        if([contact preBuyEquipStatusWithCurrentExtraEquip])
        {
            if(contact.earnPrice > 0)
            {
                sellTxt = [NSString stringWithFormat:@"%.0f %@",contact.earnRate,sellTxt];
                equipName = [NSString stringWithFormat:@"%@ %@",contact.earnPrice,equipName];
                rateColor = [UIColor orangeColor];

            }
        }
    }
    
    UIFont * font = cell.totalNumLbl.font;
    cell.latestMoneyLbl.text = sellTxt;
    cell.timeLbl.textColor = earnColor;
    cell.sellRateLbl.font = font;
    cell.latestMoneyLbl.font = font;
    cell.sellDateLbl.hidden = YES;
    cell.sellRateLbl.text = equipName;
    cell.sellRateLbl.textColor = equipBuyColor;
    cell.latestMoneyLbl.textColor = rateColor;
    
    cell.selected = NO;
    if(secNum == 0 )
    {
        color = [UIColor lightGrayColor];
        NSString * txt = nil;
//        NSDate * date = [NSDate dateWithTimeIntervalSince1970:[contact.selling_time floatValue]];
//        cell.sellTimeLbl.text = [date toString:@"MM-dd HH:mm"];
        
        NSInteger statusNum = [detail.status integerValue];
        txt = (statusNum!=4&&statusNum!=6)?@"尚有":@"无";
        color = self.latestContain?[UIColor redColor]:[UIColor lightGrayColor];

        cell.sellTimeLbl.text = txt;
        cell.sellTimeLbl.textColor = color;
        
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }

    
    return cell;
}
#pragma mark - 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(contact)
    {
        ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
        detail.listData = contact;
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
