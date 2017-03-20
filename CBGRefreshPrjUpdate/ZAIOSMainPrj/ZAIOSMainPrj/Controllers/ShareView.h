//
//  ShareView.h
//  Photography
//
//  Created by jialifei on 15/4/1.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DPViewController;
@interface ShareView : UIView
{
    UIView *bottom;
}
@property (nonatomic,weak) DPViewController *dp;
@property (nonatomic,weak) NSString *type;

-(id)initWithFrame:(CGRect)frame type:(NSString *)type;

@end
