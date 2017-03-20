//
//  ShareInputView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ShareInputView.h"
#import "PGTextView.h"
#define ShareInputBtnAddNum 100
@interface ShareInputView()
{
    UITextView * inputTXTView;
}
@end

@implementation ShareInputView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) [self createShareView];
    return self;
}

-(void)createShareView
{
    UIView * bgView = self;
    
    CGSize viewSize = self.bounds.size;
    
    CGFloat sep_Y = 10;
    CGFloat startY = sep_Y;
    //标题
    UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, startY, viewSize.width, 40)];
    titleLbl.text = @"众安保险";
    [bgView addSubview:titleLbl];
    titleLbl.font = [UIFont systemFontOfSize:18];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [titleLbl sizeToFit];
    titleLbl.center = CGPointMake(viewSize.width/2.0, titleLbl.bounds.size.height/2.0 + sep_Y);
    
    startY += titleLbl.bounds.size.height;
    startY += sep_Y;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,startY, viewSize.width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineView];
    
    startY += sep_Y/2.0;
    //左侧icon 来源
    CGFloat leftWidth = viewSize.width/3.0;
    CGFloat logWidth = 60;
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logWidth, logWidth)];
    imgView.image = [UIImage imageNamed:@"QQLogin"];
    [bgView addSubview:imgView];
    imgView.center = CGPointMake(leftWidth/2.0 , startY + logWidth/2.0);
    
    startY += logWidth;
    startY += sep_Y/2.0;
    
    UILabel * fromLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftWidth, 40)];
    fromLbl.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:fromLbl];
    fromLbl.text = @"来自:众安保险";
    fromLbl.textColor = [UIColor lightGrayColor];
    fromLbl.backgroundColor = [UIColor clearColor];
    [fromLbl sizeToFit];
    fromLbl.center = CGPointMake(leftWidth/2.0,startY + fromLbl.bounds.size.height/2.0);
    
    startY += fromLbl.bounds.size.height;
    startY += sep_Y/2.0;
    
    //输入框
    PGTextView * shareText = [[PGTextView alloc] initWithFrame:CGRectMake(0, startY, viewSize.width, 30)];
    shareText.font = [UIFont systemFontOfSize:16];
    shareText.placeHolder = @"说些什么";
    shareText.placeholderColor = [UIColor darkGrayColor];
    [bgView addSubview:shareText];
    inputTXTView = shareText;
    
    
    startY += shareText.bounds.size.height;
    startY += sep_Y/2.0;

    lineView = [[UIView alloc] initWithFrame:CGRectMake(0,startY, viewSize.width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineView];
    
    //底部按钮
    CGFloat btnWidth = viewSize.width/2.0;
    UIButton *tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapBtn setTitle:@"取消" forState:UIControlStateNormal];
    tapBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    tapBtn.tag = 0+ShareInputBtnAddNum;
    [tapBtn addTarget:self action:@selector(tapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    tapBtn.frame = CGRectMake(0, startY, btnWidth, viewSize.height - startY);
    [bgView addSubview:tapBtn];
    [tapBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tapBtn setBackgroundColor:[UIColor clearColor]];

    
    tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapBtn setTitle:@"分享" forState:UIControlStateNormal];
    tapBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    tapBtn.tag = 1+ShareInputBtnAddNum;
    [tapBtn addTarget:self action:@selector(tapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    tapBtn.frame = CGRectMake(btnWidth, startY, btnWidth, viewSize.height - startY);
    [bgView addSubview:tapBtn];
    [tapBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tapBtn setBackgroundColor:[UIColor clearColor]];

    CGFloat sep_min = 3;
    lineView = [[UIView alloc] initWithFrame:CGRectMake(btnWidth -1 ,startY + sep_min, 1, viewSize.height - startY - sep_min)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineView];
    
    //右侧  文本
    CGPoint rightPt = imgView.center;
    rightPt.x = (viewSize.width - leftWidth)/2.0 + leftWidth;
    UILabel * rightLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (viewSize.width - leftWidth), 40)];
    rightLbl.numberOfLines = 0;
    rightLbl.font = [UIFont systemFontOfSize:16];
    rightLbl.text = kShareAPP_URL_DES_TXT;
    [bgView addSubview:rightLbl];
    [rightLbl sizeToFit];
    rightLbl.center = rightPt;
    
}


-(void)tapedOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    int tag = btn.tag - ShareInputBtnAddNum;
    if(self.TapedOnBottomBtnBlock)
    {
        NSString * text = inputTXTView.text;
        self.TapedOnBottomBtnBlock(tag,text);
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
