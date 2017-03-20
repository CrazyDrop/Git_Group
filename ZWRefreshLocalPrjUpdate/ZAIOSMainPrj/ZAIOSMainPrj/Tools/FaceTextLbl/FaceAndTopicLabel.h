//
//  FaceAndTopicLabel.h
//  ViewControllerTest
//
//  Created by Apple on 14-8-28.
//  Copyright (c) 2014年 ___李言___. All rights reserved.
//

#import <UIKit/UIKit.h>
//实现表情和话题的展示,使用方法,赋值话题数组，赋值text
@interface FaceAndTopicLabel : UILabel
//要求先设置topicArray 后设置text ，否则无效
@property (nonatomic,strong) NSArray * topicArray;
@property (nonatomic,copy) void(^tapTopicBlock)(id data);

@property (nonatomic,copy) UIImage *(^faceImageForFaceTextBlock)(NSString *text);


@property (nonatomic, assign) CGFloat lineSpace;

@end
