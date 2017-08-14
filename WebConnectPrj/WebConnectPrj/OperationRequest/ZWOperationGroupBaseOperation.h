//
//  ZWOperationGroupBaseOperation.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/13.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionReqModel.h"
#import "ZWSessionReqOperation.h"
//单一operation，完成批量数据的请求，
//独立进行数据的发送、接收，数据结果拼接
//
@class ZWOperationGroupBaseOperation;
@protocol ZWOperationGroupBaseOperationDelegate <NSObject>

-(NSArray *)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
                         finishEveReq:(NSDictionary *)backDic
                         sessionModel:(SessionReqModel *)sessionModel;
//进行结果输出
-(void)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
                       finishReq:(NSArray *)backDicArr
                        errorDic:(NSArray *)errDicArr;

//多次请求，回调多次
@optional
-(void)groupBaseRequestOperation:(ZWOperationGroupBaseOperation *)session
     doneWebRequestBackHeaderDic:(NSDictionary *)dic
                     andStartUrl:(NSString *)url;

//结果数据解析

-(NSArray *)groupBaseRequestOperationCreateReqModels:(ZWOperationGroupBaseOperation *)session;



@end

@interface ZWOperationGroupBaseOperation : NSOperation

@property (nonatomic, assign) id<ZWOperationGroupBaseOperationDelegate> dataDelegate;

@property (nonatomic, strong) NSArray * reqModels;//也可以通过代理方法生成
@property (nonatomic, assign) NSInteger timeOutNum;
@property (nonatomic, assign) BOOL saveCookie;



@end
