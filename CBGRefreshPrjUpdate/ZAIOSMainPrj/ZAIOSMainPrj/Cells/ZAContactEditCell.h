//
//  ZAContactEditCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPTableViewCell.h"

@interface ZAContactEditCell : DPTableViewCell
{
    
}
@property (nonatomic,strong) UILabel * headerLbl;
@property (nonatomic,strong) UITextField * editTfd;
@property (nonatomic,strong) UIButton * endEditBtn;
@property (nonatomic,strong) UIView * bottomLine;


@end
