//
//  ZAPanicPayHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZAPanicPayHistoryVC.h"
#import "ZAAutoBuyHomeVC.h"

@interface ZAPanicPayHistoryVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic, strong) NSArray * hisArr;
@end

@implementation ZAPanicPayHistoryVC

- (void)viewDidLoad
{
    self.showRightBtn = NO;
    self.viewTtle = @"历史推荐";
    [super viewDidLoad];

    CGRect rect = [[UIScreen mainScreen] bounds];

    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;

    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    self.listTable = table;
    [self.view addSubview:table];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    self.hisArr = total.panicHistory;
    [self.listTable reloadData];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.hisArr count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ZAPanicSortSchoolVC_Panic_Style";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary * eveDic = [self.hisArr objectAtIndex:indexPath.section];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString * rate = [eveDic objectForKey:@"rate"];
    NSString * price = [eveDic objectForKey:@"price"];
    NSString * webUrl = [eveDic objectForKey:@"weburl"];
  
    NSMutableString * showStr = [NSMutableString string];
    if(rate)
    {
        [showStr appendFormat:@"%@%%  ",rate];
    }
    if(price)
    {
        [showStr appendFormat:@"价格%@  ",price];
    }
    if(webUrl)
    {
        [showStr appendFormat:@"url:%@  ",webUrl];
    }

    cell.textLabel.text = showStr;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * eveDic = [self.hisArr objectAtIndex:indexPath.section];
    
    NSString * rate = [eveDic objectForKey:@"rate"];
    NSString * price = [eveDic objectForKey:@"price"];
    NSString * webUrl = [eveDic objectForKey:@"weburl"];
    
    ZAAutoBuyHomeVC * home = [[ZAAutoBuyHomeVC alloc] init];
    home.webUrl = webUrl;
    //历史记录查看，不再进行自动购买，屏蔽利差
//    home.rate = [rate integerValue];
//    home.price = [price integerValue];
    [[self rootNavigationController] pushViewController:home animated:YES];
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
