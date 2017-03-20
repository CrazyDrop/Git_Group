//
//  WWSideslipViewController.m
//  WWSideslipViewControllerSample
//
//  Created by 王维 on 14-8-26.
//  Copyright (c) 2014年 wangwei. All rights reserved.
//

#import "WWSideslipViewController.h"

@interface WWSideslipViewController ()
@property (nonatomic,assign) BOOL isLeftOpen;
@end

@implementation WWSideslipViewController
@synthesize speedf,sideslipTapGes;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.view addSubview:mainControl.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(instancetype)initWithLeftView:(UIViewController *)LeftView
                    andMainView:(UIViewController *)MainView
                   andRightView:(UIViewController *)RighView
                        andBackgroundImage:(UIImage *)image;
{
    if(self){
        speedf = 0.5;
        
        leftControl = LeftView;
        mainControl = MainView;
        righControl = RighView;
        
        UIImageView * imgview = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [imgview setImage:image];
        [self.view addSubview:imgview];
        
        //滑动手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [mainControl.view addGestureRecognizer:pan];
        
        
        //单击手势
        sideslipTapGes= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handeTap:)];
        [sideslipTapGes setNumberOfTapsRequired:1];
        
        [mainControl.view addGestureRecognizer:sideslipTapGes];
        
        leftControl.view.hidden = YES;
        righControl.view.hidden = YES;
        
        [self.view addSubview:leftControl.view];
        [self.view addSubview:righControl.view];
        
        [self.view addSubview:mainControl.view];
        
    }
    return self;
}



#pragma mark - 滑动手势

//滑动手势
- (void) handlePan: (UIPanGestureRecognizer *)rec{
    
    CGPoint point = [rec translationInView:self.view];
    
    scalef = (point.x*speedf+scalef);

    //根据视图位置判断是左滑还是右边滑动
    if (rec.view.frame.origin.x>=0){
        rec.view.center = CGPointMake(rec.view.center.x + point.x*speedf,rec.view.center.y);
        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-scalef/1000,1-scalef/1000);
        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
        
        righControl.view.hidden = YES;
        leftControl.view.hidden = NO;
        
    }
    else
    {
        rec.view.center = CGPointMake(rec.view.center.x + point.x*speedf,rec.view.center.y);
        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1+scalef/1000,1+scalef/1000);
        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
    
        
        righControl.view.hidden = NO;
        leftControl.view.hidden = YES;
    }

    
    
    //手势结束后修正位置
    if (rec.state == UIGestureRecognizerStateEnded) {
        if (scalef>140*speedf){
            [self showLeftView];
        }
        else if (scalef<-140*speedf) {
            [self showRighView];        }
        else
        {
            [self showMainView];
            scalef = 0;
        }
    }

}


#pragma mark - 单击手势
-(void)handeTap:(UITapGestureRecognizer *)tap{
    
    if (tap.state == UIGestureRecognizerStateEnded) {
        [UIView beginAnimations:nil context:nil];
        tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        tap.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
        [UIView commitAnimations];
        scalef = 0;

    }

}

#pragma mark - 修改视图位置
//恢复位置
-(void)showMainView{
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    mainControl.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    [UIView commitAnimations];
}

//显示左视图
-(void)showLeftView{
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
    CGFloat endPoint = SCREEN_WIDTH * 0.9;
    mainControl.view.center = CGPointMake(endPoint,[UIScreen mainScreen].bounds.size.height/2);
    [UIView commitAnimations];

}

//显示右视图
-(void)showRighView{
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
    CGFloat startPoint = SCREEN_WIDTH * 0.2 * -1;
    mainControl.view.center = CGPointMake(startPoint,[UIScreen mainScreen].bounds.size.height/2);
    [UIView commitAnimations];
}

- (void)toggleLeftView
{
    if(self.isLeftOpen) [self showMainView];
    [self showLeftView];
}

#warning 为了界面美观，所以隐藏了状态栏。如果需要显示则去掉此代码
- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hiden
}

@end

@implementation UIViewController (WWSlideViewController)
//
//static const char* WWSlideViewControllerKey = "WWSlideViewControllerKey";
//
//- (WWSideslipViewController*)viewDeckController_core {
//    return objc_getAssociatedObject(self, WWSlideViewControllerKey);
//}
//
//- (WWSideslipViewController*)viewDeckController {
//    WWSideslipViewController* result = [self viewDeckController_core];
//    if (!result && self.navigationController) {
//        result = [self.navigationController viewDeckController_core];
//        if (!result) {
//            for (UIViewController* controller in [self.navigationController.viewControllers reverseObjectEnumerator]) {
//                if ([controller isKindOfClass:[WWSideslipViewController class]])
//                    result = (WWSideslipViewController*)controller;
//                else
//                    result = [controller viewDeckController_core];
//                //                if (result) {//当前逻辑内无IIViewDeckNavigationControllerIntegrated状态，IIViewDeckNavigationControllerContained异常
//                //                    if (result.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated)
//                //                        break;
//                //                    result = nil;
//                //                }
//            }
//        }
//    }
//    
//    UIViewController * containVC = self.tabBarController;
//    if (!result && containVC)
//    {
//        result = [containVC viewDeckController];
//        if (!result && containVC.navigationController)
//        {
//            result = [containVC.navigationController viewDeckController_core];
//            if (!result) {
//                for (UIViewController* controller in [containVC.navigationController.viewControllers reverseObjectEnumerator]) {
//                    if ([controller isKindOfClass:[WWSideslipViewController class]])
//                        result = (WWSideslipViewController*)controller;
//                    else
//                        result = [controller viewDeckController_core];
////                    if (result) {
////                        if (result.navigationControllerBehavior == IIViewDeckNavigationControllerIntegrated)
////                            break;
////                        result = nil;
////                    }
//                }
//            }
//        }
//    }
//    
//    return result;
//}
//
//- (void)setViewDeckController:(WWSideslipViewController*)viewDeckController
//{
//    objc_setAssociatedObject(self, WWSlideViewControllerKey, viewDeckController, OBJC_ASSOCIATION_ASSIGN);
//}
//
//

@end


