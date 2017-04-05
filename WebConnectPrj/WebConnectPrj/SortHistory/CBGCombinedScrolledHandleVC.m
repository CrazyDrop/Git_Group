//
//  CBGCombinedScrolledHandleVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/2.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGCombinedScrolledHandleVC.h"
#import "CBGCombinedHistoryHandleVC.h"
#import "ZALocationLocalModel.h"
@interface CBGCombinedScrolledHandleVC ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSArray * controllerArr;
@property (nonatomic, strong) UIScrollView * vcScroll;
@end

@implementation CBGCombinedScrolledHandleVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat bgWidth = rect.size.width;
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [bgView addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(bgWidth * 3, rect.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.scrollsToTop = NO;
    self.vcScroll = scrollView;
    
    
    NSArray * arr = [self createControllsVCAndLoadView];
    self.controllerArr = arr;
    
    [self refreshLatestScrolledHandledCombineVC];
    [self refreshControllersShowedIndexAndScrollCenter];

}
-(void)refreshLatestScrolledHandledCombineVC
{//全部刷新，拆为单独方法
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];

    NSArray * vcArr = self.controllerArr;
    for (NSInteger index = 0;index < [vcArr count] ;index ++ )
    {
        CBGCombinedHistoryHandleVC * handle = [vcArr objectAtIndex:index];
        handle.showPlan = self.showPlan;
        NSString * showDate = self.selectedDate;
        if(index == 0){
            showDate = [self refreshLatestHandleSelectedDateWithNext:NO];
        }else if(index == 2){
            showDate = [self refreshLatestHandleSelectedDateWithNext:YES];
        }
        NSArray * dbArray = [manager localSaveEquipHistoryModelListForTime:showDate];
        handle.dbHistoryArr = dbArray;
        handle.selectedDate = showDate;
        [handle refreshCombinedHistoryListWithTips:NO];
    }

}

//根据controller顺序 ，移动视图位置，移动焦点
-(void)refreshControllersShowedIndexAndScrollCenter
{
    NSMutableArray * vcArr  =[NSMutableArray array];
    CGFloat bgWidth = self.vcScroll.bounds.size.width;
    CGFloat viewHeight = self.vcScroll.bounds.size.height;
    UIView * bgView = self.vcScroll;
    
    for (NSInteger index = 0;index < [self.controllerArr count] ;index ++ )
    {
        CGFloat startX = index * bgWidth;
        
        CBGCombinedHistoryHandleVC * handle = [self.controllerArr objectAtIndex:index];
        
        UIView * handleView = handle.view;
        handleView.frame = CGRectMake(startX, 0, bgWidth, viewHeight);
        [bgView addSubview:handleView];
        
        [vcArr addObject:handle];
    }
    
    [self.vcScroll setContentOffset:CGPointMake(bgWidth, 0) animated:NO];
}


-(NSArray *)createControllsVCAndLoadView
{
    NSMutableArray * vcArr  =[NSMutableArray array];
    for (NSInteger index = 0;index < 3 ;index ++ )
    {
        
        CBGCombinedHistoryHandleVC * handle = [[CBGCombinedHistoryHandleVC alloc] init];
        [self addChildViewController:handle];
        
        [vcArr addObject:handle];
    }
    return vcArr;
}

-(NSString *)refreshLatestHandleSelectedDateWithNext:(BOOL)next
{
    if(!self.selectedDate) return nil;
    
    NSString * formatStr = @"yyyy-MM-dd HH:mm:ss";
    formatStr = [formatStr substringToIndex:[self.selectedDate length]];
    NSInteger length = [formatStr length];
    
    NSDateFormatter * format = [NSDate format:formatStr];
    NSDate * formatDate = [format dateFromString:self.selectedDate];
    NSTimeInterval  second = 0;
    if(length == 4){
        second = YEAR;
        formatDate = [formatDate dateByAddingTimeInterval:6* MONTH];
    }else if(length == 7){
        second = MONTH;//当前时间为月份初始时间、需要递减则直接到下月，需要递增则需要先增加本月天数
        formatDate = [formatDate dateByAddingTimeInterval:15 * DAY];
    }else if(length == 10){
        second = DAY;
    }
    if(!next)
    {
        second *= -1;
    }
    NSDate * showDate = [formatDate dateByAddingTimeInterval:second];
    NSString * showString = [showDate toString:formatStr];
    return showString;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //刷新对应的视图
    CGPoint pt = scrollView.contentOffset;
    NSInteger index = pt.x / scrollView.bounds.size.width;
    
    [self exchangeHandleCombineControllerArrayAndRefreshScrollWithIndex:index];
}
-(void)exchangeHandleCombineControllerArrayAndRefreshScrollWithIndex:(NSInteger)index
{
    if(index == 1) return;

    //0 1 2
    if([self.controllerArr count] > index)
    {
        //取出最新时间
        CBGCombinedHistoryHandleVC * nextCenter = [self.controllerArr objectAtIndex:index];
        NSString * date = nextCenter.selectedDate;
        self.selectedDate = date;

        //调整vc位置  刷新vc数据
        NSInteger removeIndex = [self.controllerArr count] - index - 1;
        CBGCombinedHistoryHandleVC * disHandle = [self.controllerArr objectAtIndex:removeIndex];
        NSMutableArray * editArr = [NSMutableArray arrayWithArray:self.controllerArr];
        [editArr removeObject:disHandle];
        
        NSString * showDate = nil;
        if(removeIndex == 0){
            showDate = [self refreshLatestHandleSelectedDateWithNext:YES];
            [editArr addObject:disHandle];
        }else{
            showDate = [self refreshLatestHandleSelectedDateWithNext:NO];
            [editArr insertObject:disHandle atIndex:0];
        }
        self.controllerArr = editArr;
        
        //刷新数据
        ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
        NSArray * dbArray = [manager localSaveEquipHistoryModelListForTime:showDate];
        disHandle.dbHistoryArr = dbArray;
        disHandle.selectedDate = showDate;
        disHandle.showPlan = self.showPlan;
        [disHandle refreshCombinedHistoryListWithTips:NO];

        //调整视图位置
        [self refreshControllersShowedIndexAndScrollCenter];
        [nextCenter refreshCombinedHistoryListWithTips:YES];
    }
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
