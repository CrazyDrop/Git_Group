//
//  ZWDaysListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDaysListController.h"
#import "ZWDataDetailModel.h"
#import "RefreshListCell.h"
#import "NSDate+Extension.h"
@interface ZWDaysListController ()
@property (nonatomic,assign) BOOL refreshRate;
@end

@implementation ZWDaysListController

- (void)viewDidLoad {
    self.viewTtle = @"持有时间变化";
    self.rightTitle = @"变化";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startDetailDaysSellListData];
}
-(void)submit
{
    self.refreshRate = !self.refreshRate;
    [self startDetailDaysSellListData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //不可继续点击
}


//加载数据
-(void)startDetailDaysSellListData
{
    NSArray * array = [ZWDataDetailModel zwResultArrayForContainDifferentDaysAndEarnRateWithModel:self.dataModel withRefresh:self.refreshRate];
    self.dataArr = array;
    [self.listTable reloadData];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
