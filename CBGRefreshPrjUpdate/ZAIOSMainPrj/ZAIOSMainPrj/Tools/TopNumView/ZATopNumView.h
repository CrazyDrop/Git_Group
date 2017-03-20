//
//  ZATopNumView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/28.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

//引导页面顶部视图
//包括  一个横线  一个背景环，三个数字view
@interface ZATopNumView : UIView

//需要设置不同透明度，使用子视图区分
@property (nonatomic,assign) NSInteger numIndex;




@end
