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



@end
