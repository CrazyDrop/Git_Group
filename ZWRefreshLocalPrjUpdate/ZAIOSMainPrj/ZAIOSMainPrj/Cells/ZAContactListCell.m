//
//  ZAContactListCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListCell.h"
@interface ZAContactListCell()
{
    
}
@property (nonatomic,strong) UIButton * rightBtn;
@end
@implementation ZAContactListCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andTableView:(UITableView *)table
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                             icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                             icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                             icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                             icon:[UIImage imageNamed:@"list.png"]];
    
//    [rightUtilityButtons addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                             title:@"More"];
    [rightUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                             title:@"删除"];
    
    self = [super initWithStyle:style
                                  reuseIdentifier:reuseIdentifier
                              containingTableView:table // Used for row height and selection
                               leftUtilityButtons:nil
                              rightUtilityButtons:rightUtilityButtons];
    if(self)
    {
        [self createCellSubViews];
    }
    return self;
}


-(void)createCellSubViews
{

    CGFloat imgWidth = FLoatChange(21);
    CGSize imgSize = CGSizeMake(imgWidth, imgWidth / 21.0 * 38.0);
    UIView * bgView = self.scrollViewContentView;
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH - 20 - imgSize.width,(bgView.bounds.size.height - imgSize.height)/ 2.0 , imgSize.width, imgSize.height);
    [btn setImage:[UIImage imageNamed:@"detail_arrow"] forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
    self.rightBtn = btn;
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIView * topLine = [DZUtils ToolCustomLineView];
    [bgView addSubview:topLine];
    topLine.backgroundColor = [UIColor lightGrayColor];
    topLine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

    
    UIView * bottomLine = [DZUtils ToolCustomLineView];
    [bgView addSubview:bottomLine];
    bottomLine.center = CGPointMake(SCREEN_WIDTH/2.0, bgView.bounds.size.height - bottomLine.bounds.size.height/2.0);
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
}


-(void)scrollArrowWithOpenState:(BOOL)open animated:(BOOL)animated{
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
