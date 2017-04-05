//
//  ZWSystemBaseListVC.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/12.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSystemBaseListVC.h"
#import "RefreshListCell.h"
#import "ZWSysSellModel.h"

@interface ZWSystemBaseListVC ()<UITableViewDelegate,UITableViewDataSource>

@end
@implementation ZWSystemBaseListVC



- (void)viewDidLoad {
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

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.row;
    ZWSysSellModel * contact = [self.dataArr objectAtIndex:secNum];
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier_Sell";
    RefreshListCell *cell = (RefreshListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        //            cell = [[ZAContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andTableView:tableView];
        //            cell.delegate = self;
        
        
        RefreshListCell * swipeCell = [[[NSBundle mainBundle] loadNibNamed:@"RefreshListCell"
                                                                     owner:nil
                                                                   options:nil] lastObject];
        
        //        [[RefreshListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [swipeCell setValue:cellIdentifier forKey:@"reuseIdentifier"];
        
        cell = swipeCell;
    }
    
    cell.rateLbl.textColor = [UIColor lightGrayColor];
    cell.rateLbl.text = contact.duration_str;
    cell.totalNumLbl.text = contact.name;
    
    
    
    cell.latestMoneyLbl.text = [NSString stringWithFormat:@"%@人",contact.month_order_count];
    
    
    cell.sellTimeLbl.text = contact.start_date;
    
    
    //更新时间
    NSDateFormatter * upFormat = [NSDate format:@"yyyyMMddHHmmss"];
    NSDate * updateDate = [upFormat dateFromString:contact.updated_at];
    cell.timeLbl.text = [updateDate toString:@"MM-dd HH:mm"];
//    cell.timeLbl.text = contact.sell_date;
    
    cell.sellDateLbl.hidden = YES;
    cell.sellRateLbl.text =  [NSString stringWithFormat:@"%.1fW %ldW 余%.1fW",[contact.sold_amount floatValue]/10000/100,[contact.total_amount integerValue]/10000/100,([contact.total_amount integerValue]-[contact.sold_amount floatValue])/10000/100];
    
    UIColor * color = [UIColor grayColor];
    if(!contact.is_sell_out)
    {
        color = [UIColor redColor];
    }
    cell.sellRateLbl.textColor = color;
    
    return cell;
}


@end
