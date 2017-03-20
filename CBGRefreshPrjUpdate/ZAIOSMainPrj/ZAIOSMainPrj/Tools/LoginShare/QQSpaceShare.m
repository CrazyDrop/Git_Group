//
//  TXShare.m
//  TXShare
//
//  Created by CBSi-陈爽 on 13-3-8.
//  Copyright (c) 2013年 CBSi. All rights reserved.
//

#import "QQSpaceShare.h"
#import <TencentOpenAPI/sdkdef.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "JSONKit.h"
//#import "KMStatis.h"
#import "Constant.h"
#import "DZUtils.h"
#import "TencentOAuthOld.h"
#import "AppDelegate.h"
#define kUserDefaultKeyListAlbumId @"afc3d5d493a8705568117b9b9ed8127b"
#define appID @"1104743955"
#define __TencentDemoAppid_  @"222222"

@interface QQSpaceShare()
{
    TencentOAuthOld * oldOAuth;
}

-(BOOL)zaShareNewsToQQWithOnLine:(BOOL)online withUrl:(NSURL *)url andContent:(NSString *)contentString andTitleString:(NSString *)titleString;

@end
@implementation QQSpaceShare

@synthesize qqSpaceDelegate;
@synthesize qqSpaceShareWordArray;
//@synthesize sendWeiType;

static QQSpaceShare * shareQQSpace;
+(QQSpaceShare*)shareQQSpace
{
    @synchronized(self)
    {
        if (shareQQSpace == nil)
        {
            shareQQSpace = [[QQSpaceShare alloc] init];
        }
        return shareQQSpace;
    }
}

-(void)currentBackToAppFromQQWithErrorCode:(NSInteger)sendResult
{
    if(sendResult==NSNotFound) return;
    //相应后续的成功与否
    
    
    //成功失败均提示
    NSString * str = nil;
    if(self.type == OthersAppDetailShareType_Notice)
    {
        str = @"通知成功";
        if(sendResult!=EQQAPISENDSUCESS)
        {
            str = @"通知失败";
            if(sendResult == -4)
            {
                str = @"通知已取消";
            }
        }
    }else if(self.type == OthersAppDetailShareType_SharePath){
        str = @"您的位置已成功分享";
        if(sendResult!=EQQAPISENDSUCESS)
        {
            str = @"您的位置分享失败";
            if(sendResult == -4)
            {
                str = @"您的位置分享已取消";
            }
        }
    }else{
        str = @"分享成功";
        if(sendResult!=EQQAPISENDSUCESS)
        {
            str = @"分享失败";
            if(sendResult == -4)
            {
                str = @"分享取消";
            }
        }
        
    }
    self.type = OthersAppDetailShareType_Share;
    
    [DZUtils noticeCustomerWithShowText:str];
    
    
    //分享相关，登录接口里没有ErrorCode
    [KMStatis staticShareEvent:(sendResult==EQQAPISENDSUCESS)?StaticShareEventType_QQ_Success:StaticShareEventType_QQ_Fail andNoticeStr:str];

    
}

-(id)init
{
    self = [super init];
    if( self )
    {
        //需要开通的权限
        permissions = [[NSMutableArray arrayWithObjects:
                         kOPEN_PERMISSION_GET_USER_INFO,
                         kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                         kOPEN_PERMISSION_ADD_ALBUM,
                         kOPEN_PERMISSION_ADD_ONE_BLOG,
                         kOPEN_PERMISSION_ADD_SHARE,
                         kOPEN_PERMISSION_ADD_TOPIC,
                         kOPEN_PERMISSION_GET_INFO,
                         kOPEN_PERMISSION_LIST_ALBUM,
                         kOPEN_PERMISSION_UPLOAD_PIC,
                         nil] retain];
        
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:appID
                                               andDelegate:self];
        
        NSDictionary * temporaryDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QQSpaceAuthData"];
        [tencentOAuth setAccessToken:[temporaryDic objectForKey:@"qqSpaceToken"]];
        [tencentOAuth setOpenId:[temporaryDic objectForKey:@"qqSpaceOpenId"]];
        [tencentOAuth setExpirationDate:[temporaryDic objectForKey:@"qqSpaceDate"]];
        
        qqSpaceShareWordArray = [[NSMutableArray alloc] init];
        
        
        oldOAuth = [[TencentOAuthOld alloc] initWithAppId:appID andDelegate:self];
        [oldOAuth setAccessToken:[temporaryDic objectForKey:@"qqSpaceToken"]];
        [oldOAuth setOpenId:[temporaryDic objectForKey:@"qqSpaceOpenId"]];
        [oldOAuth setExpirationDate:[temporaryDic objectForKey:@"qqSpaceDate"]];
    }
    
    return self;
}

-(void)dealloc
{
    [tencentOAuth release];tencentOAuth = nil;
    [oldOAuth release]; oldOAuth = nil;
    [qqSpaceShareWordArray release];qqSpaceShareWordArray = nil;
    [permissions release];permissions = nil;
    
    [super dealloc];
}

-(BOOL)isLoggedIn
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"QQSpaceAuthData"]!=nil;
}

-(BOOL)isTXAuthorizeExpired
{
    return [tencentOAuth isSessionValid];
}

-(void)login
{
    if ([QQApiInterface isQQInstalled])
    {
        [tencentOAuth authorize:permissions inSafari:NO];

    }else
    {
        [oldOAuth authorize:permissions inSafari:NO];
    }
    
}

-(void)logout
{
    if ([QQApiInterface isQQInstalled])
    {
        [tencentOAuth logout:self];
        
    }else
    {
        [oldOAuth logout:self];
    }
}

-(NSString *)qqSpaceScreenName
{
    NSDictionary * temporaryDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QQSpaceAuthData"];
    
    return [temporaryDic objectForKey:@"screenName"];
}

#pragma mark TXDelegate
- (void)showLoginWebViewController:(UIViewController *)web
{
//    UINavigationController * navController = [[[UINavigationController alloc]initWithRootViewController:web] autorelease];
    UIViewController * root = [DZUtils currentRootViewController];
    [root presentViewController:web
                       animated:YES
                     completion:nil];
}
- (void)tencentDidLogin
{
//    [KMStatis staticShareEvent:StaticShareEventType_QQLogin_Success];

    if ([QQApiInterface isQQInstalled]&&tencentOAuth.accessToken
        && 0 != [tencentOAuth.accessToken length])
    {
        NSDictionary * temporaryDic = [NSDictionary dictionaryWithObjectsAndKeys:tencentOAuth.accessToken, @"qqSpaceToken", tencentOAuth.openId, @"qqSpaceOpenId", tencentOAuth.expirationDate, @"qqSpaceDate", nil];
        [[NSUserDefaults standardUserDefaults] setObject:temporaryDic forKey:@"QQSpaceAuthData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tencentOAuth getUserInfo];
        
        //绑定QQ空间统计
//        [KMStatis statisOfShareLogInOut:YES shareType:StatisShareType_qqZone];
        
        NSLog(@"openId = %@", tencentOAuth.openId);
        NSLog(@"accessToken = %@", tencentOAuth.accessToken);
    }
    else if(oldOAuth.accessToken
            && 0 != [oldOAuth.accessToken length])
    {
        //网页登录
        NSDictionary * temporaryDic = [NSDictionary dictionaryWithObjectsAndKeys:oldOAuth.accessToken, @"qqSpaceToken", oldOAuth.openId, @"qqSpaceOpenId", oldOAuth.expirationDate, @"qqSpaceDate", nil];
        [[NSUserDefaults standardUserDefaults] setObject:temporaryDic forKey:@"QQSpaceAuthData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [oldOAuth getUserInfo];
        
        //绑定QQ空间统计
        //        [KMStatis statisOfShareLogInOut:YES shareType:StatisShareType_qqZone];
        
        NSLog(@"openId = %@", oldOAuth.openId);
        NSLog(@"accessToken = %@", oldOAuth.accessToken);
    }else
    {
        //没有登录成功
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
//    [KMStatis staticShareEvent:StaticShareEventType_QQLogin_Fail];

    //登陆失败
}

- (void)tencentDidNotNetWork
{
//    [KMStatis staticShareEvent:StaticShareEventType_QQLogin_Fail];

    //网路不好，登陆失败
}

//读取用户数据回调方法
- (void)getUserInfoResponse:(APIResponse*)response
{
    NSDictionary * temporaryDic  = nil;
    if ([response isKindOfClass:[APIResponse class]])
    {
       temporaryDic = [NSDictionary dictionaryWithObjectsAndKeys:tencentOAuth.accessToken, @"qqSpaceToken", tencentOAuth.openId, @"qqSpaceOpenId", tencentOAuth.expirationDate, @"qqSpaceDate", [response.jsonResponse objectForKey:@"nickname"], @"qqNickName", [response.jsonResponse objectForKey:@"gender"], @"qqGender", [response.jsonResponse objectForKey:@"figureurl_qq_2"], @"qqHeadImageURL", nil];


    }else if([response isKindOfClass:[APIResponseOld class]])
    {
       temporaryDic = [NSDictionary dictionaryWithObjectsAndKeys:oldOAuth.accessToken, @"qqSpaceToken", oldOAuth.openId, @"qqSpaceOpenId", oldOAuth.expirationDate, @"qqSpaceDate", [response.jsonResponse objectForKey:@"nickname"], @"qqNickName", [response.jsonResponse objectForKey:@"gender"], @"qqGender", [response.jsonResponse objectForKey:@"figureurl_qq_2"], @"qqHeadImageURL", nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:temporaryDic forKey:@"QQSpaceAuthData"];
    
    NSString * type = [NSString stringWithFormat:@"%d",ThirdPartyTypeQQ];
    [[NSUserDefaults standardUserDefaults] setObject:[temporaryDic valueForKey:@"qqSpaceToken"] forKey:USERDEFAULT_NAME_OTHERLOGIN_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:type forKey:USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //数据写入完成，用户昵称可被读取
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_NAME_OTHERLOGIN_LOGINSUCCESS object:nil];

//    NSString * noticeStr = [NSString stringWithFormat:@"%@(%@)",temporaryDic[@"qqNickName"],temporaryDic[@"qqGender"]];
//    [DZUtils noticeCustomerWithShowText:noticeStr];
}

//登出成功回调方法
- (void)tencentDidLogout
{
    //解绑QQ空间统计
//    [KMStatis statisOfShareLogInOut:NO shareType:StatisShareType_qqZone];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QQSpaceAuthData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE];
    
}

//转发方法
-(void)forwardingPic:(NSString *)titleString content:(NSString *)contentString pic:(NSString *)imageUrl html:(NSString *)htmlString introduction:(NSString *)introductionString
{
    TCAddShareDic *params = [TCAddShareDic dictionary];
    params.paramTitle = titleString;     //框内显示的内容，是文章的标题
    params.paramComment = contentString;  //框外的大标题，顶部显示的内容，是用户填写的内容
    params.paramSummary = introductionString;      //框内显示的内容，是文章的简介
    params.paramImages = imageUrl;      //图片网址链接
    params.paramUrl = htmlString;    //链接
    params.paramNswb = @"1";
    
    [tencentOAuth addShareWithParams:params];
}
//分享到QQ
-(BOOL)zaShareToQQOnlineWithContent:(NSString *)contentString
{
    NSString * url = kShareAPP_URL_PATH;
    NSString * titleString = kShareAPP_URL_DES_TXT;
    NSString * imgName = @"share_icon_menu";
    
    
    NSData * imgData = nil;
    UIImage * img = [UIImage imageNamed:imgName];
    if(!imgData) imgData = UIImagePNGRepresentation(img);
    
    QQApiURLObject* txtObj =    [[QQApiURLObject alloc] initWithURL:[NSURL URLWithString:url]
                                                              title:titleString
                                                        description:contentString
                                                   previewImageData:imgData
                                                  targetContentType:QQApiURLTargetTypeNews];

//    txtObj = [QQApiTextObject objectWithText:titleString];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    return NO;
}
//分享到QQ空间
-(BOOL)zaShareToQQSpaceWithContent:(NSString *)contentString
{
    //当安装了QQ空间,优先进入QQ空间
    //    if([TencentApiInterface isTencentAppInstall:kIphoneQZONE])
    {
        NSString * url = kShareAPP_URL_PATH;
        NSString * titleString = kShareAPP_URL_DES_TXT;
        NSString * imgName = @"share_icon_menu";
        
        NSData * imgData = nil;
        UIImage * img = [UIImage imageNamed:imgName];
        if(!imgData) imgData = UIImagePNGRepresentation(img);
        
        QQApiURLObject* txtObj =    [[QQApiURLObject alloc] initWithURL:[NSURL URLWithString:url]
                                                                  title:titleString
                                                            description:contentString
                                                       previewImageData:imgData
                                                      targetContentType:QQApiURLTargetTypeNews];
        
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
        
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        [self handleSendResult:sent];
        if(sent==EQQAPISENDSUCESS) return YES;
        return NO;
    }
    
    return NO;
}
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    //成功失败均提示
    if(sendResult!=EQQAPISENDSUCESS && (![QQApiInterface isQQSupportApi]||![QQApiInterface isQQInstalled]))
    {
        NSString * url = [QQApiInterface getQQInstallUrl];
        NSURL * dowURL = [NSURL URLWithString:url];
        if(dowURL)
        {
            [[UIApplication sharedApplication] openURL:dowURL];
        }

    }
    

    
    return;
    
//    NSString * errorTitle = @"提示";
//    if(sendResult!=EQQAPISENDSUCESS)
//    {
//        UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:errorTitle
//                                                         message:@"QQ分享失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [msgbox show];
//        [msgbox release];
//        return;
//    }
    
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            [msgbox release];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
//            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
//            [msgbox show];
//            [msgbox release];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

-(BOOL)zaShareNewsToQQWithOnLine:(BOOL)online withUrl:(NSURL *)url andContent:(NSString *)content{
    NSString * title = @"位置分享（来自@怕怕）";
    
    return [self zaShareNewsToQQWithOnLine:online
                                   withUrl:url
                                andContent:content
                            andTitleString:title];
}



//发送链接
-(BOOL)zaShareNewsToQQWithOnLine:(BOOL)online withUrl:(NSString *)urlStr andContent:(NSString *)contentString andTitleString:(NSString *)titleString
{
    NSURL * url = [NSURL URLWithString:urlStr];
    if(!url) return NO;
    
    NSString * imgName = @"AppIcon";
    
    NSData * imgData = nil;
    UIImage * img = [UIImage imageNamed:imgName];
    if(!imgData) imgData = UIImagePNGRepresentation(img);
    
    QQApiURLObject* txtObj =    [[QQApiURLObject alloc] initWithURL:url
                                                              title:titleString
                                                        description:contentString
                                                   previewImageData:imgData
                                                  targetContentType:QQApiURLTargetTypeNews];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    
    QQApiSendResultCode sent = EQQAPISENDSUCESS;
    if(online)
    {
        sent=[QQApiInterface sendReq:req];
    }else
    {
        sent=[QQApiInterface SendReqToQZone:req];
    }
    [self handleSendResult:sent];
    if(sent==EQQAPISENDSUCESS) return YES;
    return NO;
}


//转发回调方法
- (void)addShareResponse:(APIResponse*) response {
	if (response.retCode == URLREQUEST_SUCCEED)
	{
		[qqSpaceDelegate qqSpacePostFinish];
    }
	else
    {
		[qqSpaceDelegate qqSpacePostFail];
	}
}

@end
