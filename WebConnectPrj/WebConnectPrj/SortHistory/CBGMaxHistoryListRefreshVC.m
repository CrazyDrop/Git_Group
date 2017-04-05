//
//  CBGMaxHistoryListRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/3.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGMaxHistoryListRefreshVC.h"
#import "RecorderTimeRefreshManager.h"
#import "ZALocationLocalModel.h"

@interface CBGMaxHistoryListRefreshVC ()
{
    NSInteger startIndex;
    NSInteger eveSubCount;
    NSInteger tryNumber;
}
@property (nonatomic, copy) NSArray * subArr;
@property (nonatomic, strong) NSArray * retryArr;
@property (nonatomic, strong) UITextView * logTxt;
@end

@implementation CBGMaxHistoryListRefreshVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        startIndex = 0;
        eveSubCount = 300;
        tryNumber = 0;
    }
    return self;
}
- (void)viewDidLoad {
    self.viewTtle = @"集中刷新";
    self.rightTitle = @"分类";
    self.showRightBtn = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.listTable.hidden = YES;
    UIView * bgView = self.view;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height = FLoatChange(138);
    CGPoint pt = rect.origin;
    pt.y = FLoatChange(158);
    rect.origin = pt;
    
    UITextView * pickerView = [[UITextView alloc] initWithFrame:rect];
    [bgView addSubview:pickerView];
    pickerView.layoutManager.allowsNonContiguousLayout = NO;
    self.logTxt = pickerView;
    
    
    UIButton * bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.frame = CGRectMake(0, 0, 100, 80);
    [bottomBtn setBackgroundColor:[UIColor greenColor]];
    [bottomBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bottomBtn setTitle:@"开始" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(startMaxDetailListRequest) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:bottomBtn];
    bottomBtn.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(pickerView.frame) + 200);
    
    
    pickerView.text = [NSString stringWithFormat:@"总任务 %ld 当前%ld 分段%ld \n",[self.startArr count],startIndex,eveSubCount];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    _detailModel = nil;
    _dpModel = nil;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    EquipDetailArrayRequestModel * detailRefresh = _detailModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    //    _detailModel = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
}
-(void)startLocationDataRequest
{
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
    //    NSLog(@"%s",__FUNCTION__);
    
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}

-(void)startOpenTimesRefreshTimer
{
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 3;
    //    if(total.refreshTime && [total.refreshTime intValue]>0){
    //        time = [total.refreshTime intValue];
    //    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        [weakSelf startRefreshDataModelRequest];
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    EquipDetailArrayRequestModel * detailRefresh = _detailModel;
    if(detailRefresh.executing)
    {
        return;
    }
    
    NSInteger errNum = [self.retryArr count];
    NSInteger lengNum = eveSubCount - errNum;
    NSRange range = NSMakeRange(startIndex, lengNum);
    
    NSArray * eveArr = nil;
    if(range.location + range.length < [self.startArr count]){
        eveArr = [self.startArr subarrayWithRange:range];
    }else
    {
        range.length = [self.startArr count] - startIndex;
        eveArr = [self.startArr subarrayWithRange:range];
    }
    
    startIndex += ( [eveArr count]);
    NSMutableArray * subTotal = [NSMutableArray arrayWithArray:self.retryArr];
    [subTotal addObjectsFromArray:eveArr];
    self.subArr = subTotal;
    
    tryNumber ++;
    
    NSString * startLog = [NSString stringWithFormat:@"启动:%ld 次 上次失败 %ld 开始%ld 新增 %ld 总计:%ld 已结束%ld",tryNumber,errNum,range.location,range.length,[subTotal count],range.location];

    [self writeToViewLogWithLatestString:startLog];
    [self startSubDetailRequestWithSubArray:subTotal];
}
-(void)startSubDetailRequestWithSubArray:(NSArray *)arr
{
    if([arr count] == 0)
    {
        NSInteger total = [self.startArr count];
        NSString * startLog = [NSString stringWithFormat:@"请求结束 剩余%ld 全部%ld",total - startIndex,total];
        [self writeToViewLogWithLatestString:startLog];
        [DZUtils noticeCustomerWithShowText:@"更新结束"];
        
        
        [UIApplication sharedApplication].idleTimerDisabled=NO;
        RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
        [manager endAutoRefreshAndClearTime];
        
        [[ZALocation sharedInstance] stopUpdateLocation];
        return;
    }
    
//    NSMutableArray * urls = [NSMutableArray array];
//    for (NSInteger index = 0; index < [arr count]; index ++)
//    {
//        CBGListModel * list = [arr objectAtIndex:index];
//        NSString * eveUrl = list.detailDataUrl;
//        [urls addObject:eveUrl];
//    }
    
    [self startLatestDetailListRequestForShowedCBGListArr:arr];
}

-(void)writeToViewLogWithLatestString:(NSString *)append
{
    NSLog(@"%s %@",__FUNCTION__,append);
    NSString * current = self.logTxt.text;
    self.logTxt.text = [NSString stringWithFormat:@"%@ %@ \n",current,append];
    [self.logTxt scrollRangeToVisible:NSMakeRange([self.logTxt.text length],1)];
}


-(void)startMaxDetailListRequest
{
    //启动一个timer，假设处于请求
    [self startLocationDataRequest];
}
-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
//    NSMutableArray * errorArr = [NSMutableArray array];
//    for (NSInteger index = 0;index < [array count] ;index ++ )
//    {
//        CBGListModel * eveModel = [array objectAtIndex:index];
//        if(!eveModel.detailRefresh)
//        {
//            [errorArr addObject:eveModel];
//        }
//    }
//    
//    self.retryArr = errorArr;
}

-(void)finishDetailListRequestWithErrorCBGListArray:(NSArray *)array
{

    NSMutableArray * errorArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        CBGListModel * eveModel = [array objectAtIndex:index];
        if(!eveModel.detailRefresh)
        {
            [errorArr addObject:eveModel];
        }
    }
    
    self.retryArr = errorArr;
    
    NSString * startLog = [NSString stringWithFormat:@"本次结束 失败 %ld",[errorArr count]];
    [self writeToViewLogWithLatestString:startLog];
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
