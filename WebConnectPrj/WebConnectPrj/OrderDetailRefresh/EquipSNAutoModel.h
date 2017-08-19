//
//  EquipSNAutoModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
//属性自动变更url
@interface EquipSNAutoModel : BaseDataModel

-(id)initWithEquipSN:(NSString *)orderSn andEquipId:(NSInteger)equipId;


@property (nonatomic, strong) NSString * serverId;
@property (nonatomic, strong) NSString * orderSN;

@property (nonatomic, assign, readonly) NSInteger startNum;
@property (nonatomic, assign, readonly) NSInteger latestIdNum;
@property (nonatomic, assign) NSInteger timeNum;

@property (nonatomic, assign, readonly) NSInteger nextEquipId;

- (NSString * )latestOrderSN;
- (NSString * )detailDataUrl;

- (NSString * )nextOrderSN;
- (NSString * )nextTryDetailDataUrl;

- (NSString * )next2OrderSN;
- (NSString * )next2TryDetailDataUrl;


@end
