//
//  Adapter.h
//  photographer
//
//  Created by jialifei on 15/4/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#ifndef photographer_Adapter_h
#define photographer_Adapter_h

#import "AppDelegate.h"
CG_INLINE CGRect
CGRectMakeAdapter(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    CGRect rect;
    rect.origin.x = x * myDelegate.autoSizeScaleX;
    rect.origin.y = y * myDelegate.autoSizeScaleY;
    rect.size.width = width * myDelegate.autoSizeScaleX;
    rect.size.height = height * myDelegate.autoSizeScaleY;
    return rect;
}
CG_INLINE float
FLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    newS = size *myDelegate.autoSizeScaleX;
    return newS;
    
}

CG_INLINE float
YFLoatChange(CGFloat size)
{
    CGFloat newS;
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    newS = size *myDelegate.autoSizeScaleY;
    return newS;
    
}

#endif
