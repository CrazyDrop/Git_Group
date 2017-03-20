//
//  PoundTopicModel.h
//  ShaiHuo
//
//  Created by 王晓宇 on 14-1-22.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

/*!
 *	@class	话题标签
 */
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TopicModelType_users = 0,//非官方
    TopicModelType_official,//官方话题

} TopicModelType;

@interface PoundTopicModel : NSObject//暂时不启用
@property (assign,nonatomic) int uid;//话题或标签的ID
@property (retain,nonatomic) NSString *content;//话题或标签文字
@property (retain,nonatomic) NSString *specialUrl;//特殊的跳转链接

//V2.0
@property (nonatomic, copy) NSString *imgUrlStr;//话题图
@property (nonatomic, copy) NSString *detail; //官方话题描述
@property (nonatomic, assign) TopicModelType topicType;//是否为官方
@end
