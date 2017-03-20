//
//  ZAPWDNumLineView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/23.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
//使用ZAEveLineView
@interface ZAPWDNumLineView : UIView

@property (nonatomic,copy) NSString * tempTxt;  //临时数据
@property (nonatomic,assign) NSInteger currentIndex;  //当前序号 //大小为 0到totalNum 都包括，0为全部没选中
@property (nonatomic,assign) NSInteger totalNum;      //总数目

-(void)refreshCurrentIndex:(NSInteger)index WithTempTxt:(NSString *)txt;


@end
