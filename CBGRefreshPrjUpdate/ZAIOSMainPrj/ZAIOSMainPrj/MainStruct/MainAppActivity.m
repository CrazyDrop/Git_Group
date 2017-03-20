//
//  MainAppActivity.m
//  ZAIOSMainPrj
//
//  Created by zhangchaoqun on 15/5/4.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "MainAppActivity.h"
#import "REMenu.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
#import "MobClick.h"
#import "BlockAlertView.h"
#import "SharePopupView.h"
#import "WeixinShare.h"
#import "QQSpaceShare.h"
#import "KMStatis.h"
#import "ProductListController.h"
#import "ProductListCollectionCell.h"
#import "MSAlertController.h"
#import "ZALocation.h"
#import "LocationTimeRefreshManager.h"
#import "ZACircularSlider.h"
#import "TBCircularSlider.h"
@interface MainAppActivity ()<REMenuDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIImageView * userIcon;
    UILabel * nameLbl;
    
//    LogoutModel * _quitModel;
}
@property (strong, readwrite, nonatomic) REMenu *menu;
//@property (nonatomic, strong) LoginModel *loginModel;
@property (nonatomic, assign) SharePopupViewEventType shareType;
@property (nonatomic, strong) NSArray * listArr;
@end

@implementation MainAppActivity

- (void)viewWillAppear:(BOOL)animated
{
//    if([[AccountManager sharedInstance] hasLogedIn])
//    {
//        AccountInfo *info = [[AccountManager sharedInstance] accoutInfo];
//        if(info)
//        {
//            nameLbl.text = info.realName;
//        }else{
//            nameLbl.text = @"";
//        }
//    }else{
//        nameLbl.text = ZAViewLocalizedStringForKey(@"ZAViewLocal_Main_None_User_Title");
//    }
}

- (void)viewDidLoad {
    
    self.viewTtle = ZAViewLocalizedStringForKey(@"ZAViewLocal_Main_Title");
    BOOL hidden = self.navigationController.navigationBarHidden;
    if(hidden)
    {
        self.showLeftBtn = YES;
    }else
    {
        self.title = self.viewTtle;
    }
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if(hidden)
    {
        UIButton * aBtn = self.leftBtn;
        [aBtn setImage:[UIImage imageNamed:@"top_left"] forState:UIControlStateNormal];
    }else
    {
        self.titleBar.hidden = YES;
        UIButton * aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [aBtn setTitle:@"列表" forState:UIControlStateNormal];
        aBtn.frame = CGRectMakeAdapter(0, 0, 50, 40);
//        [aBtn setBackgroundColor:[UIColor redColor]];
        [aBtn setImage:[UIImage imageNamed:@"top_left"] forState:UIControlStateNormal];
        [aBtn setImage:[UIImage imageNamed:@"top_left"] forState:UIControlStateHighlighted];


        [aBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aBtn];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        
        
        aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [aBtn setTitle:@"列表" forState:UIControlStateNormal];
        aBtn.frame = CGRectMakeAdapter(0, 0, 50, 40);
        //        [aBtn setBackgroundColor:[UIColor redColor]];
        [aBtn setImage:[UIImage imageNamed:@"top_left"] forState:UIControlStateNormal];
        [aBtn setImage:[UIImage imageNamed:@"top_left"] forState:UIControlStateHighlighted];
        
        
        [aBtn addTarget:self action:@selector(tapedOnRightBtn) forControlEvents:UIControlEventTouchUpInside];
        backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aBtn];
        self.navigationItem.rightBarButtonItem = backButtonItem;
    }
    
    //登陆界面点击头像
    CGFloat startY = 20;
    CGFloat startX = 10;
    CGFloat btnWidth = 100 * WindowWidthFloat;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, btnWidth, btnWidth);
    btn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnStartLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [btn setTitle:@"点击登陆" forState:UIControlStateNormal];
    btn.tag = 10;
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, btn.center.y);
    
    
    
//    TBCircularSlider * circle = [[TBCircularSlider alloc] initWithFrame:CGRectMake(0, 0, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
//    [self.view addSubview:circle];
//    [circle addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
//    [circle setSliderScale:0.9];

    ZACircularSlider * circle = [[ZACircularSlider alloc] initWithFrame:CGRectMake(0, 0, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    [self.view addSubview:circle];
    [circle addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];

    circle.center = CGPointMake(SCREEN_WIDTH/2.0, btn.center.y + 200);
    
}
-(void)newValue:(TBCircularSlider*)slider{
    //TBCircularSlider *slider = (TBCircularSlider*)sender;
//    NSLog(@"Slider Value %d",slider.angle);
}


-(void)zaMainCode
{
    BOOL hidden = self.navigationController.navigationBarHidden;

    //登陆界面点击头像
    CGFloat startY = 20;
    CGFloat startX = 10;
    CGFloat btnWidth = 100 * WindowWidthFloat;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, btnWidth, btnWidth);
    btn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnStartLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [btn setTitle:@"点击登陆" forState:UIControlStateNormal];
    btn.tag = 10;
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, btn.center.y);
    
    
    CGFloat imgWidth = btnWidth* 0.8;
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgWidth)];
    [btn addSubview:img];
    
    img.clipsToBounds = YES;
    CALayer * aLayer = img.layer;
    aLayer.cornerRadius = imgWidth/2.0;
    aLayer.borderWidth = 0.5;
    aLayer.borderColor = [[UIColor clearColor] CGColor];
    
    img.image = [UIImage imageNamed:@"QQLogin"];
    img.center = CGPointMake(btnWidth/2.0, imgWidth/2.0);
    userIcon = img;
    
    
    
    UILabel * aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnWidth - imgWidth)];
    [btn addSubview:aLbl];
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.text = ZAViewLocalizedStringForKey(@"ZAViewLocal_Main_None_User_Title");
    aLbl.center = CGPointMake(btnWidth/2.0, imgWidth + aLbl.bounds.size.height/2.0);
    nameLbl = aLbl;
    
    
    CGFloat bottomHeight = 45 ;
    if(SCREEN_HEIGHT>480) bottomHeight = 60;
    
    bottomHeight *= WindowWidthFloat;
    
    startY = SCREEN_HEIGHT - bottomHeight *3 ;
    if(!hidden)
        startY -= (44 + 20);
    
    UIView * bgView = self.view;
    //底部列表区域
    CGRect rect = CGRectMake(0, startY, SCREEN_WIDTH, bottomHeight);
    
    
    UIButton * proBtn = [self createButton:rect text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Main_Product_List_Title") color:[UIColor blackColor] action:@selector(tapedOnProductBtn:)];
    [bgView addSubview:proBtn];
    proBtn.tag = 10;
    
    startY += bottomHeight;
    rect.origin.y = startY;
    
    UIButton * payBtn = [self createButton:rect text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Main_Start_Claims_Title") color:[UIColor darkGrayColor] action:@selector(tapedOnProductBtn:)];
    [bgView addSubview:payBtn];
    
    startY += bottomHeight;
    rect.origin.y = startY;
    payBtn.tag = 11;
    
    UIButton * myBtn = [self createButton:rect text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Main_MY_Claims_Title") color:[UIColor lightGrayColor] action:@selector(tapedOnProductBtn:)];
    [bgView addSubview:myBtn];
    myBtn.tag = 12;
    
    CGFloat sepY = 10;
    rect.origin.y = CGRectGetMaxY(btn.frame) + sepY;
    rect.size.height = CGRectGetMinY(proBtn.frame)  - rect.origin.y - sepY ;
    
    
//    self.listArr = [ProductListDataModel localListArray];
    CGSize cellSize = CGSizeZero;
    cellSize.height = rect.size.height / 2.0;
    cellSize.width = SCREEN_WIDTH / 4.0;
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing=0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = cellSize;
    
    
    //功能列表按钮
    UICollectionView * list = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flowLayout];
    list.delegate = self;
    list.dataSource = self;
    list.showsHorizontalScrollIndicator = NO;
    [bgView addSubview:list];
    list.backgroundColor = [UIColor clearColor];
    [list registerClass:[ProductListCollectionCell class] forCellWithReuseIdentifier:@"ProductListCell_main"];
    
    //监听第三方登录结果，如果成功，进行检查 跳转
    [self createMenuView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCheckOtherLogin:) name:NOTIFICATION_NAME_OTHERLOGIN_LOGINSUCCESS object:nil];
    
}

-(REMenu *)menu
{
    if(!_menu)
    {
        [self createMenuView];
    }
    return _menu;
}


-(void)startCheckOtherLogin:(id)sender
{
//    //检查第三方登录
//    LoginModel * model = _loginModel;
//    if(!model)
//    {
//        model = [[LoginModel alloc] init];
//        [model addSignalResponder:self];
//        _loginModel = model;
//    }
//    model.isOtherLogin = YES;
//    model.otherToken = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKEN];
//    model.otherTokenType = [[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE] intValue];
//    [model sendRequest];
    
}
#pragma mark LoginModel
handleSignal( LoginModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( LoginModel, requestLoaded )
{
    [self hideLoading];
    //此时，如果返回特定标识 进入第三方注册页面
    
//    ThirdPartyLoginResponse * response = signal.object;
//    if(!response.hasRegisted)
//    {
//        OtherRegisterController * other = [[OtherRegisterController alloc] init];
//        [self.navigationController pushViewController:other animated:YES];
//        return;
//    }
//    
//    if([DZUtils checkAndNoticeErrorWithSignal:signal])
//    {
//        TokenRefreshManager * manager =  [TokenRefreshManager sharedInstance];
//        [manager userLoginSuccess];
//        
//        //第三方登录成功
//        Account * account = [[AccountManager sharedInstance] account];
//        if(account.isInfoCompleted)//信息齐全
//        {
//            [DZUtils noticeCustomerWithShowText:@"登录成功"];
//            [self.navigationController popViewControllerAnimated:YES];
//            return;
//        }
//        
//        //进行信息补全
//        InfoCompleteController * complete = [[InfoCompleteController alloc] init];
//        [self.navigationController pushViewController:complete animated:YES];
//    }
    
}

handleSignal( LoginModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
#pragma mark -
#pragma mark LogoutModel
handleSignal( LogoutModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( LogoutModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [DZUtils noticeCustomerWithShowText:@"退出登录"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

handleSignal( LogoutModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
#pragma mark -
#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    id obj = nil;
    if([self.listArr count]>indexPath.row) obj = [self.listArr objectAtIndex:indexPath.row];
    
//    if([(ProductListDataModel * )obj proType]==TYPEPRODUCT_SHOW_TYPE_LIST)
//    {
//        ProductListController * list = [[ProductListController alloc] init];
//        [self.navigationController pushViewController:list animated:YES];
//    }
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.listArr count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //
    static NSString *CellIdentifier = @"ProductListCell_main";
    ProductListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    id obj = nil;
    if([self.listArr count]>indexPath.row) obj = [self.listArr objectAtIndex:indexPath.row];
    [cell loadCellData:obj];
    return cell;
    return nil;
}

#pragma mark BottomBtnActions
-(void)tapedOnProductBtn:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 10:
        {
            ProductListController * list = [[ProductListController alloc] init];
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case 11:
        {
            
        }
            break;
        case 12:
        {
            
        }
            break;
        default:
            break;
    }
    
}

#pragma mark -
-(void)createMenuView
{
    __typeof (self) __weak weakSelf = self;
    REMenuItem *aboutUSItem = [[REMenuItem alloc] initWithTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_MenuList_AboutUS")
                                                    subtitle:nil
                                                       image:[UIImage imageNamed:@"Icon_Home"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          NSLog(@"Item: %@", item);
//                                                          [KMStatis staticMenuEvent:StaticMenuEventType_AboutUS];
                                                          
                                                          AboutViewController * about = [[AboutViewController alloc] init];
                                                          about.viewTtle = ZAViewLocalizedStringForKey(@"ZAViewLocal_AboutUS_Title");
                                                          about.url = [NSString stringWithFormat:@"%@%@",@"http://10.139.32.222:9080/za-clare/",@"app/user/getUserInfo/123"];
                                                          [weakSelf.navigationController pushViewController:about animated:YES];
                                                      }];
    
    REMenuItem *feedBackItem = [[REMenuItem alloc] initWithTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_MenuList_FeedBack")
                                                       subtitle:nil
                                                          image:[UIImage imageNamed:@"Icon_Explore"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
//                                                                                                                   [KMStatis staticMenuEvent:StaticMenuEventType_FeedBack];
                                                             FeedBackViewController * about = [[FeedBackViewController alloc] init];
                                                             [weakSelf.navigationController pushViewController:about animated:YES];
                                                         }];
    
    REMenuItem *infoCompleteItem = [[REMenuItem alloc] initWithTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_MenuList_InfoComplete")
                                                        subtitle:nil
                                                           image:[UIImage imageNamed:@"Icon_Activity"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              NSLog(@"Item: %@", item);
//                                                                                                                                                      [KMStatis staticMenuEvent:StaticMenuEventType_InfoComplete];                                InfoCompleteController *controller = [[InfoCompleteController alloc] init];
//                                                              [weakSelf.navigationController pushViewController:controller animated:YES];
//                                                              controller.TapedOnRightBtnBlock = ^(void){
//                                                                  [weakSelf.navigationController popViewControllerAnimated:NO];
//                                                              };
                                                              
                                                          }];
    
    
    REMenuItem *shareItem = [[REMenuItem alloc] initWithTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_MenuList_ShareApp")
                                                          image:[UIImage imageNamed:@"Icon_Profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
//                                                             [KMStatis staticMenuEvent:StaticMenuEventType_ShareApp];
                                                             [weakSelf tapedOnShareBtn:nil];
                                                             //                                                             ProfileViewController *controller = [[ProfileViewController alloc] init];
                                                             //                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    NSString * current = [DZUtils currentAppBundleShortVersion];
    NSString * name = ZAViewLocalizedStringForKey(@"ZAViewLocal_MenuList_CheckVersion");
    NSString * title = [NSString stringWithFormat:@"%@(%@)",name,current];
    REMenuItem *versionItem = [[REMenuItem alloc] initWithTitle:title
                                                          image:[UIImage imageNamed:@"Icon_Profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             NSLog(@"Item: %@", item);
//                                                             [KMStatis staticMenuEvent:StaticMenuEventType_CheckVersion];
                                                             [weakSelf tapedOnCheckVersion:nil];
                                                         }];
    REMenuItem *quitItem = [[REMenuItem alloc] initWithTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_MenuList_Quit")
                                                          image:[UIImage imageNamed:@"Icon_Profile"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
//                                                             [KMStatis staticMenuEvent:StaticMenuEventType_QuitLogin];

                                                             NSLog(@"Item: %@", item);
                                                             [weakSelf tapedOnQuitOut:nil];
                                                             //                                                             ProfileViewController *controller = [[ProfileViewController alloc] init];
                                                             //                                                             [weakSelf setViewControllers:@[controller] animated:NO];
                                                         }];
    
    // You can also assign a custom view for any particular item
    // Uncomment the code below and add `customViewItem` to `initWithItems` array, for example:
    // self.menu = [[REMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem, customViewItem]]
    //
    /*
     UIView *customView = [[UIView alloc] init];
     customView.backgroundColor = [UIColor blueColor];
     customView.alpha = 0.4;
     REMenuItem *customViewItem = [[REMenuItem alloc] initWithCustomView:customView action:^(REMenuItem *item) {
     NSLog(@"Tap on customView");
     }];
     */
    

    
    aboutUSItem.tag = 0;
    feedBackItem.tag = 1;
    infoCompleteItem.tag = 2;
    shareItem.tag = 3;
    versionItem.tag = 4;
    quitItem.tag = 5;
    
//    Account * account = [[AccountManager sharedInstance] account];
//    
//    NSMutableArray * array = [NSMutableArray arrayWithObjects:aboutUSItem, feedBackItem, infoCompleteItem, shareItem,versionItem,quitItem, nil];
//    
//    if(!account||!account.token)  [array removeObject:quitItem];
//    if(!account||account.isInfoCompleted) [array removeObject:infoCompleteItem];
    
//    self.menu = [[REMenu alloc] initWithItems:array];
    
    
    
    // Background view
    //
    //self.menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    //self.menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.menu.backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    
    //self.menu.imageAlignment = REMenuImageAlignmentRight;
    //self.menu.closeOnSelection = NO;
    //self.menu.appearsBehindNavigationBar = NO; // Affects only iOS 7
    if (!REUIKitIsFlatMode()) {
        self.menu.cornerRadius = 4;
        self.menu.shadowRadius = 4;
        self.menu.shadowColor = [UIColor blackColor];
        self.menu.shadowOffset = CGSizeMake(0, 1);
        self.menu.shadowOpacity = 1;
    }
    
    // Blurred background in iOS 7
    //
    //self.menu.liveBlur = YES;
    //self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleDark;
    
    self.menu.separatorOffset = CGSizeMake(15.0, 0.0);
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
    self.menu.delegate = self;
}




- (UIButton *)createButton:(CGRect)frame text:(NSString *)text color:(UIColor *)cl action:(SEL)action{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = cl;
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    CGRect aRect = btn.bounds;
    aRect.size.width *= 0.8;
    
    UILabel * coverLbl = [[UILabel alloc] initWithFrame:aRect];
    [btn addSubview:coverLbl];
    coverLbl.textColor = [UIColor whiteColor];
    coverLbl.font = [UIFont boldSystemFontOfSize:20];
    coverLbl.center = CGPointMake(frame.size.width/2.0,frame.size.height/2.0);
    coverLbl.text = text;
    
    return btn;
}
#pragma mark MenuAction
-(void)tapedOnQuitOut:(id)sender
{
//    AccountManager * manager = [AccountManager sharedInstance];
//    if(![manager hasLogedIn]){
//        [DZUtils noticeCustomerWithShowText:@"您尚未登录"];
//        return;
//    }
    
    
    __weak MainAppActivity * weakSelf = self;
    NSString * log = @"确定要退出登录?";
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:nil message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"退出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf startLogoutRequest];
                             }];
    [alertController addAction:action];
    
    
    
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:@"取消" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        
    }];
    [alertController addAction:action2];
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
    
}
-(void)startLogoutRequest
{
//    LogoutModel * model = _quitModel;
//    if(!model)
//    {
//        model = [[LogoutModel alloc] init];
//        [model addSignalResponder:self];
//        _quitModel = model;
//    }
//    [model sendRequest];
//    
//    [[AccountManager sharedInstance] saveAccount:nil];
//    
//    //清空本地存储数据
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKEN];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE];
//    
//    [[WeixinShare shareWeixin] logout];
//    [[QQSpaceShare shareQQSpace] logout];
//    
//    TokenRefreshManager * manager =  [TokenRefreshManager sharedInstance];
//    [manager userLogout];
}
-(void)tapedOnShareBtn:(id)sender
{

    __weak MainAppActivity * weakSelf = self;
    SharePopupView *popupView=[[SharePopupView alloc]initWithType:SharePopupViewType_OnlyShare];
    [popupView setSharePopupViewEvent:^(SharePopupViewEventType eventType)
    {
        weakSelf.shareType = eventType;
        NSString * text = kShareAPP_URL_DES_SUB_TXT;
        [weakSelf shareInputTextForApplicationWith:text];
    }];
    
    UIViewController * controller = self;
    if(self.navigationController&&[self.navigationController.viewControllers count]==1)
        controller = self.navigationController;
    
    [popupView showInView:controller.view animated:true];
}

-(void)shareInputTextForApplicationWith:(NSString *)txt
{
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
            BOOL result = [[WeixinShare shareWeixin] zaPostWeinxinNews:WXSceneTimeline content:txt];
//            [KMStatis staticShareEvent:result?StaticShareEventType_WX_Sucess:StaticShareEventType_WXLogin_Fail];
        }
            break;
        case SharePopupViewEventType_WXSession:
        {
            BOOL result =  [[WeixinShare shareWeixin] zaPostWeinxinNews:WXSceneSession content:txt];
//            [KMStatis staticShareEvent:result?StaticShareEventType_WX_Sucess:StaticShareEventType_WXLogin_Fail];

        }
            break;
        default:
            break;
    }
    
    
}

-(void)tapedOnCheckVersion:(id)sender
{
//    [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
}

- (void)appUpdate:(NSDictionary *)info
{
    NSString * path = [info valueForKey:@"path"];
    NSString * log = [info valueForKey:@"update_log"];
    
    BOOL update = [[info valueForKey:@"update"] boolValue];
    BOOL needForceUpdate = NO;
    
    //如果不需要，直接返回
    if(!update)
    {
        [DZUtils noticeCustomerWithShowText:@"当前为最新版本"];
        return;
    }
    
    //弹出提示框
    //        NSDictionary * dic = [MobClick getConfigParams];
    NSString * str = [MobClick getConfigParams:@"forceUpdate"];
    NSArray * arr = [str componentsSeparatedByString:@","];
    //获取本地版本号
    NSString * current = [DZUtils currentAppBundleShortVersion];
    needForceUpdate = [arr containsObject:current];
    //是否需要强制更新
    
    //需要强制升级
    NSString * rightTxt = @"暂不升级";
    if(needForceUpdate)
    {
        rightTxt = @"退出";
    }
    
    
    //也可以考虑替换 BlockAlertView
    BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
    [alert setDestructiveButtonWithTitle:@"升级" block:^{
        NSString * urlString = [NSString stringWithFormat:kShareAPP_URL_PATH];
        if(path) urlString = path;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }];
    [alert setCancelButtonWithTitle:rightTxt block:^{
        if(needForceUpdate)
        {
            exit(0);
        }
    }];
    [alert show];
    
    return;
}



#pragma mark - REMenu Delegate Methods
//-(void)willOpenMenu:(REMenu *)menu
//{
//    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
//}
//
//-(void)didOpenMenu:(REMenu *)menu
//{
//    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
//}
//
//-(void)willCloseMenu:(REMenu *)menu
//{
//    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
//}
//
//-(void)didCloseMenu:(REMenu *)menu
//{
//    NSLog(@"Delegate method: %@", NSStringFromSelector(_cmd));
//}
#pragma mark - ButtonActions
-(void)leftAction
{
    if (self.menu.isOpen)
        return [self.menu close];
    
    self.menu = nil;//确保内容为最新的
    [self.menu showFromNavigationController:self.navigationController];
}

-(void)tapedOnRightBtn
{
    if (self.menu.isOpen)
        [self.menu close];
    
    [self tapedOnShareBtn:nil];
    
}

-(void)checkUpCurrentLocationWithString:(CLLocation *)str
{
    //如果有定位的数据返回，则用户同意，启动定位功能
    if(!str) return;
    
    //启动定时
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager refreshRefreshTimeWithNormalPriority];
    
}

-(void)tapedOnStartLocationButton:(id)sender
{

    NSString * log = nil;
    ZALocation * locationInstance = [ZALocation sharedInstance];
    __weak MainAppActivity * weakSelf = self;

    //点击登录按钮
    //未设置过，弹出提示页面，确认后弹出系统请求页面
    if([ZALocation locationStatusNeverSetting])
    {
        //也可以考虑替换 BlockAlertView
        log = @"我们怕怕需要您的位置信息,以判定您可能的危险";
        BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
        [alert setDestructiveButtonWithTitle:@"确定" block:^{
            [[ZALocation sharedInstance] startLocationRequestUserAuthorization];
        }];
        [alert show];
        
        [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *str)
        {
            [weakSelf checkUpCurrentLocationWithString:str];
        }];
        return;
    }
    
    //没启动定位功能，用户拒绝后再次点击
    if(![ZALocation locationStatusEnableInBackground])
    {
        if(iOS8_constant_or_later)
        {
            log = @"我们怕怕需要您的位置信息,需要您许可该功能,请在设置中打开";
            BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
            [alert setDestructiveButtonWithTitle:@"确定" block:^{
                [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
            }];
            [alert show];
            return;
        }
        //进行提示
        log = @"您尚未允许我们使用您的位置信息，请在 设置->隐私->定位服务->怕怕 中开启后使用";
        [DZUtils noticeCustomerWithShowText:log];
        return;
    }

    
    //启动定时的定位服务
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager refreshRefreshTimeWithNormalPriority];

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
