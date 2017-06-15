//
//  CBGSortHistoryBaseStyleVC.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/4.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseSortVC.h"
//基础VC，包含排序、分组按钮
typedef NSString * (^ZWWriteDBFunctionBlock)(id model1,id model2);

@interface CBGSortHistoryBaseStyleVC : CBGSortHistoryBaseSortVC


-(void)outLatestShowDetailDBCSVFile;

//数据写入
-(void)writeLocalCSVWithFileName:(NSString *)fileName
                     headerNames:(NSString *)headerName
                      modelArray:(NSArray *)models
                  andStringBlock:(ZWWriteDBFunctionBlock)block;

-(void)createFilePath:(NSString *)path;


@end
