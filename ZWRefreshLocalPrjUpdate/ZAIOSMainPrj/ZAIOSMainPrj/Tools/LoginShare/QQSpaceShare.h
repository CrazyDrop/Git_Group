//
//  TXShare.h
//  TXShare
//
//  Created by CBSi-陈爽 on 13-3-8.
//  Copyright (c) 2013年 CBSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
//#import "KMStatis.h"

@protocol  QQSpaceShareDelegate <NSObject>

@optional
/*!
 *	@brief	发送成功
 */
-(void)qqSpacePostFinish;

/*!
 *	@brief	其他原因发送失败时的回调方法
 */
-(void)qqSpacePostFail;

/*!
 *	@brief	仅提供给QQSpaceViewController弹出键盘的方法，如果其他类继承了此代理切记实现此代理方法（方法内可以什么都不写）
 */
-(void)showKeyboard;


@end

@interface QQSpaceShare : NSObject <TencentSessionDelegate, UIImagePickerControllerDelegate>
{
    TencentOAuth * tencentOAuth;
    
    //需要取得用户的授权类型，根据需求选择
    NSMutableArray * permissions;
}

@property (nonatomic, assign) id<QQSpaceShareDelegate> qqSpaceDelegate;
@property (nonatomic, retain) NSMutableArray * qqSpaceShareWordArray;

//@property (nonatomic, assign) StaticShareContentType sendWeiType;

+(QQSpaceShare*)shareQQSpace;

@property (nonatomic,assign) OthersAppDetailShareType type;

/*!
 *	@brief	判断是否登陆过
 *
 *	@return	登陆过返回YES
 */
-(BOOL)isLoggedIn;


/*!
 *	@brief	检查授权是否过期
 *
 *	@return	YES表示有效，NO表示无效
 */
-(BOOL)isTXAuthorizeExpired;

/*!
 *	@brief	读取用户昵称
 *
 *	@return	返回用户昵称
 */
-(NSString *)qqSpaceScreenName;


/*!
 *	@brief  登陆QQ空间
 */
-(void)login ;

/*!
 *	@brief	退出QQ空间
 */
-(void)logout;

/*!
 *	@brief	转发消息
 *
 *	@param 	titleString 	标题
 *	@param 	contentString 	文字描述
 *	@param 	imageUrl 	图片链接
 *	@param 	htmlString 	文章链接
 *	@param 	introductionString 	文章简介
 */
-(void)forwardingPic:(NSString *)titleString content:(NSString *)contentString pic:(NSString *)imageUrl html:(NSString *)htmlString introduction:(NSString *)introductionString;

//分享，QQ的分享，返回标示为是否跳转标示
//分享到QQ
-(BOOL)zaShareToQQOnlineWithContent:(NSString *)content;

//分享到QQ空间
-(BOOL)zaShareToQQSpaceWithContent:(NSString *)content;

//发送链接，路径分享
-(BOOL)zaShareNewsToQQWithOnLine:(BOOL)online withUrl:(NSString *)url andContent:(NSString *)content;

-(void)currentBackToAppFromQQWithErrorCode:(NSInteger)code;

@end
