//
//  ZWSortListController.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/26.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSortListController.h"
#import "ZALocationLocalModel.h"
#import "ZWDataDetailModel.h"
#import "RefreshListCell.h"
#import "NSDate+Extension.h"
#import "ZWDetailListController.h"
#import "ZWSortArrModel.h"

@interface ZWSortListController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView * listTable;

@end

@implementation ZWSortListController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.viewTtle = @"统计数据";
        self.rightTitle = nil;
        self.showRightBtn = NO;
    }
    return self;
}


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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ZWSortArrModel * sort = [self.sortArr objectAtIndex:section];
    return [sort.daysArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ZWSortArrModel * sort = [self.sortArr objectAtIndex:section];
    return [sort description];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.section;
    NSInteger rowNum = indexPath.row;
    ZWSortArrModel * sort = [self.sortArr objectAtIndex:secNum];
    ZWDataDetailModel * contact = [sort.daysArr objectAtIndex:rowNum];
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier";
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
    cell.rateLbl.text = contact.annual_rate_str;
    cell.totalNumLbl.text = [NSString stringWithFormat:@"%@  %@",contact.duration_str,contact.total_money];
    
    UIColor * color = [UIColor grayColor];
    if([contact.total_money intValue]>5000){
        color = [UIColor redColor];
    }
    
    NSString * rate = contact.earnRate;
    cell.latestMoneyLbl.text = rate;
    cell.latestMoneyLbl.textColor = color;
    
    NSInteger contain = 30;
    if(contact.containDays){
        contain = [contact.containDays intValue];
    }
    NSString * sellTxt = [NSString stringWithFormat:@"%.2f%%/%ld天",[contact.sellRate intValue]/100.0,[contact.duration_str intValue] - contain];
    cell.sellRateLbl.text = sellTxt;
    NSDate * date = [NSDate fromString:contact.finishedDate];
    cell.sellTimeLbl.text = [date toString:@"MM-dd HH:mm"];
    
    NSDate * startDate = [NSDate fromString:contact.start_sell_date];
    cell.timeLbl.text = [startDate toString:@"MM-dd HH:mm"];
    cell.sellDateLbl.hidden = YES;
    
    //    color = [UIColor lightGrayColor];
    //    NSString * txt = nil;
    //    DetailModelSaveType type = [contact currentModelState];
    //    if(type == DetailModelSaveType_Buy){
    //        color = [UIColor redColor];
    //        txt = @"购买";
    //    }else if(type == DetailModelSaveType_Notice){
    //        color = [UIColor greenColor];
    //        txt = @"关注";
    //    }
    //    cell.sellTimeLbl.textColor = color;
    //    cell.sellTimeLbl.text = txt;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.section;
    NSInteger rowNum = indexPath.row;
    ZWSortArrModel * sort = [self.sortArr objectAtIndex:secNum];
    ZWDataDetailModel * contact = [sort.daysArr objectAtIndex:rowNum];
    
    ZWDetailListController * detail = [[ZWDetailListController alloc] init];
    detail.dataModel = contact;
    [[self rootNavigationController] pushViewController:detail animated:YES];
    
}




@end
