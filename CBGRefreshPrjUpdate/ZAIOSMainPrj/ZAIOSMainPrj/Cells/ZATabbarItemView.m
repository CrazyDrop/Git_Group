//
//  ZATabbarItemView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATabbarItemView.h"

@interface ZATabbarItemView()
@property (nonatomic,assign) CGFloat bottomLblMaxY;
@property (nonatomic,assign) CGFloat spaceHeight;

@property (nonatomic,assign) CGFloat centerImgLblY;
@end

@implementation ZATabbarItemView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        CGRect rect = self.bounds;
        CGFloat effectiveHeight = rect.size.height/2.0;
        rect.size.height = effectiveHeight;
        
        //        UIView * aView = [[UIView alloc] initWithFrame:rect];
        //        aView.center = CGPointMake(self.bounds.size.width/2.0,self.bounds.size.height/2.0);
        //        [self addSubview:aView];
        //        aView.backgroundColor = [UIColor clearColor];
        //        self.bgView = aView;
        
        UIView * aView = self;

        
        CGFloat viewWidth = self.bounds.size.width;
        
        UIColor * color = [UIColor clearColor];
        rect.size.height *= (1/2.0);
        UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
        lbl.text = @"120";
        lbl.textAlignment = NSTextAlignmentCenter;
        [aView addSubview:lbl];
        lbl.font = [UIFont systemFontOfSize:FLoatChange(15)];
        [lbl sizeToFit];
        lbl.backgroundColor = color;
        self.topLbl = lbl;
        
        lbl.center = CGPointMake(viewWidth/2.0, FLoatChange(30));
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
        [aView addSubview:img];
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.center = CGPointMake(lbl.center.x, lbl.center.y);
        self.imgView = img;
        
        rect.size.height *= (1/2.0);
        UILabel * bottom = [[UILabel alloc] initWithFrame:rect];
        bottom.text = @"分钟";
        bottom.textAlignment = NSTextAlignmentCenter;
        bottom.font = [UIFont systemFontOfSize:FLoatChange(9)];
        [bottom sizeToFit];
        [aView addSubview:bottom];
        bottom.center = CGPointMake(lbl.center.x, FLoatChange(50));
        bottom.backgroundColor = color;
    
        self.bottomLbl = bottom;
        
        self.bottomLblMaxY = CGRectGetMaxY(bottom.frame);
        self.spaceHeight = (CGRectGetMinY(bottom.frame) - CGRectGetMaxY(lbl.frame));
        
        self.centerImgLblY = (CGRectGetMinY(lbl.frame) + CGRectGetMaxY(bottom.frame))/2.0;
    }
    return self;
}

-(void)refreshTransformForPersent:(CGFloat)persent
{
//    UIView * mainView = self.bgView;
    CGFloat extend = persent;
    CGFloat maxScale = 1.3;
    CGFloat scale = 1 + (maxScale -1) * (extend); //范围 0.6- 1，extend为0 scale为1
    CGFloat bigScale = 1 + (1.5 -1) * (extend); //范围 0.6- 1，extend为0 scale为1
    //extend距离为0时 缩放为1
    
    //0-0.667//persent为1时，effectivePersent为0
    CGFloat effectivePersent = (1-persent) * (1/3.0);
    
    self.bottomLbl.textColor = [UIColor colorWithWhite:effectivePersent alpha:1];
    self.topLbl.textColor = [UIColor colorWithWhite:effectivePersent alpha:1];
    
    UIFont * font = [UIFont systemFontOfSize:FLoatChange(15)];
    if(persent==1)
    {
        font = [UIFont fontWithName:@"STHeitiTC-Light" size:FLoatChange(15)];
    }
    self.topLbl.font = font;
    
    CGFloat startSize =  FLoatChange(15);
    CGFloat fontScale = 1 + (maxScale -1) * (extend); //范围 0.6- 1，extend为0 scale为1
//    CGFloat endSize = startSize * fontScale;
    
//    self.topLbl.font = [UIFont systemFontOfSize:endSize];
    CGFloat viewWidth = self.bounds.size.width;
    
    CGFloat imgScale = 0.8;
    self.bottomLbl.transform = CGAffineTransformMakeScale(scale,scale);
    self.topLbl.transform = CGAffineTransformMakeScale(bigScale,bigScale);
    self.imgView.transform = CGAffineTransformMakeScale(bigScale*imgScale,bigScale*imgScale);

    

    CGRect rect = CGRectZero;
    //文本底线保持一致
//    rect = self.bottomLbl.frame;
//    rect.origin.y = self.bottomLblMaxY - rect.size.height;
//    self.bottomLbl.frame = rect;
//    
//    rect = self.topLbl.frame;
//    rect.origin.y = self.bottomLblMaxY - rect.size.height - self.bottomLbl.bounds.size.height - self.spaceHeight;
//    self.topLbl.frame = rect;
//    
//    CGFloat spaceExtend = 0;
//    if(persent == 1.0)
//    {
//        spaceExtend = self.spaceHeight * persent * 0.5;
//    }
//    rect = self.imgView.frame;
//    rect.origin.y = self.bottomLblMaxY - rect.size.height - self.bottomLbl.bounds.size.height - self.spaceHeight - spaceExtend;
//    self.imgView.frame = rect;
    
    //文本和图片的中心点保持一致
    //即，缩放后，centerImgLblY仍未两者中心
    //1实现间距不变，改变底部bottomLbl 的位置
    
    
    //中间距离要逐渐变小，因为放大后，文本边距增大了
    CGFloat spaceExtend = self.spaceHeight;
    CGFloat maxSpaceScale = 0.6;
    //当persent 为1时，spaceExtend取到0.8 persent为0时，使用1
    spaceExtend = (maxSpaceScale + (1 - persent) * (1-maxSpaceScale)) * spaceExtend;

    rect = self.bottomLbl.frame;
    rect.origin.y = CGRectGetMaxY(self.topLbl.frame) + spaceExtend;
    self.bottomLbl.frame = rect;

    
    //计算两者当前中心点
    CGFloat currentCenter = (CGRectGetMinY(self.topLbl.frame) + CGRectGetMaxY(self.bottomLbl.frame))/2.0;
    CGFloat exchange = (currentCenter - self.centerImgLblY);

    
    //此点，较self.centerImgLblY肯定有变化，偏差量即放大差额
    //目标，实现currentCenter 与 self.centerImgLblY 实现一致，两者间隔仍为 spaceHeight
    //进行平移，向上或向下，统一移动
    
    rect = self.bottomLbl.frame;
    rect.origin.y -= exchange;
    self.bottomLbl.frame = rect;
    
    rect = self.topLbl.frame;
    rect.origin.y -= exchange;
    self.topLbl.frame = rect;

    
    rect = self.imgView.frame;
    rect.origin.y -= exchange;
    self.imgView.frame = rect;
    
    
    //上面设定imgView位置,之后设定 bottomLbl、topLbl位置
    maxSpaceScale = 0.4;
    //当persent 为1时，spaceExtend取到0.8 persent为0时，使用1
    spaceExtend = (maxSpaceScale + (1 - persent) * (1-maxSpaceScale)) * spaceExtend;
    
    rect = self.bottomLbl.frame;
    rect.origin.y = CGRectGetMaxY(self.topLbl.frame) + spaceExtend;
    self.bottomLbl.frame = rect;
    
    
    //计算两者当前中心点
    currentCenter = (CGRectGetMinY(self.topLbl.frame) + CGRectGetMaxY(self.bottomLbl.frame))/2.0;
    exchange = (currentCenter - self.centerImgLblY);
    
    rect = self.bottomLbl.frame;
    rect.origin.y -= exchange;
    self.bottomLbl.frame = rect;
    
    rect = self.topLbl.frame;
    rect.origin.y -= exchange;
    self.topLbl.frame = rect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
