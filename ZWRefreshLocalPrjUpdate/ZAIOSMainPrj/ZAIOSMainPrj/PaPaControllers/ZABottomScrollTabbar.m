//
//  ZABottomScrollTabbar.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZABottomScrollTabbar.h"
#define ZABottomTabbarAdd 100
@interface ZABottomScrollTabbar()<UIScrollViewDelegate>
{
    UIScrollView * bottomScroll;
    CGFloat tabbarEveWidth;
    BOOL scrollInUse;
    CGFloat tipStartX;
    NSLock * arrLock;
}

@property (nonatomic,strong) UIView * coverView;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,strong) NSArray * showViews;
@property (nonatomic,strong) UIView * scrollBgView;
@end

@implementation ZABottomScrollTabbar

-(UIView *)scrollBgView
{
    if(!_scrollBgView)
    {
        UIView * bg = [[UIView alloc] initWithFrame:bottomScroll.bounds];
        bg.backgroundColor = [UIColor clearColor];
        self.scrollBgView = bg;
    }
    return _scrollBgView;
}
-(UIView *)coverView
{
    if(!_coverView)
    {
        UIView * aView = [[UIView alloc] initWithFrame:bottomScroll.bounds];
        aView.backgroundColor = [UIColor clearColor];
        aView.alpha = 0.2;
        self.coverView = aView;
    }
    return _coverView;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.selectedIndex = NSNotFound;
        UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scroll];
        scroll.decelerationRate = 0.2;
        scroll.delegate = self;
        scroll.showsHorizontalScrollIndicator = NO;
        scrollInUse = NO;
        arrLock = [[NSLock alloc] init];
        bottomScroll = scroll;
    }
    return self;
}

-(void)tapedOnShowView:(UITapGestureRecognizer *)ges
{
    UIView * aView = ges.view;
    NSInteger index = (aView.tag - ZABottomTabbarAdd);
    scrollInUse = YES;
    if(self.selectedIndex == index) return;
    [self replaceSubViewsAndScrollToSelectedViewForIndex:index];
}

-(void)replaceSubViewsAndScrollToSelectedViewForIndex:(NSInteger)index
{
    [self replaceTabbarShowViewsForSelectedIndex:index];
    
    //调用比例系数代理
    if(self.delegate&&[self.delegate respondsToSelector:@selector(zaBottomScrollTabbar:didSelectedIndex:)])
    {
        [self.delegate zaBottomScrollTabbar:self didSelectedIndex:index];
    }
    
    self.selectedIndex = index;
    
    [self scrollToSelectedIndexAnimated:YES];
}
-(void)replaceTabbarShowViewsForSelectedIndex:(NSInteger)index
{
    [arrLock lock];
    NSMutableArray * array = [NSMutableArray arrayWithArray:self.showViews];
    
    //之前的数据，新数据
    //替换之前
    
    NSInteger preIndex = self.selectedIndex;
    UIView * replaceSelectView = nil;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(zaBottomScrollTabbar:customViewForTabbarIndex:)])
    {
        replaceSelectView = [self.dataSource zaBottomScrollTabbar:self customViewForTabbarIndex:preIndex];
    }
    
    
    UIView * view = [self.showViews objectAtIndex:preIndex];
    replaceSelectView.frame = view.frame;
    replaceSelectView.tag = ZABottomTabbarAdd + preIndex;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnShowView:)];
    [replaceSelectView addGestureRecognizer:tap];
    
    [view removeFromSuperview];
    [self.scrollBgView addSubview:replaceSelectView];
    [array replaceObjectAtIndex:preIndex withObject:replaceSelectView];
    
    
    //替换新选中
    UIView * currentSelectedView = nil;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(zaBottomScrollTabbar:selectedViewForTabbarIndex:)])
    {
        currentSelectedView = [self.dataSource zaBottomScrollTabbar:self selectedViewForTabbarIndex:index];
    }
    
    view = [self.showViews objectAtIndex:index];
    currentSelectedView.frame = view.frame;
    currentSelectedView.tag = ZABottomTabbarAdd + index;
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnShowView:)];
    [currentSelectedView addGestureRecognizer:tap1];
    
    [view removeFromSuperview];
    [self.scrollBgView addSubview:currentSelectedView];
    [array replaceObjectAtIndex:index withObject:currentSelectedView];
    
    self.showViews = array;
    [arrLock unlock];
}

-(void)scrollToSelectedIndexAnimated:(BOOL)animated
{
    //计算中心点位置，和要到达的位置
    //简单使用，所有的视图均一样大
    CGFloat viewWidth = self.bounds.size.width;
    NSInteger index = self.selectedIndex;
    
    CGFloat startX = 0;
    
    CGFloat width = tabbarEveWidth;
    startX = width * index + width/2.0;
    startX -= (viewWidth/2.0);
    
    [bottomScroll setContentOffset:CGPointMake(startX, 0) animated:animated];
}

#pragma mark - PublicMethods
-(UIView *)zaTabbarItemViewForIndex:(NSInteger)index
{
    [arrLock lock];
    //未考虑线程安全
    UIView * aView = [self.showViews objectAtIndex:index];
    [arrLock unlock];
    
    return aView;
}
-(void)tabbarSelectIndex:(NSInteger)index withScrollAnimated:(BOOL)animated
{
    [self replaceTabbarShowViewsForSelectedIndex:index];
    
    self.selectedIndex = index;
    
    [self scrollToSelectedIndexAnimated:animated];
}

//视图重新替换
-(void)refreshTabbar
{
    if(self.selectedIndex == NSNotFound)
    {
        self.selectedIndex = self.startedIndex;
    }
    
    [self.scrollBgView removeFromSuperview];
    self.scrollBgView = nil;
    
//    [bottomScroll addSubview:self.coverView];
    [bottomScroll addSubview:self.scrollBgView];
    [bottomScroll sendSubviewToBack:self.scrollBgView];
    
    CGFloat viewWidth = self.bounds.size.width;
    //创建相应的视图，添加到数组
    NSMutableArray * views = [NSMutableArray array];
    UIView * bg = self.scrollBgView;
    NSInteger totalNum = 0;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfTabbarViewForZABottomScrollTabbar:)])
    {
        totalNum = [self.dataSource numberOfTabbarViewForZABottomScrollTabbar:self];
    }
    
    
    CGFloat totalLength = 0;
    
    //创建视图
    for (NSInteger index = 0;index < totalNum; index++)
    {
        UIView * showView = nil;
        if (index == self.selectedIndex)
        {
            if(self.dataSource && [self.dataSource respondsToSelector:@selector(zaBottomScrollTabbar:selectedViewForTabbarIndex:)])
            {
                showView = [self.dataSource zaBottomScrollTabbar:self selectedViewForTabbarIndex:index];
            }
        }else
        {
            if(self.dataSource && [self.dataSource respondsToSelector:@selector(zaBottomScrollTabbar:customViewForTabbarIndex:)])
            {
                showView = [self.dataSource zaBottomScrollTabbar:self customViewForTabbarIndex:index];
            }
        }
        
        if(!showView) NSAssert(YES, @"视图不可以为空");
        
        showView.tag = ZABottomTabbarAdd + index;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnShowView:)];
        [showView addGestureRecognizer:tap];
        [views addObject:showView];
        
        CGRect rect = showView.bounds;
        rect.origin.x = totalLength;
        showView.frame = rect;
        
        totalLength += showView.bounds.size.width;
        [bg addSubview:showView];
        
    }
    self.showViews = views;
    
    //控制位置
    //scrollview前后均添加空间，以便选中者居中展示
    //改变scrollBgView的大小
    CGFloat halfLength = viewWidth/2.0;
    CGFloat preLength = 0;
    CGFloat endLength = 0;
    
    UIView * first = nil;
    UIView * end = nil;
    if([views count]>0)
    {
        first = (UIView *)[views firstObject];
        end = (UIView *)[views lastObject];
    }
    tabbarEveWidth = first.bounds.size.width;
    
    preLength = halfLength - first.bounds.size.width/2.0;
    endLength = halfLength - end.bounds.size.width/2.0;
    
    CGRect rect = bg.frame;
    rect.size.width = totalLength;
    bg.frame = rect;
    
    scrollInUse = YES;
    
    bottomScroll.contentInset = UIEdgeInsetsMake(0, preLength, 0, endLength);
    bottomScroll.contentSize = CGSizeMake(totalLength , self.bounds.size.height);

    scrollInUse = NO;
    
    //滑动到选中位置
    [self scrollToSelectedIndexAnimated:YES];
    
}
#pragma mark -

#pragma mark - ScrollViewDelegate
-(NSInteger)tabbarIndexForContentOffsetX:(CGFloat)offX
{
    //根据currentStartX 计算index
    CGFloat width = tabbarEveWidth;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat startX = offX + (viewWidth/2.0) ;//    - width/2.0;
    NSInteger index = startX/width;
    if(index < 0 ) return 0;
    if(index > [self.showViews count] -1) return [self.showViews count] -1;
    
    return index;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentStartX = scrollView.contentOffset.x;
    self.coverView.center = CGPointMake(currentStartX + scrollView.bounds.size.width/2.0, scrollView.bounds.size.height/2.0);
    //改变coverview位置

    if (scrollInUse) return;
    
//    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGPoint(scrollView.contentOffset));
    NSInteger index = [self tabbarIndexForContentOffsetX:currentStartX];

    
    if(self.selectedIndex != index)
    {
        [self replaceTabbarShowViewsForSelectedIndex:index];
        //调用比例系数代理
        if(self.delegate&&[self.delegate respondsToSelector:@selector(zaBottomScrollTabbar:didSelectedIndex:)])
        {
            [self.delegate zaBottomScrollTabbar:self didSelectedIndex:index];
        }
        self.selectedIndex = index;
    }
    
    
    //当有手指触碰时，替换视图，并且选中新的
    if(scrollView.isDragging )
    {
        NSInteger nextIndex = index;
        CGFloat width = tabbarEveWidth;
        CGFloat startX = currentStartX + (self.bounds.size.width/2.0) ;
        
        CGFloat persent = 0;
        if(tipStartX<startX)
        {
            nextIndex = [self tabbarIndexForContentOffsetX:currentStartX + width];
            persent = (startX - index * width)/(width + 0.0);
            
        }else
        {
            nextIndex = [self tabbarIndexForContentOffsetX:currentStartX - width];
            persent = (index * width - startX + width)/(width + 0.0);
        }
        
        
        tipStartX = startX;
        
        //当有下一目标时调用
        if(index != nextIndex)
        {
            //调用比例系数代理
            if(self.delegate&&[self.delegate respondsToSelector:@selector(zaBottomScrollTabbar:scrollviewWillChangeFrom:ToIndex:andScrollPersent:)])
            {
                [self.delegate zaBottomScrollTabbar:self scrollviewWillChangeFrom:self.selectedIndex ToIndex:nextIndex andScrollPersent:persent];
            }
        }
    }
    
}
//动画结束，不调用代理
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    scrollInUse = NO;
//    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGPoint(scrollView.contentOffset));

}
//停止滑动
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //继续滑动、且选中
    //进行调整，修正最终位置
    [self scrollToSelectedIndexAnimated:YES];
}

//停止拖拽
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //处理无递进情况
    if(!decelerate)
    {
        [self scrollToSelectedIndexAnimated:YES];
    }
}

#pragma mark -
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
