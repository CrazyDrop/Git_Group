//
//  ZWAutoRefreshListModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWAutoRefreshListModel.h"
@interface ZWAutoRefreshListModel()
@property (nonatomic, assign) NSInteger pageIndex;
//页码序列号，鉴于当前的服务器数据刷新频率低，
//进行循环，每次请求后更换url  0、1、2、3  数据相当于12s刷新一次
@property (nonatomic, assign) NSInteger maxPageNum; //并发请求数量控制
@property (nonatomic, assign) NSInteger latestIndex;
@end
@implementation ZWAutoRefreshListModel

-(id)init
{
    self = [super init];
    if(self){
        self.maxPageNum = 3;
    }
    return self;
}
-(void)sendRequest
{
    //每次开启前，
    
    if(!self.executing)
    {
        //        NSInteger lineNum = 55;
        if(self.autoRefresh){
            //自动递增  1、2、3页独立请求
            self.pageNum = 1;
            self.pageIndex ++;
            [self refreshPageIndexForLatestWebReqeust];
        }else{
            self.pageNum = 3;
        }
    }
    [super sendRequest];
}
-(void)refreshPageIndexForLatestWebReqeust
{
    NSArray * urls = self.requestArr;
    NSMutableArray * replaceArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [urls count]; index ++)
    {
        NSString * preStr = [urls objectAtIndex:index];
        NSString * subStr = @"page=";
        NSRange range = [preStr rangeOfString:subStr];
        //        NSString * preIndex = [preStr substringWithRange:NSMakeRange(range.length + range.location, 1)];
        NSInteger pageNum =  (self.pageIndex + 2) % self.maxPageNum + 1;//数值  123  pageindex为1pageNum为1
        self.latestIndex = pageNum;
        NSString * refreshStr = [subStr stringByAppendingFormat:@"%ld",pageNum];
        
        range.length += 1;
        NSString * result = [preStr stringByReplacingCharactersInRange:range withString:refreshStr];
        [replaceArr addObject:result];
    }
    
    [self refreshWebRequestWithArray:replaceArr];
}


@end
