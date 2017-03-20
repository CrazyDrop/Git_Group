//
//  ZWSystemListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSystemListController.h"
#import "ZWDataDetailModel.h"
@interface ZWSystemListController ()

@end

@implementation ZWSystemListController

- (void)viewDidLoad {
    self.viewTtle = @"系统";
    self.rightTitle = @"清空";
    self.showRightBtn = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self startLocalZWListData];
}

//加载数据
-(void)startLocalZWListData
{
    NSArray * array = [ZWDataDetailModel systemArrayFromLocalSave];
    
    self.dataArr = array;
    [self.listTable reloadData];
}

-(void)submit
{
//    [[ZALocationLocalModelManager sharedInstance] clearTotalLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
