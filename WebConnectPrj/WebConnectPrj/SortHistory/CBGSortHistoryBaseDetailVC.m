//
//  CBGSortHistoryBaseDetailVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseDetailVC.h"
#import "EquipDetailArrayRequestModel.h"
#import "CBGListModel.h"
#import "EquipModel.h"
#import "ZALocationLocalModel.h"
#import "ZACBGDetailWebVC.h"
#import "RefreshListCell.h"
#import "CBGMaxHistoryListRefreshVC.h"
@interface CBGSortHistoryBaseDetailVC ()
{
    
}
@property (nonatomic, strong) NSArray * requestModels;
@property (nonatomic, strong) UILabel * numLbl;

@end

@implementation CBGSortHistoryBaseDetailVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.viewTtle = @"历史";
        self.rightTitle = @"筛选";
        self.showRightBtn = NO;
    }
    return self;
}


- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);

    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UILabel * aLbl = nil;
    CGFloat btnStartY = aHeight;
    
    NSString * name = @"数量";
    aLbl = [[UILabel alloc] init];
    aLbl.text = name;
    aLbl.frame = CGRectMake(1 * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
    aLbl.textColor = [UIColor redColor];
    aLbl.backgroundColor = [UIColor clearColor];
    [bgView addSubview:aLbl];
    aLbl.textAlignment = NSTextAlignmentCenter;
    self.numLbl = aLbl;
    aLbl.hidden = YES;
}
-(void)refreshNumberLblWithLatestNum:(NSInteger)number
{
    self.numLbl.hidden = NO;
    self.numLbl.text = [NSString stringWithFormat:@"数量:%ld",(long)number];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    [model cancel];
    [model removeSignalResponder:self];
    _detailListReqModel = nil;
}
#pragma mark - DetailArrayRequest
//刷新最新的数据，补全是否售出   更新主表
-(void)startLatestDetailListRequestForShowedCBGListArr:(NSArray *)array
{
    //启动批量网络请求，刷新回传数据，补充库表
    //缓存当前数据，触发对应请求
    if([array count] > 300)
    {
        CBGMaxHistoryListRefreshVC * max  = [[CBGMaxHistoryListRefreshVC alloc] init];
        max.startArr = [NSArray arrayWithArray:array];
        [[self rootNavigationController] pushViewController:max animated:YES];
        return;
    }
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(model.executing)
    {
        return;
    }
    NSMutableArray * models = [NSMutableArray array];
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        CBGListModel * eveModel = [array objectAtIndex:index];
        if(!eveModel.errored)
        {
            [models addObject:eveModel];
        }
    }
    
    self.requestModels = models;
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0;index <[models count] ;index ++) {
        CBGListModel * eveModel = [models objectAtIndex:index];
        NSString * eveUrl = eveModel.detailDataUrl;
        [urls addObject:eveUrl];
    }
    
    
    [_detailListReqModel removeSignalResponder:self];
    [_detailListReqModel cancel];
    _detailListReqModel = nil;
    
    [self startEquipDetailAllRequestWithUrls:urls];
}
-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
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
    [self showLoading];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //进行存储操作、展示
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
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
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * serverArr = [manager localServerNameAndIDTotalDictionaryArray];
    NSMutableArray * idNumArr = [NSMutableArray array];
    for (NSDictionary * eveDic in serverArr )
    {
        [idNumArr addObject:[eveDic objectForKey:@"SERVER_ID"]];
    }
    
    //有改变的dic
    NSMutableDictionary * serverAddDic = [NSMutableDictionary dictionary];
    
    NSMutableArray * updateModels = [NSMutableArray array];
    NSMutableArray * errorModels = [NSMutableArray array];
    NSArray * models = self.requestModels;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }
        
        CBGListModel * obj = [models objectAtIndex:index];
        obj.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            if(detailEve.game_ordersn)
            {
                [obj refreshCBGListDataModelWithDetaiEquipModel:detailEve];
            }else
            {
                obj.errored = YES;
                obj.equip_more_append = [obj createLatestMoreAppendString];
            }
            [updateModels addObject:obj];
        }else{
            [errorModels addObject:obj];
        }
        
        if([detailEve isKindOfClass:[EquipModel class]])
        {
            NSNumber * idKeyNum = detailEve.serverid;
            if(!idKeyNum)
            {
                continue;
            }
            if(![idNumArr containsObject:idKeyNum] && ![serverAddDic objectForKey:idKeyNum])
            {
                NSString * serverName = [NSString stringWithFormat:@"%@-%@",detailEve.area_name,detailEve.server_name];
                NSNumber * tagNum = [NSNumber numberWithInt:0];
                
                NSDictionary * serverDic = @{@"SERVER_NAME":serverName,
                                             @"SERVER_ID":idKeyNum,
                                             @"SERVER_TEST":tagNum};
                [serverAddDic setObject:serverDic forKey:idKeyNum];
            }
        }
    }
    
    NSLog(@"历史列表刷新 %lu error%ld",(unsigned long)[updateModels count],[errorModels count]);
    
    [manager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateModels];
    if([serverAddDic count] > 0 ){
        NSArray * servers = [serverAddDic allValues];
        [manager localSaveServerNameAndIDDictionaryArray:servers];
    }
    
    [self finishDetailListRequestWithFinishedCBGListArray:updateModels];
    [self finishDetailListRequestWithErrorCBGListArray:errorModels];
}

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    
}
-(void)finishDetailListRequestWithErrorCBGListArray:(NSArray *)array
{
    
}
#pragma mark -
#pragma mark HistoryTableDelegate


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
