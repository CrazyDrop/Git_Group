//
//  ZAStartBGController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartBGController.h"
#import "TPKeyboardAvoidingTableView.h"
#define CExpandContentOffset @"contentOffset"
@interface ZAStartBGController ()
{
    CGFloat startHeight;
    UIView * topCoverView;
}
@end

@implementation ZAStartBGController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    _topHeaderLbl.textColor = [UIColor whiteColor];
    _topHeaderSmallLbl.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    [self.leftBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [self.leftBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.leftBtn addTarget:self action:@selector(startGoBack:) forControlEvents:UIControlEventTouchUpInside];
    
    //统一处理返回按钮大小
    UIButton * btn = self.leftBtn;
    CGPoint pt = btn.center;
    CGFloat btnWidth = SCREEN_WIDTH * 65.0/750.0;
    CGRect rect = btn.frame;
    rect.size = CGSizeMake(btnWidth, btnWidth);
    btn.frame = rect;
    pt.x = SCREEN_WIDTH * 0.1;
    btn.center = pt;
    
    CALayer * layer = btn.layer;
    [layer setCornerRadius:btn.bounds.size.height/2.0];
    [btn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    
    rect = [[UIScreen mainScreen] bounds];
    TPKeyboardAvoidingTableView * table = [[TPKeyboardAvoidingTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    table.showsVerticalScrollIndicator = NO;
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
    [self.view sendSubviewToBack:table];
    table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
    table.separatorColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    startTableview = table;
    
    //设置头部
    CGFloat topHeight = FLoatChange(188);
    rect.size.height = topHeight;
    UIView * topView = [[UIView alloc] initWithFrame:rect];
    topView.backgroundColor = [UIColor clearColor];
    [table addSubview:topView];
    topCoverView = topView;
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:topView.bounds];
    [topView addSubview:img];
    img.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    img.image = [UIImage imageNamed:@"start_top_img"];
//
    CGFloat lblHeight = FLoatChange(35);
    rect.size.height = lblHeight;
    rect.origin.y = topHeight - lblHeight;
    UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
    [topView addSubview:aLbl];
    aLbl.backgroundColor = [UIColor clearColor];
    aLbl.textColor = [UIColor whiteColor];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.text = @"请输入您的个人信息";
    aLbl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    topGuideLbl = aLbl;
    
    CGFloat viewHeight = SCREEN_WIDTH/750.0*127.0;
    ZATopNumView * numView = [[ZATopNumView alloc] initWithFrame:CGRectMake(0, topHeight - viewHeight - lblHeight, SCREEN_WIDTH, viewHeight)];
    [topView addSubview:numView];
    numView.backgroundColor = [UIColor clearColor];
    numView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    topNumView = numView;
    
    //设置底部按钮
    rect = table.bounds;
    CGFloat bottomHeight = FLoatChange(104);
    rect.size.height = bottomHeight;
    UIView * bottom = [[UIView alloc] initWithFrame:rect];
    bottom.backgroundColor = [UIColor clearColor];
    
    rect.size.width *=  (255/320.0);
    rect.size.height *= (40/104.0);
    
    UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = rect;
    addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, bottomHeight/2.0);
    [addMoreBtn setTitle:@"下一步" forState:UIControlStateNormal];
//    [addMoreBtn addTarget:self action:@selector(tapedOnAddMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:addMoreBtn];
    [addMoreBtn setBackgroundColor:Start_Green_Button_BGColor];
    table.tableFooterView = bottom;
    bottomBtn = addMoreBtn;
    
    layer = addMoreBtn.layer;
    [layer setCornerRadius:5];
    
    //后期处理
    startHeight = topHeight;
    table.contentInset = UIEdgeInsetsMake(startHeight, 0, 0, 0);
    [table addObserver:self forKeyPath:CExpandContentOffset options:NSKeyValueObservingOptionNew context:nil];
    [table setContentOffset:CGPointMake(0, - startHeight)];
    
    //调整位置
    rect = topView.frame;
    rect.origin.y = - startHeight;
    topView.frame = rect;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (![keyPath isEqualToString:CExpandContentOffset]) {
        return;
    }
    CGFloat offsetY = startTableview.contentOffset.y;
    [self refreshHeaderViewWithContentY:offsetY];
}
-(void)refreshHeaderViewWithContentY:(CGFloat)height
{
    CGFloat effectiveLine = -1*startHeight * 2.5/3.0;//隐藏线
//    if(height>effectiveLine)
    
    BOOL hidden = height>effectiveLine;
    _topHeaderLbl.hidden = hidden;
    _topHeaderSmallLbl.hidden = hidden;
    
    
    CGRect currentFrame = topCoverView.frame;
    currentFrame.origin.y = height;
    currentFrame.size.height = -1*height;
    
//    NSLog(@"heightheight %@",NSStringFromCGRect(currentFrame));

//    if(height*-1>startHeight)
//    {
//        //修改width和x值
//        CGFloat scale = startHeight/SCREEN_WIDTH;
//        CGFloat totalWidth = -1 * height / scale; //比例
//        currentFrame.size.width = totalWidth;
//        currentFrame.origin.x = -(totalWidth - SCREEN_WIDTH)/2.0;
//        
//    }

    topCoverView.frame = currentFrame;
    
}
-(void)dealloc
{
    [startTableview removeObserver:self forKeyPath:CExpandContentOffset];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
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
    
    if(indexPath.row==0) return FLoatChange(55);
    return FLoatChange(51);
    
    return FLoatChange(39);
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    
//}

//顶部控件追加
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if(section==0) return FLoatChange(16);
//    return FLoatChange(13);
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 13)];
//    line.backgroundColor = [UIColor clearColor];
//    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    return line;
//}


-(void)startGoBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
