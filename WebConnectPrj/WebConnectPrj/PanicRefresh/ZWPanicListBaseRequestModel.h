//
//  ZWPanicListBaseRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/12.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZALocalModelDBManager.h"

//自定义model，处理代理，回调
//完成列表数据请求，库表查询，详情请求，拆分
//包含、启动请求、停止请求
//请求结果代理回调
//
@class ZWPanicListBaseRequestModel;
@protocol PanicListRequestTagListDelegate <NSObject>

-(void)panicListRequestFinishWithModel:(ZWPanicListBaseRequestModel *)model listArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr;
-(void)panicListRequestFinishWithModel:(ZWPanicListBaseRequestModel *)model withListError:(NSError *)list;

@end


@interface ZWPanicListBaseRequestModel : NSObject
{
    ZALocalModelDBManager  * dbManager;
    NSMutableDictionary * cacheDic;//以时间为key  model为value

}
@property (nonatomic, assign) id<PanicListRequestTagListDelegate> requestDelegate;
@property (nonatomic, strong) NSString * tagString;
@property (nonatomic, strong) NSArray * cacheArr;

@property (nonatomic, assign, readonly) NSInteger priceStatus;
@property (nonatomic, assign, readonly) NSInteger schoolNum;

@property (nonatomic, assign, readonly) NSInteger requestNum;
@property (nonatomic, assign, readonly) NSInteger errorTotal;


-(void)prepareWebRequestParagramForListRequest;

-(NSArray *)dbLocalSaveTotalList;
-(void)localSaveDBUpdateEquipListWithArray:(NSArray *)arr;

-(void)startRefreshDataModelRequest;
-(void)startRefreshLatestDetailModelRequest;

-(void)stopRefreshRequestAndClearRequestModel;



@end
