//
//  ZALocalStateModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/9.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//之前使用userdefault存储的本地状态较多，改为统一存储
//外部宏定义文本太多，统一内部使用
//需要和applewatch共用，暂保持独立

#define Local_File_ZALocalStateModel_Model         @"Model.ZALocalStateModel"

@interface ZALocalStateModel : NSObject
{
//    NSString * _warningId;
//    NSString * _password;
    NSLock * safeLock;
}

//识别标识
@property (nonatomic,copy) NSString * stateIdentifier;

//倒计时id   修改无效
@property (nonatomic,copy) NSString * warningId;

//密码   修改无效
@property (nonatomic,copy) NSString * password;

//默认时间   此处使用时与applewatch交互过麻烦，使用default替代
//@property (nonatomic,copy) NSString * currentTimeLength;

//密码页面
@property (nonatomic,assign) BOOL showPWD;//展示密码页面


//紧急模式启动后，runwarning失败，默认为NO，当紧急模式启动成功，但是run失败时，置为YES
//启动时检测此数据，仅当再次启动时，展示有倒计时的密码页面
//应用删除，或退出登录时，置为安全需要清空
@property (nonatomic,assign) BOOL runErr;//展示密码页面


//倒计时相关
@property (nonatomic,assign) NSInteger totalTime;//倒计时总时间
@property (nonatomic,copy) NSDate * endDate;//倒计时结束时间


//通知时间，结束预警时置为空，为空时表示登录带来的预警，作为已经通知到处理，当前时间早于此时间时展示红色顶部，其他展示蓝顶
@property (nonatomic,copy) NSDate * noticeDate;//预计通知时间


//需要再次关闭预警，当前以服务器返回状态为准，不需要此处
//@property (nonatomic,assign) BOOL needReCancel;//需要再次关闭


//本地统一存储的数据，鉴于和applewatch通信，统一使用设置束(使用单例存在两对象问题)
+(instancetype)currentLocalStateModel;

//数据存储到本地
-(void)localSave;


//数据重新读取，仅针对iphone手机端信息有修改的情况调用
-(void)refreshLocalSaveStateDataWithCurrentData;



@end
