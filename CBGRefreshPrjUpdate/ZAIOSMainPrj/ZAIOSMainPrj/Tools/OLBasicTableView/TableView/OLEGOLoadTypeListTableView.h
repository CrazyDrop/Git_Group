//
//  OLEGOLoadTypeListTableView.h
//  WebConnectPrj
//
//  Created by Apple on 15/2/12.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOCustomListTableView.h"
//可以指定刷新形式，此处刷新形式为默认效果，建议不要修改
//主要完成混合刷新形式的功能
@interface OLEGOLoadTypeListTableView : OLEGOCustomListTableView

//加载更多样式，设置此属性之后，egofooter的设置无效
@property (nonatomic,assign) OL_LIST_DATA_LOAD_TYPE loadMoreType;

//下拉刷新样式，设置此属性之后，egoheader的设置无效
@property (nonatomic,assign) OL_LIST_DATA_LOAD_TYPE loadRefreshType;

//仅当设置类型为混合时有效
@property (nonatomic,assign) CGFloat effectiveHeight;





@end
