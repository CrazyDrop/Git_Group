//
//  SharePopupView.h
//  ShaiHuo
//
//  Created by 王晓宇 on 14-2-22.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

/*!
 *	@class	分享的弹窗
 */
#import "YRPopupPane.h"


typedef enum {
    SharePopupViewType_OnlyShare=1,//只有分享(单行)
    SharePopupViewType_ShareAndMore,//分享和更多功能(双行)
    SharePopupViewType_NoneMSG,     //微信、QQ、空间、朋友圈
    SharePopupViewType_SharePath,   //短信、微信、QQ
    SharePopupViewType_NoticeTA,    //短信、微信
}SharePopupViewType;

typedef enum {
    SharePopupViewEventType_Sina=1288,//新浪微博点击了
    SharePopupViewEventType_WXTimeLine,//微信朋友圈
    SharePopupViewEventType_WXSession,//微信好友
    SharePopupViewEventType_QQ,//QQ好友
    SharePopupViewEventType_QQSession,//QQ空间
    SharePopupViewEventType_ShareContacts,//一键发送紧急联系人
    
    SharePopupViewEventType_DownloadImage,//下载图片
    SharePopupViewEventType_BigPicture,//查看大图
    SharePopupViewEventType_Delete,//删除
    SharePopupViewEventType_Report,//举报
    
    SharePopupViewEventType_Instagram,//Instagram
    SharePopupViewEventType_Message//短信功能

}SharePopupViewEventType;//各种点击事件

typedef void (^SharePopupViewEvent)(SharePopupViewEventType eventType);


@interface SharePopupView : YRPopupPane
{
    UIButton *_shareSinaButton;//新浪
    UIButton *_shareWXTimeLineButton;//微信朋友圈
    UIButton *_shareWXSessionButton;//微信好友
    UIButton *_shareQQButton;//QQ好友
    
    //    V2.0
    UIButton *_shareInstagramBtn;//分享到Instagram
    
    
    UIButton *_settingDownloadButton;//下载图片
    UIButton *_settingBigPicButton;//查看大图
    UIButton *_settingDeleteButton;//删除
    UIButton *_settingReportButton;//举报
    
    UIButton *_cancelButton;
}


-(id)initWithType:(SharePopupViewType)type;
@property (assign,nonatomic) SharePopupViewType type;
@property (assign,nonatomic) BOOL showDeleteButton;//是否展示删除按钮
@property (copy,nonatomic) SharePopupViewEvent SharePopupViewEvent;

@property (nonatomic, strong) UIButton *settingDeleteButton;//删除
@property (nonatomic, strong) UIButton *settingReportButton;//举报

-(void)setSharePopupViewEvent:(SharePopupViewEvent)SharePopupViewEvent;

@end

