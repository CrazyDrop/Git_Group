//
//  ZAShareLocationController.m
//  ZAIOSMainPrj
//
//  Created by 赵宪云 on 15/12/30.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAShareLocationController.h"
#import "ZAAddSomethingController.h"
#import <MapKit/MapKit.h>
#import "ZAAnnotationModel.h"
#import "SharePopupView.h"
#import "DPViewController+Message.h"
#import "QQSpaceShare.h"
#import "WeixinShare.h"
#import "DPViewController+SharePath.h"
@interface ZAShareLocationController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    
}
@property (nonatomic, strong) CLLocationManager *mgr;
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, assign) BOOL firstDisplay; // 只添加一次
@property (nonatomic,assign) SharePopupViewEventType shareType;
@property (nonatomic,strong) NSString * currentInputStr;
@property (nonatomic,strong) ZAAnnotationModel * preModel;
@property (nonatomic,strong) UILabel * inputTxtLbl;


@end

@implementation ZAShareLocationController

- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle = @"分享个人轨迹";
        self.showLeftBtn = YES;
        self.showRightBtn = NO;
    }
    return self;
}
-(CLLocationManager *)mgr
{
    if (_mgr == nil) {
        CLLocationManager * locationManager = [[CLLocationManager alloc]init];
        
        locationManager.delegate=self;//设置代理
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
        locationManager.distanceFilter=10.0f;//设置距离筛选器
        
        self.mgr = locationManager;
    }
    return _mgr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Custom_View_Gray_BGColor;
    
    [self setUpUI];
    
}

- (void)setUpUI{
    
    // 顶部提示
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    CGRect rect = CGRectMake(0, startY, SCREEN_WIDTH, 60);
    UILabel *tipLbl = [[UILabel alloc]initWithFrame:rect];
    [self.view addSubview:tipLbl];
    tipLbl.text = @"点击分享，使您的好友在结束防护前能看到您的轨迹";
    tipLbl.font = [UIFont systemFontOfSize:FLoatChange(11)];
    [tipLbl setTextAlignment:NSTextAlignmentCenter];
    [tipLbl setTextColor:Custom_Blue_Button_BGColor];
    tipLbl.userInteractionEnabled = NO;
    
    // 地图
    CGRect rectMap = CGRectMake(0, CGRectGetMaxY(tipLbl.bounds)+FLoatChange(20), FLoatChange(265), FLoatChange(265));
    MKMapView *map = [[MKMapView alloc]initWithFrame:rectMap];
    map.backgroundColor = [UIColor whiteColor];
    map.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(tipLbl.frame)+FLoatChange(130));
    map.delegate = self;
    map.showsUserLocation = YES;
    map.mapType = MKMapTypeStandard;
    [self.view addSubview:map];
    
//    [self.mgr startUpdatingLocation];
    self.map = map;
    self.firstDisplay = YES;
    
    // 捎句话
    CGRect rectAddLbl = CGRectMake(0, CGRectGetMaxY(map.frame)+FLoatChange(30), SCREEN_WIDTH, FLoatChange(47));
    UILabel *addLbl = [[UILabel alloc]initWithFrame:rectAddLbl];
    addLbl.text = @"捎句话给TA";
    addLbl.font = [UIFont systemFontOfSize:FLoatChange(14)];
    [addLbl setTextAlignment:NSTextAlignmentCenter];
    [addLbl setTextColor:[UIColor blackColor]];
    [addLbl setBackgroundColor:[UIColor whiteColor]];
    addLbl.userInteractionEnabled = YES;
    self.inputTxtLbl = addLbl;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addStr:)];
    [addLbl addGestureRecognizer:tap];
    [self.view addSubview:addLbl];
    
    CGSize imgSize = CGSizeMake(FLoatChange(8), FLoatChange(16));
    UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    rightArrow.frame = CGRectMake(SCREEN_WIDTH - 20 - imgSize.width, CGRectGetMinY(addLbl.frame) + FLoatChange(16), imgSize.width, imgSize.height);
    [rightArrow setBackgroundImage:[UIImage imageNamed:@"detail_arrow"] forState:UIControlStateNormal];
    rightArrow.userInteractionEnabled = NO;
    [self.view addSubview:rightArrow];
    
    //
    rect.size.width = FLoatChange(275);
    rect.size.height = FLoatChange(43);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = rect;
    btn.backgroundColor = Custom_Blue_Button_BGColor;
    [[btn layer]setCornerRadius:5.0];
    [btn setTitle:@"分享" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showShareStyleView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, self.view.bounds.size.height - FLoatChange(100) + rect.size.height/2.0);
}
// 分享
-(void)showShareStyleView
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"test"];
    
    [KMStatis staticSharePathStaticEvent:StaticPaPaSharePathEventType_ShowShare];

    [self showSharePathShareStyleView];
}


- (void)addStr:(NSString *)str
{
    
    __weak typeof(self) weakSelf = self;
    ZAAddSomethingController *add = [[ZAAddSomethingController alloc] init];
    add.DoneEditToDoBlock = ^(NSString *str)
    {
        weakSelf.inputTxtLbl.text = str;
        weakSelf.currentInputStr = str;
        
        if(!str || [str length]==0)
        {
            str = @"捎句话给TA";
            weakSelf.currentInputStr = nil;
            weakSelf.inputTxtLbl.text = str;
        }
    };
    [self.navigationController pushViewController:add animated:YES];
}

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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
