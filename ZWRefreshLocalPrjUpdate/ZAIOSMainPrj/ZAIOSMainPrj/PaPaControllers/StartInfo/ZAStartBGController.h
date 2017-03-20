//
//  ZAStartBGController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "ZAStartCustomCell.h"
#import "ZATopNumView.h"
#import "TPKeyboardAvoidingTableView.h"
//实现统一的背景，统一列表，统一底部按钮,返回按钮
@interface ZAStartBGController : DPWhiteTopController<UITableViewDataSource,UITableViewDelegate>
{
    UILabel * topGuideLbl;
    UIButton * bottomBtn;
    UITableView * startTableview;
    ZATopNumView * topNumView;
}




@end
