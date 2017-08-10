//
//  VPNEditDataAddVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "VPNEditDataAddVC.h"
#import "VPNProxyModel.h"
#import "ZWDetailCheckManager.h"
@interface VPNEditDataAddVC ()
{
    UITextField * editIpTfd;
    UITextField * editPortTfd;
}
@end

@implementation VPNEditDataAddVC

- (void)viewDidLoad {
    self.viewTtle = @"代理编辑";
//    self.rightTitle = @"删除";
//    self.showRightBtn = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    startY += 20;
    //添加、编辑
    editIpTfd = [[UITextField alloc] initWithFrame:CGRectMake(0, startY , FLoatChange(200), FLoatChange(50))];
    [bgView addSubview:editIpTfd];
    editIpTfd.placeholder = @"代理ip地址";
    editIpTfd.backgroundColor = [UIColor grayColor];
    editIpTfd.clearButtonMode = UITextFieldViewModeAlways;
    
    startY += 20;
    startY += editIpTfd.bounds.size.height;
    
    editPortTfd = [[UITextField alloc] initWithFrame:CGRectMake(0, startY , FLoatChange(200), FLoatChange(50))];
    [bgView addSubview:editPortTfd];
    editPortTfd.backgroundColor = [UIColor grayColor];
    editPortTfd.placeholder = @"代理ip端口";
    editPortTfd.clearButtonMode = UITextFieldViewModeAlways;
    
    startY += 120;
    CGFloat btnWith = 100;
    UIButton * btn  = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWith, btnWith);
    [bgView addSubview:btn];
    [btn setTitle:@"添加" forState:UIControlStateNormal];
    btn.center = CGPointMake(btnWith/2.0 , startY);
    [btn addTarget:self action:@selector(tapedOnAddMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn  setBackgroundColor:[UIColor greenColor]];
    [btn  setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    btn  = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnWith, btnWith);
    [bgView addSubview:btn];
    [btn setTitle:@"删除" forState:UIControlStateNormal];
    btn.center = CGPointMake(SCREEN_WIDTH - btnWith/2.0 , startY);
    [btn addTarget:self action:@selector(tapedOnRemoveSelectedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn  setBackgroundColor:[UIColor greenColor]];
    [btn  setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    if(self.dataObj)
    {
        VPNProxyModel * model = (VPNProxyModel *)self.dataObj;
        editIpTfd.text = model.idNum;
        editPortTfd.text = model.portNum;
    }
    
}
-(void)tapedOnAddMoreBtn:(id)sender
{
    VPNProxyModel * eve = nil;
    
    eve = [[VPNProxyModel alloc] init];
    eve.idNum = editIpTfd.text;
    eve.portNum = editPortTfd.text;
    
    ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSMutableArray * edit = [NSMutableArray arrayWithArray:manager.proxyArrCache];
    [edit addObject:eve];
    manager.proxyArrCache = edit;
    
    NSArray * dicArr = [VPNProxyModel proxyDicArrayFromDetailProxyArray:edit];
    total.proxyDicArr = dicArr ;
    [total localSave];
    
}
-(void)tapedOnRemoveSelectedBtn:(id)sender
{
    VPNProxyModel * eve = nil;
    
    eve = [[VPNProxyModel alloc] init];
    eve.idNum = editIpTfd.text;
    eve.portNum = editPortTfd.text;
    
    ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];

    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSMutableArray * edit = [NSMutableArray arrayWithArray:manager.proxyArrCache];
    NSMutableDictionary * editDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0;index <[edit count] ;index ++ )
    {
        VPNProxyModel * model = [edit objectAtIndex:index];
        [editDic setObject:model forKey:model.idNum];
    }
    [editDic removeObjectForKey:eve.idNum];
    
    [edit removeAllObjects];
    [edit addObjectsFromArray:[editDic allValues]];
    manager.proxyArrCache = edit;
    
    NSArray * dicArr = [VPNProxyModel proxyDicArrayFromDetailProxyArray:edit];
    total.proxyDicArr = dicArr ;
    [total localSave];

    
    
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
