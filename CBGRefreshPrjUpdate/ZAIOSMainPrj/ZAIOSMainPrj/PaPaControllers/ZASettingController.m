//
//  ZASettingController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZASettingController.h"
#import "SharePopupView.h"
#import "QQSpaceShare.h"
#import "WeixinShare.h"
#import "ZAContactListController.h"
#import "ZAPWDEditController.h"
#import "ZANameEditController.h"
#import "NSString+EmojiString.h"
#import "SFHFKeychainUtils.h"
#import "MSAlertController.h"
#import "FeedBackViewController.h"
#import "BlockActionSheet.h"
#import "ZAIntroduceController.h"
#import "FeedBackLeanViewcontroller.h"
#import "ZWRateEditController.h"
#import "ZALocationLocalModel.h"
#import "ZWDetailBuyVC.h"

@interface ZASettingController ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat leftWidth;
    
    UILabel * nameLbl;
    UILabel * telLbl;
}
@property (nonatomic,strong) UIAlertView * watchAlert;
@property (nonatomic, assign) SharePopupViewEventType shareType;
@property (nonatomic,strong) NSArray * dataArr;
@property (nonatomic,assign) BOOL hideSharing;//未安装QQ、微信，则为YES
@property (nonatomic,strong) UITableView * settingTable;
@property (nonatomic,strong) UIView * redCircle1;
@end

@implementation ZASettingController

-(BOOL)appInstalledStateForListShow
{//当两者均为安装，则隐藏
    BOOL QQHide = ![TencentOAuth iphoneQQInstalled];
    BOOL WXHide = ![WXApi isWXAppInstalled];
    return QQHide && WXHide;
}
-(UIView *)redCircle1
{
    if(!_redCircle1)
    {
        CGFloat redWidth = FLoatChange(8);
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redWidth, redWidth)];
        aView.backgroundColor = [DZUtils colorWithHex:@"FF4D4D"];
        [aView.layer setCornerRadius:redWidth/2.0];
        self.redCircle1 = aView;
    }
    return _redCircle1;
}
-(void)appendContactRedNotificationObserve
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRedCircleForNotification:)
                                                 name:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                               object:nil];
}
-(void)refreshRedCircleForNotification:(NSNotification *)noti
{
    //不使用之前数据
    NSNumber * num = noti.object;
    BOOL showState = [num boolValue];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    showState = [ContactsModel contactNeedRedStateForContactListArr:total.contacts];
    
    
    self.redCircle1.hidden = !showState;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];//隐藏顶部
    self.titleBar.hidden = YES;  //隐藏文本
    

    self.dataArr = @[@"当前利率设置",@"库表合并",@"分享给好友",@"刷新时间",@"给我评分",@"用户指南",@"退出登录",@"调研功能"];
    self.hideSharing = [self appInstalledStateForListShow];
    
    
    //方便cell自定义使用
    CGFloat normalLeft  = self.viewDeckController.leftViewSize;
    CGFloat preCenterX = normalLeft + SCREEN_WIDTH/2.0;
    CGFloat minScale = 0.8;
    CGFloat currentLeftX = preCenterX - minScale * (SCREEN_WIDTH)/2.0;
    
    leftWidth = currentLeftX ;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"setting_bg"];
    [self.view addSubview:img];
    
    rect.size.width = leftWidth;
    rect.origin.y = kTop;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:table];
    table.separatorColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.rowHeight = 52.0f;
    self.settingTable = table;
    
    self.view.backgroundColor = RGB(26, 33, 44);
    
    //头部
    UIView * header = [self tableviewHeaderView];
    table.tableHeaderView = header;
    
    
    //底部
//    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, table.bounds.size.width, 1)];
//    lineView.backgroundColor = [UIColor whiteColor];
//    table.tableFooterView = lineView;
    

    
    
    CGFloat bottomWidth = currentLeftX;
    
    CGFloat bottomHeight = FLoatChange(165);
    CGFloat btnHeight = FLoatChange(45);
    CGFloat startY = FLoatChange(20);
    UIFont * font = [UIFont boldSystemFontOfSize:FLoatChange(12)];
    rect = table.bounds;
    rect.size.height = bottomHeight;
    rect.size.width = bottomWidth;
    
    rect.origin.y = SCREEN_HEIGHT - bottomHeight;
    UIView * bottomView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = [UIColor clearColor];
    
    
    CGFloat lblHeight = FLoatChange(20);
    rect = bottomView.bounds;
    rect.size.height = lblHeight;
    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
    [bottomView addSubview:lbl];
    lbl.textColor = Setting_Btn_Dark_Color;
    lbl.font = font;
    lbl.textAlignment = NSTextAlignmentCenter;
    NSString * testName = @"测试";
    testName = @"";
#ifdef USERDEFAULT_Created_DeviceNum_Show
    testName = @"调研测试";
#endif
    
    
    
    
    NSString * version = [DZUtils currentAppBundleShortVersion];
#ifdef  USERDEFAULT_DEBUG_FOR_COMPANY
    version = [DZUtils currentAppBundleVersion];
#endif
    
    NSString * txt = [NSString stringWithFormat:@"怕怕 %@v%@",testName,version];
    lbl.text = txt;
    lbl.center = CGPointMake(bottomWidth/2.0, startY + lbl.bounds.size.height/2.0);
    
    
    startY = lbl.center.y;
    lbl = [[UILabel alloc] initWithFrame:rect];
    [bottomView addSubview:lbl];
    lbl.textColor = Setting_Btn_Dark_Color;
    lbl.font = font;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = @"客服电话: 010-89178958";
    lbl.center = CGPointMake(bottomWidth/2.0, startY + lbl.bounds.size.height);

    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    rect.size.height = btnHeight;
    rect.size.width = 0.8 * bottomWidth;
    btn.frame = rect;
    [bottomView addSubview:btn];
    [btn setBackgroundColor:Setting_Btn_Dark_Color];
    [btn addTarget:self action:@selector(tapedOnLogOutBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"库表替换" forState:UIControlStateNormal];
    btn.center = CGPointMake(bottomWidth/2.0, bottomHeight - FLoatChange(40) - btnHeight/2.0);
    [btn.layer setCornerRadius:5];
    [btn refreshZASelectedButtonWithCurrentBGColor:btn.backgroundColor];
    
    
    CGFloat redWidth = self.redCircle1.bounds.size.width;
    UITableViewCell * cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    rect = cell.bounds;
    CGPoint pt = CGPointMake(2.9/5.0*leftWidth,FLoatChange(50)/2.0 - redWidth);
    [cell addSubview:self.redCircle1];
    self.redCircle1.center = pt;
    
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    BOOL show = model.contactRed_Need_Show;
    self.redCircle1.hidden = !show;
    
    [self appendContactRedNotificationObserve];
    
    
}
-(void)showDialogForNoWatchStartedError
{
    if(!self.watchAlert)
    {
        NSString * log = @"您已经在Apple watch上开启防护，为了保证您的安全，请在结束防护后再退出登录。";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
        self.watchAlert = alert;
    }
    [self.watchAlert show];
    //    您还没有设置紧急联系人，无法开启防护哦~
}
-(void)insertPreDataBaseIntoLatestDatabase
{
    //将之前的数据，插入最新数据库
    //total part   将part内的数据，写入total
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager localCopySoldOutDataToPartDataBase];
    
    
}

-(void)tapedOnLogOutBtn:(id)sender
{
//    [SFHFKeychainUtils exchangeLocalCreatedDeviceNum];
//    
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    total.randomAgent = [[DZUtils currentDeviceIdentifer] MD5String];
//    [total localSave];

    NSString * path = [[NSBundle mainBundle] pathForResource:@"zadatabase.db" ofType:nil];
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager exchangeLocalDBWithCurrentDBPath:path];
    
    return;
    if(![DZUtils localWarningStateCheckIsNone])
    {
        [self showDialogForNoWatchStartedError];
        return;
    }
    
    [self tapedOnLogoutForCurrentAPP];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    PaPaUserInfoModel * model = total.userInfo;
    
    telLbl.text = [model.mobile telNumHidePartString];
    nameLbl.text = model.username;
    
    //状态检查更新
    BOOL state = [self appInstalledStateForListShow];
    if(state != self.hideSharing)
    {
        self.hideSharing = state;
        [self.settingTable reloadData];
    }
    
}
-(void)tapedOnEditUserInfoBtn:(id)sender
{
    static NSInteger nameEdit = 0;
    nameEdit++;
    
    ZANameEditController * edit = [[ZANameEditController alloc] init];
    edit.local1 = (nameEdit%2==0);
    [[self rootNavigationController] pushViewController:edit animated:YES];
//    [self.viewDeckController closeLeftViewAnimated:YES];
}
-(void)clearLocalCurrentLoginSaveData
{
    [ZALocalStateTotalModel clearLocalStateForLogout];
}

-(void)clearLocalSaveData
{
    //清空还原本地数据
    //userdefault
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    [stand removeObjectForKey:USERDEFAULT_UserInfo_Model]; //用户数据
    [stand removeObjectForKey:USERDEFAULT_UserInfo_Contact_List]; //联系人列表
    [stand removeObjectForKey:USERDEFAULT_WarnTiming_Model]; //联系人列表    
    [stand removeObjectForKey:USERDEFAULT_Warning_Model_NeedRestart]; //是否需要检测
    [stand removeObjectForKey:USERDEFAULT_NAME_START_PASSWORD]; //密码状态
    [stand removeObjectForKey:USERDEFAULT_NAME_START_TIMEEND_TIME]; //到达时间
    [stand removeObjectForKey:USERDEFAULT_NAME_START_TIMETOTAL_TIME]; //结束时间
    [stand synchronize];
    
    
    //钥匙串数据
    [DZUtils localSaveObject:nil withKeyStr:USERDEFAULT_StartInfo_Finished];
    [DZUtils localSaveObject:nil withKeyStr:USERDEFAULT_CoverView_Tips_Main_Show];
    [DZUtils localSaveObject:nil withKeyStr:USERDEFAULT_CoverView_Tips_Start_Show];
    [DZUtils localSaveObject:nil withKeyStr:USERDEFAULT_PASSWORD_LOCAL];
    
    [SFHFKeychainUtils exchangeLocalCreatedDeviceNum];//更换标识码
}
-(void)tapedOnLogoutForCurrentAPP
{
    NSLog(@"%s",__FUNCTION__);
    
    NSString * log = [NSString stringWithFormat:@"确定要退出当前账号？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"确定" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action)
                             {
                                 [weakSelf startWebRequestForLogout];
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
-(void)tapedOnLogoutForAPPTest
{
    NSString * log = [NSString stringWithFormat:@"确定要重新启用调研模式？确定后需要重新打开应用"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"确定" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action)
                             {
                                 [weakSelf clearLocalSaveData];
                                 exit(0);
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

-(UIView *)tableviewHeaderView
{
    CGFloat topHeight = FLoatChange(105);
    CGFloat sepX = FLoatChange(20);
    CGRect rect = CGRectMake(0, 0, leftWidth, topHeight);
    UIView * bgView = [[UIView alloc] initWithFrame:rect];

    CGSize size = CGSizeMake(FLoatChange(50), FLoatChange(50));
    UIButton * editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(0, 0, size.width, size.height);
    [editBtn addTarget:self action:@selector(tapedOnEditUserInfoBtn:) forControlEvents:UIControlEventTouchUpInside];
//    editBtn.backgroundColor = [UIColor redColor];
    [editBtn setImage:[UIImage imageNamed:@"left_edit"]  forState:UIControlStateNormal];
    [bgView addSubview:editBtn];
    editBtn.hidden = YES;
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 5, 5, 5);
    [editBtn setImageEdgeInsets:inset];
    editBtn.center = CGPointMake(leftWidth - sepX - size.width/2.0, topHeight / 2.0);
    
    rect = bgView.bounds;
    rect.origin.x = sepX ;
    rect.size.height = topHeight / 2.0;
    rect.size.width -= (sepX *2 + size.width);
    
    UILabel * topLbl = [[UILabel alloc] initWithFrame:rect];
    [bgView addSubview:topLbl];
    topLbl.font = [UIFont systemFontOfSize:FLoatChange(22)];
    topLbl.text = @"姓名";
    [topLbl sizeToFit];
    rect.size.height = topLbl.bounds.size.height;
    rect.origin.y = topHeight / 2.0 - rect.size.height ;
    topLbl.frame = rect;
    nameLbl = topLbl;
    topLbl.textColor = [UIColor whiteColor];
    
    
    topLbl = [[UILabel alloc] initWithFrame:rect];
    [bgView addSubview:topLbl];
    topLbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
    topLbl.text = @"180***1309";
    [topLbl sizeToFit];
    rect.size.height = topLbl.bounds.size.height;
    topLbl.frame = rect;
    topLbl.center = CGPointMake(topLbl.center.x, topHeight-FLoatChange(33));
    telLbl = topLbl;
    topLbl.textColor = [UIColor whiteColor];
    
    UIButton * nameCoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nameCoverBtn.frame = bgView.bounds;
    [bgView addSubview:nameCoverBtn];
    [nameCoverBtn addTarget:self action:@selector(tapedOnEditUserInfoBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return bgView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FLoatChange(50);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#ifdef USERDEFAULT_Created_DeviceNum_Show
    return 8;
#endif
    NSInteger totalNum = 6;
    if(self.hideSharing) totalNum--;
    
    return totalNum;
}
-(UIView *)createSubBGView
{
    UIView * aView = [[UIView alloc] initWithFrame:CGRectZero];
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    return aView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexNum = indexPath.row;
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = tableView.backgroundColor;
//        UIView * aView  = [self createSubBGView];
//        aView.backgroundColor = tableView.backgroundColor;
//        cell.backgroundView = aView;
//        
//        aView  = [self createSubBGView];
//        aView.backgroundColor = [DZUtils colorWithHex:@"0D1C31"];
//        cell.selectedBackgroundView = aView;
        
        //添加底线
        CGFloat imgWidth = FLoatChange(15);
        CGSize imgSize = CGSizeMake(imgWidth, imgWidth / 21.0 * 38.0);
        UIView * bgView = cell;
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(tableView.bounds.size.width - 20 - imgSize.width,(bgView.bounds.size.height - imgSize.height)/ 2.0 , imgSize.width, imgSize.height);
        [btn setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
        btn.userInteractionEnabled = NO;
        [bgView addSubview:btn];
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
    }
    
    cell.indentationLevel = 1;
    cell.indentationWidth = 5;
    cell.textLabel.font = [UIFont systemFontOfSize:FLoatChange(16)];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [NSString stringWithFormat:@"设置安全密码%ld",(long)indexNum];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_arrow"]];
    
    NSString * txt = nil;
    
    if(self.hideSharing && indexNum>=2)
    {
        indexNum++;
    }
    
    if([self.dataArr count]>indexNum)
    {
        txt = [self.dataArr objectAtIndex:indexNum];
    }
    cell.textLabel.text = txt;
    
//    if(indexNum == 4 || indexNum==5)
//    {
//        cell.accessoryType = UITableViewCellSelectionStyleNone;
//        cell.accessoryView.hidden = YES;
//    }
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [DZUtils colorWithHex:@"1F2732"];
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = tableView.backgroundColor;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //列表点击事件
    NSInteger indexNum = indexPath.row;
    
    if(self.hideSharing && indexNum>=2)
    {
        indexNum++;
    }
    
//    @[@"安全密码设置",@"紧急联系人设置",@"分享给好友",@"反馈意见",@"给我评分",@"用户指南",@"退出登录",@"调研功能"]
    switch (indexNum) {
        case 0:
        {
            ZAPWDEditController * contact = [[ZAPWDEditController alloc] init];
            [[self rootNavigationController] pushViewController:contact animated:YES];
        }
            break;
        case 1:
        {
            [self insertPreDataBaseIntoLatestDatabase];
        }
            break;
        case 2:
        {
            [self showShareStyleView];
        }
            break;
        case 3:
        {
            FeedBackLeanViewcontroller * back = [[FeedBackLeanViewcontroller alloc] init];
            [[self rootNavigationController] pushViewController:back animated:YES];
//            FeedBackViewController * back = [[FeedBackViewController alloc] init];
//            [[self rootNavigationController] pushViewController:back animated:YES];
        }
            break;
        case 4:
        {
            [self showShareScore];

        }
            break;
        case 5:
        {
            ZAIntroduceController * contact = [[ZAIntroduceController alloc] init];
            [[self rootNavigationController] pushViewController:contact animated:YES];
        }
            break;
        case 6:
        {
            return;
            [self tapedOnLogoutForCurrentAPP];
        }
            break;
            
        default:
            break;
    }
    return;
    
    
    NSString * title = @"设置安全密码";
    switch (indexNum) {
        case 0:
        {
            title = @"设置安全密码";
        }
            break;
        case 1:
        {
            title = @"紧急联系人";
        }
            break;
        case 2:
        {
            title = @"分享给好友";
        }
            break;
        case 3:
        {
            title = @"高级功能";
        }
            break;
        default:
            break;
    }
    
    //页面打开
    DPViewController * dp = [[DPViewController alloc] init];
    dp.viewTtle = title;
    [[self rootNavigationController] pushViewController:dp animated:NO];
    
//    [self.viewDeckController closeLeftViewAnimated:YES];
    
}
-(void)postNotificationForContactRed
{
//    if(total.contactRed_Need_Show)
    {
       
        BOOL showRed = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                            object:[NSNumber numberWithBool:showRed]];
    }
}
-(void)showShareScore
{
    NSString * m_appleID = @"1047549816";
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",
                     m_appleID ];
    if(IOS7_OR_LATER)
    {
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",m_appleID];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)showShareStyleView
{
    ZWRateEditController * rate = [[ZWRateEditController alloc] init];
    [[self rootNavigationController] pushViewController:rate animated:YES];
    return;
    [self.viewDeckController closeLeftViewAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kShareAPP_TYPE_CURRENT_SETTING];
    
    __weak ZASettingController * weakSelf = self;
    SharePopupView *popupView=[[SharePopupView alloc]initWithType:SharePopupViewType_NoneMSG];
    [popupView setSharePopupViewEvent:^(SharePopupViewEventType eventType)
     {
         weakSelf.shareType = eventType;
         NSString * text = kShareAPP_URL_DES_SUB_TXT;
         [weakSelf shareInputTextForApplicationWith:text];
     }];
    
    UIViewController * controller = self.viewDeckController;
    if(!controller) controller = self;
    [popupView showInView:controller.view animated:YES];
}
-(void)shareInputTextForApplicationWith:(NSString *)txt
{
    [QQSpaceShare shareQQSpace].type = OthersAppDetailShareType_Share;
    [WeixinShare shareWeixin].type = OthersAppDetailShareType_Share;
    //根据shareType确定文本
    //    txt确定内容解释
    //进行分享
    SharePopupViewEventType type = self.shareType;
    switch (type) {
        case SharePopupViewEventType_QQ:
        {
            [[QQSpaceShare shareQQSpace] zaShareToQQOnlineWithContent:txt];
        }
            break;
        case SharePopupViewEventType_QQSession:
        {
            [[QQSpaceShare shareQQSpace] zaShareToQQSpaceWithContent:txt];
        }
            break;
        case SharePopupViewEventType_WXTimeLine:
        {
            [[WeixinShare shareWeixin] zaPostWeinxinNews:WXSceneTimeline content:txt];
        }
            break;
        case SharePopupViewEventType_WXSession:
        {
            [[WeixinShare shareWeixin] zaPostWeinxinNews:WXSceneSession content:txt];
            
        }
            break;
        default:
            break;
    }
    
    
}
-(void)startWebRequestForLogout
{
    //数据上传
    LogoutModel * model = (LogoutModel *) _dpModel;
    if(!model){
        model = [[LogoutModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}

#pragma mark - LogoutModel
handleSignal( LogoutModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( LogoutModel, requestLoading )
{
    [self showLoading];
}

handleSignal( LogoutModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
//        [DZUtils noticeCustomerWithShowText:@"退出登录成功"];
        [self clearLocalCurrentLoginSaveData];
        [self.viewDeckController closeLeftViewAnimated:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHECK_STATE object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                            object:[NSNumber numberWithBool:NO]];
    }
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
