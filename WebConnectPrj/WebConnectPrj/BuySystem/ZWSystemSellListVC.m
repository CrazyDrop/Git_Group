//
//  ZWSystemSellListVC.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/12.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSystemSellListVC.h"
#import "RefreshListCell.h"
#import "ZALocationLocalModel.h"
#import "ZWSysSellModel.h"

@interface ZWSystemSellListVC()
@property (nonatomic,strong) NSArray * dateList;
@property (nonatomic,strong) NSDictionary * sortDic;
@end

@implementation ZWSystemSellListVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.showListForName = NO;
    }
    return self;
}
- (void)viewDidLoad
{

    NSString * today = [NSDate unixDate];
    today = [today substringToIndex:[@"2016-08-15" length]];

    NSString * str = [NSString stringWithFormat:@"历史 %@",today];
    self.viewTtle = str;
    self.showRightBtn = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.showListForName){
        [self showLocalListDataForName];
    }else{
        [self showLocalListDataForRefreshDate];
    }
   
}

//数据加载方式
-(void)showLocalListDataForName
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * array = nil;
//    [manager localSystemSellArray];
    
    NSArray * sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZWSysSellModel * sys1 = (ZWSysSellModel * )obj1;
        ZWSysSellModel * sys2 = (ZWSysSellModel * )obj2;

        ;
        return [sys1.name compare:sys1.name];
//        NSNumber * num1 = [NSNumber numberWithInteger:[[ZATfdLocalCheck localInputNumberInputForTotalText:sys1.name] integerValue]];
//        NSNumber * num2 = [NSNumber numberWithInteger:[[ZATfdLocalCheck localInputNumberInputForTotalText:sys2.name] integerValue]];
//        
//        
//        NSComparisonResult result = [num2 compare:num1];
//        if(result == NSOrderedSame){
//            
//            return [sys2.sell_date compare:sys1.sell_date];
//        }
//        
//        return result;
    }];
    
    
    //分组
    NSMutableArray * dateArr = [NSMutableArray array];
    NSMutableDictionary * dateDic = [NSMutableDictionary dictionary];
    for (ZWSysSellModel * eve in sortArr)
    {
        NSString * eveDate = eve.name;
        NSMutableArray * eveArr = [dateDic valueForKey:eveDate];
        if(!eveArr){
            eveArr = [NSMutableArray array];
            [dateDic setObject:eveArr forKey:eveDate];
            [dateArr addObject:eveDate];
        }
        [eveArr addObject:eve];
    }
    
    self.dateList = dateArr;
    self.sortDic = dateDic;
    [self.listTable reloadData];
}


//加载数据  按照刷新日期
-(void)showLocalListDataForRefreshDate
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * array = nil;
//    [manager localSystemSellArray];
    
    NSArray * sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZWSysSellModel * sys1 = (ZWSysSellModel * )obj1;
        ZWSysSellModel * sys2 = (ZWSysSellModel * )obj2;
        
        NSString * date1 = [sys1.sell_date substringToIndex:[@"2016-08-15" length]];
        NSString * date2 = [sys2.sell_date substringToIndex:[@"2016-08-15" length]];
        
        if([date1 compare:date2] == NSOrderedSame){
            return [[NSNumber numberWithInteger:[sys2.duration_str integerValue]] compare:[NSNumber numberWithInteger:[sys1.duration_str integerValue]]];
        }
        return [date2 compare:date1];
    }];
    

    //分组
    NSMutableArray * dateArr = [NSMutableArray array];
    NSMutableDictionary * dateDic = [NSMutableDictionary dictionary];
    for (ZWSysSellModel * eve in sortArr)
    {
        NSString * eveDate = eve.sell_date;
        eveDate = [eveDate substringToIndex:[@"2016-08-15" length]];
        NSMutableArray * eveArr = [dateDic valueForKey:eveDate];
        if(!eveArr){
            eveArr = [NSMutableArray array];
            [dateDic setObject:eveArr forKey:eveDate];
            [dateArr addObject:eveDate];
        }
        [eveArr addObject:eve];
    }
    
    self.dateList = dateArr;
    self.sortDic = dateDic;
    [self.listTable reloadData];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dateList count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * date = [self.dateList objectAtIndex:section];
    NSArray * arr = [self.sortDic valueForKey:date];
    return [arr count];
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * date = [self.dateList objectAtIndex:section];
    return date;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.section;
    NSString * date = [self.dateList objectAtIndex:secNum];
    NSArray * arr = [self.sortDic valueForKey:date];
    
    NSInteger rowNum = indexPath.row;
    ZWSysSellModel * contact = [arr objectAtIndex:rowNum];
    
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
    
    
    //更新时间
    NSDateFormatter * upFormat = [NSDate format:@"yyyyMMddHHmmss"];
    NSDate * updateDate = [upFormat dateFromString:contact.updated_at];
    cell.timeLbl.text = [updateDate toString:@"MM-dd HH:mm"];
    
    
//      NSDate * localDate = [NSDate fromString:contact.sell_date];
//      [localDate  toString:@"MM-dd HH:mm"];
    NSString * start = [contact.start_date stringByReplacingOccurrencesOfString:@"2016-" withString:@""];
    cell.sellTimeLbl.text = [NSString stringWithFormat:@"起 %@",start];
    
    //记录时间
//    cell.sellTimeLbl.text = [contact.sell_date substringFromIndex:5];

    
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
