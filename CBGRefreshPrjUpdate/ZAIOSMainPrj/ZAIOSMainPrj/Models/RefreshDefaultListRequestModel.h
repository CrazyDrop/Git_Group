//
//  RefreshDefaultListRequestModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/4.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//列表数据请求基类
@interface RefreshDefaultListRequestModel : BaseRequestModel

@property (nonatomic, assign) BOOL executing;
@property (nonatomic, strong, readonly) NSURLSession * listSession;

//服务器数据，一一对应，若请求失败，则填充null
@prop_strong( NSArray *,		listArray	OUT )


-(void)refreshWebRequestWithArray:(NSArray *)array;


//提供请求url数组
-(NSArray *)webRequestDataList;


//提供解析方法，需要能满足多线程操作
-(NSArray *)backObjectArrayFromBackDataDic:(NSDictionary *)aDic;


//取消请求，结束回调
-(void)cancel;




@end
