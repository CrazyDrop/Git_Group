//
//  ProductListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ProductListController.h"
#import "OLBasicListTableView.h"
#import "ProductListCell.h"
@interface ProductListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray * dataArr;
@end

@implementation ProductListController

- (void)viewDidLoad {
    self.viewTtle = ZAViewLocalizedStringForKey(@"ZAViewLocal_Product_List_Title");
    self.showLeftBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = startY;
    rect.size.height -= startY;
    
    OLBasicListTableView * table =[[OLBasicListTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    table.loadMoreType = OL_LIST_DATA_LOAD_TYPE_NONE;
    table.loadRefreshType = OL_LIST_DATA_LOAD_TYPE_NONE;
    table.separatorColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.rowHeight = 150;
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];

    self.dataArr = @[@"product_1.jpg",@"product_2.jpg",@"product_3.jpg"];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection %@",self.dataArr);
    return [self.dataArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[ProductListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    id model = [self.dataArr objectAtIndex:indexPath.row];
    [cell loadCellData:model];
    return cell;

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
