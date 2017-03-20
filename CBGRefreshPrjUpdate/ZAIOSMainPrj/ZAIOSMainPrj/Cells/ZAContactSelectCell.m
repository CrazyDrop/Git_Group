//
//  ZAContactSelectCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactSelectCell.h"
#import "NSString+EmojiString.h"
@interface ZAContactSelectCell()<UITextFieldDelegate>
@end
@implementation ZAContactSelectCell
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
    
    CGFloat startX = FLoatChange(50);
    CGFloat endX = FLoatChange(15);
    UIFont * font = [UIFont systemFontOfSize:FLoatChange(14)];
    
    rect.origin.x = startX;
    rect.size.width -= (rect.origin.x + endX);
    
//    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
//    lbl.font = font;
//    lbl.backgroundColor = [UIColor clearColor];
//    lbl.textColor = [UIColor grayColor];
//    self.contactTxtTfd = lbl;
//    [bgView addSubview:lbl];
//    lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UITextField * tfd = [[ZATextField alloc] initWithFrame:rect];
    tfd.font = font;
    [bgView addSubview:tfd];
//    tfd.delegate = self;
    self.contactTxtTfd = tfd;
    tfd.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tfd.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UIView * line = [DZUtils ToolCustomLineView];
    line.center = CGPointMake(endX + SCREEN_WIDTH /2.0, bgView.bounds.size.height - line.bounds.size.height/2.0);
    line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:line];
    self.bottomLine = line;
    
    CGSize aSize = [@"关系:  " sizeWithFont:font];
    rect.origin.x += aSize.width;
    rect.size.width -= aSize.width;
    
    
    CGFloat imgWidth = FLoatChange(17);
    CGSize size = CGSizeMake(imgWidth, imgWidth / 36.0 * 30.0);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btn.backgroundColor = [UIColor redColor];
//    [btn setBackgroundImage:[UIImage imageNamed:@"select_arrow"] forState:UIControlStateNormal];
    btn.frame = CGRectMake((startX - imgWidth)/2.0, 0, size.width, size.height);
    btn.center = CGPointMake(startX/2.0 + 5, bgView.bounds.size.height/2.0);
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [bgView addSubview:btn];
    btn.userInteractionEnabled = NO;
    self.selectedArrow = btn;
    btn.backgroundColor = [UIColor clearColor];
    [btn setImage:[UIImage imageNamed:@"select_arrow"] forState:UIControlStateNormal];
//
//    self.endEditBtn = btn;
    
    UILabel * lbl =  [[UILabel alloc] initWithFrame:self.bounds];
    [bgView addSubview:lbl];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.coverLbl = lbl;
    lbl.font = tfd.font;
    lbl.hidden = YES;
    
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
