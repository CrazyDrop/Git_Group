//
//  ZAStartController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartController.h"

@interface ZAStartController ()

@end

@implementation ZAStartController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imgBg.hidden = YES;
    self.titleV.textColor = [UIColor blackColor];
    UIImage * backImg = [UIImage imageNamed:@"black_back_arrow"];
    [self.leftBtn setImage:backImg forState:UIControlStateNormal];
    [topBgView setBackgroundColor:[UIColor whiteColor]];
    
//    [self.leftBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [self.leftBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.leftBtn addTarget:self action:@selector(startGoBack:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    TPKeyboardAvoidingTableView * table = [[TPKeyboardAvoidingTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    table.showsVerticalScrollIndicator = NO;
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
    [self.view sendSubviewToBack:table];
    table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"white_bg"];
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];
    
    
    table.separatorColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    startTableview = table;
    
    
    CGFloat bottomHeight = FLoatChange(122);//原92
    rect.size.height = bottomHeight;
    UIView * bottom = [[UIView alloc] initWithFrame:rect];
    bottom.backgroundColor = [UIColor clearColor];
    
    
    rect.size.height = FLoatChange(48);
    UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = rect;
    [addMoreBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [bottom addSubview:addMoreBtn];
    [addMoreBtn setBackgroundColor:Custom_Blue_Button_BGColor];
    table.tableFooterView = bottom;
    addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(92-48) + (rect.size.height / 2.0) );
    [addMoreBtn refreshButtonSelectedBGColor];

    //    [addMoreBtn.layer setCornerRadius:5];
    bottomBtn = addMoreBtn;
    
    //头部视图
    CGFloat topViewHeight = FLoatChange(145);
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topViewHeight)];
    header.backgroundColor = [UIColor clearColor];
    table.tableHeaderView = header;
    
    rect = [[UIScreen mainScreen] bounds];
    CGFloat topHeight = FLoatChange(8);
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    
    rect.size.height = topHeight;
    rect.origin.y = startY;
    UIView * selectBGView = [[UIView alloc] initWithFrame:rect];
    [header addSubview:selectBGView];
    [selectBGView setBackgroundColor:RGB(162, 185, 202)];
    topSelectBGView = selectBGView;
    
    rect = selectBGView.bounds;
    rect.size.width *= (1/2.0);
    UIView * selectView = [[UIView alloc] initWithFrame:rect];
    [selectBGView addSubview:selectView];
    selectView.backgroundColor = RGB(62, 143, 204);
    topSelectView = selectView;
    
    startY += topHeight;
    
    rect.size.width = 0.9 * SCREEN_WIDTH;
    rect.size.height = topViewHeight - startY;
    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
    lbl.numberOfLines = 0;
    lbl.textColor = Custom_Blue_Button_BGColor;
    [header addSubview:lbl];
    lbl.center = CGPointMake(SCREEN_WIDTH/2.0, (topViewHeight - startY)/2.0 + startY);
    topGuideLbl = lbl;

    
    
}

-(void)startGoBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContactListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"(子类重写)%s",__FUNCTION__];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FLoatChange(47);
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
