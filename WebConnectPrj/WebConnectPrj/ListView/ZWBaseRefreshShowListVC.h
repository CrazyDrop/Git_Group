//
//  ZWBaseRefreshShowListVC.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"

@interface ZWBaseRefreshShowListVC : DPWhiteTopController
{
    NSLock * requestLock;
    BaseRequestModel * _detailListReqModel;
}
@property (nonatomic,strong) UIView * tipsView;
@property (nonatomic,strong) NSArray * showArray;
@property (nonatomic,strong) NSArray * detailsArr;
-(void)checkDetailErrorForTipsError;
-(void)startRefreshDataModelRequest;
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  replace:(BOOL)replace;

-(void)refreshTitleWithTitleTxt:(NSString *)title;


@end
