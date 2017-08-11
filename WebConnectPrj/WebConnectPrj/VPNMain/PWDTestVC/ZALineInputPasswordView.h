//
//  ZALineInputPasswordView.h
//  ZAIOSMainPrj
//
//  Created by Apple on 2017/8/11.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//


@interface ZALineInputPasswordView : UIView

@property (nonatomic,copy) NSString * tempTxt;  //临时数据
@property (nonatomic,assign) NSInteger currentIndex;  //当前序号 //大小为 0到totalNum 都包括，0为全部没选中
@property (nonatomic,assign) NSInteger totalNum;      //总数目

//-(void)refreshShowStyleWithUserInputTxt:(NSString *)txt;
-(void)refreshShowStyleWithTxt:(NSString *)txt;

@end
