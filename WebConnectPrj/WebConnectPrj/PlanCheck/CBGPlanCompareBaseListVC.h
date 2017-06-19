//
//  CBGPlanCompareBaseListVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "CBGSortHistoryBaseStyleVC.h"


@interface CBGPlanCompareBaseListVC : CBGSortHistoryBaseStyleVC
@property (nonatomic, assign) NSInteger startLinePrice;
@property (nonatomic, strong) NSString * headerNames;


-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice;

-(NSArray *)moreFunctionsForDetailSubVC;



@end
