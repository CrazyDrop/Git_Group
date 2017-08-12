//
//  ZWSessionGroupOperation.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZWSessionGroupOperation;
@protocol ZWSessionGroupDelegate <NSObject>

-(NSArray *)ZWSessionGroupOperationBackObjectArrayFromBackDataDic:(NSDictionary *)aDic;

-(void)sessionRequestOperation:(ZWSessionGroupOperation *)session
                  finishResult:(NSArray *)backArr;

@end

//每个组内并发，最大10个
@interface ZWSessionGroupOperation : NSOperation


@property (nonatomic, assign) NSInteger maxOperationNum;
@property (nonatomic, assign) NSInteger timeOutNum;
@property (nonatomic, strong) NSArray * reqModels;
@property (nonatomic, assign) id<ZWSessionGroupDelegate> dataDelegate;



@end
