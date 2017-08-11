//
//  ViewController.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "ViewController.h"
#import "NTConnectClient.h"
#import "NTBasicRequest.h"
#import "CBGTotalHistroySortVC.h"
#import "OLBasicListTableView.h"
#import "OLMainTopicListViewController.h"
#import "NTConnectSepcialClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSWebView.h"
#import "OLEGOCustomListTableView.h"
#import "OLBasicListTableView.h"
#import "ZALocalStateTotalModel.h"
#import "ZWRefreshListController.h"
#import "ZALocationLocalModel.h"
#import "ZWHistoryListController.h"
#import "CBGWebListRefreshVC.h"
#import "CBGWebListErrorCheckVC.h"
#import "CBGCopyUrlDetailCehckVC.h"
#import "CBGSettingURLEditVC.h"
#import "CBGMixedListCheckVC.h"
#import "CBGPlanSortHistoryVC.h"
#import "CBGDaysDetailSortHistoryVC.h"
#import "CBGCombinedHistoryHandleVC.h"
#import "CBGDetailWebView.h"
#import "CBGMaxHistoryListRefreshVC.h"
#import "CBGDepthStudyVC.h"
#import "CBGPlanListDetailCheckVC.h"
#import "CBGCombinedScrolledHandleVC.h"
#import "CBGLatestPlanBuyVC.h"
#import "CBGLatestDetailCheckVC.h"
#import "ZWPanicRefreshController.h"
#import "CBGPanicMaxedListRefreshVC.h"
#import "CBGPanicMixedNightListVC.h"
#import "ZAAutoBuySettingVC.h"
#import "ZWPanicMaxCombinedVC.h"
#import "CBGSpecialCompareListVC.h"
#import "CBGBargainListVC.h"
#import "ZWPanicMaxCombineUpdateVC.h"
#import "CBGMixedUpdateAndRefreshVC.h"
#import "ZWAutoRefreshListController.h"
#import "ZWServerRefreshListVC.h"
#import "CBGMixedServerMobileRefreshVC.h"
#import "ZWServerEquipListVC.h"
#import "ZWServerURLCheckVC.h"
#import "ZWServerRefreshAutoEquipVC.h"
#import "CBGMixedServerNormalRefreshVC.h"
#import "ZWLimitCircleRefreshVC.h"
#import "VPNMainListVC.h"
#import "CBGHistoryMianListVC.h"
#import "ZWDetailCheckManager.h"
#define BlueDebugAddNum 100

@interface ViewController ()
{
    OLEGOCustomListTableView * nameList;
    
    
    dispatch_queue_t queue1;
    dispatch_queue_t queue2;
}
@property (nonatomic,assign) NSInteger foo;
@property (nonatomic,assign) NSInteger bar;
@end

@implementation ViewController
@synthesize foo;
@synthesize bar;

-(NSString *)functionNamesForDetailFunctionStyle:(CBGDetailTestFunctionStyle)style
{
    NSString * name = @"未知";
    switch (style)
    {
        case CBGDetailTestFunctionStyle_Notice:
        {
            name = @"响铃(开)";
        }
            break;

        case CBGDetailTestFunctionStyle_CopyData:
        {
            name = @"read数据导入";
        }
            break;

        case CBGDetailTestFunctionStyle_MobileMax:
        {
            name = @"夜间模式";//适用于新数据上架频次较低，无人工查看的情况
        }
            break;

        case CBGDetailTestFunctionStyle_MobileMin:
        {
            name = @"mobile3页";
        }
            break;

        case CBGDetailTestFunctionStyle_WebRefresh:
        {
            name = @"Web刷新";
        }
            break;
        case CBGDetailTestFunctionStyle_MixedRefresh:
        {
            name = @"混合刷新";
        }
            break;
            
        case CBGDetailTestFunctionStyle_HistoryTotal:
        {
            name = @"全部在售";
        }
            break;
            
        case CBGDetailTestFunctionStyle_HistoryPart:
        {
            name = @"分段历史";
        }
            break;
            
        case CBGDetailTestFunctionStyle_HistoryMonthPlan:
        {
            name = @"本月估价";
        }
            break;
            
        case CBGDetailTestFunctionStyle_HistoryToday:
        {
            name = @"当日历史";
        }
            break;
        case CBGDetailTestFunctionStyle_HistoryUpdate:
        {
            name = @"更新历史";
        }
            break;

        case CBGDetailTestFunctionStyle_URLCheck:
        {
            name = @"链接估价";
        }
            break;

        case CBGDetailTestFunctionStyle_WEBCheck:
        {
            name = @"页面验证码";
        }
            break;
            
        case CBGDetailTestFunctionStyle_StudyMonth:
        {
            name = @"当月走势";
        }
            break;
            
        case CBGDetailTestFunctionStyle_RepeatList:
        {
            name = @"倒手分析";
        }
            break;
        case CBGDetailTestFunctionStyle_PayStyle:
        {
            name = @"支付(系统APP)";
        }
            break;

        case CBGDetailTestFunctionStyle_LatestPlan:
        {
            name = @"近期估价";
        }
            break;
        case CBGDetailTestFunctionStyle_EditCheck:
        {
            name = @"开发校验";
        }
            break;
        case CBGDetailTestFunctionStyle_PanicRefresh:
        {
            name = @"改价刷新";
        }
            break;
        case CBGDetailTestFunctionStyle_ClearCache:
        {
            name = @"清空缓存";
        }
            break;
        case CBGDetailTestFunctionStyle_PanicMixed:
        {
            name = @"改价混合";
        }
            break;
        case CBGDetailTestFunctionStyle_NightMixed:
        {
            name = @"夜间混合";
        }
            break;
        case CBGDetailTestFunctionStyle_AutoSetting:
        {
            name = @"自动购买";
        }
            break;
        case CBGDetailTestFunctionStyle_MaxPanic:
        {
            name = @"改价监听";
        }
            break;
        case CBGDetailTestFunctionStyle_SpecialList:
        {
            name = @"关注列表";
        }
            break;
        case CBGDetailTestFunctionStyle_BargainList:
        {
            name = @"还价列表";
        }
            break;
        case CBGDetailTestFunctionStyle_MobileAndUpdate:{
            name = @"附带更新";
        }
            break;
        case CBGDetailTestFunctionStyle_MobileLimit:{
            name = @"限制刷新";
        }
            break;
        case CBGDetailTestFunctionStyle_MobileServer:{
            name = @"单服mobile";
        }
            break;
        case CBGDetailTestFunctionStyle_MixedServer:{
            name = @"mobile混合";
        }
            break;
        case CBGDetailTestFunctionStyle_EquipServer:{
            name = @"递增刷新";
        }
            break;
        case CBGDetailTestFunctionStyle_EquipPage:{
            name = @"递增页面";
        }
            break;
        case CBGDetailTestFunctionStyle_MixedEquip:{
            name = @"递增混合";
        }
            break;
        case CBGDetailTestFunctionStyle_MobilePage:{
            name = @"mobile代理";
        }
            break;
        case CBGDetailTestFunctionStyle_VPNList:{
            name = @"代理列表";
        }
            break;
        case CBGDetailTestFunctionStyle_MainHistory:{
            name = @"历史主页";
        }
            break;
        case CBGDetailTestFunctionStyle_DetailProxy:{
            name = @"代理状态";
        }
            break;
            
        default:
            break;
    }
    return name;
}

- (void)viewDidLoad
{
    self.showLeftBtn = NO;
    self.viewTtle = @"测试";
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    ZWProxyRefreshManager * manager =[ZWProxyRefreshManager sharedInstance];
    manager.proxyArrCache = total.proxyModelArray;
    
    //增加监听
//    CBGDetailWebView * detail = [[CBGDetailWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self.view addSubview:detail];
    
    NSArray * testFuncArr = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_Notice],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_PayStyle],
                             
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_MobileMin],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_WebRefresh],

                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_MixedRefresh],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_SpecialList],

                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_EquipPage],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_VPNList],
                             
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_MobileAndUpdate],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_HistoryTotal],
                             
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_MainHistory],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_HistoryMonthPlan],

                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_MaxPanic],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_LatestPlan],
                             
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_AutoSetting],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_RepeatList],
                             
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_MobilePage],
                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_URLCheck],

                             [NSNumber numberWithInt:CBGDetailTestFunctionStyle_DetailProxy],
                             
                             nil];
    
    UIView * bgView = self.view;
    for(NSInteger index = 0 ;index < [testFuncArr count]; index ++)
    {
        NSNumber * num = [testFuncArr objectAtIndex:index];
        NSString * title = [self functionNamesForDetailFunctionStyle:[num integerValue]];
        UIButton * btn = [self customTestButtonForIndex: index andMoreTag:[num integerValue]];
        [btn setTitle:title forState:UIControlStateNormal];
        [bgView addSubview:btn];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    
    [self refreshNoticeBtnStateWithNoticeState:total.isAlarm];
    [self refreshPayStyleBtnStateWithStyle:!total.isNotSystemApp];
    [self refreshDetailRequestProxyStateWithProxyState:total.isProxy];
//    [self refreshLocalPanicBtnWithLatestNumber:total.refreshSchool];
}
//-(void)refreshLocalPanicBtnWithLatestNumber:(NSInteger)index
//{
//    NSInteger noticeTag = CBGDetailTestFunctionStyle_PanicRefresh;
//    UIButton * btn = (UIButton *)[self.view viewWithTag:BlueDebugAddNum + noticeTag];
//    
//    NSString * name = [CBGListModel schoolNameFromSchoolNumber:index];
//    if([name isEqualToString:@"门派"]){
//        name = @"全部";
//    }else
//    {
//        if([name length] >= 2){
//            name = [name substringToIndex:2];
//        }
//    }
//    
//    NSString * showState = [NSString stringWithFormat:@"改价:%@",name];
//    [btn setTitle:showState forState:UIControlStateNormal];
//}
-(void)refreshDetailRequestProxyStateWithProxyState:(BOOL)proxy
{
    NSInteger noticeTag = CBGDetailTestFunctionStyle_DetailProxy;
    UIButton * btn = (UIButton *)[self.view viewWithTag:BlueDebugAddNum + noticeTag];
    NSString * showState = proxy?@"代理(开)":@"代理(关)";
    [btn setTitle:showState forState:UIControlStateNormal];
}

-(void)refreshNoticeBtnStateWithNoticeState:(BOOL)notice
{
    NSInteger noticeTag = CBGDetailTestFunctionStyle_Notice;
    UIButton * btn = (UIButton *)[self.view viewWithTag:BlueDebugAddNum + noticeTag];
    NSString * showState = notice?@"响铃(开)":@"响铃(关)";
    [btn setTitle:showState forState:UIControlStateNormal];
}
-(void)refreshPayStyleBtnStateWithStyle:(BOOL)inCBG
{
    NSInteger noticeTag = CBGDetailTestFunctionStyle_PayStyle;
    UIButton * btn = (UIButton *)[self.view viewWithTag:BlueDebugAddNum + noticeTag];
    NSString * showState = inCBG?@"支付(CBG)":@"支付(WEB)";//密码支付
    [btn setTitle:showState forState:UIControlStateNormal];
}
-(void)refreshWriteInBtnForWriteFinish:(BOOL)finish
{
    NSInteger noticeTag = CBGDetailTestFunctionStyle_CopyData;
    UIButton * btn = (UIButton *)[self.view viewWithTag:BlueDebugAddNum + noticeTag];
    NSString * showState = finish?@"写入结束":@"read数据导入";
    [btn setTitle:showState forState:UIControlStateNormal];
}


-(void)exchangeDetailRequestProxyStateForBtnTaped
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.isProxy = !total.isProxy;
    [total localSave];
    
    [self refreshDetailRequestProxyStateWithProxyState:total.isProxy];
}
-(void)exchangeNoticeForNoticeBtnTaped
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.isAlarm = !total.isAlarm;
    [total localSave];
    [self refreshNoticeBtnStateWithNoticeState:total.isAlarm];
}

-(UIButton * )customTestButtonForIndex:(NSInteger)indexNum andMoreTag:(NSInteger)tag
{
    NSInteger lineNum = indexNum/2;
    NSInteger rowNum = indexNum%2;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag + BlueDebugAddNum;
    btn.frame = CGRectMake(0, 0,FLoatChange(120) ,FLoatChange(50));
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnTestButtonWithSender:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame) + FLoatChange(20) + btn.bounds.size.height/2.0;
    CGFloat sepHeight = FLoatChange(10);
    CGFloat startX = SCREEN_WIDTH / 2.0 /2.0;
    btn.center = CGPointMake( startX + rowNum * SCREEN_WIDTH / 2.0 ,startY + (sepHeight + btn.bounds.size.height) * lineNum);
    
    return btn;
}

-(void)tapedOnTestButtonWithSender:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger indexNum = btn.tag - BlueDebugAddNum;
    
    [self debugDetailTestWithIndexNum:indexNum andTitle:btn.titleLabel.text];
}
-(void)debugDetailTestWithIndexNum:(NSInteger)indexNum andTitle:(NSString *)title
{
    NSLog(@"%s %@",__FUNCTION__,title);
    [self refreshLastestServerNameDictionary];
    
    switch (indexNum)
    {
        case CBGDetailTestFunctionStyle_Notice:
        {
            [self exchangeNoticeForNoticeBtnTaped];
            
        }
            break;
        case CBGDetailTestFunctionStyle_DetailProxy:
        {
            [self exchangeDetailRequestProxyStateForBtnTaped];
            
        }
            break;

        case CBGDetailTestFunctionStyle_CopyData:
        {
            NSString * dbExchange = @"写入结束";
            NSInteger preNum = 0;
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray *   totalArr = [dbManager localSaveEquipHistoryModelListTotal];
            preNum = [totalArr count];
            dbExchange = [dbExchange stringByAppendingFormat:@"pre %ld",preNum];
            
            [dbManager localCopySoldOutDataToPartDataBase];
            totalArr = [dbManager localSaveEquipHistoryModelListTotal];
            dbExchange = [dbExchange stringByAppendingFormat:@"append %ld finished %ld ",[totalArr count] - preNum,[totalArr count]];
            {
                NSLog(@"localCopySoldOutDataToPartDataBase %@",dbExchange);
                //                    [self refreshWriteInBtnForWriteFinish:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [DZUtils noticeCustomerWithShowText:dbExchange];
                    self.titleV.text = [NSString stringWithFormat:@"%ld",[totalArr count] - preNum];
                });
            }
        }
            break;
        case CBGDetailTestFunctionStyle_MobileMax:
        {
            ZWRefreshListController * list = [[ZWRefreshListController alloc] init];
            list.maxRefresh = YES;
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MobileMin:
        {
            ZWRefreshListController * list = [[ZWRefreshListController alloc] init];
            list.onlyList = YES;
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_WebRefresh:
        {
            
            CBGWebListRefreshVC * list = [[CBGWebListRefreshVC alloc] init];
            list.endEanble = YES;
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MixedRefresh:
        {
            
            CBGMixedListCheckVC * copy = [[CBGMixedListCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:copy animated:YES];
            
        }
            break;
            
        case CBGDetailTestFunctionStyle_HistoryTotal:
        {
            CBGTotalHistroySortVC * history = [[CBGTotalHistroySortVC alloc] init];
            [[self rootNavigationController] pushViewController:history animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_HistoryUpdate:{
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotal];
            
            CBGMaxHistoryListRefreshVC * list = [[CBGMaxHistoryListRefreshVC alloc] init];
            list.startArr = soldout;
            [[self rootNavigationController] pushViewController:list animated:YES];
            
        }
            break;
        case CBGDetailTestFunctionStyle_HistoryMonthPlan:
        {
            NSString * todayDate = [NSDate unixDate];
            
            if(todayDate)
            {
                todayDate = [todayDate substringToIndex:[@"2017-03" length]];
            }
            
            CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
            combine.selectedDate = todayDate;
            combine.showStyle = CBGCombinedHandleVCStyle_Plan;
            
            [[self rootNavigationController] pushViewController:combine animated:YES];

        }
            break;
        case CBGDetailTestFunctionStyle_HistoryToday:
        {
            NSString * todayDate = [NSDate unixDate];
            
            if(todayDate)
            {
                todayDate = [todayDate substringToIndex:[@"2017-03-29" length]];
            }
            
            CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
            combine.selectedDate = todayDate;
            combine.showStyle = CBGCombinedHandleVCStyle_Plan;
            
            [[self rootNavigationController] pushViewController:combine animated:YES];
        }
            break;

        case CBGDetailTestFunctionStyle_HistoryPart:{
            CBGDaysDetailSortHistoryVC * plan = [[CBGDaysDetailSortHistoryVC alloc] init];
            [[self rootNavigationController] pushViewController:plan animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_URLCheck:
        {
            CBGCopyUrlDetailCehckVC * copy = [[CBGCopyUrlDetailCehckVC alloc] init];
            [[self rootNavigationController] pushViewController:copy animated:YES];
            
            
        }
            break;

        case CBGDetailTestFunctionStyle_WEBCheck:{
//            CBGWebListErrorCheckVC * list = [[CBGWebListErrorCheckVC alloc] init];
            ZWServerURLCheckVC * list = [[ZWServerURLCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
            
        }
            break;
        case CBGDetailTestFunctionStyle_StudyMonth:{
            NSString * todayDate = [NSDate unixDate];
            NSDate * now = [NSDate date];
            if(now.day > 15)
            {
                todayDate = [todayDate substringToIndex:[@"2017-03" length]];
            }else
            {//年度
                todayDate = [todayDate substringToIndex:[@"2017" length]];
            }
            
            CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
            combine.selectedDate = todayDate;
            combine.showStyle = CBGCombinedHandleVCStyle_Study;
            
            [[self rootNavigationController] pushViewController:combine animated:YES];
            
        }
            break;
        case CBGDetailTestFunctionStyle_RepeatList:{
            
            CBGPlanListDetailCheckVC * combine = [[CBGPlanListDetailCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:combine animated:YES];
            
        }
            break;

        case CBGDetailTestFunctionStyle_LatestPlan:{
            
            CBGLatestPlanBuyVC * combine = [[CBGLatestPlanBuyVC alloc] init];
            [[self rootNavigationController] pushViewController:combine animated:YES];
            
        }
            break;
        case CBGDetailTestFunctionStyle_PayStyle:
        {
            //当大于20 价格小于1.3W 使用密码支付
            ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
            total.isNotSystemApp = !total.isNotSystemApp;
            [total localSave];
            
            
            [self refreshPayStyleBtnStateWithStyle:!total.isNotSystemApp];
            
        }
            break;
        case CBGDetailTestFunctionStyle_EditCheck:
        {
            CBGLatestDetailCheckVC * latest = [[CBGLatestDetailCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_PanicRefresh:
        {
            ZWPanicRefreshController * latest = [[ZWPanicRefreshController alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_ClearCache:
        {
            [DZUtils noticeCustomerWithShowText:@"清空缓存"];
        }
            break;

        case CBGDetailTestFunctionStyle_PanicMixed:
        {
            CBGPanicMaxedListRefreshVC * latest = [[CBGPanicMaxedListRefreshVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
            
        }
            break;
        case CBGDetailTestFunctionStyle_NightMixed:
        {
            CBGPanicMixedNightListVC * latest = [[CBGPanicMixedNightListVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
            
        }
            break;
        case CBGDetailTestFunctionStyle_AutoSetting:
        {
            ZAAutoBuySettingVC * latest = [[ZAAutoBuySettingVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MaxPanic:
        {
            ZWPanicMaxCombineUpdateVC * latest = [[ZWPanicMaxCombineUpdateVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_SpecialList:
        {
            CBGSpecialCompareListVC * latest = [[CBGSpecialCompareListVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
        }
            break;

        case CBGDetailTestFunctionStyle_BargainList:
        {
            CBGBargainListVC * latest = [[CBGBargainListVC alloc] init];
//            ZWPanicMaxCombinedVC * latest = [[ZWPanicMaxCombinedVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MobileAndUpdate:{
            CBGMixedUpdateAndRefreshVC * latest = [[CBGMixedUpdateAndRefreshVC alloc] init];
            [[self rootNavigationController] pushViewController:latest animated:YES];

        }
            break;
        case CBGDetailTestFunctionStyle_MobileLimit:{
            ZWAutoRefreshListController * list = [[ZWAutoRefreshListController alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MobileServer:
        {
            ZWServerRefreshListVC * list = [[ZWServerRefreshListVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MixedServer:{
            CBGMixedServerMobileRefreshVC * list = [[CBGMixedServerMobileRefreshVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_EquipServer:{
            ZWServerEquipListVC * list = [[ZWServerEquipListVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];

        }
            break;
        case CBGDetailTestFunctionStyle_EquipPage:{
            ZWServerRefreshAutoEquipVC * list = [[ZWServerRefreshAutoEquipVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MixedEquip:{
            CBGMixedServerNormalRefreshVC * list = [[CBGMixedServerNormalRefreshVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
          
        }
            break;
        case CBGDetailTestFunctionStyle_MobilePage:{
            ZWLimitCircleRefreshVC * list = [[ZWLimitCircleRefreshVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];

        }
            break;
        case CBGDetailTestFunctionStyle_VPNList:{
            VPNMainListVC * list = [[VPNMainListVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGDetailTestFunctionStyle_MainHistory:{
            CBGHistoryMianListVC * list = [[CBGHistoryMianListVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;

            
    }
}
-(void)refreshLastestServerNameDictionary
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * dbArray = [manager localServerNameAndIDTotalDictionaryArray];
    
    NSMutableDictionary  * nameDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0;index < [dbArray count] ;index ++ ) {
        NSDictionary * eveDic = [dbArray objectAtIndex:index];
        NSNumber * keyNum = [eveDic objectForKey:@"SERVER_ID"];
        NSString * name = [eveDic objectForKey:@"SERVER_NAME"];
        
        [nameDic setObject:name forKey:keyNum];
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.serverNameDic = nameDic;
    [total localSave];
}

-(void)tapedOnTestBtn:(id)sender
{
//    nameList.loadMoreType++;
//    
//    return;
//    [nameList reloadData];

    ///异步打印
//    dispatch_async(queue2,^(){
//        [[self class] showLogStart:100];
//    });
//    
//    NSLog(@"dispatch_async finish");
//    
//     
//    dispatch_sync(queue2,^(){
//        [[self class] showLogStart:20000];
//    });
//    
//    NSLog(@"dispatch_sync finish");
//    
//    
//    return;
//    NSURLResponse *
//    [[NSURLCache sharedURLCache] setMemoryCapacity:1*1024*1024];
//
//    
//    NSString * str = @"http://olshow.onlylady.com/index.php?c=LookAPI&a=Default&rd=20&pm=2&se=0&sre=1&sud=12428402&ud=12428402";
//    static int num = 0;
//    num++;
//    if (num%2==0)
//    {
//        
//        NTBasicRequest * request = [[NTBasicRequest alloc] init];
//        request.requestUrlStr = str;
//        
//        [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request andEndBlock:^(id responseData, NSError *error) {
//            NSLog(@"sharedNTConnectClient cache %@",responseData);
//        }];
//        return;
//    }
//    
//    str = @"http://olshow.onlylady.com/index.php?c=LookAPI&a=Default&rd=20&pm=1&se=0&sre=1&sud=12428402&ud=12428402";
//    NTBasicRequest * request2 = [[NTBasicRequest alloc] init];
//    request2.requestUrlStr = str;
//    
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request2 andEndBlock:^(id responseData, NSError *error) {
//        NSLog(@"sharedNTConnectClient first %@",responseData);
//    }];
////    return;
//    str = @"http://olshow.onlylady.com/index.php?c=LookAPI&a=Default&rd=20&pm=2&se=0&sre=1&sud=12428402&ud=12428402";
//    request2.requestUrlStr = str;
//    
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request2 andEndBlock:^(id responseData, NSError *error) {
//        NSLog(@"sharedNTConnectClient second %@",responseData);
//    }];
//    return;
//    OLMainTopicListViewController * ol = [[OLMainTopicListViewController alloc] init];
//    [self presentViewController:ol animated:YES completion:nil];
    
//    OLBasicRequest * aRequest = [[OLBasicRequest alloc] initWithRequestIdStr:@"200"];
//    aRequest.requestUrlStr = @"http://www.456ri.com/html/article/index14923.html";
//    [[NTConnectSepcialClient sharedNTConnectSepcialClient] specialRequestWithBasicRequest:aRequest
//                                                                              andEndBlock:^(id responseData, NSError *error) {
//                                                                                  NSLog(@"%@",responseData);
//                                                                              }];


    
//    nameList.loadMoreType = nameList.loadMoreType+1;
//    [nameList startLoadMoredDataInForcedWithViewAnimated:YES];
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString * urlstr = @"http://www.456ri.com/html/article/index14923.html";
    
    JSWebView * aWeb = [[JSWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:aWeb];
    aWeb.endJSOperationBlcok = ^(NSArray *arr){
        
    };
    
    [manager GET:urlstr
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *textFile = operation.responseString;
             if (!textFile)
             {
                 NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                 textFile  = [[NSString alloc] initWithData:responseObject encoding:enc];
             }
             
             NSLog(@"responseObject%@ %@",operation.responseString,textFile);
             [aWeb loadWebHtml:textFile];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"responseObject%@",error);
         }];
    

    
    return;
//    //普通请求
//    OLConfigRequest * arequest = [[OLConfigRequest alloc] init];
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:arequest
//                                                         andEndBlock:^(id responseData, NSError *error) {
//                                                             NSLog(@"%@ %@",responseData,error);
//                                                         }];
//    
//    
//    
//    
//    
//    //需要结果处理的大量数据请求
//    OLProtocolRequest * request = [[OLProtocolRequest alloc] init];
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request
//                                                         andEndBlock:^(id responseData, NSError *error) {
//                                                             
//                                                             
//                                                             
//                                                         }];
//    
//    
//    [[NTConnectClient sharedNTConnectClient] requestModelDataArrayWithBasicRequest:request
//                                                                checkResponseBlock:^NSArray *(id responseData) {
//                                                                    NSDictionary * dic = [responseData valueForKey:@"de"];
//
//                                                                    NSLog(@"allKeys %@",[dic allKeys]);
//                                                                    return [dic allKeys];
//                                                                } andEndBlock:^(BOOL netWorkType, NSArray *array) {
//                                                                    NSLog(@"netWorkType %d %@",netWorkType,array);
//                                                                }];
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
     NSLog(@"observeValueForKeyPathobserveValueForKeyPath ");
//    NSLog(@"%@ %@ %@",keyPath,object,nameList.dataArr);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
