//
//  ZAPWDEditController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAPWDEditController.h"

@interface ZAPWDEditController ()
{
    UITextField * oldPwdLbl;
    UITextField * newPwdTfd;
    BOOL refreshed;
}
@end

@implementation ZAPWDEditController

- (void)viewDidLoad {
    self.viewTtle = @"一年内利率";
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
    CGFloat startX = FLoatChange(10);
    
    UIView * whiteView = [[UIView alloc] initWithFrame:rect];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    
    UIView * topLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:topLine];

    UITextField * tfd = [[UITextField alloc] initWithFrame:CGRectMake(startX, 0, SCREEN_WIDTH - startX, eveHeight)];

    [whiteView addSubview:tfd];
    tfd.font = [UIFont systemFontOfSize:FLoatChange(9)];
    tfd.backgroundColor = [UIColor clearColor];
//    NSString * pwd =  local.password;;
    
    NSString * yearNumStr = kAPP_YEAR_TOTAL_RATE_NUMBER;
    ZALocalStateTotalModel  * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * rate = total.sellRateStr;
    if(rate && [[rate componentsSeparatedByString:@","] count]==14)
    {
        yearNumStr = rate;
    }
    tfd.text = [NSString stringWithFormat:@"%@",yearNumStr];
    oldPwdLbl = tfd;
    tfd.userInteractionEnabled = NO;
    
    UIView * centerLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:centerLine];
    centerLine.center = CGPointMake(startX + SCREEN_WIDTH/2.0, eveHeight);
    
    
    tfd = [[UITextField alloc] initWithFrame:CGRectMake(startX , eveHeight, SCREEN_WIDTH - startX, eveHeight)];
    [whiteView addSubview:tfd];
    tfd.placeholder = @"新利率";
    tfd.font = [UIFont systemFontOfSize:FLoatChange(9)];
    newPwdTfd = tfd;
    tfd.keyboardType = UIKeyboardTypeNumberPad;
    tfd.backgroundColor = [UIColor clearColor];
    tfd.text = yearNumStr;
    
    UIView * bottomLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:bottomLine];
    bottomLine.center = CGPointMake(SCREEN_WIDTH/2.0,eveHeight * 2.0 - bottomLine.bounds.size.height/2.0);
    
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(startX , eveHeight, SCREEN_WIDTH - startX, eveHeight)];
    lbl.font = tfd.font;
    lbl.textColor = [UIColor grayColor];
    lbl.backgroundColor = [UIColor clearColor];
    NSArray * arr = [yearNumStr componentsSeparatedByString:@","];
    NSMutableString * result = [NSMutableString string];
    NSString * special = @"*";
    [result appendString:special];

    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result appendString:special];
        [result appendFormat:@"%lu",(unsigned long)(idx+1)];
        if(idx<10){
             [result appendString:special];
        }
        if(idx%7==0 && idx!=0){
            
        }else{
            [result appendString:special];
        };
    }];
    NSString * show = nil;
//    [result stringByReplacingOccurrencesOfString:special withString:@" "];
    show = result;
    lbl.text = show;
    [self.view addSubview:lbl];
    lbl.center = CGPointMake(tfd.center.x,CGRectGetMaxY(whiteView.frame) - eveHeight);
    lbl.hidden = SCREEN_Check_Special;

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self firstTfdBecomeResponsder];
}

-(void)firstTfdBecomeResponsder
{
    if(refreshed) return;
    [newPwdTfd becomeFirstResponder];
    refreshed = YES;
}

-(void)submit
{
    //进行密码保存
    NSString * pwd = newPwdTfd.text;

    NSString * errorStr = nil;
    
    ZALocalStateTotalModel  * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * rate = pwd;
    if(rate && [[rate componentsSeparatedByString:@","] count]==14)
    {
        total.sellRateStr = rate;
        [total localSave];
    }else{
        [DZUtils noticeCustomerWithShowText:@"总个数错误"];
    }
    
    //判定本地密码
//    errorStr = [ZATfdLocalCheck localCheckInputLocalPWDWithText:pwd];
//    if(errorStr)
//    {
//        [DZUtils noticeCustomerWithShowText:errorStr];
//        return;
//    }
    
    
//    //数据上传
//    ModifyUserInfoModel  * model = (ModifyUserInfoModel *) _dpModel;
//    if(!model){
//        model = [[ModifyUserInfoModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    model.password = pwd;
//    [model sendRequest];
    

}
#pragma mark ModifyUserInfoModel
handleSignal( ModifyUserInfoModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( ModifyUserInfoModel, requestLoading )
{
    [self showLoading];
}

handleSignal( ModifyUserInfoModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [self refreshWithSuccess];
    }
}
#pragma mark -
-(void)refreshWithSuccess
{
    //数据检查
    ModifyUserInfoModel  * model = (ModifyUserInfoModel *) _dpModel;

    //密码，用户名保存
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.userInfo.password = [model.password copy];
    total.password = [model.password copy];
    [total localSave];
    

    
    [self.navigationController popViewControllerAnimated:YES];
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
