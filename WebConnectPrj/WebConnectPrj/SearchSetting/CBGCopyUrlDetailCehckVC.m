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
@interface CBGCopyUrlDetailCehckVC ()
{
    Equip_listModel * baseList;
}
@property (nonatomic,strong) UITextView * textView;

@property (nonatomic,strong) EquipModel * detailModel;
@end

@implementation CBGCopyUrlDetailCehckVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        baseList = [[Equip_listModel alloc] init];
        self.viewTtle = @"查询";
        
        self.showRightBtn = YES;
        self.rightTitle = @"保存";
    }
    return self;
}

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //copy信息抓去，解析，展示
    
    UIView * bgView = self.view;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 200, 100, 100);
    [btn addTarget:self action:@selector(tapedOnCheckDetailRequestTxtBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"查看详情" forState:UIControlStateNormal];
    [bgView addSubview:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH - 100, 200, 100, 100);
    [btn addTarget:self action:@selector(tapedOnCheckDetailTxtBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"WEB信息" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [bgView addSubview:btn];

    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 300, 100, 100);
    [btn addTarget:self action:@selector(tapedOnRemoveLatestSelectedModelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"移除" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [bgView addSubview:btn];

    
    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 80)];
    [bgView addSubview:txt];
    self.textView = txt;
    
    
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

-(void)submit
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
                    baseList.serverid = [NSNumber numberWithInt:[serverId intValue]];
                }
            }
            
            NSArray * orderSNArr = @[@"ordersn=",@"game_ordersn="];
            for (NSString * eve in orderSNArr)
            {
                if([detailEve hasPrefix:eve])
                {
                    NSString * orderSN = [detailEve stringByReplacingOccurrencesOfString:eve withString:@""];
                    baseList.game_ordersn = orderSN;
                }
            }
        }
        NSString * showTxt = [NSString stringWithFormat:@"serverId %@ orderSN %@",[baseList.serverid stringValue],baseList.game_ordersn];
        if(baseList.serverid && baseList.game_ordersn)
        {
            showTxt = [showTxt stringByAppendingString:@" 读取成功"];
        }
        self.textView.text = showTxt;
        
    }else if([detailCopy integerValue] > 0)
    {
        //识别roleid
        NSString * roleId = [NSString stringWithFormat:@"%ld",[detailCopy integerValue]];
        NSString * showTxt = [NSString stringWithFormat:@"复制文本 %@ roleid %@ ",detailCopy,roleId];

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
