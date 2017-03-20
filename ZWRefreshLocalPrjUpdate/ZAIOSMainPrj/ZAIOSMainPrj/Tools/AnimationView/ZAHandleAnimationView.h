//
//  ZAHandleAnimationView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/28.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAHandleAnimationView : UIView



@property (nonatomic,assign) BOOL showPerson;//默认为NO，控制顶部图像

-(void)startAnimation;
-(void)stopAnimation;
- (void)resetAnimations;

@end
