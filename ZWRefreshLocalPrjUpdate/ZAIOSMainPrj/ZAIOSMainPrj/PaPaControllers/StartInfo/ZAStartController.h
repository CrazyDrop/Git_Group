//
//  ZAStartController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"
#import "TPKeyboardAvoidingTableView.h"
@interface ZAStartController : DPViewController<UITableViewDataSource,UITableViewDelegate>
{
    UILabel * topGuideLbl;
    UIView * topSelectView;
    UIView * topSelectBGView;
    
    UIButton * bottomBtn;
    UITableView * startTableview;
}

@end
