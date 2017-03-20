//
//  ZAContactSelectCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPTableViewCell.h"
//完成列表的选中功能
@interface ZAContactSelectCell : DPTableViewCell

@property (nonatomic,strong) UIView * selectedArrow;
@property (nonatomic,strong) UILabel * coverLbl;
@property (nonatomic,strong) UITextField * contactTxtTfd;
@property (nonatomic,strong) UIView * bottomLine;


@end
