//
//  VPNProxyModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"

@interface VPNProxyModel : BaseDataModel

@property (nonatomic, strong) NSString * idNum;
@property (nonatomic, strong) NSString * portNum;
@property (nonatomic, assign) BOOL https;

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL errored;
@property (nonatomic, assign) NSInteger errorNum;//失败次数

-(id)initWithDetailDic:(NSDictionary *)dic;


-(NSDictionary *)detailProxyDic;
+(NSArray *)localSaveProxyArray;
+(NSArray *)proxyDicArrayFromDetailProxyArray:(NSArray *)array;



@end
