//
//  ZAWarnCancelController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/9/18.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAWarnCancelController.h"
#import "DPViewController+WebCheck.h"
#import "CityLocationManager.h"
#import "UIButton+ZASelected.h"
#import "ZALocationLocalModel.h"
#import "ZAAnimationPointView.h"
#import "ZARecorderManager.h"
#import "RecorderTimeRefreshManager.h"
#import "CircleStateView.h"
#import "DPViewController+Message.h"
#import "SDWebImageCompat.h"
#define TopNoticeNormalText     @"收到预警，正在处理中"
#define TopNoticeSpecialText    @"请说出您想说的话"

@interface ZAWarnCancelController ()<MFMessageComposeViewControllerDelegate>
{
    UIView * animatedCircle;
    
    ZAAnimationPointView * pointView;
    
    BaseRequestModel * uploadModel;
    UILabel * topNoticeLbl;
    NSInteger retryNumber;
}
@property (nonatomic,strong) CAAnimation * circleAnimation;
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) UIViewController * smsVC;
@property (nonatomic,strong) UIAlertView * recorderAlert;
@property (nonatomic,strong) CircleStateView * stateView;
@end

@implementation ZAWarnCancelController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startCircleAnimation];
    [self cityLocationResultCheck];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  
//    [self setUpUI];
    
    
//    [self refreshWebListenForSpecialController];
    
//    [self startAutoRecorderAndTimer];

}
-(void)setUpUI
{
    [self showSpecialStyleTitle];
    self.titleBar.hidden = YES;
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"dark_blue_total"];
    img.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];
    
    UIView * bgView = self.view;
    rect.size.height = FLoatChange(390);
    if(SCREEN_HEIGHT==480)
    {
        rect.size.height *= 0.85;
    }
    
    CGFloat btnWidth = SCREEN_WIDTH;
    CGFloat btnHeight = FLoatChange(72);
    //    if(SCREEN_HEIGHT == 480) btnHeight = 50;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, SCREEN_HEIGHT - btnHeight, btnWidth, btnHeight);
    [btn addTarget:self action:@selector(tapedOnCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(18)];
    [btn setTitle:@"取消预警" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_bottom_btn"] forState:UIControlStateNormal];
    
    
    btnWidth = FLoatChange(115);
    CGFloat redBtnHeight = FLoatChange(48);
    
    //居中时
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWidth, redBtnHeight);
    [btn addTarget:self action:@selector(tapedOnTelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(18)];
    [btn setTitle:@"电话110" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_bg"] forState:UIControlStateNormal];
    CGFloat sepX = (SCREEN_WIDTH - btnWidth * 2)/4.0;
    btn.center = CGPointMake(sepX + btnWidth/2.0, SCREEN_HEIGHT - btnHeight * 2 + redBtnHeight/2.0);
    telBtn = btn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWidth, redBtnHeight);
    [btn addTarget:self action:@selector(tapedOnMessageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(18)];
    [btn setTitle:@"短信110" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_bg"] forState:UIControlStateNormal];
    btn.center = CGPointMake(SCREEN_WIDTH - (sepX + btnWidth/2.0), SCREEN_HEIGHT - btnHeight * 2 + redBtnHeight/2.0);
    messageBtn = btn;
    
    
    CGFloat lblHeight = FLoatChange(35);
    UILabel * topLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,kTop , SCREEN_WIDTH, lblHeight)];
    topLbl.textAlignment = NSTextAlignmentCenter;
    topLbl.text = TopNoticeNormalText;
    [bgView addSubview:topLbl];
    topLbl.textColor = [UIColor whiteColor];
    topLbl.font = [UIFont systemFontOfSize:FLoatChange(18)];
    topLbl.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(45));
    if(SCREEN_HEIGHT==480)
    {
        topLbl.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(self.titleBar.frame));
    }
    topNoticeLbl = topLbl;
    
    
    ZAAnimationPointView * ptView = [[ZAAnimationPointView alloc] initWithFrame:topLbl.bounds];
    [bgView addSubview:ptView];
    ptView.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMidY(topLbl.frame)+lblHeight );
    pointView = ptView;
    
    
    CGFloat imgCenterY = FLoatChange(225);
    CGPoint centerPt = CGPointMake(SCREEN_WIDTH/2.0, imgCenterY);
    
    CGFloat circleWidth = FLoatChange(225);
    
    UIImageView * circleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
    circleImg.image = [UIImage imageNamed:@"cancel_circle_bg"];
    [bgView addSubview:circleImg];
    circleImg.center = centerPt;
    
    UIImageView * userIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel_user_icon"]];
    [bgView addSubview:userIcon];
    userIcon.center = centerPt;
    userIcon.hidden = self.startRecorder;
    
    CGFloat aWidth = circleWidth * (305.0/516.0);
    CircleStateView * circle = [[CircleStateView alloc] initWithFrame:CGRectMake(0, 0,aWidth ,aWidth )];
    [bgView addSubview:circle];
    circle.center = centerPt;
    centerNumLbl = circle.timeNumLbl;
    circle.hidden = !self.startRecorder;
    self.stateView = circle;
    __weak typeof(self) weakSelf = self;
    circle.RetryUploadForUploadErrorBlock = ^(){
        [weakSelf retryUpload];
    };
    
    
    CGFloat lblCenterY = (CGRectGetMaxY(circleImg.frame) + CGRectGetMinY(btn.frame))/2.0;
    UILabel * lbl = [[UILabel alloc] initWithFrame:circleImg.bounds];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont boldSystemFontOfSize:FLoatChange(10.5)];
    lbl.numberOfLines = 0;
    lbl.textColor = [DZUtils colorWithHex:@"2C69B7"];
    //    lbl.text = @"虚假报警将承担法律责任，请您\n\n慎重使用以下功能";
    //    lbl.text = @"您的报警内容将第一时间通知警务中心\n\n虚假广告将承担法律责任";
    lbl.text = @"虚假报警将承担法律责任，请您谨慎使用\n\n以下报警功能";
    [bgView addSubview:lbl];
    lbl.center = CGPointMake(SCREEN_WIDTH/2.0, lblCenterY);

}

-(void)tapedOnTelBtn:(id)sender
{
    NSString * str = @"110";
    //
    NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",str];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
}
-(void)tapedOnMessageBtn:(id)sender
{
    //发送网络请求，成功后保存数据，成功失败均弹出界面
    [self startCityLocationRequest];

}
-(void)startCityLocationRequest
{
    BOOL isLoading = [[CityLocationManager sharedInstanceManager] isUpdating];
    if(isLoading)
    {
        [self sendSMS];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(listenToCityLocationUpdate)
                                                 name:NOTIFICATION_UPLOAD_CITY_LOCATION_STATE
                                               object:nil];
    [self showLoading];
    [[CityLocationManager sharedInstanceManager] startLastestLocationUpdate];
}
-(void)finishedWithCityLocationRequest
{
    [self hideLoading];
    [self sendSMS];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPLOAD_CITY_LOCATION_STATE object:nil];
}
-(void)listenToCityLocationUpdate
{
    [self finishedWithCityLocationRequest];
}

-(void)refreshBtnListForCityContain:(BOOL)contain
{
    CGPoint pt = telBtn.center;
    messageBtn.hidden = !contain;
    if(contain)
    {
        //修改电话btn尺寸与短信一致
        telBtn.frame = messageBtn.frame;
        
        pt.x = SCREEN_WIDTH/2.0 * 2 - messageBtn.center.x;
        telBtn.center = pt;

    }else{
        CGRect rect = telBtn.frame;
        CGFloat btnWidth =  FLoatChange(220);
        rect.size.width = btnWidth;
        telBtn.frame = rect;
        pt.x = SCREEN_WIDTH/2.0;
        telBtn.center = pt;
    }
    
    
}


- (void)sendSMS
{
    BOOL canSendSMS = [DPViewController canPostMessage];
    if(!canSendSMS) return;

    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * name = total.userInfo.username;
    NSString * tel = total.userInfo.mobile;
    NSString * add = total.locationAddress;
    NSString * add_des = total.locationAddress_des;
    NSString * time = [[NSDate date] toString:@"HH:mm"];
    
    NSMutableString * postStr = [NSMutableString string];
    [postStr appendFormat:@"求助，我（%@，号码%@）%@",name,tel,time];
    
    if(add && add_des)
    {
        [postStr appendFormat:@"在%@，%@",add,add_des];
    }else{
        ZALocationLocalModel * model = [[ZALocationLocalModelManager sharedInstance] latestLocationModel];
        if(model)
        {
            [postStr appendFormat:@"在经纬度（%@，%@）",model.latitude,model.longtitude];
        }
    }
    
    [postStr appendString:@"遇到危险，请求帮助。"];
    
    NSString * telNum = @"13051850107";
    telNum = @"12110";
    NSArray * list = [NSArray arrayWithObject:telNum];
    
    [self startActionForPostMessageWithContainString:postStr andListArr:list];
}

-(void)effectiveForWebStateCheck:(BOOL)connect
{
    if(!connect)
    {
        [self showDialogForWebConnectError];
    }else{
        [self.diaAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}
-(void)cityLocationResultCheck
{
    BOOL canSendSMS = [DPViewController canPostMessage];
    if(!canSendSMS) {
        [self refreshBtnListForCityContain:NO];
        return;
    }

    BOOL result = [CityLocationManager cityListContainCurrentCity];
    [self refreshBtnListForCityContain:result];
}
-(void)startCircleAnimation
{
    if(pointView && [pointView respondsToSelector:@selector(startPointAnimation)])
    {
        [pointView startPointAnimation];
    }
    
//    if(!animatedCircle) return;
//    
//    CAAnimation * animation =[animatedCircle.layer animationForKey:@"animatedCircleAnimation"];
//    if(!animation)
//    {
//        animation = self.circleAnimation;
//    }
//    [animatedCircle.layer removeAnimationForKey:@"animatedCircleAnimation"];
//    [animatedCircle.layer addAnimation:animation forKey:@"animatedCircleAnimation"];
}
-(void)showDialogForWebConnectError
{
    if(!self.diaAlert)
    {
        NSString * log = @"当前无网络，请检查您的网络，您的救助请求已发送，我们仍会和您及您的朋友联系。";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"当前无网络"
                                                         message:log
                                                        delegate:nil
                                               cancelButtonTitle:@"确认"
                                               otherButtonTitles:nil, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
    
}

//两个提示框指挥展示一个，所以不需要考虑重复弹出问题
-(void)showDialogForLocalRecorderAlert
{
    if(!self.recorderAlert)
    {
        NSString * log = @"亲，怕怕会在您求助时录音，记录当下的环境和您的留言，以便确定怎样更好地帮您。请接下来允许怕怕使用麦克风权限～";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        self.recorderAlert = alert;
    }
    [self.recorderAlert show];
    
}
-(void)showDialogNoneAuthRecorderAlert
{
    self.recorderAlert = nil;
    if(!self.recorderAlert)
    {
        NSString * log = @"亲，怕怕没有获得您的麦克风权限，无法正常录音，请开启麦克风权限，让我知道怎样更好的帮您~";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        self.recorderAlert = alert;
    }
    [self.recorderAlert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.recorderAlert)
    {
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.recorder_Alert_Noticed = YES;
        [total localSave];
        
        [self prepareAndStartLocalRecorder];
    }
    
}
-(void)restartRecorderTimerRefresh
{
    UILabel * titleLbl = centerNumLbl;
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
    __weak typeof(self)  weakSelf = self;
    manager.refreshInterval = 1;
    manager.functionInterval = 1;
    manager.funcBlock = ^()
    {
        [weakSelf localSecondTimeDidChange:nil];
    };
    
    titleLbl.text = @"30";
    ZAConfigModel * config = [ZAConfigModel sharedInstanceManager];
    NSString * str = config.quick_recorder_length;
    if(str && [str intValue]>0) titleLbl.text = str;
    titleLbl.hidden = NO;
    [manager saveCurrentAndStartAutoRefresh];
}

-(void)localSecondTimeDidChange:(id)sender
{
    NSLog(@"%s 录音中",__FUNCTION__);

    [[RecorderTimeRefreshManager sharedInstance] finishFunctionAndSaveCurrentTime];
    
    
    UILabel * showLbl = centerNumLbl;
    NSString * time =  showLbl.text;
    NSInteger number = NSNotFound;
    number = [time intValue];
    
    number --;
    
    if(number>=0)
    {
        showLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
    }
    
    if(number == 0)
    {
        [showLbl setNeedsDisplay];
        //倒计时结束，关闭
        [[RecorderTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
        [self finishedAudioRecorderAndStartDataUpload];

        
    }
}

-(void)tapedOnNumBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSString * str = btn.titleLabel.text;
    //
    NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",str];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    
}
-(void)finishedAudioRecorderAndStartDataUpload
{
    if(self.recorderUnable)
    {
        [self refreshStateViewForState:CircleStateViewStateType_RECORDER_START_FAIL];
        //进行切换
        return;
    }
    NSLog(@"%s",__FUNCTION__);
    topNoticeLbl.text = TopNoticeNormalText;
//    [self refreshStateViewForState:CircleStateViewStateType_COMBINE_ING];
    
    ZARecorderManager * manager = [ZARecorderManager sharedInstanceManager];
    [manager stopRecorder];
}
-(void)startAudioRecorder
{
    __weak typeof(self) weakSelf = self;
    __weak ZARecorderManager * manager = [ZARecorderManager sharedInstanceManager];
    manager.DoneRecorderAndFinishedExchangeBlock = ^(BOOL result){
        
        NSString * path = [manager localSaveRecorderPath];
        NSString * duration = [manager localMediaMP3TotalLength];
#if TARGET_IPHONE_SIMULATOR
        duration = @"30";
#endif
        
        if(!result)
        {
            path = nil;
            duration = nil;
        }
        [weakSelf startUploadRecorderAutoWithPath:path andLength:duration];
    };
    [manager clearLocalSaveAudio];
    [manager startRecorder];
}
-(void)startUploadRecorderAutoWithPath:(NSString *)path andLength:(NSString *)length
{
    if(!path || [path length]==0)
    {
        //录音错误展示
        [self refreshStateViewForState:CircleStateViewStateType_RECORDER_FAIL];
        return;
    }

    retryNumber = 0;
    
    DataUploadModel * model = (DataUploadModel *)uploadModel;
    if(!model){
        model = [[DataUploadModel alloc] init];
        [model addSignalResponder:self];
        uploadModel = model;
    }

    model.mediaLength = length;
    model.fileType = DataUploadModelFileTYPE_VOICE;
    model.filePath = path;
    [model sendRequest];

}
-(void)retryUploadForUploadError
{
    retryNumber++;
    if(retryNumber >= 3 || !uploadModel)
    {
        [self hideLoading];
        [self refreshStateViewForState:CircleStateViewStateType_UPLOAD_FAILED];
        [DZUtils noticeCustomerWithShowText:@"网络异常，录音上传失败"];
        return;
    }
    [self retryUpload];
}
-(void)retryUpload
{
    DataUploadModel * model = (DataUploadModel *)uploadModel;
    [model sendRequest];
}

#pragma mark DataUploadModel
handleSignal( DataUploadModel, requestError )
{
    [self retryUploadForUploadError];
    
}
handleSignal( DataUploadModel, requestLoading )
{
    [self showLoading];
    [self refreshStateViewForState:CircleStateViewStateType_UPLOAD_ING];
    
}

handleSignal( DataUploadModel, requestLoaded )
{
    [self hideLoading];
    [self refreshStateViewForState:CircleStateViewStateType_UPLOAD_SUCESS];
    
}
#pragma mark -


#pragma mark UserIconDownModel
handleSignal( UserIconDownModel, requestError )
{
    [self hideLoading];
}
handleSignal( UserIconDownModel, requestLoading )
{
    [self showLoading];

}

handleSignal( UserIconDownModel, requestLoaded )
{
    [self hideLoading];

    
//    UserIconDownModel * model = (UserIconDownModel *)uploadModel;
//    if(model.iconData && [model.iconData length]>0)
//    {
//        UIImage * img = [UIImage imageWithData:model.iconData];
//        [iconBtn setBackgroundImage:img forState:UIControlStateNormal];
//    }
}
#pragma mark -




-(void)prepareAndStartLocalRecorder
{
    __weak typeof(self) weakSelf = self;
    [ZARecorderManager startRecorderAuthRequestWithBlock:^(BOOL enable)
     {
         dispatch_main_sync_safe(^{
//             __strong typeof(self) *sself = weakSelf;
             [weakSelf startRecorderAndTimerWithRecorderAuth:enable];
         })
     }];
    
//    //询问并处理返回结果
//    if([ZARecorderManager recorderNeverStarted])
//    {
//        [ZARecorderManager startRecorderAuthRequestWithBlock:^(BOOL enable)
//         {
//             [self startRecorderAndTimerWithRecorderAuth:enable];
//         }];
//    }else{
//        BOOL enable = [ZARecorderManager recorderIsEnable];
//        [self startRecorderAndTimerWithRecorderAuth:enable];
//    }
}
-(void)startRecorderAndTimerWithRecorderAuth:(BOOL)enable
{
//    self.startRecorder = NO;
    
    [self restartRecorderTimerRefresh];

    if(enable)
    {
        topNoticeLbl.text = TopNoticeSpecialText;
        [self startAudioRecorder];
    }else
    {
        [self refreshStateViewForState:CircleStateViewStateType_RECORDER_FAIL];
    }
}

-(void)startAutoRecorderAndTimer
{
    if(!self.startRecorder) return;
    
    //进行方法测试
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if([ZARecorderManager recorderNeverStarted])
    {//之前未弹出，展示弹框
        [self showDialogForLocalRecorderAlert];
    }else if([ZARecorderManager recorderIsEnable])
    {
        [self startRecorderAndTimerWithRecorderAuth:YES];
    }else{
        [self showDialogNoneAuthRecorderAlert];
        [self refreshStateViewForState:CircleStateViewStateType_RECORDER_FAIL];
        [self startRecorderAndTimerWithRecorderAuth:NO];
    }
}

-(void)refreshStateViewForState:(CircleStateViewStateType)type
{
    [self.stateView setState:type];
}


-(void)tapedOnCancelBtn:(id)sender
{
    
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        [DZUtils noticeCustomerWithShowText:kAppNone_Network_Error];
        return;
    }
    
    if (self.TapedCancelWarnBlock)
    {
        self.TapedCancelWarnBlock();
    }
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
