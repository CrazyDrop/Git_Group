//
//  ZWBaseRefreshController.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWBaseRefreshController.h"
#import "EquipDetailArrayRequestModel.h"
#import "EquipListRequestModel.h"
#import "Equip_listModel.h"
#import "CBGDetailWebView.h"
#import "ZACBGDetailWebVC.h"
#import "CBGPlanDetailPreShowWebVC.h"
#import "RefreshListCell.h"
@interface ZWBaseRefreshController ()<UITableViewDataSource,UITableViewDelegate,RefreshCellCopyDelgate>
{
    
    
}
@property (nonatomic,strong) UIView * tipsView;
@property (nonatomic,strong) NSArray * grayArray;
//@property (nonatomic,strong) NSArray * dataArr;
@property (nonatomic,strong) NSArray * dataArr2;
@property (nonatomic,strong) CBGDetailWebView * planWeb;

@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) id latest;
@end

@implementation ZWBaseRefreshController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        requestLock = [[NSLock alloc] init];
        
        self.viewTtle = @"刷新列表";
        self.rightTitle = @"无";
        self.showRightBtn = NO;

    }
    return self;
}
-(void)refreshTitleViewTitleWithLatestTitleName:(NSString *)title{
    self.titleV.text = title;
}
-(UIView *)tipsView
{
    if(!_tipsView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"错误(刷新)";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshGesture:)];
        [aView addGestureRecognizer:tapGes];
        self.tipsView = aView;
    }
    return _tipsView;
}

-(void)tapedRefreshGesture:(id)sender
{
    //    [SFHFKeychainUtils exchangeLocalCreatedDeviceNum];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.randomAgent = [[DZUtils currentDeviceIdentifer] MD5String];
    [total localSave];
}

- (void)viewDidLoad
{
//    self.viewTtle = @"刷新列表";
//    self.rightTitle = @"提交";
//    self.showRightBtn = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleV.adjustsFontSizeToFitWidth = YES;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    table.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.listTable = table;
    [self.view addSubview:table];
    
    [self.view addSubview:self.tipsView];
    self.tipsView.hidden = YES;
    
}

-(BOOL)checkListInputForNoticeWithArray:(NSArray *)array
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.isAlarm)
    {
        return NO;
    }
    
    
    NSInteger compareId = total.minServerId;
    
    Equip_listModel * maxModel = nil;
    CGFloat maxRate = 0;
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        Equip_listModel * list = [array objectAtIndex:index];
        
        BOOL equipBuy = [list preBuyEquipStatusWithCurrentExtraEquip];//缺少了服务器3年外判定
        if(equipBuy)
        {
            CBGEquipRoleState state = list.listSaveModel.latestEquipListStatus;
            BOOL unSold = ( state == CBGEquipRoleState_InSelling|| state == CBGEquipRoleState_InOrdering || state == CBGEquipRoleState_unSelling);
            CGFloat rate = list.earnRate;
            if(unSold && rate >= maxRate){
                maxRate = rate;
                maxModel = list;
            }
        }
    }
    
    
    if(maxModel)
    {

        //三年内区时，并且利率不是很大，仅进行提醒
        if(!total.isNotSystemApp && [maxModel.serverid integerValue] >= compareId && total.limitRate > 0 && maxModel.earnRate < total.limitRate * 2)
        {
            return NO;
        }
        
        NSLog(@"%s %.2f %@",__FUNCTION__,maxModel.earnRate,maxModel.detailWebUrl);
        NSString * webUrl = maxModel.detailWebUrl;
        NSString * urlString = webUrl;
        
        [self copyToLocalForPasteWithString:webUrl];
        
        NSString * param = [NSString stringWithFormat:@"rate=%ld&price=%ld",(NSInteger)maxModel.earnRate,[maxModel.price integerValue]/100];
        
        NSString * appUrlString = [NSString stringWithFormat:@"refreshPayApp://params?weburl=%@&%@",[urlString base64EncodedString],param];
        
        [DZUtils startNoticeWithLocalUrl:appUrlString];
        
        NSURL *appPayUrl = [NSURL URLWithString:appUrlString];
        
        
        if(!total.isNotSystemApp || maxModel.earnRate < total.limitRate || [maxModel.price integerValue] / 100 > total.limitPrice){
            //当用户主动选择APP支付，或者金钱不足，或者利率过低，或者
            appPayUrl = [NSURL URLWithString:maxModel.listSaveModel.mobileAppDetailShowUrl];
        }
        
        //当需要跳转时系统APP时，对于利率不是很高的，进行快速展示，但不进行主动跳转
        if(!total.isNotSystemApp && maxModel.earnRate < total.limitRate && total.limitRate > 0){
            return YES;
        }


        if([[UIApplication sharedApplication] canOpenURL:appPayUrl]  &&
           [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            [[UIApplication sharedApplication] openURL:appPayUrl];
        }else
        {
            self.planWeb = [[CBGDetailWebView alloc] init];
            [self.planWeb prepareWebViewWithUrl:urlString];
            
            self.latest = maxModel;
            self.latestContain = YES;
        }
    }
    
    return maxModel;
}
-(void)copyToLocalForPasteWithString:(NSString *)url
{
    if(!url) return;
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = url;
}



-(void)refreshTableViewWithLatestCacheArray:(NSArray *)cacheArr
{
    if([cacheArr count] >= 2)
    {
        cacheArr = [cacheArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Equip_listModel * eve1 = (Equip_listModel *)obj1;
            Equip_listModel * eve2 = (Equip_listModel *)obj2;
            
            if([eve1.price integerValue] > 0 && [eve2.price integerValue] > 0){
                return [eve1.price compare:eve2.price];
            }
            
            if([eve1.price integerValue] == 0 && [eve2.price integerValue] == 0)
            {
                return [eve1.serverid compare:eve2.serverid];
            }
            
            NSNumber * num1 = eve1.price?:@0;
            NSNumber * num2 = eve2.price?:@0;
            return [num1 compare:num2];
        }];
    }
    
    self.dataArr = cacheArr;
//    [self.listTable reloadData];
}

//列表刷新，按照最新的返回数据,新增，还是替换
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr
{
    if([array count] == 0 && [cacheArr count] == [self.dataArr count])
    {
        return;
    }
    
    NSMutableArray * refreshArray = [NSMutableArray array];
    if([array count] > 0)
    {
        self.grayArray = array;
        
        [refreshArray addObjectsFromArray:self.showArray];
        
        if(NO)
        {
            
            NSInteger minNum = MIN([array count], [refreshArray count]);
            //替换
            for (NSInteger index = 0; index < minNum; index++)
            {
                id eveOjb = [array objectAtIndex:index];
                [refreshArray replaceObjectAtIndex:index withObject:eveOjb];
            }
        }else{
            //插入删除
            
            //最大
            NSInteger maxShowNum = RefreshListMaxShowNum;
            //当前
            NSInteger listNum = [self.showArray count];
            //新增
            NSInteger inputNum = [array count];
            
            if(inputNum >= maxShowNum)
            {
                [refreshArray removeAllObjects];
                [refreshArray addObjectsFromArray:array];
                [refreshArray removeObjectsInRange:NSMakeRange(maxShowNum,inputNum - maxShowNum)];
                
            }else{
                //需要移除的数量
                NSInteger removeNum = listNum - (maxShowNum - inputNum);
                
                if(removeNum > 0)
                {
                    [refreshArray removeObjectsInRange:NSMakeRange(listNum - removeNum, removeNum)];
                }
                for (NSInteger index = 0;index < [array count]; index ++)
                {
                    NSInteger backIndex = [array count] - index - 1;
                    id eveOjb = [array objectAtIndex:backIndex];
                    [refreshArray insertObject:eveOjb atIndex:0];
                }
            }
        }
        
        self.showArray = refreshArray;
        self.dataArr2 = refreshArray;
    }
    
//    self.dataArr = cacheArr;
    [self.listTable reloadData];
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return [self.dataArr count];
    }else{
        return [self.dataArr2 count];
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)tapedOnRefreshCellCopyDelegateWithIndex:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(contact)
    {
        NSString * planUrl = contact.detailWebUrl;
        if(planUrl)
        {
            UIPasteboard * board = [UIPasteboard generalPasteboard];
            board.string = planUrl;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    //两种数据   有历史、没历史
    //有详情、没详情
    static NSString *cellIdentifier = @"RefreshListCellIdentifier";
    RefreshListCell *cell = (RefreshListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        //            cell = [[ZAContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andTableView:tableView];
        //            cell.delegate = self;
        
        
        RefreshListCell * swipeCell = [[[NSBundle mainBundle] loadNibNamed:@"RefreshListCell"
                                                                     owner:nil
                                                                   options:nil] lastObject];
        
        //        [[RefreshListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [swipeCell setValue:cellIdentifier forKey:@"reuseIdentifier"];
        
        cell = swipeCell;
        
        cell.cellDelegate = self;
    }
    cell.coverBtn.hidden = NO;
    cell.indexPath = indexPath;
    
    //用来标识是否最新一波数据
    UIColor * numcolor = [self.grayArray containsObject:contact]?[UIColor blackColor]:[UIColor lightGrayColor];
    
    NSString * centerDetailTxt = contact.desc_sumup;
    
    UIColor * color = [UIColor lightGrayColor];
    NSString * sellTxt = [NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%@  -  %@",contact.equip_name,contact.subtitle];
    NSString * leftPriceTxt = contact.price_desc;
    
    if(!contact)
    {
        sellTxt = nil;
        equipName = nil;
        centerDetailTxt = nil;
    }
    
    cell.latestMoneyLbl.textColor = color;
    
    //列表剩余时间
    NSString * dateStr = contact.sell_expire_time_desc;
    //    @"dd天HH小时mm分钟"
    NSDateFormatter * format = [NSDate format:@"dd天HH小时mm分钟"];
    NSDate * date = [format dateFromString:dateStr];
    NSString * rightTimeTxt =  [date toString:@"HH:mm(余)"];
    NSString * rightStatusTxt = contact.status_desc;
    
    //详情剩余时间
    EquipModel * detail = contact.equipModel;
    UIColor * earnColor = [UIColor lightGrayColor];
    CBGListModel * listModel = [contact listSaveModel];
    CBGListModel * historyModel = [contact appendHistory];
    NSInteger histroyPrice = 0;
    //仅无详情时有效，此时数据为库表数据补全
    if(historyModel)
    {
        //有历史、此时有无详情不重要，展示历史，价格状态、刷新即可
        if(historyModel.historyPrice > 0){
            histroyPrice = historyModel.historyPrice;
        }else
        {
            histroyPrice = historyModel.equip_price;
            historyModel.historyPrice = histroyPrice;
        }
        
        if([contact.price integerValue] > 0){
            historyModel.style = CBGEquipPlanStyle_None;
            historyModel.equip_price = [contact.price integerValue];
        }
        
        //状态刷新
        if([detail.price integerValue] > 0){
            historyModel.style = CBGEquipPlanStyle_None;
            historyModel.equip_price = [detail.price integerValue];
        }
//        historyModel.equip_price = listModel.equip_price;
        historyModel.equip_accept = contact.accept_bargain;
        historyModel.equip_status = [contact.equip_status integerValue];
        
        //用数据刷新界面
        listModel = historyModel;
    }
    listModel.style = CBGEquipPlanStyle_None;
    
    UIColor * equipBuyColor = [UIColor lightGrayColor];
    UIColor * leftRateColor = [UIColor lightGrayColor];
    UIColor * rightStatusColor = [UIColor lightGrayColor];
    UIColor * priceColor = [UIColor redColor];

    if(secNum == 1)
    {
        equipBuyColor = Custom_Green_Button_BGColor;
    }

    //无详情、无历史
    if(!detail && !historyModel)
    {
        date = [NSDate fromString:contact.selling_time];
        rightTimeTxt =  [date toString:@"HH:mm"];
        
    }else
    {
        //补全列表数据缺失
        if(detail)
        {
            sellTxt = [NSString stringWithFormat:@"%@-%@",detail.area_name,detail.server_name];
            equipName = [NSString stringWithFormat:@"%@  -  %@",detail.equip_name,detail.subtitle];
            rightStatusTxt = detail.status_desc;
            leftPriceTxt = detail.last_price_desc;
        }
        
        if((!leftPriceTxt || [leftPriceTxt intValue] == 0 )&& listModel.equip_price > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%.2ld元",listModel.equip_price/100];
        }
        
        date = [NSDate fromString:contact.selling_time];
        rightTimeTxt =  [date toString:@"HH:mm"];
        
        if(detail)
        {
            date = [NSDate fromString:detail.selling_time];
            rightTimeTxt =  [date toString:@"HH:mm"];

            NSTimeInterval interval = [self timeIntervalWithCreateTime:detail.create_time andSellTime:detail.selling_time];
            if(interval < 60 * 60 * 24 )
            {
                earnColor = [UIColor orangeColor];
            }
            if(interval < 60){
                earnColor = [UIColor redColor];
            }
        }
        
        if(listModel.plan_total_price != 0)
        {
            centerDetailTxt = [NSString stringWithFormat:@"%ld (%ld) %d",listModel.plan_total_price,listModel.plan_zhaohuanshou_price + listModel.plan_zhuangbei_price,(int)listModel.price_base_equip];
        }
        
        NSInteger priceChange = histroyPrice/100 - [contact.price integerValue]/100;
        if(detail){
            priceChange = histroyPrice/100 - [detail.price integerValue]/100;
        }
        
        if([contact preBuyEquipStatusWithCurrentExtraEquip])
        {
            sellTxt = [NSString stringWithFormat:@"%.0ld %@",listModel.price_rate_latest_plan,sellTxt];
            equipName = [NSString stringWithFormat:@"%.0ld %@",listModel.price_earn_plan,equipName];
            
        }else if(histroyPrice > 0 && priceChange != 0 && ([contact.price integerValue] > 0 || [detail.price integerValue]> 0))
        {
            if(priceChange >0)
            {
                leftRateColor = [UIColor orangeColor];
            }
            sellTxt = [NSString stringWithFormat:@"%ld%@",histroyPrice/100,sellTxt];
        }
        
        switch (listModel.style) {
            case CBGEquipPlanStyle_Worth:
            {
                rightStatusColor = [UIColor redColor];
            }
                break;
            case CBGEquipPlanStyle_PlanBuy:
            {
                leftRateColor = Custom_Green_Button_BGColor;
            }
                break;
            default:
                break;
        }

        if(listModel.equip_accept > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
        }
        
        if(listModel.planMore_zhaohuan || listModel.planMore_Equip)
        {
            numcolor = [UIColor redColor];
        }
        
        if(listModel.price_rate_latest_plan > 0)
        {
            rightStatusColor = [UIColor redColor];
        }

    }

    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = centerDetailTxt;
    cell.rateLbl.text = leftPriceTxt;
    cell.rateLbl.textColor = priceColor;
    cell.sellTimeLbl.text = rightStatusTxt;
    cell.sellTimeLbl.textColor = rightStatusColor;
    cell.timeLbl.text = rightTimeTxt;
    
    UIFont * font = cell.totalNumLbl.font;
    cell.latestMoneyLbl.text = sellTxt;
    cell.timeLbl.textColor = earnColor;
    cell.sellRateLbl.font = font;
    cell.latestMoneyLbl.font = font;
    cell.sellDateLbl.hidden = YES;
    cell.sellRateLbl.text = equipName;
    cell.sellRateLbl.textColor = equipBuyColor;
    cell.latestMoneyLbl.textColor = leftRateColor;
    
    cell.selected = NO;
    if(secNum == 0 )
    {
        color = [UIColor lightGrayColor];
        NSString * txt = nil;
        //        NSDate * date = [NSDate dateWithTimeIntervalSince1970:[contact.selling_time floatValue]];
        //        cell.sellTimeLbl.text = [date toString:@"MM-dd HH:mm"];
        
        NSInteger statusNum = [detail.status integerValue];
        txt = (statusNum!=4&&statusNum!=6 && detail)?@"尚有":@"无";
        color = self.latestContain?[UIColor redColor]:[UIColor lightGrayColor];
        
        cell.sellTimeLbl.text = txt;
        cell.sellTimeLbl.textColor = color;
        
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}
#pragma mark -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(contact)
    {
//        NSString * planUrl = self.planWeb.showUrl;
//        if([planUrl isEqualToString:contact.detailWebUrl])
//        {
//            CBGPlanDetailPreShowWebVC * detail = [[CBGPlanDetailPreShowWebVC alloc] init];
//            detail.planWebView = self.planWeb;
//            detail.cbgList = [contact listSaveModel];
//            detail.detailModel = contact.equipModel;
//            [[self rootNavigationController] pushViewController:detail animated:YES];
//        }else
        {
            CBGListModel * hisCBG = contact.appendHistory;
            if(contact.equipModel)
            {
                contact.listSaveModel = nil;
                hisCBG = [contact listSaveModel];
            }
            ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
            detail.cbgList = hisCBG;
            detail.detailModel = contact.equipModel;
            [[self rootNavigationController] pushViewController:detail animated:YES];
        }
        
    }
    
    
    
}
-(NSTimeInterval)timeIntervalWithCreateTime:(NSString *)create andSellTime:(NSString *)selltime
{
    NSDate * createDate = [NSDate fromString:create];
    NSDate * sellDate = [NSDate fromString:selltime];
    
    NSTimeInterval interval = [sellDate timeIntervalSinceDate:createDate];
    //    NSLog(@"interval %f",interval);
    return interval;
    
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
