//
//  ZATopNumView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/28.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATopNumView.h"

@interface ZATopNumView()
{
    UIImageView * topLine;
    UIView * selectCircle;
    UIImageView * bgImgView;
    
    UILabel * lbl1;
    UILabel * lbl2;
    UILabel * lbl3;
}
@end

@implementation ZATopNumView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self createTopSubViews];
    }
    return self;
}
-(void)createTopSubViews
{
    CGRect rect = self.bounds;
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:img];
    img.image = [UIImage imageNamed:@"start_bg_circle"];
    bgImgView = img;
    bgImgView.alpha = 0.3;
    
    
    img = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:img];
    img.image = [UIImage imageNamed:@"start_bg_line"];
    topLine = img;
    topLine.alpha = 0.1;
    
    UIView * aCircle = [[UIView alloc] initWithFrame:rect];
    [self addSubview:aCircle];
    aCircle.clipsToBounds = YES;
    selectCircle = aCircle;
//    aCircle.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    
    UIView * cover = [[UIView alloc] initWithFrame:aCircle.bounds];
    cover.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [aCircle addSubview:cover];
    cover.backgroundColor = [UIColor whiteColor];
    cover.alpha = 0.2;
    
    lbl1 = [self customNumberTxtLbl];
    lbl1.text = @"1";
    
    lbl2 = [self customNumberTxtLbl];
    lbl2.text = @"2";
    
    lbl3 = [self customNumberTxtLbl];
    lbl3.text = @"3";
}
-(void)layoutSubviews
{
    //子视图位置排列
    NSInteger selectIndex = self.numIndex;
    if(selectIndex<0||selectIndex>2) selectIndex = 0;
    
    topLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/750.0*87.0);
    topLine.center = CGPointMake(SCREEN_WIDTH/2.0, 0);
    
    CGRect rect = self.bounds;
    CGFloat circleRadius = 80.0/127.0*rect.size.height;
    CGFloat startY = 60.0/127.0*rect.size.height;
    CGFloat startX = 215.0/750.0*rect.size.width;
    
    //修改选中视图样式
    CGPoint pt = CGPointMake(startX, startY);
    rect.size = CGSizeMake(circleRadius, circleRadius);
    rect.origin = pt;
    
    UILabel * selectLbl = nil;
    //循环，添加数字123
    for (NSInteger index=0;index< 3; index++)
    {
        UILabel * lbl = nil;
        switch (index) {
            case 0:
                lbl = lbl1;
                pt = CGPointMake(startX, startY);
                break;
            case 1:
                lbl = lbl2;
                pt = CGPointMake(self.bounds.size.width/2.0, circleRadius/2.0);
                break;
            case 2:
                lbl = lbl3;
                pt = CGPointMake(self.bounds.size.width - startX, startY);
                break;
            default:
                break;
        }
        lbl.frame = rect;
        [bgImgView addSubview:lbl];
        lbl.center = pt;
        
        if(selectIndex == index) selectLbl = lbl;
    }

    //特殊处理新增的选中视图
    //处理大小
    UIView * select = selectCircle;
    select.frame = rect;
    select.center = selectLbl.center;
    
    CALayer * layer = select.layer;
    [layer setCornerRadius:rect.size.height/2.0];
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor whiteColor] CGColor];
    
    rect = [bgImgView convertRect:selectLbl.frame toView:select];
    selectLbl.frame = rect;
    [select addSubview:selectLbl];
}

-(UILabel *)customNumberTxtLbl
{
    CGRect rect = CGRectZero;
    UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
    aLbl.backgroundColor = [UIColor clearColor];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.textColor = [UIColor whiteColor];
    return aLbl;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    [super drawRect:rect];
//    
//    CGFloat circleRadius = 80.0/127.0*rect.size.height;
//    CGFloat startY = 60.0/127.0*rect.size.height;
//    CGFloat startX = 215.0/750.0*rect.size.width;
//    
//    //绘制图形
//    UIImage * bgImg = [UIImage imageNamed:@"start_bg_circle"];
//    [bgImg drawInRect:rect];
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    //选中圆圈
//    CGContextAddArc(ctx, startX,startY, circleRadius/2.0, 0 , M_PI * 2  , 0);
//    [[UIColor redColor] setStroke];
//    CGContextSetLineWidth(ctx, 2);
//    CGContextSetLineCap(ctx, kCGLineCapButt);
//    CGContextDrawPath(ctx, kCGPathStroke);
//    
//}

@end
