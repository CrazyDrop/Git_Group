//
//  ZALineNumberView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/26.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALineNumberView.h"

@implementation ZALineNumberView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.opaque = NO;
        self.circleColor = [DZUtils colorWithHex:@"969696"];
        self.selectedColor = [DZUtils colorWithHex:@"45c771"];
        _totalNum = 4;
        _currentIndex = 0;
        self.radius = 10;
    }
    return self;
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self setNeedsDisplay];
}
-(void)setTotalNum:(NSInteger)totalNum
{
    _totalNum = totalNum;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    //区分大小
    NSInteger total = _totalNum;
    if(total<=0) return;
    
    NSInteger index = _currentIndex;
    if(index<0) index = 0 ;
    if(index>total)index = total;

    //计算位置
    CGFloat sepLength = self.bounds.size.width - self.radius * 2 ;
    CGFloat eveLength = sepLength / (total - 1.0);
    CGFloat sepX = self.radius;
    CGFloat startY = CGRectGetMidY(self.bounds);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat startX = 0;
    //绘制选中图形
    for (NSInteger i=0;i<index ; i ++ )
    {
        startX = sepX + eveLength * i;
        CGContextAddArc(ctx, startX, startY, self.radius, 0 , M_PI * 2  , 0);
        UIColor * color = self.selectedColor?:[UIColor greenColor];
        [color setFill];
        CGContextSetLineWidth(ctx, 1);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextDrawPath(ctx, kCGPathFill);
        
    }
    
    //绘制未选中图形
    for (NSInteger i=index;i<total ; i ++ )
    {
        startX = sepX + eveLength * i;
        CGContextAddArc(ctx, startX, startY, self.radius, 0 , M_PI * 2  , 0);
        UIColor * color = self.circleColor?:[UIColor blackColor];
        [color setStroke];
        CGContextSetLineWidth(ctx, 1);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    

}


@end
