//
//  ZWPanicMaxCombineUpdateVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicMaxCombineUpdateVC.h"
#import "EquipDetailArrayRequestModel.h"
#import "Equip_listModel.h"

@interface ZWPanicMaxCombineUpdateVC ()
{
    NSMutableArray * detailArr;
}
@property (nonatomic, strong) NSArray * baseArr;
@end

@implementation ZWPanicMaxCombineUpdateVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        detailArr = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(panicCombineUpdateAddMoreDetailRefreshNoti:)
                                                     name:NOTIFICATION_ADD_REFRESH_WEBDETAIL_STATE
                                                   object:nil];
        
        
    }
    return self;
}
-(void)panicCombineUpdateAddMoreDetailRefreshNoti:(NSNotification *)noti
{
    NSString * keyStr = (NSString *)[noti object];
    @synchronized (detailArr)
    {
        if(![detailArr containsObject:keyStr])
        {
            [detailArr addObject:keyStr];
        }
    }
}
-(void)startPanicDetailArrayRequestRightNow
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipDetailArrayRequestModel * listRequest = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(listRequest.executing) return;

    //以当前的detailArr  创建对应的model
    NSMutableArray * base = [NSMutableArray array];
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0;index < [detailArr count] ;index ++ )
    {
        NSString * eveBase = [detailArr objectAtIndex:index];
        NSArray * arr = [eveBase componentsSeparatedByString:@"|"];
        if([arr count] == 2)
        {
            Equip_listModel * eveList = [[Equip_listModel alloc] init];
            eveList.game_ordersn = [arr firstObject];
            eveList.serverid = [NSNumber numberWithInteger:[[arr lastObject] integerValue]];
            
            [urls addObject:[eveList detailDataUrl]];
            [base addObject:eveList];
        }
    }
    self.baseArr = base;
    [self startEquipDetailAllRequestWithUrls:urls];
}

-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    NSLog(@"%s",__FUNCTION__);
    
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
}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    NSInteger errorNum = 0;
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            errorNum ++;
            [detailModels addObject:[NSNull null]];
        }
    }
    
    NSArray * list = self.baseArr;
    NSMutableArray * refreshArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [list count] ;index ++ )
    {
        Equip_listModel * eveList = [list objectAtIndex:index];
        if([detailModels count] > index)
        {
            EquipModel * equip = [detailModels objectAtIndex:index];
            if([equip isKindOfClass:[EquipModel class]])
            {
                eveList.equipModel = equip;
                if(equip.equipState != CBGEquipRoleState_unSelling)
                {
                    [refreshArr addObject:eveList];
                }
            }
        }
    }
    
    if([refreshArr count] > 0)
    {
        for (NSInteger index = 0;index < [refreshArr count] ;index ++ )
        {
            Equip_listModel * eveList = [refreshArr objectAtIndex:index];
            NSString * removeStr = [eveList listCombineIdfa];
            @synchronized (detailArr)
            {
                if([detailArr containsObject:removeStr])
                {
                    [detailArr removeObject:removeStr];
                }
            }
            [self finishDetailRefreshPostNotificationWithBaseDetailModel:eveList];
        }
    }
    
    @synchronized (detailArr)
    {
        
    }
    
}
-(void)finishDetailRefreshPostNotificationWithBaseDetailModel:(Equip_listModel *)listModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                        object:listModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
