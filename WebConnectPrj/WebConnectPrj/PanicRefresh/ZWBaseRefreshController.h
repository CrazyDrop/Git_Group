//
//  ZWBaseRefreshController.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
//进行数据展示，数据提醒，web页面提前加载
@interface ZWBaseRefreshController : DPWhiteTopController
{
    NSLock * requestLock;
    BaseRequestModel * _detailListReqModel;
}
@property (nonatomic,strong,readonly) UIView * tipsView;
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  replace:(BOOL)replace;

@end
