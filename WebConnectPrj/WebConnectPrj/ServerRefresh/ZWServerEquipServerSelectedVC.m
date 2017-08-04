//
//  ZWServerEquipServerSelectedVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/4.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerEquipServerSelectedVC.h"
@interface ZWServerEquipServerSelectedVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic,strong) UIView * tipsView;
@property (nonatomic, strong) NSArray * allKeys;
@property (nonatomic, strong) NSDictionary * serNameDic;
@end

@implementation ZWServerEquipServerSelectedVC

- (void)viewDidLoad
{
    self.showRightBtn = YES;
    self.rightTitle = @"蓬莱岛";
    
    self.viewTtle = @"选择服务器";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serNameDic = total.serverNameDic;
    self.serNameDic = serNameDic;
    self.allKeys = [serNameDic allKeys];

    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    self.listTable = table;
    [self.view addSubview:table];
    
//    [self.view addSubview:self.tipsView];
    //增加按钮开关，设定8000上、下、无区分
//    [self refreshPriceStatusForTitleShow];
    
}
-(UIView *)tipsView{
    if(!_tipsView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"限定价格";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnExchangePriceStatusWithTapedBtn:)];
        [aView addGestureRecognizer:tapGes];
        self.tipsView = aView;
    }
    return _tipsView;
}


-(void)refreshPriceStatusForTitleShow
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger status = total.refreshPriceStatus;
    NSString * priceStatus = @"全部";
    if(status == 1){
        priceStatus = @"小于8K";
    }else if(status == 2){
        priceStatus = @"大于8K";
    }
    NSString * showTitle = [NSString stringWithFormat:@"刷新门派 %@",priceStatus];
    self.titleV.text = showTitle;
}
-(void)tapedOnExchangePriceStatusWithTapedBtn:(id)sender
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger status = total.refreshPriceStatus;
    status ++;
    if(status > 2){
        status = 0 ;
    }
    total.refreshPriceStatus = status;
    [total localSave];
    
    [self refreshPriceStatusForTitleShow];
}


-(void)submit
{
    [DZUtils noticeCustomerWithShowText:@"选中蓬莱岛"];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.refreshServerId = 33;
    [total localSave];
    
    [self.listTable reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.allKeys count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ZAPanicSortSchoolVC_Panic_Style";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSInteger index = indexPath.section ;
    NSNumber * serverNum = [self.allKeys objectAtIndex:index];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.serNameDic objectForKey:serverNum];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    UIColor * txtColor = [UIColor blackColor];
    if(total.refreshServerId == [serverNum integerValue])
    {
        txtColor = [UIColor redColor];
    }
    cell.textLabel.textColor = txtColor;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.section ;
    NSNumber * serverNum = [self.allKeys objectAtIndex:index];
    NSString * serverName = [self.serNameDic objectForKey:serverNum];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.refreshServerId = [serverNum integerValue];
    [total localSave];
    
    [self.listTable reloadData];
    
    NSString * refreshSchool = [NSString stringWithFormat:@"当前选中:%@",serverName];
    [DZUtils noticeCustomerWithShowText:refreshSchool];
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
