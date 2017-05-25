//
//  ZAAutoBuySettingVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZAAutoBuySettingVC.h"
#import "ZAPanicPayHistoryVC.h"

@interface ZAAutoBuySettingVC ()
{
    UITextField * oldPwdLbl;
    UITextField * newPwdTfd;
}
@end

@implementation ZAAutoBuySettingVC

- (void)viewDidLoad
{
    self.viewTtle = @"参数设置";
    self.rightTitle = @"保存";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    
    CGFloat eveHeight = FLoatChange(45);
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height = eveHeight * 2;
    
    
    CGFloat topY = FLoatChange(10);
    rect.origin.y += topY;
    CGFloat startX = FLoatChange(15);
    
    UIView * whiteView = [[UIView alloc] initWithFrame:rect];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    
    UIView * topLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:topLine];
    
    UITextField * tfd = [[UITextField alloc] initWithFrame:CGRectMake(startX, 0, SCREEN_WIDTH - startX, eveHeight)];
    
    [whiteView addSubview:tfd];
    tfd.font = [UIFont systemFontOfSize:FLoatChange(15)];
    tfd.backgroundColor = [UIColor clearColor];
    NSInteger pwd =  local.limitRate;;
    tfd.keyboardType = UIKeyboardTypeNumberPad;
    tfd.text = [NSString stringWithFormat:@"当前购买比例:%ld",pwd];
    tfd.placeholder = @"默认比例20";
    oldPwdLbl = tfd;
    //    tfd.text = @"所有设置页面在预警启动后均不可见，信息无外泄风险";
    
    
    UIView * centerLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:centerLine];
    centerLine.center = CGPointMake(startX + SCREEN_WIDTH/2.0, eveHeight);
    
    
    tfd = [[UITextField alloc] initWithFrame:CGRectMake(startX , eveHeight, SCREEN_WIDTH - startX, eveHeight)];
    [whiteView addSubview:tfd];
    tfd.placeholder = @"默认价格限制10000";
    NSInteger price =  local.limitPrice;;
    tfd.text = [NSString stringWithFormat:@"当前上限价格:%ld",price];
    tfd.font = [UIFont systemFontOfSize:FLoatChange(15)];
    newPwdTfd = tfd;
    tfd.keyboardType = UIKeyboardTypeNumberPad;
    
    UIView * bottomLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:bottomLine];
    bottomLine.center = CGPointMake(SCREEN_WIDTH/2.0,eveHeight * 2.0 - bottomLine.bounds.size.height/2.0);
    
    UILabel * aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FLoatChange(30))];
    [whiteView addSubview:aLbl];
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    aLbl.text = @"价格设置0即关闭,开启需先登录";
    aLbl.textColor = [UIColor darkGrayColor];
    [aLbl sizeToFit];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0,  + whiteView.bounds.size.height + aLbl.bounds.size.height/2.0 + FLoatChange(15));
    aLbl.userInteractionEnabled = YES;
    
    UIButton * bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.frame = CGRectMake(0, 0, 100, 80);
    [bottomBtn setBackgroundColor:[UIColor greenColor]];
    [bottomBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bottomBtn setTitle:@"重置" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(tapedOnClearLatestSetting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
    bottomBtn.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(whiteView.frame) + 100);
    
    CGFloat maxY = CGRectGetMaxY(bottomBtn.frame);
    bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.frame = CGRectMake(0, 0, 100, 80);
    [bottomBtn setBackgroundColor:[UIColor greenColor]];
    [bottomBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bottomBtn setTitle:@"历史" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(tapedOnClearLatestSetting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
    bottomBtn.center = CGPointMake(SCREEN_WIDTH/2.0, maxY + 100);

}
-(void)showPanicHistoryList
{
    ZAPanicPayHistoryVC * payHis = [[ZAPanicPayHistoryVC alloc] init];
    [[self rootNavigationController] pushViewController:payHis animated:YES];
}

-(void)tapedOnClearLatestSetting
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.limitPrice = 10000;
    total.limitRate = 20;
    [total localSave];
    
    [DZUtils noticeCustomerWithShowText:@"重置结束"];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
-(void)submit
{
    //进行密码保存
    NSString * rate = oldPwdLbl.text;
    NSString * price = newPwdTfd.text;

    rate = [DZUtils detailNumberStringSubFromBottomCombineStr:rate];
    price = [DZUtils detailNumberStringSubFromBottomCombineStr:price];
    
    if([rate integerValue] > 0)
    {
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.limitRate = [rate integerValue];
        [total localSave];

    }
    
    if([price integerValue] > 0)
    {
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.limitPrice = [price integerValue];
        [total localSave];
    }
    
    [DZUtils noticeCustomerWithShowText:@"操作结束"];
}




@end
