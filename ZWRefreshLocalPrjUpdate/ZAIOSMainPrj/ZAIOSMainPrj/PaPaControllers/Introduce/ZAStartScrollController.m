//
//  ZAStartScrollControllerViewController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/26.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartScrollController.h"
#import "SMPageControl.h"
@interface ZAStartScrollController ()<UIScrollViewDelegate>
{
}
@property (nonatomic,strong) UIScrollView * startScroll;
@property (nonatomic,strong) NSArray * imgArr;
@property (nonatomic,strong) UIButton * imgCoverBtn;
@property (nonatomic,strong) SMPageControl * bottomNumView;
@end

@implementation ZAStartScrollController

- (void)viewDidLoad {
    self.showLeftBtn = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleBar.hidden = YES;
    topBgView.hidden = YES;
    
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    [self.view addSubview:self.startScroll];
    [self.view addSubview:self.imgCoverBtn];
    
    [self refreshLocalImageViewsAndCoverBtn];
    [self refreshLocalImgCoverBtn];
    
    [self.view addSubview:self.bottomNumView];
    [self refreshLocalBottomNumView];

}
-(void)refreshLocalBottomNumView
{
    SMPageControl * control = self.bottomNumView;
    CGPoint pt = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(30));
    control.center = pt;
    
    control.numberOfPages = [self.imgArr count];
    if(control.numberOfPages==0) control.hidden = YES;
    
    control.currentPage = 0;
}

-(void)spacePageControlValueChange:(id)sender
{
    SMPageControl * control = (SMPageControl *)sender;
//    NSLog(@"%s %d",__FUNCTION__,control.currentPage);
    NSInteger index = control.currentPage;
    UIScrollView * scroll = self.startScroll;
    CGFloat scrollWidth = scroll.bounds.size.width;
    [scroll setContentOffset:CGPointMake(scrollWidth * index, 0) animated:NO];
    
}
-(SMPageControl *)bottomNumView
{
    if(!_bottomNumView)
    {
        CGRect rect  = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        SMPageControl * page = [[SMPageControl alloc] initWithFrame:rect];
        [page addTarget:self action:@selector(spacePageControlValueChange:) forControlEvents:UIControlEventValueChanged];
        page.indicatorDiameter = FLoatChange(12);
        
        self.bottomNumView = page;
    }
    return _bottomNumView;
}


-(void)refreshLocalImgCoverBtn
{
    //确定大小和位置
    UIButton * btn = self.imgCoverBtn;
    btn.frame = CGRectMake(0, 0, FLoatChange(215), FLoatChange(35));
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(70));
    
    //异常处理，无图片时直接展示
    if([self.imgArr count]==0)
    {
        btn.hidden = NO;
        btn.backgroundColor = Custom_Blue_Button_BGColor;
        [btn setTitle:@"退出" forState:UIControlStateNormal];
    }
}

-(void)tapedOnCoverBtn
{
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Start];
    
    if(self.StartScrollEndBlock)
    {
        self.StartScrollEndBlock();
    }
}

-(UIButton *)imgCoverBtn
{
    if(!_imgCoverBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"开始体验" forState:UIControlStateNormal];
//        [btn setBackgroundColor:Custom_Blue_Button_BGColor];
        [btn setBackgroundColor:[DZUtils colorWithHex:@"4795ff"]];
        [btn refreshButtonSelectedBGColor];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(20)]];
        [btn addTarget:self action:@selector(tapedOnCoverBtn) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setCornerRadius:5.0];
        self.imgCoverBtn = btn;
    }
    return _imgCoverBtn;
}

//填充图片界面，
-(void)refreshLocalImageViewsAndCoverBtn
{
    UIScrollView * scroll = self.startScroll;
    CGRect rect = [scroll bounds];

    NSArray * arr = self.imgArr;
    CGFloat scrollWidth = rect.size.width;
    
    for (NSInteger index =0 ;index< [arr count] ;index++ )
    {
        rect.origin.x = scrollWidth * index;
        UIImageView * imgView = [[UIImageView alloc] initWithFrame:rect];
        [scroll addSubview:imgView];
        imgView.image = [arr objectAtIndex:index];
        imgView.backgroundColor = [UIColor blackColor];
        
        if(index == [arr count]-1)
        {
            //刷新btn位置,改为self.view到imgview
            [imgView addSubview:self.imgCoverBtn];
            imgView.userInteractionEnabled = YES;
        }
    }
    
    
    
    scroll.contentSize = CGSizeMake(scrollWidth * [arr count],rect.size.height);
}
-(void)refreshImgCoverBtnStateWithPoint:(CGPoint)pt
{
    CGFloat scrollWidth = self.startScroll.bounds.size.width;
    NSInteger index = pt.x / scrollWidth;
    
//    BOOL show = (index == [self.imgArr count]-1);
//    self.imgCoverBtn.hidden = !show;
    
    self.bottomNumView.currentPage = index;
}

-(NSArray *)imgArr
{
    if(!_imgArr)
    {
        NSMutableArray * arr = [NSMutableArray array];
        for (NSInteger index = 0; index<4 ; index++)
        {
            NSString * name = [NSString stringWithFormat:@"start_info_%ld",(long)index];
            UIImage * img = [UIImage imageNamed:name];
            if(!img) continue;
            [arr addObject:img];
        }
//        [arr exchangeObjectAtIndex:0 withObjectAtIndex:1];//第一和第二页换位置
        self.imgArr = arr;
    }
    return _imgArr;
}
-(UIScrollView *)startScroll
{
    if(!_startScroll)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:rect];
        scroll.delegate = self;
        scroll.pagingEnabled = YES;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.bounces = NO;
        self.startScroll = scroll;
    }
    return _startScroll;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self refreshImgCoverBtnStateWithPoint:scrollView.contentOffset];
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
