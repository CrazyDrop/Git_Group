//
//  WeixinShare.m
//  WeixinShare
//
//  Created by chenshuang on 12-12-8.
//  Copyright (c) 2012年 chenshuang. All rights reserved.
//

#import "WeixinShare.h"
//#import "YRTools.h"
#import "Constant.h"
#import "SDImageCache.h"
@interface WeixinShare()
@property (nonatomic,strong) NSString * code;
@property (nonatomic,strong) NSString * openId;
@property (nonatomic,strong) NSString * access_token;
@end
@implementation WeixinShare

//@synthesize sendWeiType;

static WeixinShare * shareWeixin;
+(WeixinShare *)shareWeixin
{
    @synchronized(self)
    {
        if (shareWeixin == nil)
        {
            shareWeixin = [[WeixinShare alloc]init];
        }
        return shareWeixin;
    }
}

+(BOOL)AppInstalledAndSupported
{
    return [WXApi isWXAppInstalled]&&[WXApi isWXAppSupportApi];
}

//微信登陆
-(void)login
{
    
    [self sendAuthRequest];
}
-(void)logout
{
    self.code = nil;
    self.openId = nil;
    self.access_token = nil;
}


-(void)sendAuthRequest
{
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.openID = kWXAPP_URL_KEY;
    req.scope = @"snsapi_userinfo";
    req.state = @"wechat_sdk_demo" ;
    [WXApi sendReq:req];
}

-(void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        self.code = temp.code;
        
        //启动调用token
        [self getAccess_token];
    }else
    {
        //成功失败均提示
        NSString * str = nil;
        if(self.type == OthersAppDetailShareType_Notice)
        {
            str = @"通知成功";
            if(resp.errCode != WXSuccess)
            {
                str = @"通知失败";
                if(resp.errCode == WXErrCodeUserCancel)
                {
                    str = @"通知已取消";
                }
            }
        }else if(self.type == OthersAppDetailShareType_SharePath){
            str = @"您的位置已成功分享";
            if(resp.errCode != WXSuccess)
            {
                str = @"您的位置分享失败";
                if(resp.errCode == WXErrCodeUserCancel)
                {
                    str = @"您的位置分享已取消";
                }
            }
        }else{
            str = @"分享成功";
            if(resp.errCode != WXSuccess)
            {
                str = @"分享失败";
                if(resp.errCode == WXErrCodeUserCancel)
                {
                    str = @"分享取消";
                }
            }
        }
        self.type = OthersAppDetailShareType_Share;

        [DZUtils noticeCustomerWithShowText:str];
        
        [KMStatis staticShareEvent:(resp.errCode == WXSuccess)?StaticShareEventType_WX_Sucess:StaticShareEventType_WXLogin_Fail andNoticeStr:str];

        return;
    }
    
    
    
}
-(void)getAccess_token
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWXAPP_URL_KEY,kWXAPP_SECRET,self.code];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                self.access_token = [dic objectForKey:@"access_token"];
                self.openId = [dic objectForKey:@"openid"];
                
            }
            
            if(!self.access_token||!self.openId)
            {
                [DZUtils noticeCustomerWithShowText:@"token获取失败"];
                return ;
            }

            [self getUserInfo];

        });
    });
}
-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token,self.openId];
    
    
//    __weak WeixinShare * weakSelf = self;
    __strong WeixinShare * weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                
                NSString * type = [NSString stringWithFormat:@"%d",ThirdPartyTypeWechat];
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.access_token forKey:USERDEFAULT_NAME_OTHERLOGIN_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:type forKey:USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_NAME_OTHERLOGIN_LOGINSUCCESS object:nil];

                
//                NSString * noticeStr = [NSString stringWithFormat:@"%@(%@)",dic[@"nickname"],dic[@"sex"]];
//                [DZUtils noticeCustomerWithShowText:noticeStr];
                
            }
        });
        
    });
}



-(void)postWeixinImageContent:(enum WXScene)type thumbImage:(UIImage *)thumbImage largeImage:(UIImage *)largeImage
{
//    scene = type;
//    if( ![WXApi isWXAppInstalled] )
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"]];
//        return;
//    }
//    
//    UIImage * smallImage;
//    smallImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:[ImageCacheDirectory() stringByAppendingPathComponent:[imageAddress md5HexDigest]]]];
//    smallImage = [WeixinShare compressImageDownToPhoneScreenSize:smallImage];
//    
//    UIImage * LargeImage;
//    LargeImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:[ImageCacheDirectory() stringByAppendingPathComponent:[imageAddress md5HexDigest]]]];
//    
//    //发送内容给微信
//    WXMediaMessage *message = [WXMediaMessage message];
//    //用户看到的小图
//    [message setThumbImage:smallImage];
//    
//    WXImageObject *ext = [WXImageObject object];
//    //用户点击后看到的大图
//    ext.imageData = UIImageJPEGRepresentation(LargeImage, 1.0f);
//    
//    message.mediaObject = ext;
//    
//    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
//    req.bText = NO;
//    req.message = message;
//    req.scene = type;
//    
//    [WXApi sendReq:req];
    
    scene = type;
    if( ![WXApi isWXAppInstalled] )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        return;
    }
    
    UIImage * smallImage;
//    smallImage = [UIImage imageNamed:@"编辑button@2x.png"];
    smallImage = [WeixinShare compressImageDownToPhoneScreenSize:thumbImage];
    
    //发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    //用户看到的小图
    [message setThumbImage:smallImage];
    
    WXImageObject *ext = [WXImageObject object];
    //用户点击后看到的大图
    ext.imageData = UIImageJPEGRepresentation(largeImage, 1.0f);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    [WXApi sendReq:req];
}

-(void)postWeinxinNews:(enum WXScene)type title:(NSString *)titleString content:(NSString *)contentString imageURL:(NSString *)imageURL url:(NSString *)urlString shareWordType:(int)shareWordType
{
    scene = type;
    if( ![WXApi isWXAppInstalled])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.description = contentString;
    
//    switch (shareWordType) {
//        case shareWordsType_Product:
//        case shareWordsType_Topic:
//            
            message.title = [NSString stringWithFormat:@"%@", titleString];
    
    
            UIImage * smallImage;
            smallImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
            smallImage = [WeixinShare compressImageDownToPhoneScreenSize:smallImage];
            [message setThumbImage:smallImage];
//            
//            break;
//            
//        case shareWordsType_Web:
//            
//            if( titleString )
//            {
//                message.title = [NSString stringWithFormat:@"%@ | 美丽闺蜜", titleString];
//            }
//            else
//            {
//                message.title = @"美丽闺蜜iphone版精彩内容";
//            }
//            [message setThumbImage:[UIImage imageNamed:@"icon.png"]];
//            
//            break;
//            
//        default:
//            break;
//    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    [WXApi sendReq:req];
}

-(void)postWeinxinNews:(enum WXScene)type title:(NSString *)titleString content:(NSString *)contentString image:(UIImage *)image url:(NSString *)urlString
{
    scene = type;
    if( ![WXApi isWXAppInstalled])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.description = contentString;
    
    message.title = [NSString stringWithFormat:@"%@", titleString];
    
    UIImage * smallImage;
    smallImage = image;//[[YRImageCache shareImageCache]getImageFromLocalWithUrl:imageURL cacheImmediately:false];
    smallImage = [WeixinShare compressImageDownToPhoneScreenSize:smallImage];
    [message setThumbImage:smallImage];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    [WXApi sendReq:req];
}

-(BOOL)shareToWeiChat:(enum WXScene)type title:(NSString *)titleString content:(NSString *)contentString image:(UIImage *)image url:(NSString *)urlString
{
    scene = type;
    if( ![WXApi isWXAppInstalled])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你还没有安装微信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.description = contentString;
    
    message.title = [NSString stringWithFormat:@"%@", titleString];
    
    UIImage * smallImage;
    smallImage = image;
    smallImage = [WeixinShare compressImageDownToPhoneScreenSize:smallImage];
    [message setThumbImage:smallImage];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = type;
    
    return [WXApi sendReq:req];
}

//发送
-(BOOL)zaPostWeinxinNews:(enum WXScene)type content:(NSString *)contentString
{
    if( ![WXApi isWXAppInstalled])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        return NO;
    }
    
    NSString * url = kShareAPP_URL_PATH;
    NSString * titleString = kShareAPP_URL_DES_TXT;
    NSString * imgName = @"share_icon_menu";
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:kShareAPP_TYPE_CURRENT_SETTING] boolValue])
    {
        url = kShareAPP_URL_PATH_SECOND;
        titleString = kShareAPP_URL_DES_TXT_SECOND;
        imgName = @"AppIcon";
    }
    
    //    return [[[self class] shareWeixin] shareToWeiChat:type title:titleString content:contentString image:nil url:urlString];
    scene = type;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = titleString;
    message.description = contentString;
    UIImage * img = [UIImage imageNamed:imgName];
    [message setThumbImage:img];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    return  [WXApi sendReq:req];
}

-(void)zaNoticePostWeinxinType:(enum WXScene)type content:(NSString *)contentString{
    
    if( ![WXApi isWXAppInstalled])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        return;
    }
    
    self.type = OthersAppDetailShareType_Notice;
    scene = type;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = YES;
    req.text = contentString;
    req.scene = scene;
    [WXApi sendReq:req];
    
}

//分享路径功能
-(void)zaSharePathWeinxinType:(enum WXScene)type content:(NSString *)contentString andPathUrl:(NSString *)urlStr
{
    if( ![WXApi isWXAppInstalled])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        return;
    }

    
    NSString * titleString = @"位置分享（来自@怕怕）";;
    NSString * imgName = @"share_url_icon";
    
    scene = type;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = titleString;
    message.description = contentString;
    UIImage * img = [UIImage imageNamed:imgName];
    [message setThumbImage:img];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlStr;
    
    message.mediaObject = ext;
//    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}




/*!
 * @brief 将要发送的缩略图压缩到1/3的比例，微信要求缩略图的大小不能超过32K
 */

+(UIImage*)compressImageDownToPhoneScreenSize:(UIImage*)theImage{
    
    UIImage * bigImage = theImage;
    
    float actualHeight = bigImage.size.height;
    float actualWidth = bigImage.size.width;
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth/3, actualHeight/3);
    UIGraphicsBeginImageContext(rect.size);
    [bigImage drawInRect:rect];
    theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
