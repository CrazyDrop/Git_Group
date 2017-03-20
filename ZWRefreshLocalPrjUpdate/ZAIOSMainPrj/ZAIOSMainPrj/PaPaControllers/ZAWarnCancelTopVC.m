//
//  ZAWarnCancelTopVC.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/28.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAWarnCancelTopVC.h"
#import "ZAHandleAnimationView.h"
#import "ZARecorderManager.h"
#import "ZASoundLineAnimationView.h"
#import "ZAMMMaterialDesignSpinner.h"

@interface ZAWarnCancelTopVC()
{
    UIView * _cancelTopView;
    UIView * _cancelSubTopView;
    
    UILabel * _cancelTopLbl;
    UILabel * _cancelSubTopLbl;
    
    ZAHandleAnimationView * _pointAnimatedView;
    UILabel * _recorderLbl;
    UIImageView * _iconImg;
    UILabel * _preRecorderLbl;
    ZASoundLineAnimationView * _lineView;
}
@end

@implementation ZAWarnCancelTopVC
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL show = !_pointAnimatedView.hidden;
    if(show ){
        [_pointAnimatedView resetAnimations];
    }
    
    show = !_lineView.hidden;
    if(show){
        [_lineView resetAnimations];
    }
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showSpecialStyleTitle];
    self.titleBar.hidden = YES;
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView * bgView = self.view;
    
    CGFloat topHeight = FLoatChange(120);
    CGFloat headHeight = FLoatChange(76);
    
    rect.size.height = headHeight;
    UIView * aView = [[UIView alloc] initWithFrame:rect];
    [bgView addSubview:aView];
//    aView.backgroundColor = [UIColor blueColor];
    _cancelTopView = aView;
    
    rect = aView.bounds;
    UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(18)];
//    aLbl.text = @"您的紧急联系人已被通知";
    aLbl.textColor = [UIColor whiteColor];
    aLbl.textAlignment = NSTextAlignmentCenter;
    [aView addSubview:aLbl];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, headHeight - FLoatChange(25));
    _cancelTopLbl = aLbl;
    
    rect.size.height = topHeight - headHeight;
    rect.origin.y = headHeight;
    aView = [[UIView alloc] initWithFrame:rect];
    [bgView addSubview:aView];
//    aView.backgroundColor = [UIColor grayColor];
    _cancelSubTopView = aView;
    
    rect = aView.bounds;
    aLbl = [[UILabel alloc] initWithFrame:rect];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
//    aLbl.text = @"您的朋友可实时查看您的位置和求助信息";
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.textColor = [UIColor whiteColor];
    [aView addSubview:aLbl];
    _cancelSubTopLbl = aLbl;
    
    
    CGFloat btnWidth = SCREEN_WIDTH;
    CGFloat btnHeight = FLoatChange(55);
    //    if(SCREEN_HEIGHT == 480) btnHeight = 50;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, SCREEN_HEIGHT - btnHeight, btnWidth, btnHeight);
    [btn addTarget:self action:@selector(tapedOnCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(15)];
    [btn setTitle:@"我安全了" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"quick_cancel_bg"] forState:UIControlStateNormal];
    
    
    btnWidth = FLoatChange(128);
    CGFloat redBtnHeight = FLoatChange(43);
    CGFloat cornerRadius = FLoatChange(10);
    UIColor * lineColor = [DZUtils colorWithHex:@"F4558C"];
    
    //居中时
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWidth, redBtnHeight);
    [btn addTarget:self action:@selector(tapedOnTelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(18)];
    [btn setTitle:@"电话110" forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_bg"] forState:UIControlStateNormal];
    CGFloat sepX = (SCREEN_WIDTH - btnWidth * 2)/3.0;
    btn.center = CGPointMake(sepX + btnWidth/2.0, SCREEN_HEIGHT - FLoatChange(95));
    [btn setTitleColor:lineColor forState:UIControlStateNormal];
    [btn.layer setCornerRadius:cornerRadius];
    [btn.layer setBorderColor:lineColor.CGColor];
    [btn.layer setBorderWidth:1];
    telBtn = btn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWidth, redBtnHeight);
    [btn addTarget:self action:@selector(tapedOnMessageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(18)];
    [btn setTitle:@"短信110" forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_btn_bg"] forState:UIControlStateNormal];
    btn.center = CGPointMake(SCREEN_WIDTH - (sepX + btnWidth/2.0), SCREEN_HEIGHT - FLoatChange(95));
    [btn setTitleColor:lineColor forState:UIControlStateNormal];
    [btn.layer setCornerRadius:cornerRadius];
    [btn.layer setBorderColor:lineColor.CGColor];
    [btn.layer setBorderWidth:1];
    messageBtn = btn;
    
    BOOL stateHidden = !self.showNoticeLbl;
    if(self.startRecorder) stateHidden = NO;
    
    rect.origin = CGPointZero;
    rect.size.width = FLoatChange(220);
    rect.size.height = FLoatChange(180);
    ZAHandleAnimationView * stateView = [[ZAHandleAnimationView alloc] initWithFrame:rect];
    [bgView addSubview:stateView];
    CGFloat stateY = FLoatChange(260);
    if(SCREEN_Check_Special){
        stateY =  FLoatChange(240);
    }
    stateView.center = CGPointMake(SCREEN_WIDTH/2.0,stateY);
    if(stateHidden)
    {
        stateY -= FLoatChange(5);
        stateView.center = CGPointMake(SCREEN_WIDTH/2.0,stateY);
    }
    _pointAnimatedView = stateView;
    
    
    rect.size.width = SCREEN_WIDTH;
    
    UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_icon_inuse"]];
    _iconImg = img;
    aLbl = [[UILabel alloc] initWithFrame:rect];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    aLbl.text = @"        录音已上传";
    aLbl.textColor = [DZUtils colorWithHex:@"3D8AD2"];
    [aLbl sizeToFit];
    [bgView addSubview:aLbl];
    [aLbl addSubview:img];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(200));
    _recorderLbl = aLbl;
    aLbl.hidden = stateHidden;
    if(SCREEN_Check_Special){
        aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(155));
    }
    
    
    CGPoint pt = img.center;
    pt.y = aLbl.bounds.size.height/2.0;
    img.center = pt;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnRetryLbl:)];
    [aLbl addGestureRecognizer:tap];
    aLbl.userInteractionEnabled = NO;

    
    //当启动录音时，展示30s的界面
    if(self.startRecorder)
    {
        _pointAnimatedView.hidden = YES;
        _recorderLbl.hidden = YES;
        
        
        CGFloat fontSize = FLoatChange(55);
        UILabel * lbl = [[UILabel alloc] initWithFrame:bgView.bounds];
        lbl.textColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:fontSize];
        lbl.text = @"30";
        [bgView addSubview:lbl];
        [lbl sizeToFit];
        lbl.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(225));
        centerNumLbl = lbl;
        
        
        rect = lbl.bounds;
        aLbl = [[UILabel alloc] initWithFrame:rect];
        aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
        aLbl.text = @"正在录音...";
        aLbl.textAlignment = NSTextAlignmentCenter;
        aLbl.textColor = [UIColor grayColor];
        [aLbl sizeToFit];
        aLbl.hidden = YES;
        _preRecorderLbl = aLbl;
        [lbl addSubview:aLbl];
        aLbl.center = CGPointMake(rect.size.width/2.0, lbl.bounds.size.height + FLoatChange(8) + aLbl.bounds.size.height/2.0);
        
        ZASoundLineAnimationView * soundView = [[ZASoundLineAnimationView alloc] initWithFrame:CGRectMake(0, 0, FLoatChange(150), FLoatChange(45))];
        [bgView addSubview:soundView];
        soundView.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(320));
        _lineView = soundView;
        if(SCREEN_Check_Special){
            centerNumLbl.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(180));
            _lineView.center = CGPointMake(SCREEN_WIDTH/2.0,  FLoatChange(290));
        }
    }
    
    
    
    aLbl = [[UILabel alloc] initWithFrame:rect];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(11)];
    aLbl.text = @"如紧急，可联系110（虚假报警将承担法律责任）";
    aLbl.textColor = [DZUtils colorWithHex:@"282828"];
    [aLbl sizeToFit];
    [bgView addSubview:aLbl];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(145));
    if(SCREEN_Check_Special){
        aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(130));
    }
    
    if(self.changeDate)
    {
        NSTimeInterval number = [self.changeDate timeIntervalSinceNow];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(number * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.showRedTop = NO;
            [weakSelf refreshTopViewForCurrentState];
            [weakSelf refreshCenterViewLblStateAndPerson:NO];
        });
    }
    
    
    [self refreshTopViewForCurrentState];
    [self refreshCenterViewLblStateAndPerson:self.showRedTop];
    
    [self startAutoRecorderAndTimer];
}
-(void)tapedOnRetryLbl:(id)sender
{
    [self retryUpload];
}
-(void)startRecorderAndTimerWithRecorderAuth:(BOOL)enable
{
    [super startRecorderAndTimerWithRecorderAuth:enable];
    
    _preRecorderLbl.hidden = NO;
    if(!enable)
    {
        //无录音权限
        self.recorderUnable = YES;
        
        //刷新文本
        [_pointAnimatedView stopAnimation];
        _pointAnimatedView.hidden = YES;
        _recorderLbl.hidden = YES;
        
        centerNumLbl.hidden = NO;
        _lineView.hidden = NO;
        _preRecorderLbl.hidden = NO;
        
        CGPoint pt = _preRecorderLbl.center;
        _preRecorderLbl.frame = self.view.bounds;
        _preRecorderLbl.text = @"录音权限未打开，录音异常";
        [_preRecorderLbl sizeToFit];
        _preRecorderLbl.center = pt;
        [_lineView stopAnimation];

        BOOL state = !self.showRedTop;
        [self refreshTopHeaderLblTextForNormal:state];
        
    }
}


- (void)showLoading
{
    if ( nil == _smallLoadingHUD )
    {
        CGPoint pt = _iconImg.center;
        UIView * loadView = _recorderLbl;
        CGFloat viewWidth = FLoatChange(13);
        ZAMMMaterialDesignSpinner * spinner = [[ZAMMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewWidth)];
        spinner.lineWidth = 1;
//        spinner.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        spinner.center = pt;
        spinner.tintColor = [DZUtils colorWithHex:@"3D8AD2"];
        _smallLoadingHUD = spinner;
        [spinner startAnimating];
        
        [loadView addSubview:_smallLoadingHUD];
    }
}
- (void)hideLoading
{
    if ( _smallLoadingHUD )
    {
        [_smallLoadingHUD stopAnimating];
        [_smallLoadingHUD removeFromSuperview];
        _smallLoadingHUD = nil;
    }
}


-(void)refreshStateViewForState:(CircleStateViewStateType)state
{
    [super refreshStateViewForState:state];
    
    _recorderLbl.hidden = (state == CircleStateViewStateType_NORMAL);
    _recorderLbl.userInteractionEnabled = (state == CircleStateViewStateType_UPLOAD_FAILED);
    
    //进行状态修改，隐藏，展示
    if(state!=CircleStateViewStateType_NORMAL)
    {
        [_lineView stopAnimation];
        _lineView.hidden = YES;
        centerNumLbl.hidden = YES;
        
        _pointAnimatedView.hidden = NO;
        _recorderLbl.hidden = NO;
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//        BOOL redTop = NO;
        NSDate * date = total.noticeDate;
        if(date && [date timeIntervalSinceNow]>1)
        {
//            redTop = YES;
            [_pointAnimatedView startAnimation];
        }
    }
    
    //根据各种返回，改变状态
    NSString * bottomTxt = @"正在录音...";
    
    switch (state)
    {
        case CircleStateViewStateType_NORMAL:
            bottomTxt = @"正在录音...";
            break;
        case CircleStateViewStateType_RECORDER_FAIL:
            bottomTxt = @"录音未成功";
            break;
        case CircleStateViewStateType_UPLOAD_ING:
            bottomTxt = @"录音上传中";
            break;
        case CircleStateViewStateType_UPLOAD_SUCESS:
            bottomTxt = @"录音已上传";
            break;
        case CircleStateViewStateType_UPLOAD_FAILED:
            bottomTxt = @"录音上传失败，点击重新上传";
            break;
        case CircleStateViewStateType_RECORDER_START_FAIL:
            bottomTxt = @"录音权限未打开，录音异常";
            break;
        default:
            break;
    }
    
    NSString * iconName = @"recorder_icon_inuse";
    if(state == CircleStateViewStateType_RECORDER_FAIL || state == CircleStateViewStateType_RECORDER_START_FAIL || state == CircleStateViewStateType_UPLOAD_FAILED){
        iconName = @"recorder_icon_unable";
    }
    _iconImg.image = [UIImage imageNamed:iconName];
    _iconImg.hidden = (state == CircleStateViewStateType_UPLOAD_ING);
    
    CGPoint pt = _recorderLbl.center;
    _recorderLbl.text = [NSString stringWithFormat:@"        %@",bottomTxt];
    _recorderLbl.frame = self.view.bounds;
    [_recorderLbl sizeToFit];
    _recorderLbl.center = pt;
    
    pt = _iconImg.center;
    pt.y = _recorderLbl.bounds.size.height/2.0;
    _iconImg.center = pt;
    
//    _recorderLbl.textColor = (state == CircleStateViewStateType_RECORDER_FAIL || state == CircleStateViewStateType_UPLOAD_FAILED)?[UIColor lightGrayColor]:[DZUtils colorWithHex:@"3D8AD2"];
    
}

//上传成功时换为YES
//_pointAnimatedView.showPerson = NO;
-(void)refreshCenterViewLblStateAndPerson:(BOOL)preson
{
    _pointAnimatedView.showPerson = preson;

}


//控制上部分的展示
-(void)refreshTopViewForCurrentState
{
    BOOL state = !self.showRedTop;
    [self refreshTopHeaderBgColorForNormal:state];
    [self refreshTopHeaderLblTextForNormal:state];
    
}

-(void)refreshTopHeaderBgColorForNormal:(BOOL)normal
{
    UIColor * topColor = [DZUtils colorWithHex:@"3D8AD2"];
    UIColor * subColor = [DZUtils colorWithHex:@"1A5A96"];
    if(!normal)
    {
        topColor = [DZUtils colorWithHex:@"EF7367"];
        subColor = [DZUtils colorWithHex:@"E15346"];
    }
    
    if(!normal){
        if(!_pointAnimatedView.hidden) [_pointAnimatedView startAnimation];
        if(!_lineView.hidden) [_lineView startAnimation];
    }else
    {
        [_pointAnimatedView stopAnimation];
//        [_lineView stopAnimation];

    }

    _cancelTopView.backgroundColor = topColor;
    _cancelSubTopView.backgroundColor = subColor;
    
}
-(void)refreshTopHeaderLblTextForNormal:(BOOL)normal
{
    NSString * topTxt = @"已通知您的紧急联系人";
    NSString * subTxt = @"您的朋友可实时查看您的位置和求助信息";
    if(!normal)
    {
        topTxt = @"正在处理您的求助请求";
        subTxt = @"请保持手机的网络畅通，以便更好的帮助您";
        
        if(self.startRecorder && !self.recorderUnable)
        {
            topTxt = @"请说出您的求助信息";
            subTxt = @"现场的录音有助于更快速地帮助到您";
        }
    }
    _cancelTopLbl.text = topTxt;
    _cancelSubTopLbl.text = subTxt;
}




@end
