//
//  VPNMainListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "VPNMainListVC.h"
#import "MSAlertController.h"
#import "VPNEditDataAddVC.h"
#import "VPNProxyModel.h"
#import "ZWGroupVPNTestReqModel.h"
#import "Equip_listModel.h"
#import "ZWDetailCheckManager.h"
#import "EquipDetailArrayRequestModel.h"
#import "SessionReqModel.h"
#import "ZWDetailVPNTestReqModel.h"
#import "ZALocationLocalModel.h"

@interface VPNMainListVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSOperationQueue * queue;
    BaseRequestModel * _detailModel;
}
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic, strong) NSArray * vpnArr;
@property (nonatomic, strong) NSArray * sessionArr;
//@property (nonatomic, strong) UIView * tipsView;

@property (nonatomic, strong) NSArray * subVpnArr;
@property (nonatomic, strong) NSArray * subSession;
@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic, assign) BOOL runUpdate;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL detailUpdate;

@property (nonatomic, strong) CBGListModel * tagModel;
@end

@implementation VPNMainListVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.startIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    self.viewTtle = @"代理列表";
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

//    ZALocalStateTotalModel * total =[ZALocalStateTotalModel currentLocalStateModel];
//    if(!total.proxyDicArr)
//    {
//        total.proxyDicArr = [VPNProxyModel localSaveProxyArray];
//        [total localSave];
//    }
    
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * arr = [manager localSaveEquipHistoryModelListMaxedEquipID];
    if([arr count] > 0){
        self.tagModel = [arr lastObject];
    }
    
    [self readFromLocalSaveDataArray];

    [self.view addSubview:self.tipsView];
    self.tipsView.hidden = YES;
    
//    [self submit];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}
-(void)readFromLocalSaveDataArray
{
    ZWProxyRefreshManager * manager =[ZWProxyRefreshManager sharedInstance];
    self.vpnArr = manager.proxyArrCache;
    [self.listTable reloadData];
    
    NSString * txt = [NSString stringWithFormat:@"vpn:%ld",[self.vpnArr count]];
    [self refreshVCTitleWithDetailText:txt];
}
-(void)refreshVCTitleWithDetailText:(NSString *)txt
{
    self.titleV.text = txt;
}
-(void)submit
{
//    ZACompleteNameAndPWDVC * pwd = [[ZACompleteNameAndPWDVC alloc] init];
//    [[self rootNavigationController] pushViewController:pwd animated:YES];
//    return;
    
    //提供选择
    NSString * log = [NSString stringWithFormat:@"对刷新数据筛选？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    action = [MSAlertAction actionWithTitle:@"手动添加" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
//                                 [weakSelf showForDetailHistory];
                                 VPNEditDataAddVC * list = [[VPNEditDataAddVC alloc] init];
                                 [[weakSelf rootNavigationController] pushViewController:list animated:YES];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"刷新VPN-列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf startWebDataRefreshWithSelectedProxyIdForDetailRefresh:NO];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"刷新VPN-详情" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startWebDataRefreshWithSelectedProxyIdForDetailRefresh:YES];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"保存VPN" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreLocalSaveDetailVPNDicList];
              }];
    [alertController addAction:action];

    
    action = [MSAlertAction actionWithTitle:@"读取全部VPN" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLoadTotalSaveVPNListWithTxtStart];
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
-(void)refreLocalSaveDetailVPNDicList
{
    
    ZWProxyRefreshManager * manager =[ZWProxyRefreshManager sharedInstance];
    manager.proxyArrCache = self.vpnArr;
    [manager localRefreshListFileWithLatestProxyList];
    
    NSString * txt = @"保存成功";
    [self refreshVCTitleWithDetailText:txt];
}
-(void)startRefreshDataModelRequest
{
    if(self.runUpdate)
    {//开启更新
        if(self.detailUpdate)
        {
            if(self.finished)
            {//上次已经结束
                self.finished = NO;
                [self startCheckAndRefreshDetailSubSessionArray];
            }
        }else{
            if(self.finished)
            {//上次已经结束
                self.finished = NO;
                [self startCheckAndRefreshSubSessionArray];
            }

        }
    }
}

-(void)startLoadTotalSaveVPNListWithTxtStart
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"vpnList.txt" ofType:nil];
    NSError * error = nil;
    NSStringEncoding encode = NSUTF8StringEncoding;
    NSString * localTxt = [NSString stringWithContentsOfFile:path
                                                usedEncoding:&encode
                                                       error:&error];
    NSArray * strArr = [localTxt componentsSeparatedByString:@"\n"];
    NSMutableDictionary * editDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0; index < [strArr count]; index ++)
    {
        NSString * part = [strArr objectAtIndex:index];
        NSArray * partArr = [part componentsSeparatedByString:@":"];
        
        VPNProxyModel * model = [[VPNProxyModel alloc] init];
        if([partArr count] >= 2)
        {
            model.idNum = [partArr firstObject];
            model.portNum = [partArr objectAtIndex:1];
            
            [editDic setObject:model forKey:model.idNum];
        }
    }
    
    NSArray * preArr = self.vpnArr;
    for (NSInteger index = 0; index < [preArr count]; index ++)
    {
        VPNProxyModel * model = [preArr objectAtIndex:index];
        [editDic setObject:model forKey:model.idNum];
    }
    
    NSArray * remove = [VPNProxyModel localRemoveProxyIpNumberArray];
    for (NSInteger index = 0;index < [remove count] ; index ++)
    {
        NSString * ipNum = [remove objectAtIndex:index];
        [editDic removeObjectForKey:ipNum];
    }
    
    NSArray * proxyArr = [editDic allValues];
//    NSArray * subProxy = [proxyArr subarrayWithRange:NSMakeRange(0, 177)];
//    proxyArr = subProxy;
    
    NSString * txt = [NSString stringWithFormat:@"vpn:%ld",[proxyArr count]];
    [self refreshVCTitleWithDetailText:txt];
    self.vpnArr = proxyArr;
    [self.listTable reloadData];
}



-(void)startWebDataRefreshWithSelectedProxyIdForDetailRefresh:(BOOL)detail
{
    if(detail && !self.tagModel)
    {
        [DZUtils noticeCustomerWithShowText:@"当前无特定历史数据"];
        return;
    }
    if(self.runUpdate)
    {
        [DZUtils noticeCustomerWithShowText:@"当前刷新未结束"];
        return;
    }
    //重置未未读
    NSMutableArray * arr = [NSMutableArray array];
    for (NSInteger index = 0;index < [self.vpnArr count] ;index ++ )
    {
        VPNProxyModel * proxy = [self.vpnArr objectAtIndex:index];
        proxy.checked = NO;
        
        SessionReqModel * req =[[SessionReqModel alloc] initWithProxyModel:proxy];
        [arr addObject:req];
    }
    
    self.sessionArr = arr;
    
    self.detailUpdate = detail;
    self.startIndex = 0;
    self.runUpdate = YES;
    self.finished = YES;
    
}
-(void)startCheckAndRefreshDetailSubSessionArray
{
    ZWDetailVPNTestReqModel * model = (ZWDetailVPNTestReqModel *)_detailModel;
    if(model.executing) return;
    
    NSArray * subSession = nil;
    NSArray * totalArr = self.sessionArr;
    if(self.startIndex == [totalArr count])
    {
        //结束、刷新
        [self refreshTotalMaxVpnListAndLocalSave];
        self.runUpdate = NO;
        return;
    }
    NSInteger sepNumber = 30;
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        sepNumber = 10;
    }
    
    NSRange range = NSMakeRange(self.startIndex, sepNumber);
    if(range.location + range.length > [totalArr count])
    {
        range.length = [totalArr count] - range.location;
    }
    
    NSString * txt = [NSString stringWithFormat:@"vpn%ld:%ld",range.location,range.length];
    [self refreshVCTitleWithDetailText:txt];
    
    
    subSession = [totalArr subarrayWithRange:range];
    self.subVpnArr = [self.vpnArr subarrayWithRange:range];
    
    [self startDetailRefreshDataModelRequestWithSubArr:subSession];
}


-(void)startCheckAndRefreshSubSessionArray
{
    ZWGroupVPNTestReqModel * model = (ZWGroupVPNTestReqModel *)_dpModel;
    if(model.executing) return;
    
    NSArray * subSession = nil;
    NSArray * totalArr = self.sessionArr;
    if(self.startIndex == [totalArr count])
    {
        //结束、刷新
        [self refreshTotalMaxVpnListAndLocalSave];
        self.runUpdate = NO;
        return;
    }
    NSInteger sepNumber = 100;
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        sepNumber = 30;
    }
    
    NSRange range = NSMakeRange(self.startIndex, sepNumber);
    if(range.location + range.length > [totalArr count])
    {
        range.length = [totalArr count] - range.location;
    }
    
    NSString * txt = [NSString stringWithFormat:@"vpn%ld:%ld",range.location,range.length];
    [self refreshVCTitleWithDetailText:txt];

    
    subSession = [totalArr subarrayWithRange:range];
    self.subVpnArr = [self.vpnArr subarrayWithRange:range];
    
    [self startRefreshDataModelRequestWithSubArr:subSession];
}
-(void)refreshTotalMaxVpnListAndLocalSave
{
    NSMutableArray * array = [NSMutableArray array];
    NSArray * vpn = self.vpnArr;
    for (NSInteger index = 0; index < [vpn count]; index ++)
    {
        NSInteger backIndex = index;
        VPNProxyModel * vpnModel = [vpn objectAtIndex:backIndex];
        if(vpnModel.success)
        {
            [array addObject:vpnModel];
        }
    }

    NSString * txt = [NSString stringWithFormat:@"vpn:%ld",[array count]];
    [self refreshVCTitleWithDetailText:txt];
    
    self.vpnArr = array;
    [self.listTable reloadData];
    
    [self refreLocalSaveDetailVPNDicList];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.vpnArr count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ZAPanicSortSchoolVC_Panic_Style";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSInteger index = indexPath.section;
    VPNProxyModel * vpnObj = [self.vpnArr objectAtIndex:index];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString * error = vpnObj.errored?@"error ":@"";
    if(!vpnObj.checked) error = @"";
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@  %@",vpnObj.idNum,vpnObj.portNum,error];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.section;
    VPNProxyModel * vpnObj = [self.vpnArr objectAtIndex:index];
    VPNEditDataAddVC * edit = [[VPNEditDataAddVC alloc] init];
    edit.dataObj = vpnObj;
    [[self rootNavigationController] pushViewController:edit animated:YES];
    
}

-(void)startRefreshDataModelRequestWithSubArr:(NSArray *)subArr
{

    NSLog(@"%s",__FUNCTION__);
    
    //    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    ZWGroupVPNTestReqModel * model = (ZWGroupVPNTestReqModel *)_dpModel;
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        //        model = [[EquipListRequestModel alloc] init];
        model = [[ZWGroupVPNTestReqModel alloc] init];
        [model addSignalResponder:self];
        //        model.saveCookie = YES;
        _dpModel = model;
    }
    
    model.pageNum = [subArr count];
    model.sessionArr = subArr;
    model.timerState = !model.timerState;
    [model sendRequest];
}
#pragma mark ZWGroupVPNTestReqModel
handleSignal( ZWGroupVPNTestReqModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( ZWGroupVPNTestReqModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showLoading];
}


handleSignal( ZWGroupVPNTestReqModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);
    
    ZWGroupVPNTestReqModel * model = (ZWGroupVPNTestReqModel *) _dpModel;
    NSArray * total  = model.listArray;
    NSArray * vpn = self.subVpnArr;
    
    //正常序列
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = index;
        VPNProxyModel * vpnModel = [vpn objectAtIndex:backIndex];
        vpnModel.checked = YES;
        
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            vpnModel.success = YES;
        }
    }
    
    self.startIndex += [vpn count];
//    [self performSelector:@selector(startCheckAndRefreshSubSessionArray)
//               withObject:nil
//               afterDelay:2];
    
    self.finished = YES;
}
-(void)startDetailRefreshDataModelRequestWithSubArr:(NSArray *)subArr
{
    NSMutableArray * details = [NSMutableArray array];
    NSString * detailUrl = self.tagModel.detailDataUrl;
    for (NSInteger index = 0;index < [subArr count] ;index ++ )
    {
        [details addObject:detailUrl];
    }
    
    NSLog(@"%s",__FUNCTION__);
    
    //    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    ZWDetailVPNTestReqModel * model = (ZWDetailVPNTestReqModel *)_detailModel;
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        //        model = [[EquipListRequestModel alloc] init];
        model = [[ZWDetailVPNTestReqModel alloc] init];
        [model addSignalResponder:self];
        //        model.saveCookie = YES;
        _detailModel = model;
    }
    
//    model.pageNum = [subArr count];
//    model.timerState = !model.timerState;
    
    model.sessionArr = subArr;
    [model refreshWebRequestWithArray:details];
    model.timerState = !model.timerState;
    
    [model sendRequest];
}
#pragma mark ZWDetailVPNTestReqModel
handleSignal( ZWDetailVPNTestReqModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( ZWDetailVPNTestReqModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showLoading];
}


handleSignal( ZWDetailVPNTestReqModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);
    
    ZWDetailVPNTestReqModel * model = (ZWDetailVPNTestReqModel *) _detailModel;
    NSArray * total  = model.listArray;
    NSArray * vpn = self.subVpnArr;
    
    //正常序列
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = index;
        VPNProxyModel * vpnModel = [vpn objectAtIndex:backIndex];
        vpnModel.checked = YES;
        
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            EquipModel * detail = [obj lastObject];
            if([detail.equipid integerValue] == self.tagModel.equip_id){
                vpnModel.success = YES;
            }
        }
    }
    
    self.startIndex += [vpn count];
    self.finished = YES;
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
