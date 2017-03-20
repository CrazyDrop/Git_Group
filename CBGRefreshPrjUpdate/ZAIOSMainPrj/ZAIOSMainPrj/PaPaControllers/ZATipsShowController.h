//
//  ZATipsShowController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/25.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
//完成tips页面展示功能
//此页面作为悬浮层展示

@interface ZATipsShowController : UIViewController



//点击按钮响应，需要在针对index=1  进行跳转
//index=2  进行结束的时间保存
@property (nonatomic,copy) void (^TapedOnCoverBtnBlock)(NSInteger index);


//执行方法，之后置空视图
//@property (nonatomic,copy) void (^TapedOnEndFinishedBtnBlock)(void);

@property (nonatomic,assign) NSInteger startIndex;






@end
