//
//  ZWPanicRefreshSettingVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/16.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicRefreshSettingVC.h"
#import "CBGListModel.h"
@interface ZWPanicRefreshSettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic,strong) NSArray * refreshArr;

@end

@implementation ZWPanicRefreshSettingVC

- (void)viewDidLoad {
    self.showRightBtn = YES;
    self.rightTitle = @"保存";
    
    self.viewTtle = @"刷新选择";
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
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * arr = [total.ingoreCombineSchool componentsSeparatedByString:@"|"];
    self.refreshArr = arr;
}

-(void)submit
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * combine = [self.refreshArr componentsJoinedByString:@"|"];
    total.ingoreCombineSchool = combine;
    [total localSave];
    
    NSArray * arr = [total.ingoreCombineSchool componentsSeparatedByString:@"|"];
//    self.refreshArr = arr;
    
    [DZUtils noticeCustomerWithShowText:@"保存成功"];
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
    NSString * tagIndex = [NSString stringWithFormat:@"%ld",index];
    NSString * nameObj = [CBGListModel schoolNameFromSchoolNumber:index];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = nameObj;
    
    UIColor * txtColor = [UIColor blackColor];
    if(![self.refreshArr containsObject:tagIndex])
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
    NSString * tagIndex = [NSString stringWithFormat:@"%ld",index];
    NSMutableArray * edit = [NSMutableArray array];
    [edit addObjectsFromArray:self.refreshArr];
    
    if([self.refreshArr containsObject:tagIndex]){
        [edit removeObject:tagIndex];
    }else
    {
        [edit addObject:tagIndex];
    }
    self.refreshArr = edit;
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
