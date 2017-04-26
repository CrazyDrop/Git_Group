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
                            @""
                            ];
        _combineArr = names;
    }
    return _combineArr;
}

- (void)viewDidLoad {
    self.viewTtle = @"错误列表";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_Server;
    self.orderStyle = CBGStaticOrderShowStyle_School;
    
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * orderSnArr = @[
                             @"60_1493129170_60644993",
                             @"60_1493128891_60644992",
                             @"60_1493123430_60644981",
                             @"60_1493022191_60644887",
                             @"60_1492573791_60644366",
                             @"1316_1492340623_1316256359",
                             @"60_1492270530_60643953",
                             @"60_1492252047_60643920",
                             @"60_1492092055_60643766",
                             @"60_1491912284_60643516",
                             @"60_1491911867_60643514",
                             @"60_1491911603_60643513",
                             @"1316_1491895608_1316255614",
                             @"1316_1491571555_1316254901",
                             @"60_1491564675_60643057",
                             @"60_1491319517_60642682",
                             @"1316_1491316615_1316254306",
                             @"60_1491198464_60642455",
                             @"280_1491157052_281885144",
                             @"1316_1491137608_1316253898",
                             @"60_1491041876_60642192",
                             @"60_1490959281_60642064",
                             @"60_1490858922_60641895",
                             @"1265_1484233917_1265862515",
                             @"60_1490716780_60641710",
                             @"1316_1490691181_1316252890",
                             @"60_1480404387_60624841",
                             @"1316_1490364166_1316252155",
                             @"60_1490361412_60641101",
                             @"330_1490198728_331479340",
                             @"60_1490197053_60640926",
                             @"60_1490012062_60640614",
                             @"60_1489989091_60640568",
                             @"60_1489982099_60640566",
                             @"1316_1489978292_1316251314",
                             @"482_1489853079_483936717",
                             @"60_1489846567_60640383",
                             @"60_1489814122_60640327",
                             @"60_1489068080_60639061",
                             @"60_1488284600_60637743",
                             @"1316_1487757546_1316246334",
                             @"60_1487604290_60636085",
                             @"60_1487571357_60635937",
                             @"60_1487426075_60635615",
                             @"60_1487424512_60635605",
                             @"60_1486712718_60633991",
                             @"60_1484669869_60631316",
                             @"60_1479633568_60623624",
                             @"1316_1476332632_1316214482",
                             @""
                             ];
    
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
    NSArray * orderSnArr = @[
                             @"60_1493129170_60644993",
                             @"60_1493128891_60644992",
                             @"60_1493123430_60644981",
                             @"60_1493022191_60644887",
                             @"60_1492573791_60644366",
                             @"1316_1492340623_1316256359",
                             @"60_1492270530_60643953",
                             @"60_1492252047_60643920",
                             @"60_1492092055_60643766",
                             @"60_1491912284_60643516",
                             @"60_1491911867_60643514",
                             @"60_1491911603_60643513",
                             @"1316_1491895608_1316255614",
                             @"1316_1491571555_1316254901",
                             @"60_1491564675_60643057",
                             @"60_1491319517_60642682",
                             @"1316_1491316615_1316254306",
                             @"60_1491198464_60642455",
                             @"280_1491157052_281885144",
                             @"1316_1491137608_1316253898",
                             @"60_1491041876_60642192",
                             @"60_1490959281_60642064",
                             @"60_1490858922_60641895",
                             @"1265_1484233917_1265862515",
                             @"60_1490716780_60641710",
                             @"1316_1490691181_1316252890",
                             @"60_1480404387_60624841",
                             @"1316_1490364166_1316252155",
                             @"60_1490361412_60641101",
                             @"330_1490198728_331479340",
                             @"60_1490197053_60640926",
                             @"60_1490012062_60640614",
                             @"60_1489989091_60640568",
                             @"60_1489982099_60640566",
                             @"1316_1489978292_1316251314",
                             @"482_1489853079_483936717",
                             @"60_1489846567_60640383",
                             @"60_1489814122_60640327",
                             @"60_1489068080_60639061",
                             @"60_1488284600_60637743",
                             @"1316_1487757546_1316246334",
                             @"60_1487604290_60636085",
                             @"60_1487571357_60635937",
                             @"60_1487426075_60635615",
                             @"60_1487424512_60635605",
                             @"60_1486712718_60633991",
                             @"60_1484669869_60631316",
                             @"60_1479633568_60623624",
                             @"1316_1476332632_1316214482",
                             @""
                             ];
    
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
                eveList.dbStyle = CBGLocalDataBaseListUpdateStyle_CopyRefresh;
                eveList.server_id = [[preArr objectAtIndex:latestIndex] integerValue];
                [updateArr addObject:eveList];
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
