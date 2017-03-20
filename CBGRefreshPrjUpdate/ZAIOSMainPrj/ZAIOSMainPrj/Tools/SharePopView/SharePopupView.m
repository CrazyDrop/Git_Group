//
//  SharePopupView.m
//  ShaiHuo
//
//  Created by 王晓宇 on 14-2-22.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import "SharePopupView.h"
#import "TextBottomButton.h"
#import "QQSpaceShare.h"
#import "WeixinShare.h"
@implementation SharePopupView
-(id)initWithType:(SharePopupViewType)type
{
    if (self=[super initWithFrame:CGRectZero])
    {
        // Initialization code
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        UIView * coverView = [[UIView alloc] initWithFrame:rect];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0.2;
        
        UIView *customView=[[UIView alloc]init];
        customView.backgroundColor= RGB(236, 236, 236);
        self.customPopupView=customView;
        
        //取消按钮
        _cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Button_Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_cancelButton setBackgroundColor:RGB(206, 206, 206)];

        
        [self.customPopupView addSubview:_cancelButton];
        
        self.type=type;
        switch (type)
        {
            case SharePopupViewType_OnlyShare:
            {
                [self initShareButtons];
                _shareInstagramBtn.hidden = YES;
                break;
            }
            case SharePopupViewType_ShareAndMore:
            {
                [self initShareButtons];
                [self initSettingButtons];
                break;
            }
            case SharePopupViewType_NoneMSG:
            {
                [self initShareButtons];
                break;
            }
            case SharePopupViewType_SharePath:
            {
                [self initShareButtonsForSharePath];
                break;
            }
            case SharePopupViewType_NoticeTA:
            {
                [self initShareButtonsForNoticeTA];
                break;
            }
            default:
                break;
        }
    }
    return self;
}
-(void)dealloc
{
    
}
-(id)init{
    NSAssert(false, @"--SharePopupView : use initWithType instead");
    return nil;
}
- (id)initWithFrame:(CGRect)frame
{
    NSAssert(false, @"--SharePopupView : use initWithType instead");
    return nil;
}
//-(void)refreshTitleEdgeInsetsForBtn:(UIButton *)button
//{
//    CGFloat imageWith = CGRectGetWidth(button.imageView.frame);
//    CGFloat imageHeight = CGRectGetHeight(button.imageView.frame);
//
//    CGFloat labelWidth = CGRectGetWidth(button.titleLabel.frame);
//    CGFloat labelHeight = CGRectGetHeight(button.titleLabel.frame);
//
//    
//    CGFloat imageOffsetX = (imageWith + labelWidth) / 2 - imageWith / 2;
//    CGFloat imageOffsetY = imageHeight / 2;
//    
////    button.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
//    button.imageEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
//    
//    CGFloat labelOffsetY = labelHeight / 2 + 10;
//    CGFloat labelOffsetX = (imageWith + labelWidth / 2) - (imageWith + labelWidth) / 2;
////    button.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
//    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -30, 0);
//}
-(void)refreshBtnCenterForPartShowWithBtn:(UIButton *)btn andLeft:(BOOL)leftOne
{
    CGPoint pt = btn.center;
    CGFloat centerX = FLoatChange(102);
    pt.x = leftOne?centerX:(SCREEN_WIDTH - centerX);
    btn.center = pt;
}
-(void)initShareButtonsForSharePath
{
    
    UIView * bgView = self.customPopupView;
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.font = [UIFont systemFontOfSize:FLoatChange(11)];
//    [titleLabel setText:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Title")];
    titleLabel.text = @"分享位置给好友";
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:titleLabel];
    
    BOOL WXHide = ![WXApi isWXAppInstalled];
    BOOL QQHide = ![TencentOAuth iphoneQQInstalled];
    
    CGPoint pt = CGPointMake(CGRectGetMidX(self.customPopupView.bounds), FLoatChange(60)/2.0 + FLoatChange(35));
    if(WXHide && QQHide)
    {
        //仅一个居中
        //短信
        UIButton * tapBtn = nil;
        tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
        [tapBtn setImage:[UIImage imageNamed:@"message_icon"] forState:UIControlStateNormal];
        [tapBtn setTitle:@"短信" forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_Message];
        [bgView addSubview:tapBtn];
        tapBtn.center = pt;
        
    }else if(!WXHide && !QQHide)
    {
        //三个均有
        CGFloat moveX = FLoatChange(80);
        
        pt.x -= moveX;
        //微信好友
        UIButton * tapBtn = nil;
        tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
        [tapBtn setImage:[UIImage imageNamed:@"wx_icon"] forState:UIControlStateNormal];
        [tapBtn setTitle:@"微信" forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_WXSession];
        [bgView addSubview:tapBtn];
        tapBtn.hidden = WXHide;
        tapBtn.center = pt;
//        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:YES];
        
        
        pt.x += moveX;
        //短信
        tapBtn=[self createTextBottomButtonWithIndexX:1 indexY:0];
        [tapBtn setTitle:@"短信" forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"message_icon"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_Message];
        [bgView addSubview:tapBtn];
        tapBtn.center = pt;
//        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:NO];
        
        
        pt.x += moveX;
        //QQ好友
        tapBtn=[self createTextBottomButtonWithIndexX:2 indexY:0];
        [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_QQ_Space_Title") forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"qq_icon"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_QQ];
        [bgView addSubview:tapBtn];
        tapBtn.hidden = QQHide;
        tapBtn.center = pt;
//        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:YES];
        
    }else
    {
        
        //微信好友
        UIButton * tapBtn = nil;
        tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
        [tapBtn setImage:[UIImage imageNamed:@"wx_icon"] forState:UIControlStateNormal];
        [tapBtn setTitle:@"微信" forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_WXSession];
        [bgView addSubview:tapBtn];
        tapBtn.hidden = WXHide;
        tapBtn.center = pt;
        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:YES];
        
        
        //短信
        tapBtn=[self createTextBottomButtonWithIndexX:1 indexY:0];
        [tapBtn setTitle:@"短信" forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"message_icon"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_Message];
        [bgView addSubview:tapBtn];
        tapBtn.center = pt;
        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:WXHide];
        
        
        //QQ好友
        tapBtn=[self createTextBottomButtonWithIndexX:2 indexY:0];
        [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_QQ_Space_Title") forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"qq_icon"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_QQ];
        [bgView addSubview:tapBtn];
        tapBtn.hidden = QQHide;
        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:NO];
    }
    ;
    UIButton * tapBtn = nil;
    tapBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    tapBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, FLoatChange(149 - 104));
    [tapBtn setTitle:@"一键发送位置给紧急联系人" forState:UIControlStateNormal];
    [tapBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tapBtn setBackgroundColor:[DZUtils colorWithHex:@"53B7FF"]];
    [tapBtn addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    #define Custom_Blue_Button_BGColor RGB(62, 144, 204)
    [tapBtn setTag:SharePopupViewEventType_ShareContacts];
    [bgView addSubview:tapBtn];
    pt.x = bgView.bounds.size.width/2.0;
    pt.y = bgView.bounds.size.height - tapBtn.bounds.size.height/2.0;
    tapBtn.center = pt;
    
    
}


-(void)initShareButtonsForNoticeTA
{
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.font = [UIFont systemFontOfSize:FLoatChange(11)];
    [titleLabel setText:@"通知到"];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.customPopupView addSubview:titleLabel];
    
    BOOL WXHide = ![WXApi isWXAppInstalled];
    
    CGPoint pt = CGPointMake(CGRectGetMidX(self.customPopupView.bounds), FLoatChange(60)/2.0 + FLoatChange(35));
    if(WXHide)
    {
        //仅一个居中
        //短信
        UIButton * tapBtn = nil;
        tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
        [tapBtn setImage:[UIImage imageNamed:@"message_icon"] forState:UIControlStateNormal];
        [tapBtn setTitle:@"短信" forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_Message];
        [self.customPopupView addSubview:tapBtn];
        tapBtn.center = pt;
        
    }else{
        //微信好友
        UIButton * tapBtn = nil;
        tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
        [tapBtn setImage:[UIImage imageNamed:@"wx_icon"] forState:UIControlStateNormal];
        [tapBtn setTitle:@"微信" forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_WXSession];
        [self.customPopupView addSubview:tapBtn];
        tapBtn.hidden = WXHide;
        tapBtn.center = pt;
        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:YES];
        
        
        //短信
        tapBtn=[self createTextBottomButtonWithIndexX:2 indexY:0];
        [tapBtn setTitle:@"短信" forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"message_icon"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_Message];
        [self.customPopupView addSubview:tapBtn];
        tapBtn.hidden = WXHide;
        tapBtn.center = pt;
        [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:NO];

    }
    
}

-(void)initShareButtons
{
    BOOL QQHide = ![TencentOAuth iphoneQQInstalled];
    BOOL WXHide = ![WXApi isWXAppInstalled];
    
    //title
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.font = [UIFont systemFontOfSize:FLoatChange(11)];
    [titleLabel setText:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Title")];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.customPopupView addSubview:titleLabel];
    
    if(QQHide || WXHide)
    {
        //4个Button
        if(QQHide)
        {
            //微信好友
            UIButton * tapBtn = nil;
            tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
            [tapBtn setImage:[UIImage imageNamed:@"wx_icon"] forState:UIControlStateNormal];
            [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Weixin_Friends_Title") forState:UIControlStateNormal];
            [tapBtn setTag:SharePopupViewEventType_WXSession];
            [self.customPopupView addSubview:tapBtn];
            tapBtn.hidden = WXHide;
            [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:YES];
            
            //微信朋友圈
            tapBtn=[self createTextBottomButtonWithIndexX:2 indexY:0];
            [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Weixin_Circle_Title") forState:UIControlStateNormal];
            [tapBtn setImage:[UIImage imageNamed:@"wx_space"] forState:UIControlStateNormal];
            [tapBtn setTag:SharePopupViewEventType_WXTimeLine];
            [self.customPopupView addSubview:tapBtn];
            tapBtn.hidden = WXHide;
            [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:NO];
            
        }else{
            
            UIButton * tapBtn = nil;
            //QQ空间
            tapBtn=[self createTextBottomButtonWithIndexX:3 indexY:0];
            [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_QQ_Friends_Title") forState:UIControlStateNormal];
            [tapBtn setImage:[UIImage imageNamed:@"qq_space"] forState:UIControlStateNormal];
            [tapBtn setTag:SharePopupViewEventType_QQSession];
            [self.customPopupView addSubview:tapBtn];
            tapBtn.hidden = QQHide;
            [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:NO];
            
            //QQ好友
            tapBtn=[self createTextBottomButtonWithIndexX:1 indexY:0];
            [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_QQ_Space_Title") forState:UIControlStateNormal];
            [tapBtn setImage:[UIImage imageNamed:@"qq_icon"] forState:UIControlStateNormal];
            [tapBtn setTag:SharePopupViewEventType_QQ];
            [self.customPopupView addSubview:tapBtn];
            tapBtn.hidden = QQHide;
            [self refreshBtnCenterForPartShowWithBtn:tapBtn andLeft:YES];
            
        }
        
    }else{
        //4个Button
        //微信好友
        UIButton * tapBtn = nil;
        tapBtn=[self createTextBottomButtonWithIndexX:0 indexY:0];
        [tapBtn setImage:[UIImage imageNamed:@"wx_icon"] forState:UIControlStateNormal];
        [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Weixin_Friends_Title") forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_WXSession];
        [self.customPopupView addSubview:tapBtn];
        //微信朋友圈
        tapBtn=[self createTextBottomButtonWithIndexX:2 indexY:0];
        [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_Weixin_Circle_Title") forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"wx_space"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_WXTimeLine];
        [self.customPopupView addSubview:tapBtn];
        
        
        //QQ空间
        tapBtn=[self createTextBottomButtonWithIndexX:3 indexY:0];
        [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_QQ_Friends_Title") forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"qq_space"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_QQSession];
        [self.customPopupView addSubview:tapBtn];
        
        //QQ好友
        tapBtn=[self createTextBottomButtonWithIndexX:1 indexY:0];
        [tapBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Share_QQ_Space_Title") forState:UIControlStateNormal];
        [tapBtn setImage:[UIImage imageNamed:@"qq_icon"] forState:UIControlStateNormal];
        [tapBtn setTag:SharePopupViewEventType_QQ];
        [self.customPopupView addSubview:tapBtn];

    }

}

-(void)initSettingButtons{
    //分割线条
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 144, SCREEN_WIDTH, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:67/255.0 green:78/255.0  blue:83/255.0  alpha:1];
    [self.customPopupView addSubview:lineView];
    
    //下载
//    _settingDownloadButton=[self createTextBottomButtonWithIndexX:0 indexY:1];
//    [_settingDownloadButton setTitle:@"保存图片" forState:UIControlStateNormal];
//    [_settingDownloadButton setImage:[UIImage imageNamed:@"功能——下载图片.png"] forState:UIControlStateNormal];
//    [_settingDownloadButton setTag:SharePopupViewEventType_DownloadImage];
//    [self.customPopupView addSubview:_settingDownloadButton];
//    //大图
//    _settingBigPicButton=[self createTextBottomButtonWithIndexX:1 indexY:1];
//    [_settingBigPicButton setTitle:@"查看大图" forState:UIControlStateNormal];
//    [_settingBigPicButton setImage:[UIImage imageNamed:@"功能——查看大图.png"] forState:UIControlStateNormal];
//    [_settingBigPicButton setTag:SharePopupViewEventType_BigPicture];
//    [self.customPopupView addSubview:_settingBigPicButton];
//    //删除
//    _settingDeleteButton=[self createTextBottomButtonWithIndexX:2 indexY:1];
//    [_settingDeleteButton setTitle:@"删除" forState:UIControlStateNormal];
//    [_settingDeleteButton setImage:[UIImage imageNamed:@"功能——删除.png"] forState:UIControlStateNormal];
//    [_settingDeleteButton setTag:SharePopupViewEventType_Delete];
//    [self.customPopupView addSubview:_settingDeleteButton];
//    //举报
//    _settingReportButton=[self createTextBottomButtonWithIndexX:2 indexY:1];
//    [_settingReportButton setTitle:@"举报" forState:UIControlStateNormal];
//    [_settingReportButton setImage:[UIImage imageNamed:@"功能——举报.png"] forState:UIControlStateNormal];
//    [_settingReportButton setTag:SharePopupViewEventType_Report];
//    [self.customPopupView addSubview:_settingReportButton];
}

-(void)setType:(SharePopupViewType)type{
    _type=type;
    
    CGFloat height=FLoatChange(187);
    switch (_type) {
        case SharePopupViewType_OnlyShare:
        {
            height=FLoatChange(187);
            break;
        }
        case SharePopupViewType_NoticeTA:
        case SharePopupViewType_NoneMSG:
        {
            height=FLoatChange(104);
            break;
        }
        case SharePopupViewType_SharePath:
        {
            height=FLoatChange(149);
            break;
        }
        default:{
            height=332;
            break;}
    }
    self.customPopupView.frame=CGRectMake(0, 0, SCREEN_WIDTH, height);
    
    _cancelButton.frame=CGRectMake(0, self.customPopupView.frame.size.height - FLoatChange(44), self.customPopupView.frame.size.width, FLoatChange(44));
    _cancelButton.hidden = (type!=SharePopupViewType_OnlyShare);
}

-(void)setShowDeleteButton:(BOOL)showDeleteButton{
    _showDeleteButton=showDeleteButton;
    if (_type==SharePopupViewType_ShareAndMore) {
        if (!_showDeleteButton) {
            _settingDeleteButton.hidden=true;
            _settingReportButton.hidden=false;
//            _settingReportButton.frame=_settingDeleteButton.frame;
        }else{
            _settingDeleteButton.hidden=false;
            _settingReportButton.hidden=true;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(UIButton*)createTextBottomButtonWithIndexX:(int)indexX indexY:(int)indexY{
    
    
    TextBottomButton *textBottomButton=[[TextBottomButton alloc]init];
    {
        textBottomButton.small = YES;
    }
        
    [textBottomButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    CGFloat y=0;
    switch (indexY) {
        case 0:
        {
            y=FLoatChange(35);
            break;}
        case 1:{
            y=330/2.0f;
            break;}
        default:
            break;
    }
    CGFloat btnWidth = FLoatChange(55);
    CGFloat btnHeight = FLoatChange(70);
    
    {
        btnWidth = FLoatChange(55);
        btnHeight = FLoatChange(60);
    }
    
    CGFloat startX = FLoatChange(30);
    CGFloat sepX = (SCREEN_WIDTH - btnWidth*4 - startX*2)/(4-1);
    [textBottomButton setFrame:CGRectMake(startX+indexX*(btnWidth+sepX), y, btnWidth, btnHeight)];
    [textBottomButton addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    textBottomButton.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(10)];
    return textBottomButton;
}


#pragma mark ButtonEvent
-(void)itemButtonClicked:(UIButton*)sender{
    NSLog(@"-->>itemButtonClicked:sender tag=%d",sender.tag);
    if (self.SharePopupViewEvent) {
        self.SharePopupViewEvent(sender.tag);
    }
    [self hide:true];
}

-(void)cancelButtonClicked{
    [self hide:true];
}
@end
