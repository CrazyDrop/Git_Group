//
//  LYOldQQWebViewController.m
//  ShaiHuo
//
//  Created by 李言 on 14-9-16.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import "LYOldQQWebViewController.h"
#import "Samurai_Color.h"
#import "Samurai_Image.h"
#import "TencentOAuthOld.h"
@interface LYOldQQWebViewController ()

@end

@implementation LYOldQQWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.showLeftBtn = YES;
        self.viewTtle = @"QQ登录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.autoresizesSubviews = YES;
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.view.contentMode = UIViewContentModeRedraw;
    
    [self.view addSubview:_web];
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    _web.frame = CGRectMake(0, startY, SCREEN_WIDTH, SCREEN_HEIGHT-startY);
    [(TencentLoginViewOld *)_web show];
    
    
    //--------------------------------------------------------------
   UIImage *	image = [UIImage imageWithColor:RGB(248,248,248) size:[[UIScreen mainScreen] bounds].size];


    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 50, 44);
    //    [cancelButton setImage:[UIImage imageNamed:@"topback.png"] forState:UIControlStateNormal];
    [cancelButton setImageEdgeInsets:UIEdgeInsetsMake(11.75f, 19.25f-10, 11.75f, 19.25f+10)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
   // [cancelItem release];
    
//    
//    UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    refreshButton.frame = CGRectMake(0, 0, 50, 44);
//    //    [refreshButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
//    [refreshButton setImageEdgeInsets:UIEdgeInsetsMake(9.5f, 12.5f, 9.5f, 12.5f)];
//    [refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * refreshItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
//    self.navigationItem.rightBarButtonItem = refreshItem;
//    
//
   
    
    [cancelButton setImage:[UIImage imageNamed:@"后退箭头.png"] forState:UIControlStateNormal];
    
   
//    [refreshButton setImage:[UIImage imageNamed:@"个人页——未发布成功重新上传（刷新icon).png"] forState:UIControlStateNormal];
   // [refreshItem release];
//    UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
//    [self.view addSubview:aView];
//    aView.backgroundColor = [UIColor redColor];
    
   
    
  //
    
}
- (void)leftAction
{
    if([self.navigationController.viewControllers count]>2)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    UIViewController * disMiss = self.navigationController?self.navigationController:self;
    [disMiss dismissViewControllerAnimated:YES completion:nil];
}


//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarHidden = YES;
//
//
//}
//
//- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
//
//}
- (void)cancel
{
//    close = YES;
//    
//    [webView stopLoading];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
