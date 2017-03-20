//
//  ZATimerStartedController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/27.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZATimerStartedController.h"
#import "DPViewController+SharePath.h"
#import <MapKit/MapKit.h>
#import "ZAAnnotationModel.h"
#import "OpenTimesRefreshManager.h"
#import "ZALineAnimationView.h"
#import "DPViewController+WebNotice.h"
#import "ZATipsShowController.h"
@interface ZATimerStartedController()<MKMapViewDelegate>
{
    BaseRequestModel * _timesModel;
    UILabel * _timesLbl;
    UIView * _tipView;
    ZALineAnimationView * _animatedLine;
}
@property (nonatomic,strong) ZATipsShowController * showTipVC;//控制tips展示
@property (nonatomic,strong) ZAAnnotationModel * preModel;
@end
@implementation ZATimerStartedController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_animatedLine startLineAnimation];
    
    CGFloat topHeight = FLoatChange(100);
    [self refreshWebNoticeViewForCustomWithStartY:topHeight];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self refreshWebNoticeViewForNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat topHeight = FLoatChange(100);
    
    UIView * bgView = self.view;
    
    //顶部
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topHeight)];
    img.image = [UIImage imageNamed:@"timer_top_bg"];
    [bgView addSubview:img];
    
    CGFloat fontSize = FLoatChange(32);
    UIFont * font = [UIFont fontWithName:@"STHeitiTC-Light" size:fontSize];
    NSString * str = @"000000";
    
    UILabel * timeLbl = [[UILabel alloc] initWithFrame:rect];
    [img addSubview:timeLbl];
    timeLbl.font = font;
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.textColor = [UIColor whiteColor];
    [timeLbl sizeToFit];
    [img addSubview:timeLbl];
    timeLbl.text = @"：";
    timeLbl.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(45));
    
    UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
    [img addSubview:aLbl];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(13)];
    aLbl.text = @"计时结束后自动发起求助";
    aLbl.textAlignment = NSTextAlignmentCenter;
    [aLbl sizeToFit];
    aLbl.textColor = [UIColor whiteColor];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, topHeight - FLoatChange(23));
    
    rect = timeLbl.bounds;
    rect.size.width *= 0.5;
    aLbl = [[UILabel alloc] initWithFrame:rect];
    [timeLbl addSubview:aLbl];
    hourLbl = aLbl;
    aLbl.font = font;
    aLbl.textAlignment = NSTextAlignmentLeft;
    aLbl.textColor = [UIColor whiteColor];
//    aLbl.backgroundColor = [UIColor redColor];
    
    rect.origin.x = rect.size.width;
    aLbl = [[UILabel alloc] initWithFrame:rect];
    [timeLbl addSubview:aLbl];
    secondLbl = aLbl;
    aLbl.font = font;
    aLbl.textAlignment = NSTextAlignmentLeft;
    aLbl.textColor = [UIColor whiteColor];
//    aLbl.backgroundColor = [UIColor blueColor];
    
    //横线
    rect = img.bounds;
    CGFloat lineHeight = FLoatChange(4);
    rect.size.height = lineHeight;
    
    ZALineAnimationView * lineView = [[ZALineAnimationView alloc] initWithFrame:rect];
    lineView.backgroundColor = [DZUtils colorWithHex:@"27ACF0"];
    [img addSubview:lineView];
    lineView.center = CGPointMake(SCREEN_WIDTH/2.0, topHeight - lineHeight/2.0);
    _animatedLine = lineView;
    
    //底部按钮
    CGFloat btnHeight = FLoatChange(45);
    CGSize btnSize = CGSizeMake(SCREEN_WIDTH/2.0, btnHeight);
    UIColor * color = [DZUtils colorWithHex:@"FE8282"];
    UIFont * sizeFont = [UIFont systemFontOfSize:FLoatChange(14)];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    [bgView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnHelpBtn:) forControlEvents:UIControlEventTouchUpInside];
    NSString * title = @"立即求助";
    btn.titleLabel.font = sizeFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:color];
    btn.center = CGPointMake(btnSize.width/2.0, SCREEN_HEIGHT - btnHeight/2.0);
    

    color = [DZUtils colorWithHex:@"34D7F6"];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    [bgView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnSafeBtn:) forControlEvents:UIControlEventTouchUpInside];
    title = @"结束防护";
    btn.titleLabel.font = sizeFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:color];
    btn.center = CGPointMake(SCREEN_WIDTH - btnSize.width/2.0, SCREEN_HEIGHT - btnHeight/2.0);

    //底部文本
    CGFloat spaceHeight = FLoatChange(75);
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, spaceHeight)];
    coverView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:coverView];
    coverView.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - btnHeight - spaceHeight/2.0);
    
    UIColor * borderColor = [DZUtils colorWithHex:@"53B7FF"];
    CGFloat startX = FLoatChange(15);
    btnSize = CGSizeMake(FLoatChange(102), FLoatChange(49));
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    rect.size = btnSize;
    btn.frame = rect;
    btn.titleLabel.font = sizeFont;
    [btn setTitle:@"分享实时位置" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnShareForPaths) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:borderColor forState:UIControlStateNormal];
    [btn.layer setBorderWidth:1];
    [btn.layer setBorderColor:[borderColor CGColor]];
    [coverView addSubview:btn];
    btn.center = CGPointMake(SCREEN_WIDTH - btnSize.width/2.0 - startX, spaceHeight/2.0);

    
    CGFloat lblWidth = FLoatChange(180);
    aLbl = [[UILabel alloc] initWithFrame:CGRectMake(startX, startX, lblWidth, 50)];
    aLbl.text = @"分享位置给好友，您会更安全";
    aLbl.textColor = [DZUtils colorWithHex:@"282828"];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    [aLbl sizeToFit];
    aLbl.frame = CGRectMake(startX, startX, lblWidth, aLbl.bounds.size.height);
    [coverView addSubview:aLbl];
    _timesLbl = aLbl;
    
    lblWidth = FLoatChange(145);
    aLbl = [[UILabel alloc] initWithFrame:CGRectMake(startX, startX, lblWidth, 80)];
    aLbl.text = @"在您防护过程中，好友将可以\n查看您的位置和状态信息";
    aLbl.textColor = [DZUtils colorWithHex:@"919191"];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(10)];
    aLbl.numberOfLines = 0;
    [aLbl sizeToFit];
    [coverView addSubview:aLbl];
    aLbl.center = CGPointMake(aLbl.center.x, spaceHeight - startX - aLbl.bounds.size.height/2.0);
    
    //地图
    CGFloat mapHeight = SCREEN_HEIGHT - topHeight - spaceHeight - btnHeight;
    CGRect rectMap = CGRectMake(0, 0,SCREEN_WIDTH,mapHeight);
    MKMapView *map = [[MKMapView alloc]initWithFrame:rectMap];
    map.backgroundColor = [UIColor whiteColor];
    map.center = CGPointMake(SCREEN_WIDTH/2.0, topHeight + mapHeight/2.0);
    map.delegate = self;
    map.showsUserLocation = YES;
    map.mapType = MKMapTypeStandard;
    [bgView addSubview:map];

    CGFloat btnWidth = FLoatChange(45);
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImageView * aImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnWidth*0.6, btnWidth*0.6)];
    btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setImage:[UIImage imageNamed:@"warn_cancel_mapperson"] forState:UIControlStateNormal];
//    [btn addSubview:aImg];
    [bgView addSubview:btn];
//    aImg.center = CGPointMake(btnWidth/2.0, btnWidth/2.0);
    btn.center = CGPointMake(FLoatChange(40),FLoatChange(140));
//    [btn.layer setCornerRadius:btnWidth/2.0];
    [btn addTarget:self action:@selector(tapedOnPersonBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat aImgHeight = 103.0/2.0;//上面使用图片的大小
    CGFloat imgWidth = FLoatChange(230);
    CGFloat imgHeight = imgWidth/536.0*76.0;
    aImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
    aImg.image = [UIImage imageNamed:@"timer_top_notice"];
    [bgView addSubview:aImg];
//    aImg.center = CGPointMake(FLoatChange(190), CGRectGetMinY(btn.frame) +(btnWidth - aImgHeight)/2.0  + imgHeight/2.0 );
    aImg.center = CGPointMake(FLoatChange(190),CGRectGetMidY(btn.frame));
    aImg.hidden = YES;
    _tipView = aImg;
    
    aLbl = [[UILabel alloc] initWithFrame:aImg.bounds];
    aLbl.text = @"怕怕团队正在守护着您！";
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    [aLbl sizeToFit];
    aLbl.textColor = [UIColor whiteColor];
    [aImg addSubview:aLbl];
    aLbl.center = CGPointMake(imgWidth/2.0, imgHeight/2.0);

    self.leftBtn.hidden = YES;
    [self showTextWithCurrentTimingNum:nil];
    [self startOpenTimesRefreshTimer];
    [self startLocalTipsCheck];
    
}
//进行tips展示检查
-(void)startLocalTipsCheck
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.timer_Tips_Showed)
    {
        
        __weak typeof(self) weakSelf = self;
        ZATipsShowController * tip = [[ZATipsShowController alloc] init];
        tip.startIndex = 2;
        tip.TapedOnCoverBtnBlock = ^(NSInteger index){
            
            if(index==2)
            {
                model.timer_Tips_Showed = YES;
                [model localSave];
                [weakSelf.showTipVC.view removeFromSuperview];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.showTipVC = nil;
                });
            }
        };
        
        [self.view addSubview:tip.view];
        self.showTipVC = tip;
    }
}


-(void)tapedOnPersonBtn:(id)sender
{
    BOOL currentState = _tipView.hidden;
    if(!currentState) return;
    
    _tipView.hidden = NO;
    __weak UIView * weakAView = _tipView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakAView.hidden = YES;
    });
    
    
}

-(void)startOpenTimesRefreshTimer
{
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    manager.refreshInterval = 30;
    manager.functionInterval = 30;
    manager.funcBlock = ^()
    {
        [weakSelf requestOpenTimesBackgroundForTimer];
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)requestOpenTimesBackgroundForTimer
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    WarnTimingModel * local = total.timeModel;
    
    OpenTimesModel * model = (OpenTimesModel *) _timesModel;
    if(!model){
        model = [[OpenTimesModel alloc] init];
        [model addSignalResponder:self];
        _timesModel = model;
    }
    model.warnId = local.timeId;
    [model sendRequest];
}
-(void)refreshTimesForRequestSuccess
{
    OpenTimesModel * model = (OpenTimesModel *) _timesModel;
    
    NSString * str = nil;
    if(!model.times || [model.times intValue]==0)
    {
        str =  @"分享位置给好友，您会更安全";
    }else{
        str =  [NSString stringWithFormat:@"您的位置已被好友查看过%d次",[model.times intValue]];
    }

    _timesLbl.text = str;
}

#pragma mark OpenTimesModel
handleSignal( OpenTimesModel, requestError )
{
    
}
handleSignal( OpenTimesModel, requestLoading )
{
    
}
handleSignal( OpenTimesModel, requestLoaded )
{
    [self refreshTimesForRequestSuccess];
}
#pragma mark -


#pragma MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (self.preModel)
    {
        [mapView removeAnnotation:self.preModel];
    }
    
    CLLocationCoordinate2D coor = userLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor, 500, 500);
    [mapView setRegion:region animated:YES];
    
    ZAAnnotationModel *anno = [[ZAAnnotationModel alloc]init];
    self.preModel = anno;
    anno.icon = @"user_icon_default";
    anno.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [mapView addAnnotation:anno];
}

// 自定义大头针
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:[ZAAnnotationModel class]]) return nil;
    
    static NSString *annoViewID=@"annoView";
    MKAnnotationView *annoView=[mapView dequeueReusableAnnotationViewWithIdentifier:annoViewID];
    if (annoView==nil)
    {
        //        MKPinAnnotationView
        annoView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annoViewID];
        annoView.canShowCallout=NO;
    }
    
    annoView.annotation=annotation;
    ZAAnnotationModel *anno=annotation;
    annoView.image=[UIImage imageNamed:anno.icon];
    return annoView;
}

-(void)tapedOnShareForPaths
{
    [self showSharePathShareStyleView];
}


@end
