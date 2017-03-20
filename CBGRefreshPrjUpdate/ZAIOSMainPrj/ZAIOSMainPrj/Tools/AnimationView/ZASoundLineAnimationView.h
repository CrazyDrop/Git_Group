//
//  ZASoundLineAnimationView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/29.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZASoundLineAnimationView : UIScrollView

-(void)refreshSoundViewSize;

-(void)startAnimation;
-(void)stopAnimation;
- (void)resetAnimations;
@end
