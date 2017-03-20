//
//  OLEGOPullTextFooterView.h
//  WebConnectPrj
//
//  Created by Apple on 15/1/30.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGORefreshView.h"
//文本形式的上拉加载更多，模仿糗百
@interface OLEGOPullTextFooterView : OLEGORefreshView
{
    UILabel * _statusLabel;
    UIActivityIndicatorView *_activityView;
}


@end
