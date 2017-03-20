//
//  ZAStartCustomCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPTableViewCell.h"
//实现下划线,尾部后缀，文本编辑框，头部图片
@interface ZAStartCustomCell : DPTableViewCell

@property (nonatomic,strong) UIImageView * headerImg;
@property (nonatomic,strong) UITextField * editTfd;
@property (nonatomic,strong) UIButton * endEditBtn;
@property (nonatomic,strong) UIView * bottomLine;

-(void)refreshHeaderImgWith;

@end
