//
//  CBGCopyUrlDetailCehckVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/27.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGCopyUrlDetailCehckVC.h"
#import "ZACBGDetailWebVC.h"
#import "EquipDetailArrayRequestModel.h"
#import "ZALocationLocalModel.h"
#import "ZWHistoryListController.h"
#import "CBGNearHistoryVC.h"
#define BlueSettingDebugAddNum 100
@interface CBGCopyUrlDetailCehckVC ()
{
    Equip_listModel * baseList;
}
@property (nonatomic,strong) UITextView * textView;
@property (nonatomic,strong) NSArray * combineArr;
@property (nonatomic,strong) EquipModel * detailModel;
@end

@implementation CBGCopyUrlDetailCehckVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        baseList = [[Equip_listModel alloc] init];
        self.viewTtle = @"查询";
        
//        self.showRightBtn = YES;
//        self.rightTitle = @"保存";
    }
    return self;
}

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
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //copy信息抓去，解析，展示
    
    NSArray * titles = [NSArray arrayWithObjects:
                        @"查看详情",
                        @"WEB信息",
                        
                        @"保存",//进行数据存储
                        @"删除",//删除
                        
                        @"状态-收藏",//进行状态
                        @"状态-忽略",
                        @"状态-正常",
                        @"状态-购买",
                        
                        @"库表清理",
                        @"全部历史(旧)",
                        @"相关历史",
                        @"合服修改",
                        nil];
    
    UIView * bgView = self.view;
    for(NSInteger index = 0 ;index < [titles count]; index ++)
    {
        NSString * title = [titles objectAtIndex:index];
        UIButton * btn = [self customTestButtonForIndex: index];
        [btn setTitle:title forState:UIControlStateNormal];
        [bgView addSubview:btn];
    }

    
    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 80)];
    [bgView addSubview:txt];
    self.textView = txt;
    
    
}
-(UIButton * )customTestButtonForIndex:(NSInteger)indexNum
{
    NSInteger lineNum = indexNum/2;
    NSInteger rowNum = indexNum%2;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = indexNum + BlueSettingDebugAddNum;
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
    NSInteger indexNum = btn.tag - BlueSettingDebugAddNum;
    
    [self debugDetailTestWithIndexNum:indexNum andTitle:btn.titleLabel.text];
}
-(void)debugDetailTestWithIndexNum:(NSInteger)indexNum andTitle:(NSString *)title
{
    NSLog(@"%s %@",__FUNCTION__,title);
    switch (indexNum) {
        case 0:
        {
            [self tapedOnCheckDetailRequestTxtBtn:nil];
        }
            break;
        case 1:
        {
            [self tapedOnCheckDetailTxtBtn:nil];
        }
            break;

        case 2:{
            [self tapedOnLocalSaveDetailModelBtn:nil];
        }
            break;
        case 3:
        {
            [self tapedOnRemoveLatestSelectedModelBtn:nil];
        }
            break;
        case 4:
        {
            [self refreshLocalSaveIngoreStatusWithLatest:1];
        }
            break;

        case 5:
        {
            [self refreshLocalSaveIngoreStatusWithLatest:2];
        }
            break;

        case 6:
        {
            [self refreshLocalSaveIngoreStatusWithLatest:0];
        }
            break;
        case 7:
        {
            [self refreshLocalSaveIngoreStatusWithLatest:3];
        }
            break;
        case 8:
        {
            ZALocationLocalModelManager * dbManager =[ZALocationLocalModelManager sharedInstance];
            [dbManager updateFavAndIngoreStateForMaxedPlanRateListAndClearChange];
            
            NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotal];
            [DZUtils noticeCustomerWithShowText:@"库表操作结束"];

        }
            break;
        case 9:
        {
            if(!self.detailModel)
            {
                [DZUtils noticeCustomerWithShowText:@"详情不存在"];
                return;
            }
            ZWHistoryListController * list =[[ZWHistoryListController alloc] init];
            list.selectedOrderSN = self.detailModel.game_ordersn;
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case 10:
        {
            if(!self.detailModel)
            {
                [DZUtils noticeCustomerWithShowText:@"详情不存在"];
                return;
            }
            CBGListModel * cbgList = baseList.listSaveModel;

            CBGNearHistoryVC  * list = [[CBGNearHistoryVC alloc] init];
            list.cbgList = cbgList;
            list.detailModel = self.detailModel;
            [[self rootNavigationController] pushViewController:list animated:YES];

        }
            break;
        case 11:
        {
            [self refreshTotalServerIdRefresh];
        }
            break;

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
        [dbManager refreshLocalSaveEquipHistoryModelServerId:preId withLatest:nextId];
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
                eveList.dbStyle = CBGLocalDataBaseListUpdateStyle_CopyRefresh;
                eveList.server_id = [[preArr objectAtIndex:latestIndex] integerValue];
                [updateArr addObject:eveList];
            }

        }
    }
    
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateArr];
}


-(void)tapedOnRemoveLatestSelectedModelBtn:(id)sender
{
    CBGListModel * cbgList = baseList.listSaveModel;
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager deleteLocalSaveEquipHistoryObjectWithCBGModelOrderSN:cbgList.game_ordersn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readCopyDetailOrderSNAndServerId];
}
-(void)refreshLocalSaveIngoreStatusWithLatest:(NSInteger)index
{
    if(!self.detailModel){
        [DZUtils noticeCustomerWithShowText:@"详情不存在"];
        return;
    }
    //纠正估价
    [self.detailModel.equipExtra createExtraPrice];
    
    //    return;
    //强制刷新
    [baseList refrehLocalBaseListModelWithDetail:self.detailModel];
    
    CBGListModel * cbgList = baseList.listSaveModel;
    cbgList.fav_or_ingore = index;
    cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_StatusRefresh;
    NSArray * arr = @[cbgList];
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:arr];
}

-(void)tapedOnLocalSaveDetailModelBtn:(id)sender
{
    if(!self.detailModel){
        [DZUtils noticeCustomerWithShowText:@"详情不存在"];
        return;
    }
    //纠正估价
    [self.detailModel.equipExtra createExtraPrice];
    
//    return;
    //强制刷新
    [baseList refrehLocalBaseListModelWithDetail:self.detailModel];
    
    CBGListModel * cbgList = baseList.listSaveModel;
    cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
    NSArray * arr = @[cbgList];
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:arr];

}

-(void)readCopyDetailOrderSNAndServerId
{
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    NSString * detailCopy =  board.string;
    if([detailCopy containsString:@"http"])
    {
//        http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=26&ordersn=83_1489759087_83947196&equip_refer=1
//            serverid=358&game_ordersn=447_1489589792_447864717
//        serverid=275&ordersn=250_1490584375_250940629&equip_refer=1
        NSArray * urlArr = [detailCopy componentsSeparatedByString:@"?"];
        if([urlArr count] > 1){
            detailCopy = [urlArr lastObject];
        }
        
        NSArray * detailArr = [detailCopy componentsSeparatedByString:@"&"];
        for (NSInteger index = 0; index < [detailArr count]; index ++)
        {
            NSString * detailEve = [detailArr objectAtIndex:index];
            
            NSArray * serverIdArr = @[@"serverid=",@"server_id="];
            for (NSString * eve in serverIdArr)
            {
                if([detailEve hasPrefix:eve])
                {
                    NSString * serverId = [detailEve stringByReplacingOccurrencesOfString:eve withString:@""];
                    serverId = [self realStringFromSubStringText:serverId];
                    serverId = [DZUtils detailNumberStringSubFromBottomCombineStr:serverId];

                    baseList.serverid = [NSNumber numberWithInt:[serverId intValue]];
                }
            }
            
            NSArray * orderSNArr = @[@"ordersn=",@"game_ordersn="];
            for (NSString * eve in orderSNArr)
            {
                if([detailEve hasPrefix:eve])
                {
                    NSString * orderSN = [detailEve stringByReplacingOccurrencesOfString:eve withString:@""];
                    orderSN = [self realStringFromSubStringText:orderSN];
                    //排除杂乱数字
                    if([orderSN containsString:@" "])
                    {
                        NSArray * orderArr = [orderSN componentsSeparatedByString:@" "];
                        orderSN = [orderArr firstObject];
                    }
                    
                    NSString * sub = [DZUtils detailNumberStringSubFromHeaderCombineStr:orderSN];
                    NSRange subRange = [orderSN rangeOfString:sub];
                    NSRange range = NSMakeRange(0,subRange.location + subRange.length);
                    NSString * realSN = [orderSN substringWithRange:range];
                    baseList.game_ordersn = realSN;
                }
            }
        }
        NSString * showTxt = [NSString stringWithFormat:@"serverId %@ orderSN %@",[baseList.serverid stringValue],baseList.game_ordersn];
        if(baseList.serverid && baseList.game_ordersn)
        {
            showTxt = [showTxt stringByAppendingString:@" 读取成功"];
        }
        self.textView.text = showTxt;
        
    }else if([detailCopy length] > 0)
    {
        
        NSString * subStr = [DZUtils detailNumberStringSubFromBottomCombineStr:detailCopy];
        if(subStr && [subStr integerValue] > 0)
        {
            //识别roleid
            NSString * roleId = [NSString stringWithFormat:@"%ld",[subStr integerValue]];
            NSString * showTxt = [NSString stringWithFormat:@"复制文本 %@ roleid %@ ",subStr,roleId];
            
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForRoleId:roleId];
            if([roleArr count] > 0)
            {
                showTxt = [showTxt stringByAppendingString:@" 读取成功"];
                CBGListModel * list = [roleArr firstObject];
                showTxt = [showTxt stringByAppendingFormat:@"\n serverId %ld orderSN %@ \n %@",list.server_id,list.game_ordersn,list.plan_des];
                
                baseList.serverid = [NSNumber numberWithInteger:list.server_id];
                baseList.game_ordersn = list.game_ordersn;
            }
            
            self.textView.text = showTxt;
        }
    }
}
-(NSString *)realStringFromSubStringText:(NSString *)serverId
{
    serverId = [serverId stringByReplacingOccurrencesOfString:@" " withString:@""];
    serverId = [serverId stringByReplacingOccurrencesOfString:@"%20" withString:@""];
    //后续数字

    return serverId;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_dpModel;
    [model cancel];
    [model removeSignalResponder:self];
    _dpModel = nil;
}

-(void)tapedOnCheckDetailRequestTxtBtn:(id)sender
{
    [self startRefreshDataModelRequest];
}
-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    NSArray * array = @[baseList.detailDataUrl];
    
    [self startEquipDetailAllRequestWithUrls:array];
}
-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    if(!array) return;
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_dpModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}

#pragma mark EquipDetailArrayRequestModel
handleSignal( EquipDetailArrayRequestModel, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    //进行存储操作、展示
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            [detailModels addObject:[NSNull null]];
        }
    }
    
    NSLog(@"EquipDetailArrayRequestModel %lu",(unsigned long)[detailModels count]);
    
    if([detailModels count] > 0)
    {
        EquipModel * detailEve = [detailModels lastObject];
        if([detailEve isKindOfClass:[EquipModel class]])
        {
            self.detailModel = detailEve;
            //刷新baseList 由
            [baseList refrehLocalBaseListModelWithDetail:detailEve];
            
            
            NSString * urlString = baseList.detailWebUrl;
            
            NSString * prePrice = detailEve.equipExtra.detailPrePrice;
            if(!prePrice){
                prePrice = [NSString stringWithFormat:@"估价失败 %@",detailEve.desc_sumup];
            }
            prePrice = [prePrice stringByAppendingFormat:@"\n  url:%@",urlString];
            self.textView.text = prePrice;
            
            [self copyToLocalForPasteWithString:urlString];

        }else
        {
            self.textView.text = @"请求错误";
        }
    }
}


-(void)copyToLocalForPasteWithString:(NSString *)url
{
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = url;
}
-(void)tapedOnCheckDetailTxtBtn:(id)sender
{
    //界面跳转
    ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
    detail.cbgList = [baseList listSaveModel];
    detail.detailModel = baseList.equipModel;
    [[self rootNavigationController] pushViewController:detail animated:YES];
    
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
