//
//  OLEGOFooterNormalControl.h
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLEGORefreshView.h"
//一些变量在此类中可能无用，但是作为统一的父类，使用于子类中
//完成普通的上拉刷新逻辑控制
@interface OLEGOFooterNormalControl : NSObject<OLEGOViewContorlDelegate>
{
    BOOL _backDelay;
    CGFloat _defultedExtendY;
    CGFloat _showExtendY;
    CGFloat _endExtendY;
    CGFloat _effectiveHeight;
}
//延迟进行响应，此参数用于有数据缓存的模块，而又不希望数据视图变化过快时使用
//默认为NO
@property (nonatomic,assign) BOOL backDelay;


//事件响应距离
//默认为REFRESH_REGION_HEIGHT
@property (nonatomic,assign) CGFloat effectiveHeight;


//默认展示距离，正常拉动时的延伸距离
//默认为0
@property (nonatomic,assign) CGFloat defultedExtendY;


//展示加载中时的扩展距离
//默认为Normal展示距离
@property (nonatomic,assign) CGFloat showExtendY;


//展示结束时的扩展距离
//默认为0
@property (nonatomic,assign) CGFloat endExtendY;



@end
