//
//  TBCircularSlider.h
//  TB_CircularSlider
//
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commons.h"

@interface TBCircularSlider : UIControl

@property (nonatomic,assign) BOOL showPersent;//鉴于设计的第二种模式
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) int angle;

//B8E9F2  whitecolor之间互换
@property (nonatomic,strong) UIColor * circleColor;

//设定的比例值
-(void)setSliderScale:(CGFloat)scale;




@end
