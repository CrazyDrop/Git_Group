//
//  ZAStartCustomCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartCustomCell.h"
#import "NSString+EmojiString.h"
@interface ZAStartCustomCell()<UITextFieldDelegate>
@end
@implementation ZAStartCustomCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self createCellSubViews];
    }
    return self;
}
-(void)createCellSubViews
{
    UIView * bgView = self;

    CGRect rect = bgView.bounds;
    rect.size.width = SCREEN_WIDTH;
    
    //实际使用高度
    CGFloat needHeight = FLoatChange(39);

    
    CGFloat startX = FLoatChange(25);
    CGFloat imgExtend = FLoatChange(20);
    CGFloat endX = FLoatChange(60);
    UIFont * font = [UIFont systemFontOfSize:FLoatChange(14)];
    
    CGFloat centerY = self.bounds.size.height - needHeight/2.0;
    
    rect.origin.x = startX;
    rect.size.width -= (startX * 2);
    
    //底线
    UIView * line = [DZUtils ToolCustomLineView];
    rect.size.height = line.bounds.size.height;
    line.frame = rect;
    line.center = CGPointMake(SCREEN_WIDTH/2.0, bgView.bounds.size.height - line.bounds.size.height/2.0);
    line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:line];
    self.bottomLine = line;

    //图片
    CGFloat imgWidth = FLoatChange(17);
    CGSize imgSize = CGSizeMake(imgWidth, needHeight);
    rect.size = imgSize;
    rect.origin.x = (startX + imgExtend);
    UIImageView * aImg = [[UIImageView alloc] initWithFrame:rect];
    [bgView addSubview:aImg];
    aImg.contentMode = UIViewContentModeScaleAspectFit;
    self.headerImg = aImg;
    aImg.center = CGPointMake(aImg.center.x,centerY);
    aImg.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    //输入框
    rect.origin.x = startX + imgExtend + imgSize.width + FLoatChange(10);
    rect.origin.y = 0;
    rect.size.height = self.bounds.size.height;
    rect.size.width = SCREEN_WIDTH - endX - rect.origin.x;
    
    UITextField * tfd = [[ZATextField alloc] initWithFrame:rect];
    tfd.font = font;
    tfd.backgroundColor = [UIColor clearColor];
    tfd.textColor = [UIColor grayColor];
    self.editTfd = tfd;
//    tfd.delegate = self;
    [bgView addSubview:tfd];
    tfd.center = CGPointMake(tfd.center.x,centerY);
    tfd.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    tfd.delegate = self;
    
    //索引按钮
    imgWidth = FLoatChange(10);
    CGSize size = CGSizeMake(imgWidth, imgWidth / 21.0 * 38.0);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btn.backgroundColor = [UIColor redColor];
    [btn setBackgroundImage:[UIImage imageNamed:@"detail_arrow"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(SCREEN_WIDTH - endX, 0, size.width, size.height);
    btn.center = CGPointMake(btn.center.x, centerY);
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:btn];
    btn.userInteractionEnabled = NO;
    self.endEditBtn = btn;
}
-(void)refreshHeaderImgWith
{
    //修改headerImg大小
    
    //之前大小//展示比例  42/50
    CGFloat preWidth = FLoatChange(17);
    CGFloat height = preWidth / 42.0 * 50.0;
    
    //之后大小，//展示比例 52/47
    CGFloat imgWidth = height /47.0 * 52.0;
    
    CGSize size = CGSizeMake(imgWidth , height);
    
    CGPoint preCenter = self.headerImg.center;
    CGRect rect = self.headerImg.frame;
    rect.size = size;
    self.headerImg.frame = rect;
    self.headerImg.center = preCenter;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * nameStr = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([nameStr isEqualToString:@"emoji"])
    {
        return NO;
    }
    
    //    //emoji无效
    //    if([NSString stringContainsEmoji:string])
    //    {
    //        return NO;
    //    }
    
    string = [string inputStringExcept9Input];
    if([string stringContainSpecialCharacters])
    {
        return NO;
    }
    
    return YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
