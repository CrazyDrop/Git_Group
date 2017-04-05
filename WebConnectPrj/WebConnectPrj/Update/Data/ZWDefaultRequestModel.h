//
//  ZWDefaultRequestModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/19.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>


//单一网络请求，通用请求模块
@interface ZWDefaultRequestModel : BaseRequestModel

@property (nonatomic, copy) NSString * webUrl;
@property (nonatomic,strong) AFHTTPRequestOperationManager * httpManager;


@property (nonatomic, copy)  BOOL (^doneZWDefaultRequestWithFinishBlock)(NSDictionary *);



@end
