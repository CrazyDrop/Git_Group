//
//  ServerDetailRefreshModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
//服务器单体刷新控制中心，规则、服务器列表、详情列表、递增订单号
@class ServerDetailRefreshModel;
@protocol ServerDetailRefreshDelegate <NSObject>

-(void)serverDetailListRequestFinishWithUpdateModel:(ServerDetailRefreshModel *)model listArray:(NSArray *)array;
-(void)serverDetailRequestErroredWithUpdateModel:(ServerDetailRefreshModel *)model;

@end

@interface ServerDetailRefreshModel : NSObject

@property (nonatomic, assign) BOOL endRefresh;
@property (nonatomic, assign) BOOL proxyEnable;
@property (nonatomic, strong) NSString * serverTag;
@property (nonatomic, assign) id<ServerDetailRefreshDelegate> requestDelegate;

-(void)prepareWebRequestParagramForListRequest;
//-(void)autoRefreshListRequestNumberWithLatestBackNumber:(NSInteger)totalNum;

-(NSArray *)dbLocalSaveTotalList;
-(void)localSaveDBUpdateEquipListWithArray:(NSArray *)arr;

-(void)startRefreshDataModelRequest;

-(void)stopRefreshRequestAndClearRequestModel;




@end
