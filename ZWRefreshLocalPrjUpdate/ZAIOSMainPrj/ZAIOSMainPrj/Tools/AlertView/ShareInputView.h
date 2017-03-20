//
//  ShareInputView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
//分享的内容试图
@interface ShareInputView : UIView

//点击按钮事件
@property (nonatomic,copy) void (^TapedOnBottomBtnBlock)(NSInteger index, NSString * inputText);





@end
