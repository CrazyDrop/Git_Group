//
//  ZWPanicCompareModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/16.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBGListModel.h"

@interface ZWPanicCompareModel : BaseDataModel

@property (nonatomic, strong) CBGListModel * buyModel;
@property (nonatomic, strong) CBGListModel * soldModel;


@property (nonatomic, assign) NSInteger serverId;
@property (nonatomic, assign) NSInteger schoolId;

@property (nonatomic, assign) NSInteger startPrice;
@property (nonatomic, assign) NSInteger earnPrice;

@property (nonatomic, strong) NSString * startTime;
@property (nonatomic, strong) NSString * soldTime;

@end
