//
//  ZAContactSelectEditController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"

typedef enum {
    PaPaContact_Select_None = 1,
    PaPaContact_Select_Relation,
    PaPaContact_Select_PWDString
} PaPaContactSelectType;


@interface ZAContactSelectEditController : DPWhiteTopController

@property (nonatomic,assign) PaPaContactSelectType selectType;
@property (nonatomic,strong) NSString * editText;

@property (nonatomic,copy) void (^TapedOnFinishedBlock)(PaPaContactSelectType type,NSString * endText);


@end
