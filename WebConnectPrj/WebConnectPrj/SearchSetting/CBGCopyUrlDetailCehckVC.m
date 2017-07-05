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
#import "ZWPanicMaxCombinedVC.h"
#import "CBGWebDBDownModel.h"
#import "CBGWebDBUploadModel.h"
#import "CBGWebDBRemoveModel.h"


#define BlueSettingDebugAddNum 100
@interface CBGCopyUrlDetailCehckVC ()
{
    Equip_listModel * baseList;
    BaseRequestModel * _dbDataModel;
    BaseRequestModel * _dbRemoveModel;
    BaseRequestModel * _dbUploadModel;
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
-(NSString *)functionNamesForDetailFunctionStyle:(CBGDetailTestURLFunctionStyle)style
{
    NSString * name = @"未知";
    switch (style)
    {
        case CBGDetailTestURLFunctionStyle_CheckDetail:
        {
            name = @"查看详情";
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_WebShow:
        {
            name = @"WEB信息";
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_LocalSave:
        {
            name = @"保存";//适用于新数据上架频次较低，无人工查看的情况
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_LocalRemove:
        {
            name = @"删除";
        }
            break;
        case CBGDetailTestURLFunctionStyle_NoticeAdd:
        {
            name = @"添加关注";//适用于新数据上架频次较低，无人工查看的情况
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_NoticeRemove:
        {
            name = @"取消关注";
        }
            break;

            
        case CBGDetailTestURLFunctionStyle_StateIngore:
        {
            name = @"状态-忽略";
        }
            break;
        case CBGDetailTestURLFunctionStyle_StateNormal:
        {
            name = @"状态-正常";
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_DBClear:
        {
            name = @"库表清理";
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_TotalHistory:
        {
            name = @"全部历史(旧)";
        }
            break;
        case CBGDetailTestURLFunctionStyle_NearHistory:
        {
            name = @"相关历史";
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_ServerCombine:
        {
            name = @"合服修改";
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_WebRefresh:
        {
            name = @"WEB更新";
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebInput:
        {
            name = @"WEB写入";
        }
            break;
        case CBGDetailTestURLFunctionStyle_ReadRemove:
        {
            name = @"删除READ";
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebUpload:
        {
            name = @"上传WEB";
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebRemove:
        {
            name = @"WEB移除";
        }
            break;
            
            
        default:
            break;
    }
    return name;
}

- (void)viewDidLoad {
    
        //copy信息抓去，解析，展示
        self.showLeftBtn = YES;
        self.viewTtle = @"查询";
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
    
        //增加监听
        //    CBGDetailWebView * detail = [[CBGDetailWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        //    [self.view addSubview:detail];

        NSArray * testFuncArr = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_CheckDetail],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_WebShow],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_LocalSave],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_LocalRemove],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_NoticeAdd],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_NoticeRemove],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_StateIngore],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_StateNormal],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_DBClear],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_TotalHistory],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_NearHistory],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_ServerCombine],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_WebRefresh],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_WebInput],
                                 
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_ReadRemove],
                                 [NSNumber numberWithInt:CBGDetailTestURLFunctionStyle_WebUpload],
                                 

                                 
                                 nil];
        
    UIView * bgView = self.view;
    for(NSInteger index = 0 ;index < [testFuncArr count]; index ++)
    {
        NSNumber * num = [testFuncArr objectAtIndex:index];
        NSString * title = [self functionNamesForDetailFunctionStyle:[num integerValue]];
        UIButton * btn = [self customTestButtonForIndex: index andMoreTag:[num integerValue]];
        [btn setTitle:title forState:UIControlStateNormal];
        [bgView addSubview:btn];
    }
    
    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 80)];
    [bgView addSubview:txt];
    self.textView = txt;
}
-(UIButton * )customTestButtonForIndex:(NSInteger)indexNum andMoreTag:(NSInteger)tag
{
    NSInteger lineNum = indexNum/2;
    NSInteger rowNum = indexNum%2;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag + BlueSettingDebugAddNum;
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
        case CBGDetailTestURLFunctionStyle_CheckDetail:
        {
            [self tapedOnCheckDetailRequestTxtBtn:nil];
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebShow:
        {
            [self tapedOnCheckDetailTxtBtn:nil];
        }
            break;

        case CBGDetailTestURLFunctionStyle_LocalSave:{
            [self tapedOnLocalSaveDetailModelBtn:nil];
        }
            break;
        case CBGDetailTestURLFunctionStyle_LocalRemove:
        {
            [self tapedOnRemoveLatestSelectedModelBtn:nil];
        }
            break;
        case CBGDetailTestURLFunctionStyle_NoticeAdd:
        {
            [self refreshLatestNoticeListWithOrderSNAdd:YES];
//            [self refreshLocalSaveIngoreStatusWithLatest:1];
        }
            break;
            
        case CBGDetailTestURLFunctionStyle_NoticeRemove:
        {
            [self refreshLatestNoticeListWithOrderSNAdd:NO];
//            [self refreshLocalSaveIngoreStatusWithLatest:2];
        }
            break;

        case CBGDetailTestURLFunctionStyle_StateIngore:
        {
            [self refreshLocalSaveIngoreStatusWithLatest:1];
        }
            break;

        case CBGDetailTestURLFunctionStyle_StateNormal:
        {
            [self refreshLocalSaveIngoreStatusWithLatest:2];
        }
            break;

        case CBGDetailTestURLFunctionStyle_DBClear:
        {
            ZALocationLocalModelManager * dbManager =[ZALocationLocalModelManager sharedInstance];
            [dbManager updateFavAndIngoreStateForMaxedPlanRateListAndClearChange];
            
            NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotal];
            [DZUtils noticeCustomerWithShowText:@"库表操作结束"];

        }
            break;
        case CBGDetailTestURLFunctionStyle_TotalHistory:
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
        case CBGDetailTestURLFunctionStyle_NearHistory:
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
        case CBGDetailTestURLFunctionStyle_ServerCombine:
        {
            [self refreshTotalServerIdRefresh];
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebRefresh:
        {
            [self startActivityWebRequest];
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebInput:
        {
            [self showLoading];
            self.titleV.text = @"开始写入";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshLocalUpdateWithWEBReadDB];
                [self hideLoading];
            });
        }
            break;
        case CBGDetailTestURLFunctionStyle_ReadRemove:
        {
            NSError * error = [self clearCurrentLocalReadDB];
            NSString * tagStr = error?@"删除失败":@"删除成功";
            [DZUtils noticeCustomerWithShowText:tagStr];
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebUpload:
        {//先执行删除，后执行上传
//            [self refreshWebDatabaseWithLatestSaveDB];
            [self removeWebDatabaseForUploadPrepare];
        }
            break;
        case CBGDetailTestURLFunctionStyle_WebRemove:
        {
            [self removeWebDatabaseForUploadPrepare];
        }
    }
}
-(void)refreshWebDatabaseWithLatestSaveDB
{
    [self startActivityWebRequestForUpload];
}
-(void)removeWebDatabaseForUploadPrepare
{
    [self startActivityWebRequestForRemove];
}

-(void)refreshLocalUpdateWithWEBReadDB
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
    self.titleV.text = @"写入结束";
}
#pragma mark - CBGWebDBDownModel
-(void)startUpdateLocalReadDBFunction
{
    NSError * error = [self clearCurrentLocalReadDB];
    if(error){
        [DZUtils noticeCustomerWithShowText:@"删除失败"];
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startActivityWebRequest];
    });
}
-(NSError *)clearCurrentLocalReadDB
{
    NSString * path = [ZALocationLocalModelManager localSaveReadDBPath];
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if([fm fileExistsAtPath:path])
    {
        if([fm removeItemAtPath:path error:&error])
        {
            
        }
        else
        {
            NSLog(@"Failed to remove directory %@,error:%@",path,error);
        }
    }
    return error;
}
-(void)startActivityWebRequest
{
    CBGWebDBDownModel * model = (CBGWebDBDownModel *) _dbDataModel;
    if(!model){
        model = [[CBGWebDBDownModel alloc] init];
        [model addSignalResponder:self];
        _dbDataModel = model;
    }
    [model sendRequest];
}

handleSignal( CBGWebDBDownModel, requestError )
{
    [self hideLoading];
    [DZUtils noticeCustomerWithShowText:@"下载失败"];

}
handleSignal( CBGWebDBDownModel, requestLoading )
{
    [self showLoading];
}
handleSignal( CBGWebDBDownModel, requestLoaded )
{
    [self hideLoading];
//    if([DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:nil]){
//        
//    }
    [DZUtils noticeCustomerWithShowText:@"下载成功"];
    self.titleV.text = @"开始写入";
//    [self refreshLocalUpdateWithWEBReadDB];
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager localCopySoldOutDataToPartDataBase];
}
#pragma mark - CBGWebDBUploadModel
-(void)startActivityWebRequestForUpload
{
    CBGWebDBUploadModel * model = (CBGWebDBUploadModel *) _dbUploadModel;
    if(!model){
        model = [[CBGWebDBUploadModel alloc] init];
        [model addSignalResponder:self];
        _dbUploadModel = model;
    }
    [model sendRequest];
}

handleSignal( CBGWebDBUploadModel, requestError )
{
    [self hideLoading];
    [DZUtils noticeCustomerWithShowText:@"上传失败"];
    self.titleV.text = @"上传失败";

}
handleSignal( CBGWebDBUploadModel, requestLoading )
{
    [self showLoading];
}
handleSignal( CBGWebDBUploadModel, requestLoaded )
{
    [self hideLoading];
    //    if([DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:nil]){
    //
    //    }
    [DZUtils noticeCustomerWithShowText:@"上传成功"];
    self.titleV.text = @"上传成功";

}
#pragma mark - CBGWebDBRemoveModel
-(void)startActivityWebRequestForRemove
{
    CBGWebDBRemoveModel * model = (CBGWebDBRemoveModel *) _dbRemoveModel;
    if(!model){
        model = [[CBGWebDBRemoveModel alloc] init];
        [model addSignalResponder:self];
        _dbRemoveModel = model;
    }
    [model sendRequest];
}

handleSignal( CBGWebDBRemoveModel, requestError )
{
    [self hideLoading];
    [DZUtils noticeCustomerWithShowText:@"删除失败"];
    
}
handleSignal( CBGWebDBRemoveModel, requestLoading )
{
    [self showLoading];
}
handleSignal( CBGWebDBRemoveModel, requestLoaded )
{
    [self hideLoading];
    //    if([DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:nil]){
    //
    //    }
    [DZUtils noticeCustomerWithShowText:@"删除成功"];
    [self refreshWebDatabaseWithLatestSaveDB];
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
-(void)refreshLatestNoticeListWithOrderSNAdd:(BOOL)add
{
    //add为yes则添加 ，同时库表保存  为NO删除
    NSString * orderSn = baseList.game_ordersn;
    if(!orderSn)
    {
        [DZUtils noticeCustomerWithShowText:@"详情不存在"];
        return;
    }
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    //异常判定，库表操作
    if(add)
    {
        if(!self.detailModel)
        {
            [DZUtils noticeCustomerWithShowText:@"详情不存在"];
            return;
        }
        //进行
        [self tapedOnLocalSaveDetailModelBtn:nil];
    }
    
    NSString * history = total.specialHistory;
    NSArray * specialArr = [history componentsSeparatedByString:@"|"];
    NSMutableArray * editArr = [NSMutableArray arrayWithArray:specialArr];
    if(![editArr containsObject:orderSn] && add)
    {
        [editArr addObject:orderSn];
    }else if([editArr containsObject:orderSn] && !add){
        [editArr removeObject:orderSn];
    }
    NSString * comHistory = [editArr componentsJoinedByString:@"|"];
    total.specialHistory = comHistory;
    [total localSave];
    
    
    [DZUtils noticeCustomerWithShowText:@"操作成功"];
}
-(void)tapedOnRemoveLatestSelectedModelBtn:(id)sender
{
    CBGListModel * cbgList = baseList.listSaveModel;
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager deleteLocalSaveEquipHistoryObjectWithCBGModelOrderSN:cbgList.game_ordersn];
    
    
    [ZWPanicMaxCombinedVC updateCacheArrayListWithRemove:cbgList.game_ordersn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
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
    cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshStatus;
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
        CBGListModel * cbgList = [[self class] listModelBaseDataFromLatestEquipUrlStr:detailCopy];
        baseList.serverid = [NSNumber numberWithInteger:cbgList.server_id];
        baseList.game_ordersn = cbgList.game_ordersn;
        
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
+(CBGListModel *)listModelBaseDataFromLatestEquipUrlStr:(NSString *)detailCopy
{
    CBGListModel * list = [[CBGListModel alloc] init];
    
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
                
                list.server_id = [serverId intValue];
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
                list.game_ordersn = realSN;
            }
        }
    }
    return list;
}

+(NSString *)realStringFromSubStringText:(NSString *)serverId
{
    serverId = [serverId stringByReplacingOccurrencesOfString:@" " withString:@""];
    serverId = [serverId stringByReplacingOccurrencesOfString:@"%20" withString:@""];
    //后续数字

    return serverId;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
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


//- (void)upLoad
//{
//    NSString *token = [[self class] token];
//    
//    NSString * url = @"http://61.162.231.217:80/";
//    url = @"http://upload-z2.qiniu.com";
//    NSString * domain = @"upload-z2.qiniu.com";
//    
//    NSString  * access = [[self class] getAccess];
//    NSString * agent = [[self class] getUserAgent:access];
//    
//    NSString * path = [ZALocationLocalModelManager localSaveTotalDBPath];
//    NSData * data = [NSData dataWithContentsOfFile:path];
////    data = [@"hahaha" dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSString * key = @"2017test1122.xlsx";
//    NSString * mime = @"application/octet-stream";
//    
//    NSDictionary *dic = @{
//                          @"key" :key,
//                          @"token":token
//                          };
//    
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
//                                                                                        URLString:url
//                                                                                       parameters:dic
//                                                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                                                                            [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:mime];
//                                                                        }
//                                                                                            error:nil];
//    
////    request.URL = [NSURL URLWithString:url];
//    [request setValue:domain forHTTPHeaderField:@"Host"];
//    [request setValue:agent forHTTPHeaderField:@"User-Agent"];
//    [request setValue:nil forHTTPHeaderField:@"Accept-Language"];
//    
//
//    NSURLSessionUploadTask * uploadTask = [manager uploadTaskWithStreamedRequest:request
//                                                                  progress:nil
//                                                         completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                                             if(error){
//                                                                 [DZUtils noticeCustomerWithShowText:@"网络请求失败"];
//                                                             }else
//                                                             {
//                                                                 [DZUtils noticeCustomerWithShowText:@"上传结束"];
//                                                             }
//                                                         }];
//    [uploadTask resume];
//
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
