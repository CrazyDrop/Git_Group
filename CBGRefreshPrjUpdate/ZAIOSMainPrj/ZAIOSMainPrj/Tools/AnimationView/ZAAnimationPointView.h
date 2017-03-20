//
//  ZAAnimationPointView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/27.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAAnimationPointView : UIView

@property (nonatomic,assign) CGFloat ptWidth;
@property (nonatomic,assign) CGFloat ptSepX;


-(void)startPointAnimation;
-(void)stopPointAnimation;


@end
