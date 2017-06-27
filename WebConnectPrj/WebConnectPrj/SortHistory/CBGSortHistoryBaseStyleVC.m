//
//  CBGSortHistoryBaseStyleVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/4.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseStyleVC.h"
#define  CBGPlanSortHistoryStyleAddTAG  100

@interface CBGSortHistoryBaseStyleVC ()<UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController * docVc;
@end

@implementation CBGSortHistoryBaseStyleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"未结束",@"已结束",@"全部"];//按钮点击时，从全部库表选取
    
    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
//    for (NSInteger index = 0; index < [namesArr count]; index ++)
//    {
//        NSString * name = [namesArr objectAtIndex:index];
//        btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(index * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
//        btn.backgroundColor = [UIColor greenColor];
//        [btn setTitle:name forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [bgView addSubview:btn];
//        btn.tag = CBGPlanSortHistoryStyleAddTAG + index;
//        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    //增加分组、门派分组
    namesArr = @[@"时差分组",@"利差分组",@"门派分组",@"无分组"];
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        CGFloat startY = btnStartY - (index) * (btnHeight + 2);
        CGFloat startX = SCREEN_WIDTH - btnWidth;
        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.frame = CGRectMake(startX , startY, btnWidth - 1, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        btn.tag = CBGPlanSortHistoryStyleAddTAG + index;
        [btn addTarget:self action:@selector(tapedOnExchangeSortStyleWithTapedBtn:) forControlEvents:UIControlEventTouchUpInside];
    }

    
}

-(void)tapedOnExchangeSortStyleWithTapedBtn:(id)sender
{
    //重新排序
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanSortHistoryStyleAddTAG;
    switch (tagIndex) {
        case 0:
        {
            self.sortStyle = CBGStaticSortShowStyle_Space;
        }
            break;
        case 1:
        {
            self.sortStyle = CBGStaticSortShowStyle_Rate;
        }
            break;
        case 2:
        {
            self.sortStyle = CBGStaticSortShowStyle_School;
        }
            break;

        default:
            self.sortStyle = CBGStaticSortShowStyle_None;
            break;
    }
    [self refreshLatestShowTableView];
}

#pragma mark - WriteDBCSV
-(void)writeLocalCSVWithFileName:(NSString *)filePath
                     headerNames:(NSString *)headerName
                      modelArray:(NSArray *)models
                  andStringBlock:(ZWWriteDBFunctionBlock)block
{
    
    //移除
    [self removeFileWithPath:filePath];
    
    NSOutputStream *output = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
    [output open];
    
    if (![output hasSpaceAvailable])
    {
        NSLog(@"没有足够可用空间");
    } else {
        
        NSString *header = headerName;   //这里是文件第一行的头（逗号是换列，\n是换行）
        
        const uint8_t *headerString = (const uint8_t *)[header cStringUsingEncoding:NSUTF8StringEncoding];
        NSInteger headerLength = [header lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSInteger result = [output write:headerString maxLength:headerLength];
        if (result <= 0) {
            NSLog(@"写入错误");
        }
        
        for (NSInteger index = 0;index < [models count] ;index ++ )
        {
            NSInteger nextIndex = index + 1;
            NSInteger repeatIndex = nextIndex + 1;
            CBGListModel * model1 = [models objectAtIndex:index];
            CBGListModel * model2 = nil;
            if([models count] > nextIndex){
                model2 = [models objectAtIndex:nextIndex];
            }
            if([model2.sell_back_time length] > 0 && ([models count] > repeatIndex))
            {
                model2 = [models objectAtIndex:repeatIndex];
            }
            
            NSString * pathEveString = block(model1,model2);
            if(!pathEveString || [pathEveString length] == 0){
                continue;
            }
            const uint8_t *rowString = (const uint8_t *)[pathEveString cStringUsingEncoding:NSUTF8StringEncoding];
            NSInteger rowLength = [pathEveString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            result = [output write:rowString maxLength:rowLength];
            if (result <= 0)
            {
                NSLog(@"无法写入内容");
            }
        }
        [output close];
    }
}

-(void)createFilePath:(NSString *)path
{
    //    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //    path = [path stringByAppendingPathComponent:@"details"];
    //    path = [path stringByAppendingPathComponent:extend];
    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path])
    {
        NSError * error;
        if([fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
        {
            
        }
        else
        {
            NSLog(@"Failed to create directory %@,error:%@",path,error);
        }
    }
}
-(void)removeFileWithPath:(NSString *)path
{
    NSFileManager * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path])
    {
        NSError * error;
        if([fm removeItemAtPath:path error:&error])
        {
            
        }
        else
        {
            NSLog(@"Failed to remove directory %@,error:%@",path,error);
        }
    }
    
}
#pragma mark - FileOutPut
-(void)outLatestShowDetailDBCSVFile
{//单独服务器compare使用
    NSString * fileName = @"list.csv";
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"Files"];
    [self createFilePath:path];
    
    NSString *databasePath=[path stringByAppendingPathComponent:fileName];
    
    
    __weak typeof(self) weakSelf = self;
    [self writeLocalCSVWithFileName:databasePath
                        headerNames:@"开始时间,结束时间,间隔,价格,估价,服务器,门派,链接\n"
                         modelArray:[self latestTotalShowedHistoryList]
                     andStringBlock:^NSString *(CBGListModel * model1, CBGListModel * model2) {
                         NSString * subStr = [weakSelf inputModelDetailStringForFirstModel:model1
                                                                               secondModel:model2];
                         return subStr;
                     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startShowDetailLocalDBPlistWithFilePath:databasePath];
    });

}
-(NSString *)inputModelDetailStringForFirstModel:(CBGListModel *)model1 secondModel:(CBGListModel *)model2
{
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serNameDic = total.serverNameDic;
    NSNumber * serId = [NSNumber numberWithInteger:model1.server_id];
    NSString * serverName = [serNameDic objectForKey:serId];
    
    NSString * soldTime = model1.sell_sold_time?:@"无";
    if([model1.sell_back_time length] > 0){
        soldTime = model1.sell_back_time;
    }
    
    
    NSString *input = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@\n",
                       model1.sell_create_time,
                       soldTime,
                       [NSString stringWithFormat:@"%ld",model1.sell_space],
                       [NSString stringWithFormat:@"%ld",model1.equip_price/100],
                       [NSString stringWithFormat:@"%ld",model1.plan_total_price],
                       serverName,
                       model1.equip_school_name,
                       model1.detailWebUrl,
                       nil];
    return input;
}

-(void)startShowDetailLocalDBPlistWithFilePath:(NSString *)filePath
{
    if (!filePath)
    {
        return;
    }
    
    //创建实例
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    self.docVc = documentController;
    
    //设置代理
    documentController.delegate = self;
    BOOL canOpen = [documentController presentOpenInMenuFromRect:CGRectZero
                                                          inView:self.view
                                                        animated:YES];
    if (!canOpen)
    {
        NSLog(@"沒有程序可以打開要分享的文件");
    }
}
#pragma mark - UIDocumentFile
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

//点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    
}
#pragma mark -


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
