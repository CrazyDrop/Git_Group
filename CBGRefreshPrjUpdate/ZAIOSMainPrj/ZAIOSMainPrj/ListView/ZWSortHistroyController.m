//
//  ZWSortHistroyController.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/26.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSortHistroyController.h"
#import "ZALocationLocalModel.h"
#import "ZWDataDetailModel.h"
#import "ZWSortArrModel.h"
@implementation ZWSortHistroyController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startLocalZWListData];
}

-(void)startLocalZWListData
{
    NSArray * array = nil;
    array = [[ZALocationLocalModelManager sharedInstance] localLocationsArrayForAppendingDB];
    NSArray * total = [ZWSortArrModel totalSortModelArrayFromTotalDetailArray:array];
    NSArray * sortArr = [total sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZWSortArrModel * arr1 = (ZWSortArrModel *)obj1;
        ZWSortArrModel * arr2 = (ZWSortArrModel *)obj2;
        return [arr2.sortDateStr compare:arr1.sortDateStr];
    }];
    
    
//    NSArray * sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj1;
//        ZWDataDetailModel * model2 = (ZWDataDetailModel *)obj2;
//        
//        return [model2.created_at compare:model1.created_at];
//        
//    }];
//    
//    //置空售价和利润数据
//    [sortArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj;
//        model1.sellRate = nil;
//        model1.earnRate = nil;
//    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sortArr = sortArr;
        [self.listTable reloadData];
    });;
}


@end
