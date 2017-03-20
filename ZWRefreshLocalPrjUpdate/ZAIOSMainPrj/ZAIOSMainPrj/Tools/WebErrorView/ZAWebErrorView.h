//
//  ZAWebErrorView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAWebErrorView : UIView


@property (nonatomic,strong) NSString * errTxt;
@property (nonatomic,copy) void (^ZAWebRequestRetryBlock) (void);


-(void)refreshErrorViewWithLoading:(BOOL)loading;




@end
