//
//  DPViewController.m
//  Photography
//
//  Created by jialifei on 15/3/18.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "DPViewController.h"
#import "MBProgressHUD.h"
#import "ZAMMMaterialDesignSpinner.h"
#import "AppDelegate.h"
@interface DPViewController ()
{
    CGPoint center;
    MBProgressHUD * _loadingHud;

}
@property (nonatomic,strong) UIButton * coverBackBtn;
@end

@implementation DPViewController


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _showLeftBtn = YES;
        
        
        //屏蔽界面
    }
    return self;
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)showLoading
{
    if ( nil == _loadingHud )
    {
        UIView * loadView = self.navigationController.view;
        if(!loadView)
        {
            loadView = self.tabBarController.view;
        }
        if(!loadView)
        {
            loadView = self.view;
        }
        CGFloat viewWidth = FLoatChange(35);
        ZAMMMaterialDesignSpinner * spinner = [[ZAMMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewWidth)];
        spinner.lineWidth = 2;

        spinner.tintColor = [UIColor whiteColor];
        _loadingHud = [[MBProgressHUD alloc] initWithView:loadView];
        _loadingHud.mode = MBProgressHUDModeCustomView;
        _loadingHud.customView = spinner;
        _loadingHud.removeFromSuperViewOnHide = YES;
        [spinner startAnimating];
        
        [loadView addSubview:_loadingHud];
        
        [_loadingHud show:YES];
    }
}
- (void)hideLoading
{
    if ( _loadingHud )
    {
        [_loadingHud hide:YES];
        _loadingHud = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initBar];
    
//    _myClient = [[DPHttpClient alloc] init];

    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice]systemVersion]compare:@"7.0"]!=NSOrderedAscending){
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    

#endif
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleDefault;
//}
-(NSString *)classNameForKMRecord
{
    NSString * str  = NSStringFromClass([self class]);
    return str;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    NSString * name = self.viewTtle;
    if(!name) name = self.title;
    
    NSString * saveName = [self classNameForKMRecord];
    if(!saveName) return;
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    total.kmVCNameString = saveName;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSString * name = self.viewTtle;
    if(!name) name = self.title;
//    [KMStatis staticEndLogPageViewWithPageTitle:name];
}
#pragma mark - Create Methods
-(void)initBar
{
    CGFloat topHeight = FLoatChange(55) - 20;
    UIView * bgView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topHeight + kTop)];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [UIColor clearColor];
    topBgView = bgView;
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:bgView.bounds];
    img.image = [UIImage imageNamed:@"dark_blue_topBG"];
    [bgView addSubview:img];
    imgBg = img;

    //统一的顶部背景
    _titleBar= [[UIImageView alloc] initWithFrame:CGRectMake(0 , kTop , SCREEN_WIDTH, topHeight)];
    
    _titleBar.hidden = NO;
    _titleBar.userInteractionEnabled= YES;
//    _titleBar.image= [UIImage imageNamed:@"headBarBg"];
//    _titleBar.backgroundColor = [UIColor whiteColor];
    _titleBar.backgroundColor = [UIColor clearColor];
    
    _titleV= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, topHeight)];
    _titleV.textAlignment = NSTextAlignmentCenter;
    [_titleBar addSubview:_titleV];
    _titleV.font = [UIFont systemFontOfSize:FLoatChange(16.0)];
    _titleV.hidden = NO;
    _titleV.text = _viewTtle;
    _titleV.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_titleBar];
    _titleV.center = CGPointMake(SCREEN_WIDTH / 2.0,_titleV.center.y);
    _titleV.backgroundColor = [UIColor clearColor];
    _titleV.textColor = [UIColor whiteColor];

    if (_showLeftBtn)
    {
        [self creatLeftBtn];
    }
    if (_showRightBtn) {
        [self creatRightBtn];
    }

}
- (void)creatLeftBtn
{
    CGFloat leftSpace = FLoatChange(10);
    CGFloat imgWidth = 16.0;
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(0, 0, 50, 50);
    [_leftBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [_titleBar  addSubview:_leftBtn];
    _leftBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    
    _leftBtn.center = CGPointMake(leftSpace + imgWidth/2.0, _titleBar.bounds.size.height / 2.0);

}

- (void)creatRightBtn
{
    //按钮的点击事件在外部设置
    CGFloat leftSpace = FLoatChange(10);
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 60, 15, 50, 50);
    //    [self.rightBtn setTitleColor:REDCOLOR forState:UIControlStateNormal];
    //    self.rightBtn.layer.borderWidth = 1.0;
    //    self.rightBtn.layer.borderColor = [REDCOLOR CGColor];
    [_rightBtn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(16.0)]];
    [_rightBtn setBackgroundColor:[UIColor clearColor]];
    [_rightBtn setTitle:_rightTitle forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_titleBar  addSubview:_rightBtn];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton * btn = _rightBtn;
    [btn.titleLabel sizeToFit];
    CGFloat endX = btn.titleLabel.bounds.size.width/2.0 + leftSpace;
    _rightBtn.center = CGPointMake(SCREEN_WIDTH - endX, _titleBar.bounds.size.height / 2.0);

}
-(UIButton *)coverBackBtn
{
    if(!_coverBackBtn)
    {
        UIView * bgView = self.view;
        if(self.tabBarController) bgView = self.tabBarController.view;
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = [[UIScreen mainScreen] bounds];
        [bgView addSubview:btn];
        btn.hidden = YES;
        [btn addTarget:self action:@selector(tapedOnCloseSlider) forControlEvents:UIControlEventTouchUpInside];
        _coverBackBtn = btn;
    }
    return _coverBackBtn;
}



#pragma mark - Public Methods
-(UIButton *)coverBtn
{
    return self.coverBackBtn;
}

-(void)refreshDragBackEnable:(BOOL)enable{
//    KKNavigationController * na =(KKNavigationController *) self.viewDeckController.navigationController;
//    na.canDragBack = enable;
//    na.panGes.enabled = enable;
}


-(void)showSpecialStyleTitle
{
    //两种形式下，顶部高度不一致  分别  35  65
    CGFloat topHeight = FLoatChange(65);
    CGRect rect = _titleBar.frame;
    rect.size.height = topHeight;
    _titleBar.frame = rect;
    
    topBgView.hidden = YES;
    _titleV.hidden = YES;
    imgBg.hidden = YES;
    
    //展示特殊的标题形式，分上下两行
    UILabel * aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(25)];
    aLbl.text = @"怕怕";
    [aLbl sizeToFit];
    [_titleBar addSubview:aLbl];
    _topHeaderLbl = aLbl;
    CGSize barSize = _titleBar.bounds.size;
    aLbl.center = CGPointMake(barSize.width/2.0,(barSize.height - aLbl.bounds.size.height)/3.0 + aLbl.bounds.size.height/2.0);
    aLbl.textColor = [UIColor whiteColor];
    
    CGFloat topTitleHeight = aLbl.bounds.size.height;
    aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(15)];
    aLbl.textColor = [UIColor lightGrayColor];
    _topHeaderSmallLbl = aLbl;
    aLbl.text = @"papa";
    [aLbl sizeToFit];
    aLbl.hidden = YES;
    [_titleBar addSubview:aLbl];
    aLbl.center = CGPointMake(barSize.width/2.0, (barSize.height - topTitleHeight)/3.0 * 2 + topTitleHeight - aLbl.bounds.size.height / 3.0);
    
    
    //进行左侧列表展示
    UIButton * aBtn = self.leftBtn;
    [aBtn setImage:[UIImage imageNamed:@"menu_main"] forState:UIControlStateNormal];
    [aBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [aBtn addTarget:self action:@selector(tapedOnLeftBtnShowSlider) forControlEvents:UIControlEventTouchUpInside];
//    aBtn.hidden = YES;
    
    aBtn.center = CGPointMake(FLoatChange(26), _topHeaderLbl.center.y);
}

-(void)showLeftViewWithLeftSliderAnimated:(BOOL)animated
{
//    [self.viewDeckController toggleLeftViewAnimated:animated];
}

-(UINavigationController *)rootNavigationController
{
    UINavigationController * naVC = self.navigationController;
    if(naVC)
    {
        return naVC;
    }

    AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController * rootVC = appDel.window.rootViewController;
    if(![rootVC isKindOfClass:[UINavigationController class]])
    {
        naVC = rootVC.navigationController;
    }else
    {
        naVC = (UINavigationController *)rootVC;
    }
    return naVC;
}

#pragma mark ---
#pragma mark - Private Methods
-(void)tapedOnLeftBtnShowSlider
{
    [self showLeftViewWithLeftSliderAnimated:YES];
    self.coverBackBtn.hidden = NO;
}

-(void)tapedOnCloseSlider
{
    self.coverBackBtn.hidden = YES;
//    [self.viewDeckController closeLeftViewAnimated:YES];
}
- (void)leftAction
{
    UINavigationController * naVC = self.navigationController;
    if(!naVC){
        naVC = [self rootNavigationController];
    }
    [naVC popViewControllerAnimated:YES];
}

-(void)submit
{
    NSLog(@"DPViewController %s",__FUNCTION__);
}
#pragma mark ---


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
