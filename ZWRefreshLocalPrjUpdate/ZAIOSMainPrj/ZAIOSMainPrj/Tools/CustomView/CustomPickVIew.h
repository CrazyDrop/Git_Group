//
//  CustomPickVIew.h
//  Try
//
//  Created by jialifei on 15/4/8.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHPickView.h"
@interface CustomPickVIew : UIButton<ZHPickViewDelegate>

@property(nonatomic,strong) ZHPickView *pickview;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) NSString *requestString;
@property(nonatomic,strong) id delegate;
@property(nonatomic,strong) NSString *type;


-(id)initWithFrame:(CGRect)frame  type:(NSString *)t;

@end
