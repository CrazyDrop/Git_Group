//
//  ZALocalStateTotalModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocalStateModel.h"

#define Local_File_ZALocalStateTotalModel_Model         @"Model.ZALocalStateTotalModel"
//仅iphone端使用，包括信息用户  紧急联系人信息
@interface ZALocalStateTotalModel : ZALocalStateModel

//是否需要登录
@property (nonatomic,assign,readonly,getter=isUserLogin) BOOL userLogin;

//是否需要补全信息
@property (nonatomic,assign,readonly,getter=isNeedUpdate) BOOL needUpdate;

////是否需要补全信息
@property (nonatomic,assign,readonly,getter=isNeedAddContact) BOOL needAddContact;

////是否需要补全信息
@property (nonatomic,assign,readonly,getter=isNeedStartedAddContact) BOOL needStartedAddContact;

//是否需要弹出失联4天
@property (nonatomic,assign,readonly,getter=isNeedDialog) BOOL needDialog;


//是否需要检查预警，针对刚登陆不需要检查预警的处理，使用此变量，本地保存数据后设置为YES，一次使用后置NO
@property (nonatomic,assign) BOOL loginHideCheck;


//token
@property (nonatomic,assign,readonly) NSString * token;

//启动介绍页面
@property (nonatomic,assign) BOOL start_Introduce_Showed;

//权限设置页面，只展示一次
@property (nonatomic,assign) BOOL start_Authority_Showed;

//通讯录权限页面，只展示一次
@property (nonatomic,assign) BOOL address_Authority_Showed;

//是否已经添加过客服电话，添加成功的则忽略,已经添加
@property (nonatomic,assign) BOOL addresslist_Added_Contact;

//是否已经提示过弹出录音权限之前的弹框，，默认为NO
@property (nonatomic,assign) BOOL recorder_Alert_Noticed;

//紧急联系人红点相关，默认为NO
@property (nonatomic,assign) BOOL contactRed_Need_Show;

//提示页面展示情况，仅APP有效
@property (nonatomic,assign) BOOL main_Tips_Showed;//主页上的展示引导页面  YES为已经展示过
@property (nonatomic,assign) BOOL timer_Tips_Showed;//倒计时页面上展示的引导页面  YES为已经展示过
@property (nonatomic,assign) BOOL start_Tips_Showed;//注册页面上展示的引导页面  YES为已经展示过，目前相关界面不再使用

//城市名称，获取时间
@property (nonatomic,copy) NSString * locationCity;//当前的城市信息
@property (nonatomic,copy) NSString * locationAddress;//位置详情,规划地址
@property (nonatomic,copy) NSString * locationAddress_des;//位置详情,描述
@property (nonatomic,copy) NSDate * cityDate;//注册页面上展示的引导页面  YES为已经展示过


@property (nonatomic,copy) NSString * kmVCNameString;//当前的vc记录信息


//个人用户信息，修改用户信息时，修改密码password
//@property (nonatomic,strong) id  userInfo;


//紧急联系人信息
@property (nonatomic,strong) NSArray * contacts;


//model，修改timeModel时，修改warningId
//@property (nonatomic,strong) WarnTimingModel * timeModel;

//统计表
@property (nonatomic,strong) NSString * sellRateStr;

//区分是否要闹铃提示
@property (nonatomic,assign) BOOL  isAlarm;
@property (nonatomic,assign) NSInteger minServerId;//最小的服务器号

//区别用数据
@property (nonatomic,strong) NSString * randomAgent;

//实现刷新频次控制
@property (nonatomic,strong) NSString * refreshTime;

@property (nonatomic,strong) NSString * localURL1;
@property (nonatomic,strong) NSString * localURL2;

@property (nonatomic, strong) NSDictionary * serverNameDic;//通过服务器id，查找服务器名字


//针对退出登录清空数据
+(void)clearLocalStateForLogout;


@end
