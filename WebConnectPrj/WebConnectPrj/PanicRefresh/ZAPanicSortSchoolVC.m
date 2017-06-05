//
//  ZAPanicSortSchoolVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZAPanicSortSchoolVC.h"
#import "CBGListModel.h"
@interface ZAPanicSortSchoolVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic,strong) UIView * tipsView;
@end

@implementation ZAPanicSortSchoolVC

- (void)viewDidLoad
{
    self.showRightBtn = YES;
    self.rightTitle = @"全部";
    
    self.viewTtle = @"刷新门派";
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
    
    [self.view addSubview:self.tipsView];
    //增加按钮开关，设定8000上、下、无区分
    [self refreshPriceStatusForTitleShow];
    
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
    [DZUtils noticeCustomerWithShowText:@"取消选中，刷新全部"];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.refreshSchool = 0;
    [total localSave];
    
    [self.listTable reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 15;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ZAPanicSortSchoolVC_Panic_Style";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSInteger index = indexPath.section + 1;
    NSString * nameObj = [CBGListModel schoolNameFromSchoolNumber:index];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = nameObj;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    UIColor * txtColor = [UIColor blackColor];
    if(total.refreshSchool == index)
    {
        txtColor = [UIColor redColor];
    }
    cell.textLabel.textColor = txtColor;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.section + 1;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.refreshSchool = index;
    [total localSave];
    
    [self.listTable reloadData];
    
    NSString * refreshSchool = [NSString stringWithFormat:@"当前选中:%@",[CBGListModel schoolNameFromSchoolNumber:index]];
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
