//
//  ZANameEditController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/22.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZANameEditController.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface ZANameEditController ()
{
    UITextField * oldNameLbl;
    UITextField * newNameTfd;
    BOOL refreshed;
}
@end
@implementation ZANameEditController

- (void)viewDidLoad {
    NSString * str = @"刷新地址";
    str =[str stringByAppendingFormat:@"%@",self.local1?@"1":@"2"];
    self.viewTtle = str;
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
    
    TPKeyboardAvoidingScrollView * whiteView = nil;
//    [[UIView alloc] initWithFrame:rect];
    whiteView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:rect];
    whiteView.scrollEnabled = NO;
    
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    
    UIView * topLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:topLine];
    
    
    UITextField * tfd = [[UITextField alloc] initWithFrame:CGRectMake(startX, 0, SCREEN_WIDTH - startX, eveHeight)];
    [whiteView addSubview:tfd];
    tfd.font = [UIFont systemFontOfSize:FLoatChange(11)];
    tfd.backgroundColor = [UIColor clearColor];
    NSString * userName =  local.localURL2;
    if(self.local1) userName = local.localURL1;
    tfd.text = [NSString stringWithFormat:@"URL:%@",userName];
    oldNameLbl = tfd;
    tfd.userInteractionEnabled = NO;
    
    UIView * centerLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:centerLine];
    centerLine.center = CGPointMake(startX + SCREEN_WIDTH/2.0, eveHeight);
    
    
    tfd = [[UITextField alloc] initWithFrame:CGRectMake(startX, eveHeight, SCREEN_WIDTH - startX, eveHeight)];
    [whiteView addSubview:tfd];
    tfd.placeholder = @"新URL";
    tfd.font = [UIFont systemFontOfSize:FLoatChange(11)];
    newNameTfd = tfd;
    tfd.delegate = self;
    
    
    UIView * bottomLine = [DZUtils ToolCustomLineView];
    [whiteView addSubview:bottomLine];
    bottomLine.center = CGPointMake(SCREEN_WIDTH/2.0,eveHeight * 2.0 - bottomLine.bounds.size.height/2.0);
    
    
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self firstTfdBecomeResponsder];
}

-(void)firstTfdBecomeResponsder
{
    if(refreshed) return;
    [newNameTfd becomeFirstResponder];
    refreshed = YES;
}

-(void)submit
{
    //进行密码保存
    NSString * inputName = newNameTfd.text;
    
    
    ZALocalStateTotalModel  * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * rate = inputName;
//    if(rate && [[rate componentsSeparatedByString:@","] count]==12)
    {
        if(self.local1)
        {
             total.localURL1 = rate;
        }else{
             total.localURL2 = rate;
        }
        [total localSave];
    }
    
//    NSString * errorStr = nil;
//    //判定本地密码
//    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:inputName];
//    if(errorStr)
//    {
//        [DZUtils noticeCustomerWithShowText:errorStr];
//        return;
//    }
//    
//    
//    //数据上传
//    ModifyUserInfoModel  * model = (ModifyUserInfoModel *) _dpModel;
//    if(!model){
//        model = [[ModifyUserInfoModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    model.username = inputName;
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
    total.userInfo.username = [model.username copy];
    [total localSave];
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
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
