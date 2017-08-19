//
//  ZWServerEquipModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
#import "EquipModel.h"
@interface ZWServerEquipModel : BaseDataModel

@property (nonatomic, assign) NSInteger equipId;
@property (nonatomic, assign) NSInteger serverId;

@property (nonatomic, strong) EquipModel * detail;
@property (nonatomic, assign) NSString * equipDesc;

@property (nonatomic, strong) NSString * orderSN;

@property (nonatomic, assign) BOOL detailCheck;  //最新请求的id
@property (nonatomic, assign) NSInteger partSepNum;     //分段间隔数量
@property (nonatomic, assign) NSInteger checkMaxNum;    //当前检查id
@property (nonatomic, assign) BOOL cookieClear;

- (NSString * )mobileAppDetailShowUrl;
- (NSString * )detailDataUrl;
@end
