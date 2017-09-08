//
//  ZWPanicUpdateLatestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/9/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWPanicListBaseRequestModel.h"
#import "ZWPanicUpdateListBaseRequestModel.h"
//进行列表数据刷新
//刷新到未上架的数据，发送消息通知，中心处理详情扫描
//刷新结束后，接收消息通知，进行数据回写操作
@class ZWPanicUpdateListBaseRequestModel;
@class ZWOperationEquipReqListReqModel;

//数据处理切片
@interface ZWPanicUpdateLatestModel : NSObject
{
    ZALocalModelDBManager  * dbManager;
    NSMutableDictionary * cacheDic;//以时间为key  model为value
    
    EquipDetailArrayRequestModel * _detailListReqModel;
    ZWOperationEquipReqListReqModel * _dpModel;
}


@property (nonatomic, assign) id<PanicListRequestTagUpdateListDelegate> requestDelegate;
@property (nonatomic, strong) NSString * tagString;
@property (nonatomic, strong) NSArray * cacheArr;

@property (nonatomic, assign, readonly) NSInteger priceStatus;
@property (nonatomic, assign, readonly) NSInteger schoolNum;

@property (nonatomic, assign, readonly) NSInteger requestNum;
@property (nonatomic, assign, readonly) NSInteger errorTotal;


-(void)prepareWebRequestParagramForListRequest;
//-(void)autoRefreshListRequestNumberWithLatestBackNumber:(NSInteger)totalNum;

-(NSArray *)dbLocalSaveTotalList;
-(void)localSaveDBUpdateEquipListWithArray:(NSArray *)arr;

-(void)startRefreshDataModelRequest;
//-(void)startRefreshLatestDetailModelRequest;

-(void)stopRefreshRequestAndClearRequestModel;

@end
