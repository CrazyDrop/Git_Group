//
//  ZAAuthorityController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/23.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ZAAuthorityCheckResultType_None = 0,
    ZAAuthorityCheckResultType_Access,
    ZAAuthorityCheckResultType_Refuse
}ZAAuthorityCheckResultType;

@interface ZAAuthorityController : UIViewController


//是否为联系人权限申请
@property (nonatomic,assign) ZAAuthorityCheckType type;


//相关点击事件，也可以封装到类里面，不需要外部实现
@property (nonatomic,copy) void (^TapedOnAuthorityBtnBlock)(ZAAuthoritySelectType selectType);


//关闭事件
@property (nonatomic,copy) void (^TapedOnCloseAuthorityBtnBlock)();

//检查刷新当前展示某项属性和状态
-(void)checkUpAuthorityResultForSelectedType:(ZAAuthoritySelectType)type;

//刷新当前的状态
-(void)refreshCurrentAuthority;


@end
