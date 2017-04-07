//
//  ViewController.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "ViewController.h"
#import "NTConnectClient.h"
#import "NTBasicRequest.h"
#import "CBGTotalHistroySortVC.h"
#import "OLBasicListTableView.h"
#import "OLMainTopicListViewController.h"
#import "NTConnectSepcialClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSWebView.h"
#import "OLEGOCustomListTableView.h"
#import "OLBasicListTableView.h"
#import "ZALocalStateTotalModel.h"
#import "ZWRefreshListController.h"
#import "ZALocationLocalModel.h"
#import "ZWHistoryListController.h"
#import "CBGWebListRefreshVC.h"
#import "CBGWebListErrorCheckVC.h"
#import "CBGCopyUrlDetailCehckVC.h"
#import "CBGSettingURLEditVC.h"
#import "CBGMixedListCheckVC.h"
#import "CBGPlanSortHistoryVC.h"
#import "CBGDaysDetailSortHistoryVC.h"
#import "CBGCombinedHistoryHandleVC.h"
#import "CBGDetailWebView.h"
#import "CBGMaxHistoryListRefreshVC.h"

#define BlueDebugAddNum 100

@interface ViewController ()
{
    OLEGOCustomListTableView * nameList;
    
    
    dispatch_queue_t queue1;
    dispatch_queue_t queue2;
}
@property (nonatomic,assign) NSInteger foo;
@property (nonatomic,assign) NSInteger bar;
@end

@implementation ViewController
@synthesize foo;
@synthesize bar;

- (void)viewDidLoad
{
    self.showLeftBtn = NO;
    self.viewTtle = @"测试";
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //增加监听
//    CBGDetailWebView * detail = [[CBGDetailWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self.view addSubview:detail];
    
    NSArray * titles = [NSArray arrayWithObjects:
                        @"响铃(开)",
                        @"read数据导入",
                        
                        @"mobile刷新",
                        @"Web刷新",
                        
                        @"全部历史",
                        @"更新历史",
                        
                        @"页面验证码",
                        @"混合刷新",
                        
                        @"链接估价",
                        @"URL设置",
                        
                        @"当日历史",//今天的历史
                        @"细分历史",//通过时间选择
                        
                        @"mobile最新",
                        @"发送消息",
                        nil];
    
    UIView * bgView = self.view;
    for(NSInteger index = 0 ;index < [titles count]; index ++)
    {
        NSString * title = [titles objectAtIndex:index];
        UIButton * btn = [self customTestButtonForIndex: index];
        [btn setTitle:title forState:UIControlStateNormal];
        [bgView addSubview:btn];
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    total.isAlarm = YES;
//    [total localSave];
    [self refreshNoticeBtnStateWithNoticeState:total.isAlarm];
}
-(void)refreshNoticeBtnStateWithNoticeState:(BOOL)notice
{
    NSInteger noticeTag = 0;
    UIButton * btn = (UIButton *)[self.view viewWithTag:BlueDebugAddNum + noticeTag];
    NSString * showState = notice?@"响铃(开)":@"响铃(关)";
    [btn setTitle:showState forState:UIControlStateNormal];
}
-(void)exchangeNoticeForNoticeBtnTaped
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.isAlarm = !total.isAlarm;
    [total localSave];
    [self refreshNoticeBtnStateWithNoticeState:total.isAlarm];
}

-(UIButton * )customTestButtonForIndex:(NSInteger)indexNum
{
    NSInteger lineNum = indexNum/2;
    NSInteger rowNum = indexNum%2;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = indexNum + BlueDebugAddNum;
    btn.frame = CGRectMake(0, 0,FLoatChange(120) ,FLoatChange(50));
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnTestButtonWithSender:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame) + FLoatChange(20) + btn.bounds.size.height/2.0;
    CGFloat sepHeight = FLoatChange(10);
    CGFloat startX = SCREEN_WIDTH / 2.0 /2.0;
    btn.center = CGPointMake( startX + rowNum * SCREEN_WIDTH / 2.0 ,startY + (sepHeight + btn.bounds.size.height) * lineNum);
    
    return btn;
}

-(void)tapedOnTestButtonWithSender:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger indexNum = btn.tag - BlueDebugAddNum;
    
    [self debugDetailTestWithIndexNum:indexNum andTitle:btn.titleLabel.text];
}
-(void)debugDetailTestWithIndexNum:(NSInteger)indexNum andTitle:(NSString *)title
{
    NSLog(@"%s %@",__FUNCTION__,title);
    switch (indexNum) {
        case 0:
        {
            [self exchangeNoticeForNoticeBtnTaped];
            
        }
            break;
        case 1:
        {
            NSString * dbExchange = @"写入结束";
            NSInteger preNum = 0;
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotal];
            preNum = [soldout count];
            dbExchange = [dbExchange stringByAppendingFormat:@"pre %ld",preNum];
            
            [dbManager localCopySoldOutDataToPartDataBase];
            soldout = [dbManager localSaveEquipHistoryModelListTotal];
            dbExchange = [dbExchange stringByAppendingFormat:@"append %ld finished %ld ",[soldout count] - preNum,[soldout count]];
            {
                NSLog(@"localCopySoldOutDataToPartDataBase %@",dbExchange);
                [DZUtils noticeCustomerWithShowText:dbExchange];
            }
        }
            break;
        case 2:
        {
            ZWRefreshListController * list = [[ZWRefreshListController alloc] init];
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case 3:
        {
            
            CBGWebListRefreshVC * list = [[CBGWebListRefreshVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case 4:
        {
            CBGTotalHistroySortVC * history = [[CBGTotalHistroySortVC alloc] init];
            [[self rootNavigationController] pushViewController:history animated:YES];
        }
            break;
        case 5:{
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotal];
            
            CBGMaxHistoryListRefreshVC * list = [[CBGMaxHistoryListRefreshVC alloc] init];
            list.startArr = soldout;
            [[self rootNavigationController] pushViewController:list animated:YES];
            
        }
            break;
        case 6:{
            CBGWebListErrorCheckVC * list = [[CBGWebListErrorCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];

        }
            break;
        case 7:
        {
            
            CBGMixedListCheckVC * copy = [[CBGMixedListCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:copy animated:YES];
            
//            @"页面验证码",
//            @"混合刷新",
//            
//            @"链接估价",
//            @"URL设置",
        }
            break;
        case 8:
        {
            CBGCopyUrlDetailCehckVC * copy = [[CBGCopyUrlDetailCehckVC alloc] init];
            [[self rootNavigationController] pushViewController:copy animated:YES];
            
            
        }
            break;
        case 9:
        {
            CBGSettingURLEditVC * copy = [[CBGSettingURLEditVC alloc] init];
            [[self rootNavigationController] pushViewController:copy animated:YES];
            
        
        }
            break;
        case 10:
        {
            NSString * todayDate = [NSDate unixDate];
            
            if(todayDate)
            {
                todayDate = [todayDate substringToIndex:[@"2017-03-29" length]];
            }
            
            ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
            NSArray * dbArray = [manager localSaveEquipHistoryModelListForTime:todayDate];
            
            CBGCombinedHistoryHandleVC * combine = [[CBGCombinedHistoryHandleVC alloc] init];
            combine.selectedDate = todayDate;
            combine.dbHistoryArr = dbArray;
            combine.showPlan = YES;
            
            [[self rootNavigationController] pushViewController:combine animated:YES];
        }
            break;
        case 11:
        {
            CBGDaysDetailSortHistoryVC * plan = [[CBGDaysDetailSortHistoryVC alloc] init];
            [[self rootNavigationController] pushViewController:plan animated:YES];
        }
            break;
        case 12:
        {
            ZWRefreshListController * list = [[ZWRefreshListController alloc] init];
            list.onlyList = YES;
            [self.navigationController pushViewController:list animated:YES];
        }
            break;
        case 13:{
            [DZUtils localSoundTimeNotificationWithAfterSecond];
        }
            break;
            

    }
}
+(void)showLogStart:(int)number
{
    for (int i=0;i<10000 ;i++ )
    {
        NSLog(@"showLogStart %d",i+number);
    }
}

-(void)tapedOnTestBtn:(id)sender
{
//    nameList.loadMoreType++;
//    
//    return;
//    [nameList reloadData];

    ///异步打印
//    dispatch_async(queue2,^(){
//        [[self class] showLogStart:100];
//    });
//    
//    NSLog(@"dispatch_async finish");
//    
//     
//    dispatch_sync(queue2,^(){
//        [[self class] showLogStart:20000];
//    });
//    
//    NSLog(@"dispatch_sync finish");
//    
//    
//    return;
//    NSURLResponse *
//    [[NSURLCache sharedURLCache] setMemoryCapacity:1*1024*1024];
//
//    
//    NSString * str = @"http://olshow.onlylady.com/index.php?c=LookAPI&a=Default&rd=20&pm=2&se=0&sre=1&sud=12428402&ud=12428402";
//    static int num = 0;
//    num++;
//    if (num%2==0)
//    {
//        
//        NTBasicRequest * request = [[NTBasicRequest alloc] init];
//        request.requestUrlStr = str;
//        
//        [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request andEndBlock:^(id responseData, NSError *error) {
//            NSLog(@"sharedNTConnectClient cache %@",responseData);
//        }];
//        return;
//    }
//    
//    str = @"http://olshow.onlylady.com/index.php?c=LookAPI&a=Default&rd=20&pm=1&se=0&sre=1&sud=12428402&ud=12428402";
//    NTBasicRequest * request2 = [[NTBasicRequest alloc] init];
//    request2.requestUrlStr = str;
//    
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request2 andEndBlock:^(id responseData, NSError *error) {
//        NSLog(@"sharedNTConnectClient first %@",responseData);
//    }];
////    return;
//    str = @"http://olshow.onlylady.com/index.php?c=LookAPI&a=Default&rd=20&pm=2&se=0&sre=1&sud=12428402&ud=12428402";
//    request2.requestUrlStr = str;
//    
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request2 andEndBlock:^(id responseData, NSError *error) {
//        NSLog(@"sharedNTConnectClient second %@",responseData);
//    }];
//    return;
//    OLMainTopicListViewController * ol = [[OLMainTopicListViewController alloc] init];
//    [self presentViewController:ol animated:YES completion:nil];
    
//    OLBasicRequest * aRequest = [[OLBasicRequest alloc] initWithRequestIdStr:@"200"];
//    aRequest.requestUrlStr = @"http://www.456ri.com/html/article/index14923.html";
//    [[NTConnectSepcialClient sharedNTConnectSepcialClient] specialRequestWithBasicRequest:aRequest
//                                                                              andEndBlock:^(id responseData, NSError *error) {
//                                                                                  NSLog(@"%@",responseData);
//                                                                              }];


    
//    nameList.loadMoreType = nameList.loadMoreType+1;
//    [nameList startLoadMoredDataInForcedWithViewAnimated:YES];
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString * urlstr = @"http://www.456ri.com/html/article/index14923.html";
    
    JSWebView * aWeb = [[JSWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:aWeb];
    aWeb.endJSOperationBlcok = ^(NSArray *arr){
        
    };
    
    [manager GET:urlstr
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *textFile = operation.responseString;
             if (!textFile)
             {
                 NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                 textFile  = [[NSString alloc] initWithData:responseObject encoding:enc];
             }
             
             NSLog(@"responseObject%@ %@",operation.responseString,textFile);
             [aWeb loadWebHtml:textFile];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"responseObject%@",error);
         }];
    

    
    return;
//    //普通请求
//    OLConfigRequest * arequest = [[OLConfigRequest alloc] init];
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:arequest
//                                                         andEndBlock:^(id responseData, NSError *error) {
//                                                             NSLog(@"%@ %@",responseData,error);
//                                                         }];
//    
//    
//    
//    
//    
//    //需要结果处理的大量数据请求
//    OLProtocolRequest * request = [[OLProtocolRequest alloc] init];
//    [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request
//                                                         andEndBlock:^(id responseData, NSError *error) {
//                                                             
//                                                             
//                                                             
//                                                         }];
//    
//    
//    [[NTConnectClient sharedNTConnectClient] requestModelDataArrayWithBasicRequest:request
//                                                                checkResponseBlock:^NSArray *(id responseData) {
//                                                                    NSDictionary * dic = [responseData valueForKey:@"de"];
//
//                                                                    NSLog(@"allKeys %@",[dic allKeys]);
//                                                                    return [dic allKeys];
//                                                                } andEndBlock:^(BOOL netWorkType, NSArray *array) {
//                                                                    NSLog(@"netWorkType %d %@",netWorkType,array);
//                                                                }];
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
     NSLog(@"observeValueForKeyPathobserveValueForKeyPath ");
//    NSLog(@"%@ %@ %@",keyPath,object,nameList.dataArr);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
