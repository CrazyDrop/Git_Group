//
//  ZAContactEditCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactEditCell.h"
#import "NSString+EmojiString.h"
@interface ZAContactEditCell()<UITextFieldDelegate>

@end
@implementation ZAContactEditCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self createCellSubViews];
    }
    return self;
}
-(void)tapedOnEditBtn:(id)sender
{
    
}

-(void)createCellSubViews
{
    UIView * bgView = self;
    
    CGRect rect = bgView.bounds;
    rect.size.width = SCREEN_WIDTH;
    
    CGFloat startX = FLoatChange(13);
    CGFloat endX = FLoatChange(15);
    UIFont * font = [UIFont systemFontOfSize:FLoatChange(14)];
    
    rect.origin.x = startX;
    rect.size.width -= (startX + endX);
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
    lbl.font = font;
    lbl.backgroundColor = [UIColor clearColor];
    self.headerLbl = lbl;
    [bgView addSubview:lbl];
    lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIView * line = [DZUtils ToolCustomLineView];
    line.center = CGPointMake(startX + SCREEN_WIDTH /2.0, bgView.bounds.size.height - line.bounds.size.height/2.0);
    line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:line];
    self.bottomLine = line;
    
    CGSize aSize = [@"关系:  " sizeWithFont:font];
    rect.origin.x += aSize.width;
    rect.size.width -= aSize.width;
    
    UITextField * tfd = [[ZATextField alloc] initWithFrame:rect];
    tfd.font = font;
    tfd.backgroundColor = [UIColor clearColor];
//    tfd.delegate = self;
    self.editTfd = tfd;
    [bgView addSubview:tfd];
    tfd.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tfd.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    
    CGFloat imgWidth = FLoatChange(21);
    CGSize imgSize = CGSizeMake(imgWidth, imgWidth / 21.0 * 38.0);
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH - 20 - imgSize.width,(bgView.bounds.size.height - imgSize.height)/ 2.0 , imgSize.width, imgSize.height);
    [btn setImage:[UIImage imageNamed:@"detail_arrow"] forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;
    self.endEditBtn = btn;
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    

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
