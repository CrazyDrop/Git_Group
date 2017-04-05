//
//  ZWDetailListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/10.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDetailListController.h"
#import "ZWDataDetailModel.h"
#import "ZALocationLocalModel.h"
#import "ZWDaysListController.h"
#import "DZUtils.h"
@interface ZWDetailListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * dataArr;
@end

@implementation ZWDetailListController

- (void)viewDidLoad {
    self.viewTtle = @"详情";
    self.rightTitle = @"删除";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    self.listTable = table;
    [self.view addSubview:table];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startDetailSellListData];
}
-(void)submit
{

    ZALocationLocalModelManager *manager = [ZALocationLocalModelManager sharedInstance];
    [manager clearUploadedLocations:@[self.dataModel]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.section;
    secNum = [self.dataArr count] - 1 - secNum;
    NSString * contact = [self.dataArr objectAtIndex:secNum];
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];

    }
    
    cell.textLabel.text = contact;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //进入天数变化的收益列表
//    zwResultArrayForContainDifferentDaysAndEarnRateWithModel
    ZWDataDetailModel * nextModel = [(ZWDataDetailModel *)self.dataModel copy];
    
    NSInteger secNum = indexPath.section;
    secNum = [self.dataArr count] - 1 - secNum;
    NSString * string = [self.dataArr objectAtIndex:secNum];
    NSArray * array = [string componentsSeparatedByString:@"销售"];
    NSString * str = [array lastObject];
    array = [str componentsSeparatedByString:@"%"];
    str = [array firstObject];
    NSInteger sellNum = (int)([str floatValue] * 100);
    
    nextModel.sellRate = [NSString stringWithFormat:@"%ld",(long)sellNum];
    ZWDaysListController * detail = [[ZWDaysListController alloc] init];
    detail.dataModel = nextModel;
    
    UINavigationController * na = [self rootNavigationController];
    [na pushViewController:detail animated:YES];
}


//加载数据
-(void)startDetailSellListData
{
    NSArray * array = [(ZWDataDetailModel *)self.dataModel zwResultArrayForDifferentSellRate];
    self.dataArr = array;
    [self.listTable reloadData];
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
