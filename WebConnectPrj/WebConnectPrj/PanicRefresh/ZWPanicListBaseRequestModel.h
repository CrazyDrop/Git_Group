//
//  ZWPanicListBaseRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/12.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
//自定义model，处理代理，回调
//完成列表数据请求，库表查询，详情请求，拆分
//包含、启动请求、停止请求
//请求结果代理回调
//
@protocol PanicListRequestTagListDelegate <NSObject>

-(void)panicListRequestFinishWithTag:(NSString *)tagid listArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr;

@end


@interface ZWPanicListBaseRequestModel : NSObject

@property (nonatomic, assign) id<PanicListRequestTagListDelegate> requestDelegate;
@property (nonatomic, strong) NSString * tagString;
@property (nonatomic, strong) NSArray * cacheArr;

@property (nonatomic, assign, readonly) NSInteger priceStatus;
@property (nonatomic, assign, readonly) NSInteger schoolNum;

-(void)prepareWebRequestParagramForListRequest;

-(NSArray *)dbLocalSaveTotalList;
-(void)localSaveDBUpdateEquipListWithArray:(NSArray *)arr;

-(void)startRefreshDataModelRequest;
-(void)startRefreshLatestDetailModelRequest;

-(void)stopRefreshRequestAndClearRequestModel;



@end
