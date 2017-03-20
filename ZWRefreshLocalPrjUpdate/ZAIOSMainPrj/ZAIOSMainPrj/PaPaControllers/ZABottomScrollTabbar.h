//
//  ZABottomScrollTabbar.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
//底部滑动tabbar，可以认为是tabbar，或者是单一滚动视图
//实现滑动选中、点击选中，跟随滑动

//内含数据，通过代理实现
//暂不考虑视图重用
@class ZABottomScrollTabbar;
@protocol ZABottomScrollTabbarDataSource <NSObject>

-(NSInteger)numberOfTabbarViewForZABottomScrollTabbar:(ZABottomScrollTabbar *)tabbar;

-(UIView *)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar customViewForTabbarIndex:(NSInteger)index;
-(UIView *)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar selectedViewForTabbarIndex:(NSInteger)index;

@end

@protocol ZABottomScrollTabbaDelegate <NSObject>

-(void)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar didSelectedIndex:(NSInteger)index;
-(void)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar scrollviewWillChangeFrom:(NSInteger)startIndex ToIndex:(NSInteger)endIndex andScrollPersent:(CGFloat)persent;

@end


@interface ZABottomScrollTabbar : UIView

@property (nonatomic,assign) id<ZABottomScrollTabbaDelegate> delegate;
@property (nonatomic,assign) id<ZABottomScrollTabbarDataSource> dataSource;

@property (nonatomic,assign) NSInteger startedIndex;
@property (nonatomic,assign,readonly) NSInteger selectedIndex;

-(UIView *)zaTabbarItemViewForIndex:(NSInteger)index;
-(void)tabbarSelectIndex:(NSInteger)index withScrollAnimated:(BOOL)animated;

-(void)refreshTabbar;


@end
