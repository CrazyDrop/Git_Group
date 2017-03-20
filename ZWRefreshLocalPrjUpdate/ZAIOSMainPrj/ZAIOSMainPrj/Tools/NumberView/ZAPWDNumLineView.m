//
//  ZAPWDNumLineView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/23.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAPWDNumLineView.h"
#import "ZAEveLineView.h"

@interface ZAPWDNumLineView()
{
    CGFloat eveViewWidth;
}
@property (nonatomic,strong) NSArray * subViews;
@end
@implementation ZAPWDNumLineView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.opaque = NO;
        
        _totalNum = 4;
        _currentIndex = 0;
        eveViewWidth = FLoatChange(20);

    }
    return self;
}
-(void)setTotalNum:(NSInteger)totalNum
{
    _totalNum = totalNum;
    for (UIView * eve in self.subViews)
    {
        [eve removeFromSuperview];
    }
    self.subViews = nil;
    [self setNeedsDisplay];
}
-(void)setCurrentIndex:(NSInteger)index
{
    NSInteger total = self.totalNum;
    if(index<0) index = 0 ;
    if(index>total)index = total;
    
    _currentIndex = index;
    
    
    //选中当前的，并选中之前的(无动画)
    for (NSInteger i =0;i<total ;i++ )
    {
        ZAEveLineView * eve  = [self.subViews objectAtIndex:i];
        //设定初始状态
        if(i<self.currentIndex)
        {
            [eve refreshLineVewSelectedWithCurrentTxt:@"d" animated:NO];

        }else{
            [eve refreshLineVewSelectedWithCurrentTxt:nil animated:NO];
        }
    }
    
    [self setNeedsDisplay];
}

-(NSArray *)subViews
{
    if(!_subViews)
    {
        NSMutableArray * array = [NSMutableArray array];
        for (NSInteger index =0;index<self.totalNum ;index++ )
        {
            CGFloat eveWidth = eveViewWidth;
            CGFloat eveHeight = FLoatChange(30);
            ZAEveLineView * eve = [[ZAEveLineView alloc] initWithFrame:CGRectMake(0, 0, eveWidth, eveHeight)];
            [self addSubview:eve];
            
            [array addObject:eve];
        }
        
        self.subViews = array;
    }
    return _subViews;
}


-(void)refreshCurrentIndex:(NSInteger)index WithTempTxt:(NSString *)txt
{
    self.currentIndex = index;
    return;
    NSInteger total = self.totalNum;
    if(index<0) index = 0 ;
    if(index>total)index = total;
    
    _currentIndex = index;
    
    //选中当前的，并选中之前的(无动画)
    for (NSInteger i =0;i<total ;i++ )
    {
        ZAEveLineView * eve  = [self.subViews objectAtIndex:i];
        //设定初始状态
        if(i<self.currentIndex)
        {
            [eve refreshLineVewSelectedWithCurrentTxt:@"d" animated:NO];
            
        }else{
            [eve refreshLineVewSelectedWithCurrentTxt:nil animated:NO];
        }
    }
    
    if(index>0)
    {
        ZAEveLineView * eve  = [self.subViews objectAtIndex:index-1];
        [eve refreshLineVewSelectedWithCurrentTxt:txt animated:YES];
    }

    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //调整位置
    CGFloat eveWidth = eveViewWidth;
    CGFloat eveSep = (self.bounds.size.width - eveWidth * self.totalNum)/(self.totalNum -1);
    
    //刷新当前选中
    //区分大小
    CGFloat centerY  = self.bounds.size.height/2.0;
    for (NSInteger index =0;index<self.totalNum ;index++ )
    {
        ZAEveLineView * eve  = [self.subViews objectAtIndex:index];
        CGFloat centerX = eveWidth/2.0 + (eveWidth + eveSep) * index;
        eve.center = CGPointMake(centerX, centerY);
    }
    
}




@end
