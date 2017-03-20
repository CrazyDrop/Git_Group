//
//  CircleAnimationView.h
//  SimpleWebProject
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleAnimationView : UIView

@property (nonatomic,strong) UIColor * shadowColor;
@property (nonatomic,assign) CGFloat startLength;
@property (nonatomic,assign) CGFloat maxLength;


-(void)startCircleAnimation;
-(void)stopCircleAnimation;



@end
