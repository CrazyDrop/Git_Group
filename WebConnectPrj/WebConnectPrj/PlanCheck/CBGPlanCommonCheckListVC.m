//
//  CBGPlanCommonCheckListVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanCommonCheckListVC.h"
#import "ZALocationLocalModel.h"
@interface CBGPlanCommonCheckListVC ()
@property (nonatomic,strong) NSArray * combineArr;
@property (nonatomic,strong) NSArray * planArr;
@end

@implementation CBGPlanCommonCheckListVC
-(NSArray * )combineArr
{
    if(!_combineArr)
    {
        NSArray * names = @[
                            @"清晖园、白云山		",
                            @"玉海楼、烟雨江南	",
                            @"虎丘山、夫子庙		",
                            @"汇龙潭、东方明珠	",
                            @"风筝之都、青岛栈桥	",
                            @"曲院风荷、西湖龙井	",
                            @"园博园、大观园		",
                            @"白帝城、嘉陵江		",
                            @"琅琊台、孙子兵法	",
                            @"十里霓虹、五道口	",
                            @"黄浦江、逍遥三届	",
                            @"凌云殿、八闽游		",
                            @"天马山、晚芳亭",
                            @"菩提岛、燕塞湖",
                            @"丹山赤水、文澜阁",
                            @"卧龙岗、南阳府",
                            @"胶东半岛、威海卫",
                            @""
                            ];
        _combineArr = names;
    }
    return _combineArr;
}
-(NSArray *)planArr
{
    if(!_planArr)
    {
        NSArray * orderSnArr = @[
                                 @"131_1503923729_131794456",
                                 @"131_1501116053_131788983",
                                 @"407_1503948225_407653688",
                                 @"1191_1503930640_1192421317",
                                 @"1248_1503755988_1248773915",
                                 @"1249_1503928466_1249566181",
                                 @"567_1503932534_567916782",
                                 @"37_1503061167_37544176",
                                 @"1248_1503887224_1248774682",
                                 @"1234_1503883242_1235196310",
                                 @"37_1503932417_37545788",
                                 @"37_1503054260_37544159",
                                 @"131_1503367529_131793380",
                                 @""
                                 ];
        _planArr = orderSnArr;
    }
    return _planArr;
}

- (void)viewDidLoad {
    self.viewTtle = @"合服异常";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_Server;
    self.orderStyle = CBGStaticOrderShowStyle_School;
    
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * orderSnArr = self.planArr;
    
    NSMutableArray * updateArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [orderSnArr count] ; index ++)
    {
        NSString * eveSn = [orderSnArr objectAtIndex:index];
        NSArray * arr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveSn];
        if([arr count] > 0)
        {
            [updateArr addObjectsFromArray:arr];
        }
    }
    self.dbHistoryArr = updateArr;
    [self refreshLatestShowTableView];
    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"切换"];//按钮点击时，从全部库表选取
    
    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(index * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
-(void)refreshTotalServerIdRefresh
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    
    NSArray * serverArr = [dbManager localServerNameAndIDTotalDictionaryArray];
    NSMutableDictionary * serNameDic = [NSMutableDictionary dictionary];
    for (NSDictionary * eveDic in serverArr )
    {
        NSString * key = [eveDic objectForKey:@"SERVER_NAME"];
        NSArray * subArr = [key componentsSeparatedByString:@"-"];
        if([subArr count] > 1)
        {
            key = [subArr lastObject];
            NSString * obj = [eveDic objectForKey:@"SERVER_ID"];
            [serNameDic setObject:obj forKey:key];
        }
    }
    
    //查找出要替换的serverID
    NSMutableArray * preArr = [NSMutableArray array];
    NSMutableArray * latestArr = [NSMutableArray array];
    
    
    NSArray * names = self.combineArr;
    for (NSInteger index = 0;index <  [names count];index ++ )
    {
        NSString * subStr = [names objectAtIndex:index];
        NSArray * subArr = [subStr componentsSeparatedByString:@"、"];
        if([subArr count] > 1)
        {
            NSString * preStr = [subArr objectAtIndex:0];
            NSString * nextStr = [subArr objectAtIndex:1];
            
            NSString * preName = [preStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString * nextName = [nextStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            preName = [preName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            nextName = [nextName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            
            NSString * preId = [serNameDic objectForKey:preName];
            NSString * nextId = [serNameDic objectForKey:nextName];
            if(preId && nextId)
            {
                [preArr addObject:preId];
                [latestArr addObject:nextId];
            }
        }
    }
    
    
    for (NSInteger index = 0;index < [preArr count] ;index ++ )
    {
        NSString * preId = [preArr objectAtIndex:index];
        NSString * nextId = [latestArr objectAtIndex:index];
//        [dbManager refreshLocalSaveEquipHistoryModelServerId:preId withLatest:nextId];
    }
    
    [self ingoreUpdateListWithPreIdArr:preArr andLastestArr:latestArr];
    
    
    NSArray * arr = [dbManager localSaveEquipHistoryModelListTotal];
    if(arr){
        [DZUtils noticeCustomerWithShowText:@"合服修改结束"];
    }
}

-(void)ingoreUpdateListWithPreIdArr:(NSArray *)preArr andLastestArr:(NSArray *)latestArr
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * orderSnArr = self.planArr;
    
    NSMutableArray * updateArr = [NSMutableArray array];
    
    for (NSInteger index = 0;index < [orderSnArr count] ; index ++)
    {
        NSString * eveSn = [orderSnArr objectAtIndex:index];
        NSArray * arr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveSn];
        if([arr count] > 0)
        {
            CBGListModel * eveList = [arr firstObject];
            NSInteger serverId = eveList.server_id;
            NSInteger latestIndex = [latestArr indexOfObject:[NSNumber numberWithInteger:serverId]];
            if(latestIndex != NSNotFound)
            {
//                eveList.dbStyle = CBGLocalDataBaseListUpdateStyle_CopyRefresh;
//                eveList.server_id = [[preArr objectAtIndex:latestIndex] integerValue];
//                [updateArr addObject:eveList];
            }else
            {
                latestIndex = [preArr indexOfObject:[NSNumber numberWithInteger:serverId]];
                if(latestIndex != NSNotFound)
                {
                    eveList.dbStyle = CBGLocalDataBaseListUpdateStyle_CopyRefresh;
                    eveList.server_id = [[latestArr objectAtIndex:latestIndex] integerValue];
                    [updateArr addObject:eveList];
                }
            }
            
        }
    }
    
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateArr];
}

-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    [self refreshTotalServerIdRefresh];
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
