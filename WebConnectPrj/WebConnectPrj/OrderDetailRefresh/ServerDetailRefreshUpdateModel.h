//
//  ServerDetailRefreshUpdateModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/19.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerDetailRefreshUpdateModel;
@protocol ServerDetailUpdateRefreshDelegate <NSObject>

-(void)serverDetailListUpdateRequestFinishWithUpdateModel:(ServerDetailRefreshUpdateModel *)model listArray:(NSArray *)array;
-(void)serverDetailUpdateRequestErroredWithUpdateModel:(ServerDetailRefreshUpdateModel *)model;

@end

@interface ServerDetailRefreshUpdateModel : NSObject

@property (nonatomic, assign) BOOL endRefresh;
@property (nonatomic, assign) BOOL equipEnable;
@property (nonatomic, assign) BOOL proxyEnable;
@property (nonatomic, strong) NSString * serverTag;
@property (nonatomic, strong) NSString * serverName;
@property (nonatomic, assign) id<ServerDetailUpdateRefreshDelegate> requestDelegate;


-(void)prepareWebRequestParagramForListRequest;
//-(void)autoRefreshListRequestNumberWithLatestBackNumber:(NSInteger)totalNum;

-(NSArray *)dbLocalSaveTotalList;
-(void)localSaveDBUpdateEquipListWithArray:(NSArray *)arr;

-(void)startRefreshDataModelRequest;

-(void)stopRefreshRequestAndClearRequestModel;




@end
