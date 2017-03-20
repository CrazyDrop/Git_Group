//
//  WeixinShare.h
//  WeixinShare
//
//  Created by chenshuang on 12-12-8.
//  Copyright (c) 2012年 chenshuang. All rights reserved.
//

/*!
 * @class 微信分享
 */

#import <Foundation/Foundation.h>
#import "WXApiObject.h"
#import "WXApi.h"
//#import "KMStatis.h"
//#import "ShareConfig.h"

typedef void(^OnResponseBlock)(BaseResp *resp);

@interface WeixinShare : NSObject<WXApiDelegate>
{
    //友盟统计。统计发送的次数
//    StaticShareContentType sendWeiType;
    
    //发送的类型，有发送给好友和发送到朋友圈。此标记为了统计不同类型的发送次数
    enum WXScene scene;
}

@property (nonatomic,assign) OthersAppDetailShareType type;

@property (nonatomic, copy) OnResponseBlock responseBlock;

//@property (nonatomic, assign) StaticShareContentType sendWeiType;

/*!
 * @brief 单例方法，在全局范围内只创建一次即可反复使用
 */
+(WeixinShare *)shareWeixin;


+(BOOL)AppInstalledAndSupported;

//微信登陆
-(void)login;
-(void)logout;

/*!
 * @brief 以发送图片的方式分享，好友看到的是一张纯图片
 */
-(void)postWeixinImageContent:(enum WXScene)type thumbImage:(UIImage *)thumbImage largeImage:(UIImage *)largeImage;

/*!
 * @brief以发送新闻的方式分享，好友看到内容为带有缩略图、标题和文章简介的内容，点击后跳转到urlString的网址
 *
 * @note 分享到朋友圈没有文章简介只有urlString网址的域名
 */

-(void)postWeinxinNews:(enum WXScene)type title:(NSString *)titleString content:(NSString *)contentString imageURL:(NSString *)imageURL url:(NSString *)urlString shareWordType:(int)shareWordType;

-(void)postWeinxinNews:(enum WXScene)type title:(NSString *)titleString content:(NSString *)contentString image:(UIImage *)image url:(NSString *)urlString;

//带返回值的
-(BOOL)shareToWeiChat:(enum WXScene)type title:(NSString *)titleString content:(NSString *)contentString image:(UIImage *)image url:(NSString *)urlString;

//分享，微信的分享，返回标示为是否发送标示
-(BOOL)zaPostWeinxinNews:(enum WXScene)type content:(NSString *)contentString;

//通知他功能
-(void)zaNoticePostWeinxinType:(enum WXScene)type content:(NSString *)contentString;

//分享路径功能
-(void)zaSharePathWeinxinType:(enum WXScene)type content:(NSString *)contentString andPathUrl:(NSString *)url;


@end
