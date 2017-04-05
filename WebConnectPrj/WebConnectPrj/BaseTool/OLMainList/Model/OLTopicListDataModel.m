//
//  OLTopicListDataModel.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-4.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLTopicListDataModel.h"

@implementation OLTopicListDataModel
-(id)initWithWebDic:(NSDictionary *)dic
{
    self = [super initWithWebDic:dic];
    if(self)
    {
        self.nickName = [dic valueForKey:@"ue"];
        NSArray * ayArr = [dic valueForKey:@"ay"];
        if ([ayArr count]>0) {
            NSDictionary * ayDic = [ayArr lastObject];
            self.imgUrlStr = [ayDic valueForKey:@"il"];
        }
    }
    return self;
}
@end
