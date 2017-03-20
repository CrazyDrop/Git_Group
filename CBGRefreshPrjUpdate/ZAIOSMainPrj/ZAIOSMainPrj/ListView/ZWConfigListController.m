//
//  ZWConfigListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWConfigListController.h"
#import "ZALocationLocalModel.h"
#import "ZWDataDetailModel.h"
#import "RefreshListCell.h"
#import "NSDate+Extension.h"
#import "ZWDetailListController.h"
#import "Equip_listModel.h"
#import "EquipModel.h"
#import "ZACBGDetailWebVC.h"
@interface ZWConfigListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView * listTable;

@end


@implementation ZWConfigListController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.viewTtle = @"数据";
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
    
//    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = [self.dataArr objectAtIndex:secNum];
    
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
    
    //用来标识是否最新一波数据
    cell.rateLbl.text = contact.price_desc;
    
    cell.totalNumLbl.textColor = [UIColor lightGrayColor];//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = contact.desc_sumup;
    
    //    NSString * rate = [contact.level stringValue];
    UIColor * color = [UIColor lightGrayColor];
    
    NSString * sellTxt = [NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    //    if([contact.annual_rate_str floatValue]>9)
    //    cell.sellDateLbl.text = sellTxt;
    NSString * equipName = [NSString stringWithFormat:@"%@  -  %@",contact.equip_name,contact.subtitle];
    
    if(!contact)
    {
        sellTxt = nil;
        equipName = nil;
        cell.totalNumLbl.text = nil;
    }
    
    cell.latestMoneyLbl.textColor = color;
    //    cell.timeLbl.text = sellTxt;
    
    //列表剩余时间
    NSString * dateStr = contact.sell_expire_time_desc;
    //    @"dd天HH小时mm分钟"
    NSDateFormatter * format = [NSDate format:@"dd天HH小时mm分钟"];
    NSDate * date = [format dateFromString:dateStr];
    cell.timeLbl.text =  [date toString:@"HH:mm(余)"];
    
    //详情剩余时间
    EquipModel * detail = contact.detaiModel;
    cell.sellTimeLbl.text = detail.status_desc;
    UIColor * earnColor = [UIColor lightGrayColor];
    //用来标识账号是否最新一次销售
    if(detail)
    {
        cell.rateLbl.text = detail.last_price_desc;
        
        date = [NSDate fromString:detail.selling_time];
        cell.timeLbl.text =  [date toString:@"HH:mm"];
        
        NSTimeInterval interval = [self timeIntervalWithCreateTime:detail.create_time andSellTime:detail.selling_time];
        if(interval < 60 * 60 * 24 )
        {
            earnColor = [UIColor orangeColor];
        }
        if(interval < 60 * 2){
            earnColor = [UIColor redColor];
        }
        
    }
    
    
    EquipExtraModel * extra = detail.equipExtra;
    if(extra)
    {
        //        修炼、宝宝、法宝、祥瑞
        cell.totalNumLbl.text = [extra extraDes];
        
        UIColor * buyColor = [UIColor lightGrayColor];
        if([extra.buyPrice floatValue]>[detail.last_price_desc floatValue])
        {
            buyColor = [UIColor redColor];
        }
        cell.sellTimeLbl.textColor = buyColor;
        
        if([contact preBuyEquipStatusWithCurrentExtraEquip])
        {
            sellTxt = [sellTxt stringByAppendingFormat:@"-%@(%.0f)",contact.earnPrice,[contact.earnPrice floatValue] * 100/[detail.last_price_desc floatValue]];
        }
    }
    
    UIFont * font = cell.totalNumLbl.font;
    cell.latestMoneyLbl.text = sellTxt;
    cell.timeLbl.textColor = earnColor;
    cell.sellRateLbl.font = font;
    cell.latestMoneyLbl.font = font;
    cell.sellDateLbl.hidden = YES;
    cell.sellRateLbl.text = equipName;
    
    
    return cell;
}
#pragma mark -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    contact = [self.dataArr objectAtIndex:secNum];

    if(contact)
    {
        ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
        detail.listData = contact;
        [[self rootNavigationController] pushViewController:detail animated:YES];
    }
    
    
}
-(NSTimeInterval)timeIntervalWithCreateTime:(NSString *)create andSellTime:(NSString *)selltime
{
    NSDate * createDate = [NSDate fromString:create];
    NSDate * sellDate = [NSDate fromString:selltime];
    
    NSTimeInterval interval = [sellDate timeIntervalSinceDate:createDate];
    //    NSLog(@"interval %f",interval);
    return interval;
    
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
