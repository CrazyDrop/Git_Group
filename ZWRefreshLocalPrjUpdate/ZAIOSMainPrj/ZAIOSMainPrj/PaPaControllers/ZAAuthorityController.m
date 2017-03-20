//
//  ZAAuthorityController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/23.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAAuthorityController.h"
#import "ZALocation.h"
#import "ZARecorderManager.h"
#import "ZAAddressController.h"
#import "SDWebImageCompat.h"
#import "RemoteNTFRefreshManager.h"


@interface ZAAuthorityController()

@property (nonatomic,strong) UIView * grayBGView;
@property (nonatomic,strong) UIView * listView;

@property (nonatomic,strong) NSArray * desArray;
@property (nonatomic,strong) UIButton * currentBtn;

@property (nonatomic,assign) ZAAuthoritySelectType selectResult;

@end

#define ZAAuthorityTag 100
@implementation ZAAuthorityController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.type = ZAAuthorityCheckType_Main;
        
        self.desArray = [NSArray arrayWithObjects:
                         @"打开位置权限，让怕怕知道\n去哪里帮助您",
                         @"打开录音权限，录下现场情\n况，让怕怕知道去哪帮您",
                         @"打开通知权限，即时获取提\n醒信息",
                         @"打开通讯录权限，添加您的\n朋友为紧急联系人",
                         nil];
        
    }
    return self;
}
-(BOOL)checkTotalAuthorityRequestResult
{
    BOOL result = NO;
    if(self.type == ZAAuthorityCheckType_Main){
        result = (self.selectResult & ZAAuthoritySelectType_Location) &&  (self.selectResult & ZAAuthoritySelectType_Recorder) && (self.selectResult & ZAAuthoritySelectType_Notification);
    }
    if(self.type == ZAAuthorityCheckType_Address){
       result = ( self.selectResult & ZAAuthoritySelectType_Address);
    }
    return result;
}

-(void)autoCloseCurrentAuthorityView
{
    if(self.TapedOnCloseAuthorityBtnBlock)
    {
        self.TapedOnCloseAuthorityBtnBlock();
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(UIView *)grayBGView
{
    if(!_grayBGView)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        UIView * coverView = [[UIView alloc] initWithFrame:rect];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0.2;
        
        self.grayBGView = coverView;
    }
    return _grayBGView;
}

-(UIView *)listView
{
    if(!_listView)
    {
        CGFloat height  = FLoatChange(230);
        if(self.type == ZAAuthorityCheckType_Address)
        {
            height = FLoatChange(100);
        }
        CGSize listSize = CGSizeMake(FLoatChange(230), height);
        UIView * coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, listSize.width, listSize.height)];
        coverView.backgroundColor = [UIColor whiteColor];
        
        
        CALayer * layer = coverView.layer;
        layer.cornerRadius = FLoatChange(5);
        
        self.listView = coverView;
    }
    return _listView;
}
-(void)createSubListViewForList
{
    
    UIView * bgView = self.listView;
    //生成界面
    CGFloat topHead = FLoatChange(30);
    CGFloat eveHeight = FLoatChange(66);
    if(self.type == ZAAuthorityCheckType_Address)
    {
        topHead = FLoatChange(40);
        eveHeight = FLoatChange(60);
    }
    
    CGRect rect = self.listView.bounds;
    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
    lbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    lbl.text = @"需要开放以下权限";
    [lbl sizeToFit];
    [bgView addSubview:lbl];
    lbl.center = CGPointMake(rect.size.width/2.0, FLoatChange(23));
    
//    CGFloat startX = FLoatChange(12);

    CGFloat btnWidth = FLoatChange(30);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
    [btn setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
    [bgView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(rect.size.width - btnWidth/2.0, btnWidth/2.0);
    
    
//    CGFloat startX = FLoatChange(12);
    CGFloat startCenterY = FLoatChange(65);
    
    
    if(self.type == ZAAuthorityCheckType_Address)
    {
        NSInteger index = 3;
        NSString * txt = [self.desArray objectAtIndex:index];
        UIView * aview = [self authorityViewForText:txt andBtnTag:ZAAuthorityTag + index];
        aview.frame = CGRectMake(0, topHead,rect.size.width, eveHeight);
        [bgView addSubview:aview];
        
    }else {
        for (NSInteger i=0; i<3; i++)
        {
            NSString * txt = [self.desArray objectAtIndex:i];
            UIView * aview = [self authorityViewForText:txt andBtnTag:ZAAuthorityTag + i];
            aview.frame = CGRectMake(0, topHead,rect.size.width, eveHeight);
            [bgView addSubview:aview];
            CGFloat pointY = startCenterY + eveHeight * i;
            aview.center = CGPointMake(aview.center.x, pointY);
            
            UIView * imgView = [aview viewWithTag:ZAAuthorityTag - 1];
            imgView.hidden = i==2;
            
        }
    }
}
-(UIView *)authorityViewForText:(NSString *)txt andBtnTag:(NSInteger)tag
{
    CGFloat startX = FLoatChange(12);

    
    CGRect rect = self.listView.bounds;
    UIView * aView = [[UIView alloc] initWithFrame:rect];
    aView.backgroundColor = [UIColor clearColor];
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth
    ;
    
    
    rect = aView.bounds;
    rect.size.width = FLoatChange(135);
    
    NSString *text = txt;
    //创建NSMutableAttributedString实例，并将text传入
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:text];
    //创建NSMutableParagraphStyle实例
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    //设置行距
    [style setLineSpacing:FLoatChange(3)];
    //根据给定长度与style设置attStr式样
    [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [attStr length])];
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
    lbl.font = [UIFont systemFontOfSize:FLoatChange(11)];
    lbl.attributedText = attStr;
    lbl.numberOfLines =  0;
    lbl.textColor = [UIColor grayColor];
    [lbl sizeToFit];
    [aView addSubview:lbl];
    lbl.center = CGPointMake(startX + lbl.bounds.size.width/2.0,aView.bounds.size.height/2.0);
    lbl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    
    rect.size = CGSizeMake(FLoatChange(60),FLoatChange(30));
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = rect;
    [btn setTitle:@"去设置" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(11)]];
    [btn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
    btn.tag = tag;
    [aView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnStartAuthorityCheckBtn:) forControlEvents:UIControlEventTouchUpInside];
    CALayer * layer = btn.layer;
    layer.cornerRadius = FLoatChange(5);
    layer.borderWidth = 1;
    layer.borderColor = [Custom_Blue_Button_BGColor CGColor];
    btn.center = CGPointMake(aView.bounds.size.width - rect.size.width/2.0 - startX, aView.bounds.size.height/2.0);
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;


    //分割线
    UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"authority_line"]];
    [aView addSubview:img];
    img.frame = CGRectMake(0, 0, aView.bounds.size.width - startX*2, 1);
    img.center = CGPointMake(aView.bounds.size.width/2.0, aView.bounds.size.height-1);
    img.hidden = YES;
    img.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    img.tag = ZAAuthorityTag - 1;
    
    return aView;
}
-(void)tapedOnStartAuthorityCheckBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger index = btn.tag - ZAAuthorityTag;
    
    if(self.currentBtn) return;
    self.currentBtn = btn;
    
    
    ZAAuthoritySelectType type = ZAAuthoritySelectType_Location;
    switch (index) {
        case 0:
        {
            type = ZAAuthoritySelectType_Location;
        }
            break;
        case 1:
        {
            type = ZAAuthoritySelectType_Recorder;
        }
            break;
        case 2:
        {
            type = ZAAuthoritySelectType_Notification;
        }
            break;
        case 3:
        {
            type = ZAAuthoritySelectType_Address;
        }
            break;
            
        default:
            break;
    }
    
    
    
    [self startAuthorityUserRequestForSelectedType:type];
    
}


-(void)refreshBtnStateWithBtn:(UIButton *)btn andCurrentState:(BOOL)state
{
    CGPoint pt = btn.center;
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:btn.frame];
    lbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    lbl.text = @"已拒绝";
    lbl.textColor = [UIColor grayColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    if(state)
    {
        lbl.text = @"已同意";
        lbl.textColor = Custom_Blue_Button_BGColor;
    }
    
    [btn.superview addSubview:lbl];
    lbl.center = pt;
    btn.hidden = YES;
}

-(void)checkUpAuthorityResultForSelectedType:(ZAAuthoritySelectType)type
{
    switch (type)
    {
        case ZAAuthoritySelectType_Location:
        {
            ZALocation * locationInstance = [ZALocation sharedInstance];
            [locationInstance stopUpdateLocation];
        }
            break;
        case ZAAuthoritySelectType_Recorder:
        {
            
        }
            break;
        case ZAAuthoritySelectType_Notification:
        {
            
        }
            break;
        case ZAAuthoritySelectType_Address:
        {
            
        }
            break;
            
        default:
        {
            NSLog(@"%s 未知type",__FUNCTION__);
            return;
        }
            break;
    }
    
    //状态检查，刷新
    ZAAuthorityCheckResultType result = [self authorityCheckResultForSelectedType:type];
    if(result == ZAAuthorityCheckResultType_None) return;
    
    self.selectResult = self.selectResult | type;
    [self refreshBtnStateWithBtn:self.currentBtn andCurrentState:result == ZAAuthorityCheckResultType_Access];
    self.currentBtn =  nil;
    
    
    BOOL total = [self checkTotalAuthorityRequestResult];
    if(total){
//        [self autoCloseCurrentAuthorityView];
    }

}

//针对同意的情况
-(void)receiveRemoteNotificationNot:(NSNotification *)notification
{
    //停止timer
    [[RemoteNTFRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    [self checkUpAuthorityResultForSelectedType:ZAAuthoritySelectType_Notification];
}
-(void)refreshRemoteNotificationSettingLblState:(id)sender
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//    NSLog(@"%s %d",__FUNCTION__,state);

    if(state != UIApplicationStateActive){
        return;
    }
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                              forKeyPath:NSRemote_NOTIFICATION_IDENTIFIER_REGISTER];
    
    [[RemoteNTFRefreshManager sharedInstance] endAutoRefreshAndClearTime];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkUpAuthorityResultForSelectedType:ZAAuthoritySelectType_Notification];
    });
    
    
}
-(void)startRemoteNTFRefreshTimer
{
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    manager.refreshInterval = 0.1;
    manager.functionInterval = 0.1;
    manager.funcBlock = ^()
    {
        [weakSelf refreshRemoteNotificationSettingLblState:nil];
    };
    [manager saveCurrentAndStartAutoRefresh];
}

-(void)startAuthorityUserRequestForSelectedType:(ZAAuthoritySelectType)type
{
    //默认未设置
//    ZAAuthorityCheckResultType result = ZAAuthorityCheckResultType_None;
    
    __weak typeof(self) weakSelf = self;
    switch (type)
    {
        case ZAAuthoritySelectType_Location:
        {
            ZALocation * locationInstance = [ZALocation sharedInstance];
//            if([ZALocation locationStatusNeverSetting])
            {
                [locationInstance startLocationRequestUserAuthorization];
                [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *str)
                 {
                     [weakSelf checkUpAuthorityResultForSelectedType:type];
                 }];
                
            }

        }
            break;
        case ZAAuthoritySelectType_Recorder:
        {
            [ZARecorderManager startRecorderAuthRequestWithBlock:^(BOOL enable)
             {
                 dispatch_main_sync_safe(^{
                     //             __strong typeof(self) *sself = weakSelf;
                     [weakSelf checkUpAuthorityResultForSelectedType:type];
                 })
             }];
        }
            break;
        case ZAAuthoritySelectType_Notification:
        {
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(receiveRemoteNotificationNot:)
//                                                         name:NSRemote_NOTIFICATION_IDENTIFIER_REGISTER
//                                                       object:nil];
            
            if(iOS8_constant_or_later)
            {
                
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound) categories:nil]];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }else
            {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                 UIRemoteNotificationTypeAlert
                 | UIRemoteNotificationTypeBadge
                 | UIRemoteNotificationTypeSound];
            }
            
            //启动定时刷新
            [self performSelector:@selector(startRemoteNTFRefreshTimer) withObject:nil afterDelay:0.2];
            
        }
            break;
        case ZAAuthoritySelectType_Address:
        {
//            [ZAAddressController startAddressAddWithBlock:^(BOOL enable){
//                [weakSelf checkUpAuthorityResultForSelectedType:type];
//            }];
            if(self.TapedOnAuthorityBtnBlock){
                self.TapedOnAuthorityBtnBlock(type);
            }
        }
            break;
        default:
            break;
    }
    
    
    
}

-(ZAAuthorityCheckResultType)authorityCheckResultForSelectedType:(ZAAuthoritySelectType)type
{
    //默认未设置
    ZAAuthorityCheckResultType result = ZAAuthorityCheckResultType_None;

    switch (type)
    {
        case ZAAuthoritySelectType_Location:
        {
//            if(iOS8_constant_or_later)
            {
                if(![ZALocation locationStatusNeverSetting])
                {
                    BOOL enable = [ZALocation locationStatusEnableInForground];
                    result = enable?ZAAuthorityCheckResultType_Access:ZAAuthorityCheckResultType_Refuse;
                }
            }
        }
            break;
        case ZAAuthoritySelectType_Recorder:
        {
            if(iOS8_constant_or_later)
            {
                if(![ZARecorderManager recorderNeverStarted])
                {
                    BOOL enable = [ZARecorderManager recorderIsEnable];
                    result = enable?ZAAuthorityCheckResultType_Access:ZAAuthorityCheckResultType_Refuse;
                }
            }else{
                //8以下 此时无默认刷新情况，仅作为点击后的状态更新判断
                BOOL enable = [ZARecorderManager recorderIsEnable];
                result = enable?ZAAuthorityCheckResultType_Access:ZAAuthorityCheckResultType_Refuse;
            }
        }
            break;
        case ZAAuthoritySelectType_Notification:
        {
            if(iOS8_constant_or_later)
            {
//                if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
                {
                    UIUserNotificationSettings * setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
                    UIUserNotificationType notificationType = setting.types;
                    result = ZAAuthorityCheckResultType_Refuse;
                    if(notificationType != UIUserNotificationTypeNone)
                    {
                        result = ZAAuthorityCheckResultType_Access;
                    }
                }
            }else
            {
                //8以下，无启动界面时状态刷新
                UIRemoteNotificationType notification =[[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                result = ZAAuthorityCheckResultType_Refuse;
                if(notification != UIRemoteNotificationTypeNone)
                {
                    result = ZAAuthorityCheckResultType_Access;
                }
            }

        }
            break;
        case ZAAuthoritySelectType_Address:
        {
            //            if(iOS8_constant_or_later)
            {
                if(![ZAAddressController addressBookAuthNeverStarted])
                {
                    BOOL enable = [ZAAddressController addressBookAuthStateEnable];
                    result = enable?ZAAuthorityCheckResultType_Access:ZAAuthorityCheckResultType_Refuse;
                }
            }
        }
            break;
            
        default:
            break;
    }
    return result;
}

-(void)tapedOnCloseBtn:(id)sender
{
    if(self.TapedOnCloseAuthorityBtnBlock)
    {
        self.TapedOnCloseAuthorityBtnBlock();
    }
}


//刷新当前的状态，仅刷新录音权限且仅限8.0以上 (1、通讯录权限依权限判定是否弹框   2、通知权限没办法区分拒绝和未设置  3、定位功能删除后重置不需要刷新 4、8.0以下，确认权限时会自动申请权限)
-(void)refreshCurrentAuthority
{
    
    if(iOS8_constant_or_later)
    {
        UIButton * btn = (UIButton *)[self.view viewWithTag:ZAAuthorityTag + 1];
        self.currentBtn = btn;
        [self checkUpAuthorityResultForSelectedType:ZAAuthoritySelectType_Recorder];
        self.currentBtn = nil;
    }
    

    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.grayBGView];
    [self.view addSubview:self.listView];
    self.listView.center = CGPointMake(SCREEN_WIDTH/2.0,SCREEN_HEIGHT/2.0 - FLoatChange(20));
    
    
    [self createSubListViewForList];
    
    
}





@end
