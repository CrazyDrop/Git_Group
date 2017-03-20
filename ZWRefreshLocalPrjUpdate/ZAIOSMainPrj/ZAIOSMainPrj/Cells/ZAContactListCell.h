//
//  ZAContactListCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "SWTableViewCell.h"
//头部顶行的cell
@interface ZAContactListCell : SWTableViewCell
@property (nonatomic,strong,readonly) UIButton * rightBtn;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andTableView:(UITableView *)table;

-(void)scrollArrowWithOpenState:(BOOL)open animated:(BOOL)animated;


@end
