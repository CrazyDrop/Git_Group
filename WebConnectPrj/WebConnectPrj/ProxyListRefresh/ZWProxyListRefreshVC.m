//
//  ZWProxyListRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/9/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWProxyListRefreshVC.h"
#import "ZALocationLocalModel.h"
#import "ZWProxyListReqModel.h"
@interface ZWProxyListRefreshVC ()

@end

@implementation ZWProxyListRefreshVC

- (void)viewDidLoad {
    self.viewTtle = @"代理抓取";
    self.rightTitle = @"查看";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

-(void)startRefreshDataModelRequest
{
    
    
    ZWProxyListReqModel * listRequest = (ZWProxyListReqModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    //    if(self.inWebRequesting)
    //    {
    //        return;
    //    }
    //    self.inWebRequesting = YES;
    
    NSLog(@"%s",__FUNCTION__);
    
    ZWProxyListReqModel * model = (ZWProxyListReqModel *)_dpModel;
    //    CBGZhaohuanListRequestModel * model = (CBGZhaohuanListRequestModel *)_dpModel;
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ZWProxyListReqModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    
    [model sendRequest];
}

#pragma mark ZWProxyListReqModel
handleSignal( ZWProxyListReqModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( ZWProxyListReqModel, requestLoading )
{
    [self showLoading];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    [self showLoading];
}


handleSignal( ZWProxyListReqModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);

    //数据整理
    ZWProxyListReqModel * model = (ZWProxyListReqModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObjectsFromArray:obj];
        }
    }
    
    //数据存储
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager localSaveProxyListWithDetailListArray:detailModels];
    
    
}

-(void)submit
{
    ZALocationLocalModelManager *dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * nums = [dbManager localSaveTotalEquipProxyListArray];
    NSString * tipsStr = [NSString stringWithFormat:@"当前代理总数:%ld",[nums count]];
    [DZUtils noticeCustomerWithShowText:tipsStr];
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
