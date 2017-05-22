//
//  Adapter.h
//  photographer
//
//  Created by jialifei on 15/4/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//


//渠道号相关
//测试，不定义，则为appstore
#define kAPP_PAPA_Channel_Identifier @"Channel_LocalTest"

//fir.im
//#define kAPP_PAPA_Channel_Identifier @"Channel_fir"


#define kAPP_YEAR_TOTAL_RATE_NUMBER   @"620,640,640,650,650,680,720,750,780,820,830,840,900,930"


#define RefreshListMaxShowNum  50
#define RefreshListMaxPageNum  40   //最大有效页数为100
#define RefreshListMinPageNum  3    //最小有效页数为100

#define HeaderUrl_MobileRefresh_URLString  @"http://xyq-ios2.cbg.163.com/app2-cgi-bin//xyq_search.py?act=super_query&search_type=overall_role_search&orderby=selling_time%20DESC"

//#define MobileRefresh_ListRequest_Default_URLString  @"http://xyq-ios2.cbg.163.com/app2-cgi-bin//xyq_search.py?act=super_query&search_type=overall_role_search&price_min=50000&price_max=50000000&level_min=170&level_max=175&expt_fangyu=25&expt_kangfa=25&expt_total=75&bb_expt_fangyu=10&bb_expt_kangfa=10&qian_neng_guo=50&bb_expt_total=35&qian_yuan_dan=7&page=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519"

#define MobileRefresh_ListRequest_Default_URLString  @"http://xyq-ios2.cbg.163.com/app2-cgi-bin//xyq_search.py?act=super_query&search_type=overall_role_search&orderby=selling_time%20DESC&level_min=173&level_max=200&page=0"



#define HeaderUrl_WebRefresh_URLString  @"http://xyq.cbg.163.com/cgi-bin/xyq_overall_search.py?j0orjdhr&act=overall_search_role&order_by=expire_time%20DESC"

//#define WebRefresh_ListRequest_Default_URLString  @"http://xyq.cbg.163.com/cgi-bin/xyq_overall_search.py?j0orjdhr&act=overall_search_role&price_min=50000&price_max=50000000&level_min=170&level_max=175&expt_fangyu=25&expt_kangfa=25&expt_total=75&bb_expt_fangyu=10&bb_expt_kangfa=10&qian_neng_guo=50&bb_expt_total=35&qian_yuan_dan=7&page=1"

#define WebRefresh_ListRequest_Default_URLString  @"http://xyq.cbg.163.com/cgi-bin/xyq_overall_search.py?j0orjdhr&act=overall_search_role&order_by=expire_time%20DESC&level_min=173&level_max=200&page=0"



#define NOTIFICATION_NEED_PLAN_BUY_REFRESH_STATE           @"NOTIFICATION_NEED_PLAN_BUY_REFRESH_STATE"
#define NOTIFICATION_NEED_REFRESH_WEB_ERROR_STATE          @"NOTIFICATION_NEED_REFRESH_WEB_ERROR_STATE"


CG_INLINE float
FLoatChange(CGFloat size)
{
//    CGFloat newS;
//    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
//    newS = size *myDelegate.autoSizeScaleX;
    return size;
    
}

#define kAPP_BPush_Company_Identifier           @"kAPP_BPush_Company_Identifier"


//#define kAPP_Local_UMENG_Identifier_TAG           1 //YES,使用上线统计的账号
#define kAPP_Local_UMENG_Identifier_TAG               0 //NO

#define kAPP_Local_LOG_Identifier_TAG               1 //YES
//#define kAPP_Local_LOG_Identifier_TAG               0 //NO

#define kAPP_Local_Release_URL_Identifier_TAG       1 // YES  外网
//#define kAPP_Local_Release_URL_Identifier_TAG       0 //NO      UAT 或  内网


//控制是内网测试，还是UAT测试//仅kAPP_Local_Release_URL_Identifier_TAG  为0 时有效
//#define kAPP_Local_UAT_URL_Identifier_TAG       1 //YES   UAT
#define kAPP_Local_UAT_URL_Identifier_TAG       0 //NO    内网


#if kAPP_Local_LOG_Identifier_TAG
#else
#define NSLog(...) nil
#endif

//系统变量
#define WKDZUITIL_KEY_LOCAL_SAVE_TYPE               @"WKDZUITIL_KEY_LOCAL_SAVE_TYPE"
//倒计时启动
#define WKDZUITIL_KEY_TIME_STATE_TYPE_STARTED       @"WKDZUITIL_KEY_TIME_STATE_TYPE_STARTED"
//预警取消
#define WKDZUITIL_KEY_TIME_STATE_TYPE_CANCELED      @"WKDZUITIL_KEY_TIME_STATE_TYPE_CANCELED"
//立即预警，发起Runwarning消息
#define WKDZUITIL_KEY_TIME_STATE_TYPE_WARNING       @"WKDZUITIL_KEY_TIME_STATE_TYPE_WARNING"
//立即预警电话，即，紧急模式预警
#define WKDZUITIL_KEY_QUICK_STATE_TYPE_WARNING      @"WKDZUITIL_KEY_QUICK_STATE_TYPE_WARNING"
//临时时间
#define WKDZUITIL_KEY_SETTING_TIME                  @"WKDZUITIL_KEY_SETTING_TIME"
//使用状态检查，有返回值
#define WKDZUITIL_KEY_LOCAL_CURRENT_TYPE            @"WKDZUITIL_KEY_LOCAL_CURRENT_TYPE"
//使用标识watch启动数，每次启动，在首页调用一次
#define WKDZUITIL_KEY_WATCH_APPLICATIONSTART_TYPE   @"WKDZUITIL_KEY_WATCH_APPLICATIONSTART_TYPE"

//是否运行为调研模式
#define USERDEFAULT_Created_DeviceNum_Show          @"USERDEFAULT_Created_DeviceNum_Show_Identifier"

//是否运行为企业版测试版本
//#define USERDEFAULT_DEBUG_FOR_COMPANY          @"USERDEFAULT_DEBUG_FOR_COMPANY"

//本地通知id标识号
#define NSLOCAL_NOTIFICATION_IDENTIFIER             @"NSLOCAL_NOTIFICATION_IDENTIFIER"
#define NSLOCAL_NOTIFICATION_IDENTIFIER_BEFORE      @"NSLOCAL_NOTIFICATION_IDENTIFIER_BEFORE"

//推送通知，注册结果监听标识号
#define NSRemote_NOTIFICATION_IDENTIFIER_REGISTER     @"NSRemote_NOTIFICATION_IDENTIFIER_REGISTER"


//消息通知，收回密码页、倒计时页面，清空数据
//#define NOTIFICATION_WEB_PWDSTATE_CHECK_STOP        @"NOTIFICATION_WEB_PWDSTATE_CHECK_STOP"

//录音取消事件消息通知
#define NOTIFICATION_RECORDER_CANCEL_STATE          @"NOTIFICATION_RECORDER_CANCEL_STATE"

//红色圆点通知
#define NOTIFICATION_CONTACT_REDCIRCLE_STATE        @"NOTIFICATION_CONTACT_REDCIRCLE_STATE"

//网络状态提示框显示隐藏事件
#define NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE      @"NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE"

//顶部提示框、定位功能的状态
#define NOTIFICATION_LOCATION_NOTICE_SHOW_STATE      @"NOTIFICATION_LOCATION_NOTICE_SHOW_STATE"

//Token失效通知
#define NOTIFICATION_TOKEN_EXPIRE_STATE             @"NOTIFICATION_TOKEN_EXPIRE_STATE"
//状态检查
#define NOTIFICATION_START_CHECK_STATE              @"NOTIFICATION_START_CHECK_STATE"
//弹出分享页面
#define NOTIFICATION_TIMING_SUCCESS_SHARING_STATE              @"NOTIFICATION_TIMING_SUCCESS_SHARING_STATE"

//位置信息更新结束消息通知
#define NOTIFICATION_UPLOAD_CITY_LOCATION_STATE                 @"NOTIFICATION_UPLOAD_CITY_LOCATION_STATE"

//弹出添加紧急联系人的页面
#define NOTIFICATION_SETTING_ADD_CONTACT_STATE              @"NOTIFICATION_SETTING_ADD_CONTACT_STATE"

//倒计时启动页面的时间刷新
#define NOTIFICATION_TIMING_VIEWREFRESH_FORLOCK_STATE              @"NOTIFICATION_TIMING_VIEWREFRESH_FORLOCK_STATE"

//group suit name
//#define USERDEFAULT_SUIT_NAME_PAPA                 @"group.papa.watchkit.sharingdata.it"

//企业账号
#define USERDEFAULT_SUIT_NAME_PAPA                 @"group.papa.watchkitsharingdata"


//完成倒计时的继续功能
#define USERDEFAULT_NAME_START_PASSWORD             @"USERDEFAULT_NAME_START_PASSWORD"
#define USERDEFAULT_NAME_START_TIMEEND_TIME         @"USERDEFAULT_NAME_START_TIMEEND_TIME"
#define USERDEFAULT_NAME_START_TIMETOTAL_TIME       @"USERDEFAULT_NAME_START_TIMETOTAL_TIME"

//USERDEFAULT数据
#define USERDEFAULT_UserInfo_Model                  @"USERDEFAULT_UserInfo_Model"
#define USERDEFAULT_UserInfo_Contact_List           @"USERDEFAULT_UserInfo_Contact_List"
#define USERDEFAULT_WarnTiming_Model                @"USERDEFAULT_WarnTiming_Model"
#define USERDEFAULT_Warning_Model_NeedRestart       @"USERDEFAULT_Warning_Model_NeedRestart"//用来区分是否需要再次启动关闭


//用来标识倒计时启动状态
/*状态值为YES时，表明启动成功，状态为NO时，表明状态失败(此时若服务器返回lock，则数据有效)*/
#define USERDEFAULT_Timing_Started_State            @"USERDEFAULT_Timing_Started_State"


//存储到userdefault内的设备号，以解决iphone6的设别号变化问题
#define NSUSERDEFAULT_CHECK_DEVICEID_IDENTIFIER     @"NSUSERDEFAULT_CHECK_DEVICEID_IDENTIFIER"

//通讯录里的设备id，以确保唯一性
#define NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER     @"ZA_Record_Id_TEST"


//钥匙串数据
#define USERDEFAULT_PASSWORD_LOCAL                  @"USERDEFAULT_PASSWORD_LOCAL"
#define USERDEFAULT_TIMINGSETTING_LOCAL             @"USERDEFAULT_TIMINGSETTING_LOCAL"

//启动时是否弹出信息填充界面
#define USERDEFAULT_StartInfo_Finished              @"USERDEFAULT_StartInfo_Finished"
#define USERDEFAULT_CoverView_Tips_Main_Show        @"USERDEFAULT_CoverView_Tips_Main_Show"//判定是否展示主页引导页
#define USERDEFAULT_CoverView_Tips_Start_Show       @"USERDEFAULT_CoverView_Tips_Start_Show"//判定是否展示启动引导页
#define USERDEFAULT_CoverView_Tips_Timer_Show       @"USERDEFAULT_CoverView_Tips_Timer_Show"//判定是否展示倒计时引导页


//涉及之前第三方登录，暂保留
#define NOTIFICATION_NAME_ZALOGIN_LOGINSUCCESS      @"ZAMAIN_ZALOGIN_LOGINSUCCESS"
#define NOTIFICATION_NAME_OTHERLOGIN_LOGINSUCCESS   @"ZAMAIN_OTHERLOGIN_LOGINSUCCESS"
#define USERDEFAULT_NAME_OTHERLOGIN_TOKEN           @"ZAMAIN_OTHERLOGIN_TOKEN"
#define USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE       @"ZAMAIN_OTHERLOGIN_TOKENTYPE"

#if kAPP_Local_UMENG_Identifier_TAG
//#define UMengAPPKEY @"56304eee67e58e76310000c2"
#define UMengAPPKEY @"581989d8a40fa35d48001f07"
#else
//#define UMengAPPKEY @"55b8424ee0f55a67f3002893"
#define UMengAPPKEY @"581989d8a40fa35d48001f07"
#endif

#define iOS8_constant_or_later  ( [UIDevice currentDevice].systemVersion.floatValue>=8.0 )
#define iOS9_constant_or_later  ( [UIDevice currentDevice].systemVersion.floatValue>=9.0 )

#define URL_HEAD @"http://115.159.68.180:8080/"//测试服务器
//#define URL_HEAD @"http://115.28.191.58:8080/"//正式服务器

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_Check_Special (SCREEN_HEIGHT == 480)
#define kTop                        (IOS7_OR_LATER?20 :0)
#define ZA_TABBAR_HEIGHT  FLoatChange(75)
#define TBCIRCLESLIDER_COMMON_RADIUS  FLoatChange(135)
#define TBCIRCLESLIDER_2_RADIUS  (TBCIRCLESLIDER_COMMON_RADIUS * 2 + 2)

#define NAVBAR_HEIGHT YFLoatChange(65)
#define REDCOLOR [DZUtils colorWithHex:@"df2d1e"]

#define Start_Green_Button_BGColor [DZUtils colorWithHex:@"00bf86"]
#define Custom_Green_Button_BGColor [DZUtils colorWithHex:@"0bbe85"]
#define Custom_Blue_Button_BGColor [DZUtils colorWithHex:@"3e90cc"]


//#define Contasts_Btn_Blue_BGColor [DZUtils colorWithHex:@"6c95e9"]
#define Custom_View_Gray_BGColor [DZUtils colorWithHex:@"f5f5f5"]
#define Custom_Gray_Line_Color [DZUtils colorWithHex:@"E9E9EA"]
#define Tabbar_Bottom_Text_Gray_Color [DZUtils colorWithHex:@"d3efdb"]

#define Password_White_BG_Color RGB(203, 224, 235)
#define Password_White_Selected_BG_Color [DZUtils colorWithHex:@"B2C6D2"]
#define Password_Red_BG_Color [DZUtils colorWithHex:@"F57F7D"]
#define Password_Red_Selected_BG_Color RGB(220, 40, 40)

#define Custom_BG_Dark_Brown_Color RGB(13, 38, 62)
#define Setting_Btn_Dark_Color [DZUtils colorWithHex:@"354457"]

#define TITLE_LABLE_COLOR [DZUtils colorWithHex:@"222222"]
#define TITLE_LABLE_GAYCOLOR [DZUtils colorWithHex:@"888888"]
#define LINE_GAYCOLOR [DZUtils colorWithHex:@"eeeeee"]
#define VIEW_GAYCOLOR [DZUtils colorWithHex:@"e3e3e6"]
#define VIEW_BTN_GAYCOLOR [DZUtils colorWithHex:@"6c7989"]
#define TITLE_LABLE_ORGANCE [DZUtils colorWithHex:@"ff6623"]
#define START_LOING_LINE_COLOR [DZUtils colorWithHex:@"E9E9EA"]

#define TEXT_ERROR_YELLOWCOLOR RGB(248, 137, 0)
#define CONTENT_HEIGHT [UIScreen mainScreen].bounds.size.height - NAVBAR_HEIGHT
#define MAIN_LIST_BGCOLOR RGB(40, 176, 199)

#define ZA_Contacts_List_Max_Num @"8"
#define ZA_Contacts_List_Max_Effective_Num @"3"


//比例系数
#define  WindowWidthFloat  SCREEN_WIDTH / 320.0f

//使用宏定义，因为有重复判定也是
#define ZA_Relation_Replace_TXT  @"TA是谁？"

//AppID：wxa585ec15f07f80c7
//AppSecret：d86598968bf6ee3e595ffb2477dc833d

//APP默认下载地址
#define kShareAPP_URL_DOWNLOAD_PATH @"https://itunes.apple.com/cn/app/pa-pa/id1047549816?l=zh&ls=1&mt=8"

//SETTING,使用
#define kShareAPP_URL_PATH @"http://viewer.maka.im/k/TC42K97O"
#define kShareAPP_URL_DES_TXT @"怕怕安全防护，您身边的安全管家"
#define kShareAPP_URL_DES_SUB_TXT @"国内领先的个人安全防护App"


#define kShareAPP_URL_PATH_SECOND @"http://112.124.212.52/za-papa/static/html5/main.html"
#define kShareAPP_URL_DES_TXT_SECOND @"自从有了怕怕，胆子越来越大"
#define kShareAPP_URL_DES_SUB_TXT_SECOND @"打车！夜路！下班回家！"

//BOOL值，kShareAPP_TYPE_CURRENT_SETTING 为YES 标识设置里面进入的
#define kShareAPP_TYPE_CURRENT_SETTING @"kShareAPP_TYPE_CURRENT_SETTING"

#define kWXAPP_URL_KEY @"wx9d8863da708d6685"
#define kWXAPP_SECRET @"6c62773eb5065180fc2265af67ca8866"

//需要考虑appID宏定义，plist以及内容
//APP ID1104743955APP KEYhrTbGR9YWiQiFCTA  ios怕怕众安账号
#define kQQAPP_URL_KEY @"tencent1104743955"

#define kAppNone_Service_Error @"系统暂时异常，请稍后再试~"
#define kAppNone_Network_Error @"当前无网络，请稍后再试"

#define kAddress_Service_Notice_Over8   @"为方便您添加紧急联系人，请点击设置-打开通讯录读取开关"
#define kAddress_Service_Notice         @"为方便您添加紧急联系人，请进入设置->隐私->通讯录->怕怕 中开启读取通讯录"


#define NoticeMessage @"我正在使用“怕怕”安全防护软件，设置了你为紧急联系人，如果我遇到危险，怕怕会将我的位置发给你并联系你~请惠存怕怕客服号码:\n 010-89178958"


#define kShare_Default_Message @"我正在使用‘怕怕’安全软件,查看以下链接,怕怕就会告诉你我在哪： "

#define ZAViewLocalizedStringForKey(str) NSLocalizedStringFromTable(str,@"ZAViewLocal", nil)
#define ZANoticeLocalizedStringForKey(str) NSLocalizedStringFromTable(str,@"ZANoticeLocal", nil)

typedef enum
{
    DetailModelSaveType_Buy = 1,//建议购买利率  15以上
    DetailModelSaveType_Notice, //不满足购买建议，但有特殊意义
    DetailModelSaveType_Save,  //计算利率13以上，但不满足购买建议
    DetailModelSaveType_NoUse  //利率低，无特点
}DetailModelSaveType;

typedef enum
{
    OthersAppDetailShareType_Share = 1,
    OthersAppDetailShareType_Notice,
    OthersAppDetailShareType_SharePath
}OthersAppDetailShareType;

typedef enum
{
    ZAAuthorityCheckType_Main = 0,
    ZAAuthorityCheckType_Address
}ZAAuthorityCheckType;

typedef enum
{
    ZAAuthoritySelectType_None          = 0,
    ZAAuthoritySelectType_Location      = 1 << 0,
    ZAAuthoritySelectType_Recorder      = 1 << 1,
    ZAAuthoritySelectType_Notification  = 1 << 2,
    ZAAuthoritySelectType_Address       = 1 << 3,
}ZAAuthoritySelectType;


typedef enum
{
    HTTPReturnServerInternalError = -1,
    HTTPReturnSuccess = 0,
    HTTPReturnVerifyError = 1,
    HTTPReturnTokenExpire = 101,
    HTTPReturnCaptchaSendError = 3,
    HTTPReturnNoneContacts = 151
}HTTPReturnCode;

typedef enum
{
    ThirdPartyTypeWechat = 1,
    ThirdPartyTypeQQ = 2,
    ThirdPartyTypeTaobao = 3,
    ThirdPartyTypeOther = 4
}ThirdPartyLoginType;

typedef enum
{
    GenderTypeFemale = 0,
    GenderTypeMale = 1
}GenderType;

typedef enum
{
    CertificateTypeIDCard = 1,
    CertificateTypeEEPtoHK = 2,
    CertificateTypePassport = 3
}CertificateType;

typedef enum
{
    CaptchaTypeRegister = 1,
    CaptchaTypeThirdPartyRegister = 2,
    CaptchaTypeResetPwd = 3
}SendCaptchaType;

#define TokenExpiredNotification @"TokenExpiredNotification"
