//
//  ZACBGDetailWebVC.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/29.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "ZACBGDetailWebVC.h"
#import "JSONKit.h"
#import "BaseDataModel.h"
#import "CBGEquipDetailRequestManager.h"
#import "EquipDetailArrayRequestModel.h"
#import "MSAlertController.h"
#import "CBGNearHistoryVC.h"
#import "ZALocationLocalModel.h"
#import "CBGDetailWebView.h"
#import "ZAAutoBuyHomeVC.h"
@interface ZACBGDetailWebVC ()<UIWebViewDelegate>
{
    Equip_listModel * baseList;
}
//@property (nonatomic,strong) UIWebView * showWeb;
@property (nonatomic,strong) UITextView * txtView;
@property (nonatomic,strong) UIButton * payBtn;
@property (nonatomic,strong) UIButton * saveBtn;
@property (nonatomic,strong) UIButton * refreshBtn;
@property (nonatomic,strong) NSString * orderId;
@property (nonatomic,assign) CBGDetailWebFunction latestFunc;
@end

@implementation ZACBGDetailWebVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        baseList = [[Equip_listModel alloc] init];
        self.orderStyle = CBGStaticOrderShowStyle_None;
    }
    return self;
}
-(void)resizeCBGListTableViewForSmall
{
    CGRect rect = self.listTable.frame;
    rect.size.height = 120;
    self.listTable.frame = rect;
    [self.view bringSubviewToFront:self.listTable];
}
-(void)refreshLatestSelectedRoleId
{
    NSString *roleId = self.cbgList.owner_roleid;
    self.selectedRoleId = [roleId intValue];
    self.selectedOrderSN = self.cbgList.game_ordersn;
    
    baseList.serverid = [NSNumber numberWithInteger:self.cbgList.server_id];
    baseList.game_ordersn = self.cbgList.game_ordersn;
}


- (void)leftAction
{
    [self.navigationController popViewControllerAnimated:YES];
    return;
    if(!self.orderId)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self tapedOnPayBtn:nil];
    }
    
}
-(UIButton *)refreshBtn
{
    if(!_refreshBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"刷新" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blueColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(SCREEN_WIDTH - btnWidth * 2- 1, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnRefreshWebViewBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshBtn = btn;
    }
    return _refreshBtn;
}
-(UIButton *)saveBtn
{
    if(!_saveBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blueColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(SCREEN_WIDTH - btnWidth * 2- 1, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnLocalDBSaveBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.saveBtn = btn;
    }
    return _saveBtn;
}
-(void)tapedOnRefreshWebViewBtn:(id)sender
{
    [self startRefreshDataModelRequest];
    
    NSString * urlString = self.cbgList.detailWebUrl;
    if(!urlString) return;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.showWeb loadRequest:request];
}

-(void)tapedOnLocalDBSaveBtn:(id)sender
{
    //进行数据刷新
    if(!self.detailModel){
        [DZUtils noticeCustomerWithShowText:@"详情不存在"];
        return;
    }
    baseList.equipModel = self.detailModel;
    
    //强制刷新
    [baseList refrehLocalBaseListModelWithDetail:self.detailModel];
    
    CBGListModel * cbgList = [baseList listSaveModel];
    cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;

    NSArray * arr = @[cbgList];
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:arr];
}
-(UIButton *)payBtn
{
    if(!_payBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"支付" forState:UIControlStateNormal];
        [btn setTitle:@"问题" forState:UIControlStateDisabled];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateDisabled];
        [btn setBackgroundColor:[UIColor greenColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(SCREEN_WIDTH - btnWidth, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnPayBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.payBtn = btn;
    }
    return _payBtn;
}
-(void)tapedOnPayBtn:(id)sender
{
    if(self.detailModel)
    {
        [baseList refrehLocalBaseListModelWithDetail:self.detailModel];
    }
    
    NSString * urlString = self.cbgList.detailWebUrl;
    
    NSString * webUrl = [NSString stringWithFormat:@"refreshPayApp://params?weburl=%@&rate=%ld&price=%ld",[urlString base64EncodedString],(NSInteger)baseList.earnRate,[baseList.price integerValue]/100];
    NSURL *appPayUrl = [NSURL URLWithString:webUrl];

    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.isNotSystemApp){
        appPayUrl = [NSURL URLWithString:self.cbgList.mobileAppDetailShowUrl];
    }
    
    if([[UIApplication sharedApplication] canOpenURL:appPayUrl])
    {
        [[UIApplication sharedApplication] openURL:appPayUrl];
    }else
    {
        if(!self.detailModel)
        {
            [DZUtils noticeCustomerWithShowText:@"无详情信息"];
            return;
        }
        
        if(![DZUtils equipServerIdCheckResultWithSubServerId:[baseList.serverid integerValue]]){
            [DZUtils noticeCustomerWithShowText:@"角色服务器不满足条件"];
            return;
        }
        
        ZAAutoBuyHomeVC * home = [[ZAAutoBuyHomeVC alloc] init];
        home.webUrl = urlString;
        home.rate = baseList.earnRate;
        home.price = [baseList.price integerValue] / 100;
        [[self rootNavigationController] pushViewController:home animated:YES];
        
    }
}

- (void)viewDidLoad {
    self.showLeftBtn = YES;
    self.showRightBtn = YES;
    self.viewTtle = @"详情";
    self.rightTitle = @"相关";
    [super viewDidLoad];
    
    
    [self refreshLatestSelectedRoleId];
    [self refreshCurrentTitleVLableWithServerId];
    
    UIView * bgView = self.view;
    bgView.backgroundColor = [UIColor whiteColor];
    
    NSString * urlString = self.cbgList.detailWebUrl;
//    CBGDetailWebView * detail = [CBGDetailWebView sharedInstance];
    
    UIWebView *webView = nil;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, FLoatChange(65), SCREEN_WIDTH, SCREEN_HEIGHT -FLoatChange(65))];
    if(urlString)
    {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
    [bgView addSubview:webView];
    webView.delegate = self;
    self.showWeb = webView;

    //    http://115.159.68.180:8080/sdbt/about.html
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@%@",URL_HEAD,_url];
    
    [self copyToLocalForPasteWithString:urlString];

    
    
    
    NSString * string = self.detailModel.equip_desc;
//    string = @"{\"iPcktPage\":0,\"propKept\":{},\"changesch\":[5],\"iHp\":1564,\"rent_level\":0,\"iCGBoxAmount\":0,\"TA_iAllPoint\":0,\"commu_gid\":0,\"iMarry\":0,\"pet\":[],\"ori_desc\":3218,\"total_avatar\":6,\"icolor_ex\":0,\"iBeastSki4\":4,\"iMag_All\":675,\"HugeHorse\":{},\"ori_race\":3,\"iExptSki2\":11,\"iRes_All\":114,\"iSumAmountEx\":0,\"iSpe_All\":119,\"iBeastSki2\":0,\"normal_horse\":0,\"iPride\":800,\"ExpJwBase\":1000000000,\"AchPointTotal\":1077,\"iMagDef_All\":879,\"iGrade\":109,\"iPoint\":0,\"iMarry2\":0,\"iMaxExpt4\":20,\"sum_exp\":13,\"iHp_Eff\":1579,\"iMp\":1829,\"iIcon\":9,\"fabao\":{29:{\"iType\":6014,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G50#Y,五行:#G水#Y,无需佩带，在战斗中选择使用,使用回合限制：#G3#Y,使用装备限制：#G人物等级≥80#Y\"},28:{\"iType\":6033,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G500#Y,五行:#G水#Y,无需佩带，在战斗中选择使用,使用回合限制：#G10#Y,使用装备限制：#G人物等级≥100#Y\"},27:{\"iType\":6017,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G500#Y,五行:#G水#Y,无需佩带，在战斗中选择使用,使用回合限制：#G5#Y,使用装备限制：#G人物等级≥100#Y\"},26:{\"iType\":6066,\"cDesc\":\"0#G1#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82初具法力#Y,灵气:#G50#Y,五行:#G土#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥60#Y\"},25:{\"iType\":6021,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G50#Y,五行:#G水#Y,无需佩带，在战斗中选择使用,使用回合限制：#G3#Y,使用装备限制：#G人物等级≥100#Y\"},24:{\"iType\":6056,\"cDesc\":\"0#G1#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82初具法力#Y,灵气:#G50#Y,五行:#G火#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥60#Y\"},23:{\"iType\":6022,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G191#Y,五行:#G水#Y,无需佩带，非战斗中选择使用,使用装备限制：#G人物等级≥100#Y\"},22:{\"iType\":6028,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G50#Y,五行:#G火#Y,无需佩带，在战斗中选择使用,使用回合限制：#G3#Y,使用装备限制：#G人物等级≥100#Y\"},21:{\"iType\":6063,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G358#Y,五行:#G木#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥100#Y\"},20:{\"iType\":6025,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G52#Y,五行:#G金#Y,无需佩带，在战斗中选择使用,使用回合限制：#G150#Y,使用装备限制：#G人物等级≥80#Y\"},19:{\"iType\":6067,\"cDesc\":\"0#G1#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82初具法力#Y,灵气:#G50#Y,五行:#G水#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥60#Y\"},18:{\"iType\":6064,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G180#Y,五行:#G金#Y,无需佩带，在战斗中选择使用,使用回合限制：#G3#Y,使用装备限制：#G人物等级≥80#Y\"},17:{\"iType\":6070,\"cDesc\":\"0#G1#Y级法宝,修炼境界：第#G9#Y层 #cFF6F28不堕轮回#Y,灵气:#G180#Y,五行:#G水#Y,无需佩带，非战斗中选择使用,使用装备限制：#G人物等级≥60#Y\"},16:{\"iType\":6030,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G500#Y,五行:#G水#Y,无需佩带，在战斗中选择使用,使用回合限制：#G10#Y,使用装备限制：#G人物等级≥100#Y\"},15:{\"iType\":6013,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82元神初具#Y,灵气:#G500#Y,五行:#G金#Y,无需佩带，在战斗中选择使用,使用回合限制：#G1#Y,使用装备限制：#G人物等级≥100#Y\"},14:{\"iType\":6029,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G178#Y,五行:#G金#Y,无需佩带，在战斗中选择使用,使用回合限制：#G6#Y,使用装备限制：#G人物等级≥80#Y\"},13:{\"iType\":6024,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G242#Y,五行:#G金#Y,无需佩带，在战斗中选择使用,使用回合限制：#G150#Y,使用装备限制：#G人物等级≥80#Y\"},12:{\"iType\":6072,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G116#Y,五行:#G金#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥80#Y\"},11:{\"iType\":6044,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82心法初成#Y,灵气:#G300#Y,五行:#G土#Y,无需佩带，在战斗中选择使用,使用回合限制：#G6#Y,使用装备限制：#G人物等级≥80#Y\"},35:{\"iType\":6068,\"cDesc\":\"0#G1#Y级法宝,修炼境界：第#G0#Y层 #c7D7E82初具法力#Y,灵气:#G114#Y,五行:#G土#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥60#Y\"},3:{\"iType\":6045,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G15#Y层 #cFF6F28天人合一#Y,灵气:#G154#Y,五行:#G木#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥100#Y\"},2:{\"iType\":6073,\"cDesc\":\"0#G2#Y级法宝,修炼境界：第#G12#Y层 #cFF6F28法力无边#Y,灵气:#G154#Y,五行:#G水#Y,需要佩带才可在战斗中发挥效用,使用装备限制：#G人物等级≥80#Y\"},1:{\"iType\":6020,\"cDesc\":\"0#G3#Y级法宝,修炼境界：第#G12#Y层 #cFF6F28笑傲西游#Y,灵气:#G354#Y,五行:#G木#Y,传送至龙窟二层(20,7),无需佩带，非战斗中选择使用,使用装备限制：#G人物等级≥100#Y\"}},\"usernum\":31775712,\"iSkiPoint\":0,\"iBadness\":0,\"iGoodness\":1035,\"farm_level\":0,\"iMaxExpt3\":20,\"iSchool\":7,\"iHp_Max\":1579,\"TA_iAllNewPoint\":3,\"xianyu\":0,\"iMaxExpt1\":20,\"cName\":\"ы唐↓烁铠\",\"AllEquip\":{6:{\"iType\":1252,\"cDesc\":\"#r等级 100  五行 金#r#r命中 +360 伤害 +310#r耐久度 335#r#G#G耐力 -6#Y #G力量 +20#Y#Y#r#W制造者：′此人无心#Y  \"},4:{\"iType\":2852,\"cDesc\":\"#r等级 100  #r灵力 +161#r耐久度 421#r锻炼等级 5  镶嵌宝石 舍利子#Y#r#W制造者：′溺水㈢千ら强化打造#Y  \"},10:{\"iType\":2906,\"cDesc\":\"#r等级 40  #r气血 +120 防御 +22#r耐久度 300#r锻炼等级 1  镶嵌宝石 光芒石#Y#r#c4DBAF4特效：#c4DBAF4永不磨损#Y  \"},2:{\"iType\":2652,\"cDesc\":\"#r等级 100  五行 土#r#r防御 +237#r耐久度 131  修理失败 2次#r锻炼等级 4  镶嵌宝石 月亮石#r#G#G耐力 -3#Y #G体质 +20#Y#Y#r#W制造者：我累哦强化打造#Y#r#Y熔炼效果：#r#Y#r+17防御#Y  \"},1:{\"iType\":2552,\"cDesc\":\"#r等级 100  五行 水#r#r防御 +93 魔法 +110#r耐久度 240#r锻炼等级 3  镶嵌宝石 月亮石#Y#r#W制造者：vip‖烟强化打造#Y  \"}},\"iSmithski\":0,\"iDex_All\":124,\"commu_name\":0,\"HeroScore\":0,\"iCGBodyAmount\":0,\"iDod_All\":353,\"iNutsNum\":18,\"iDesc\":0,\"iSewski\":0,\"iRace\":3,\"ExAvt\":{6:{\"iType\":19064,\"order\":6,\"cName\":\"怀旧神天兵炫卡\"},5:{\"iType\":12034,\"order\":5,\"cName\":\"金风（上衣）\"},4:{\"iType\":13340,\"order\":4,\"cName\":\"金风（发饰）\"},3:{\"iType\":12608,\"order\":3,\"cName\":\"金风（下衣）\"},2:{\"iType\":14400,\"order\":2,\"cName\":\"植物装饰篮\"},1:{\"iType\":13925,\"order\":1,\"cName\":\"隐夜鬼蝠\"}},\"rent\":0,\"idbid_desc\":[],\"outdoor_level\":0,\"iErrantry\":0,\"sword_score\":0,\"iStr_All\":140,\"iExptSki3\":17,\"bid\":0,\"iSumAmount\":8,\"iCGTotalAmount\":0,\"iBeastSki3\":12,\"iUpExp\":6545968,\"more_attr\":{\"attrs\":[{\"idx\":5,\"lv\":0},{\"idx\":2,\"lv\":0},{\"idx\":4,\"lv\":0},{\"idx\":1,\"lv\":0},{\"idx\":7,\"lv\":0},{\"idx\":6,\"lv\":0},{\"idx\":8,\"lv\":0},{\"idx\":9,\"lv\":0},{\"idx\":3,\"lv\":0},{\"idx\":12,\"lv\":0},{\"idx\":10,\"lv\":0},{\"idx\":11,\"lv\":0},{\"idx\":13,\"lv\":353},{\"idx\":14,\"lv\":879}]},\"iOrgOffer\":0,\"jiyuan\":0,\"iCor_All\":155,\"iLearnCash\":2543190,\"iExptSki1\":0,\"iTotalMagDef_all\":879,\"iSaving\":0,\"total_horse\":0,\"ExpJw\":0,\"iBeastSki1\":9,\"datang_feat\":6000,\"all_skills\":{\"197\":1,\"173\":1,\"198\":1,\"210\":9,\"196\":1,\"25\":79,\"174\":1,\"208\":41,\"29\":119,\"26802\":1,\"230\":2,\"26808\":1,\"52032\":1,\"212\":3,\"34\":119,\"160\":5,\"52031\":1,\"211\":1,\"31\":119,\"52016\":1,\"26804\":1,\"179\":1,\"158\":3,\"201\":91,\"33\":80,\"202\":22,\"32\":119,\"170\":1,\"154\":6,\"203\":10,\"30\":119},\"addPoint\":9,\"iMp_Max\":3113,\"iZhuanZhi\":0,\"energy\":4,\"iAtt_All\":628,\"iTotalMagDam_all\":956,\"iCash\":80156,\"iDef_All\":746,\"i3FlyLv\":0,\"iExptSki5\":0,\"iExptSki4\":9,\"iDamage_All\":789,\"AllSummon\":[{\"summon_equip2\":{\"iType\":9209,\"cDesc\":\"#r等级 85  #r速度 +25 魔法 +68#r耐久度 324#r#G#G耐力 +11#Y#Y\"},\"iDex_All\":150,\"iHp_max\":1763,\"att_rate\":11,\"summon_equip3\":{\"iType\":9109,\"cDesc\":\"#r等级 85  #r防御 +77#r耐久度 425#r#G#G法力 +12#Y#Y\"},\"iDod_All\":125,\"iHp\":1763,\"summon_equip4_desc\":\"\",\"iBaobao\":0,\"iMag_all\":589,\"iStr_all\":161,\"iMagDef_all\":703,\"iRes_all\":141,\"summon_equip4_type\":0,\"iSpe_all\":142,\"jinjie\":{\"core\":{},\"lx\":0,\"cnt\":0},\"summon_equip1\":{\"iType\":9309,\"cDesc\":\"#r等级 85  #r命中率 +11%#r耐久度 52  修理失败 1次#r#G#G法力 +12#Y#Y#r#r镶嵌效果 #r+4灵力 镶嵌等级：1\"},\"iRealColor\":0,\"summon_color\":0,\"ruyidan\":0,\"all_skills\":{\"424\":1,\"576\":1,\"510\":1,\"426\":1,\"505\":1,\"575\":1,\"313\":1},\"iPoint\":0,\"iGrade\":116,\"life\":44,\"qianjinlu\":0,\"yuanxiao\":0,\"iGenius\":426,\"iMp\":2621,\"summon_core\":{933:[5,0,{}],906:[5,0,{}],912:[5,0,{}]},\"iMp_max\":2621,\"lianshou\":0,\"hp\":2872,\"iDef_All\":557,\"def\":1024,\"spe\":885,\"iType\":102077,\"att\":711,\"iAtt_F\":2,\"mp\":2194,\"iCor_all\":206,\"iAtt_all\":464,\"dod\":881,\"grow\":1157},{\"iDex_All\":65,\"iHp_max\":534,\"att_rate\":0,\"iDod_All\":64,\"iHp\":534,\"summon_equip4_desc\":\"\",\"iBaobao\":1,\"iMag_all\":42,\"iStr_all\":40,\"iMagDef_all\":97,\"iRes_all\":57,\"summon_equip4_type\":0,\"iSpe_all\":56,\"jinjie\":{\"core\":{},\"lx\":0,\"cnt\":0},\"iRealColor\":0,\"summon_color\":0,\"ruyidan\":0,\"all_skills\":{\"312\":1,\"310\":1,\"317\":1},\"iPoint\":150,\"iGrade\":30,\"life\":5718,\"qianjinlu\":0,\"yuanxiao\":0,\"iGenius\":0,\"iMp\":225,\"summon_core\":{},\"iMp_max\":225,\"lianshou\":0,\"hp\":4494,\"iDef_All\":173,\"def\":1184,\"spe\":1177,\"iType\":102076,\"att\":1524,\"iAtt_F\":1,\"mp\":1212,\"iCor_all\":55,\"iAtt_all\":205,\"dod\":1155,\"grow\":1215},{\"summon_equip2\":{\"iType\":9208,\"cDesc\":\"#r等级 75  #r速度 +22#r耐久度 356#Y\"},\"iDex_All\":183,\"iHp_max\":2169,\"att_rate\":11,\"summon_equip3\":{\"iType\":9109,\"cDesc\":\"#r等级 85  #r防御 +73#r耐久度 74#r#G#G灵力 +6#Y#Y#r#r镶嵌效果 #r+30气血 镶嵌等级：1\"},\"iDod_All\":180,\"iHp\":709,\"summon_equip4_desc\":\"\",\"iBaobao\":1,\"iMag_all\":642,\"iStr_all\":145,\"iMagDef_all\":781,\"iRes_all\":148,\"summon_equip4_type\":0,\"iSpe_all\":134,\"iColor\":1,\"jinjie\":{\"core\":{},\"lx\":0,\"cnt\":0},\"summon_equip1\":{\"iType\":9309,\"cDesc\":\"#r等级 85  #r命中率 +11%#r耐久度 239#r#G#G灵力 +6#Y#Y\"},\"iRealColor\":1,\"summon_color\":0,\"ruyidan\":0,\"all_skills\":{\"424\":1,\"575\":1,\"315\":1,\"429\":1},\"iPoint\":0,\"iGrade\":119,\"life\":360,\"qianjinlu\":0,\"yuanxiao\":0,\"iGenius\":429,\"iMp\":1856,\"summon_core\":{936:[1,0,{}]},\"iMp_max\":3108,\"lianshou\":0,\"hp\":4160,\"iDef_All\":686,\"def\":1345,\"spe\":1208,\"iType\":102651,\"att\":1276,\"iAtt_F\":16,\"mp\":3028,\"iCor_all\":221,\"iAtt_all\":710,\"dod\":1345,\"grow\":1240},{\"iDex_All\":35,\"iHp_max\":169,\"att_rate\":0,\"iDod_All\":44,\"iHp\":169,\"summon_equip4_desc\":\"\",\"iBaobao\":1,\"iMag_all\":14,\"iStr_all\":16,\"iMagDef_all\":24,\"iRes_all\":18,\"summon_equip4_type\":0,\"iSpe_all\":29,\"jinjie\":{\"core\":{},\"lx\":0,\"cnt\":0},\"iRealColor\":0,\"summon_color\":0,\"ruyidan\":0,\"all_skills\":{\"312\":1,\"503\":1,\"301\":1,\"325\":1},\"iPoint\":0,\"iGrade\":0,\"life\":7280,\"qianjinlu\":0,\"yuanxiao\":0,\"iGenius\":0,\"iMp\":51,\"summon_core\":{},\"iMp_max\":51,\"lianshou\":0,\"hp\":3120,\"iDef_All\":29,\"def\":1199,\"spe\":1210,\"iType\":102077,\"att\":1224,\"iAtt_F\":16,\"mp\":2220,\"iCor_all\":23,\"iAtt_all\":18,\"dod\":1545,\"grow\":1230},{\"iDex_All\":58,\"iHp_max\":444,\"att_rate\":0,\"iDod_All\":55,\"iHp\":444,\"summon_equip4_desc\":\"\",\"iBaobao\":1,\"iMag_all\":50,\"iStr_all\":40,\"iMagDef_all\":114,\"iRes_all\":72,\"summon_equip4_type\":0,\"iSpe_all\":43,\"jinjie\":{\"core\":{},\"lx\":0,\"cnt\":0},\"iRealColor\":0,\"summon_color\":0,\"ruyidan\":0,\"all_skills\":{\"412\":1,\"627\":1},\"iPoint\":150,\"iGrade\":30,\"life\":6485,\"qianjinlu\":0,\"yuanxiao\":0,\"iGenius\":0,\"iMp\":329,\"summon_core\":{},\"iMp_max\":329,\"lianshou\":0,\"hp\":3535,\"iDef_All\":205,\"def\":1248,\"spe\":1369,\"iType\":102150,\"att\":1320,\"iAtt_F\":8,\"mp\":2376,\"iCor_all\":45,\"iAtt_all\":188,\"dod\":1300,\"grow\":1252}],\"AllRider\":{2:{\"all_skills\":{},\"ExtraGrow\":95,\"exgrow\":22637,\"iGrade\":99,\"mattrib\":\"魔力\",\"iType\":502},1:{\"all_skills\":{},\"ExtraGrow\":0,\"exgrow\":12855,\"iGrade\":5,\"mattrib\":\"\",\"iType\":502}},\"iSchOffer\":137,\"iMaxExpt2\":20,\"cOrg\":\"\",\"igoodness_sav\":12915}";
    
//    string = @"{\"AllEquip\":{6:{\"iType\":1252,\"cDesc\":\"#r等级 100  五行 金#r#r命中 +360 伤害 +310#r耐久度 335#r#G#G耐力 -6#Y #G力量 +20#Y#Y#r#W制造者：′此人无心#Y  \"},4:{\"iType\":2852,\"cDesc\":\"#r等级 100  #r灵力 +161#r耐久度 421#r锻炼等级 5  镶嵌宝石 舍利子#Y#r#W制造者：′溺水㈢千ら强化打造#Y  \"},10:{\"iType\":2906,\"cDesc\":\"#r等级 40  #r气血 +120 防御 +22#r耐久度 300#r锻炼等级 1  镶嵌宝石 光芒石#Y#r#c4DBAF4特效：#c4DBAF4永不磨损#Y  \"},2:{\"iType\":2652,\"cDesc\":\"#r等级 100  五行 土#r#r防御 +237#r耐久度 131  修理失败 2次#r锻炼等级 4  镶嵌宝石 月亮石#r#G#G耐力 -3#Y #G体质 +20#Y#Y#r#W制造者：我累哦强化打造#Y#r#Y熔炼效果：#r#Y#r+17防御#Y  \"},1:{\"iType\":2552,\"cDesc\":\"#r等级 100  五行 水#r#r防御 +93 魔法 +110#r耐久度 240#r锻炼等级 3  镶嵌宝石 月亮石#Y#r#W制造者：vip‖烟强化打造#Y  \"}}}";
    
    if(string)
    {
        NSDictionary * dic = [string objectFromJSONString];
        NSLog(@"NSDictionary %@",dic);
    }

//    [CreateModel createModelWithJsonData:dic rootModelName:@"EquipExtraModel"];
    
//    CBGEquipDetailRequestManager * cbgMan = [CBGEquipDetailRequestManager sharedInstance];
//    [cbgMan startDetailRequest];
    
//    EquipExtraModel * extra = [cbgMan extraModelFromLatestEquipDESC:self.listData.detaiModel];
    

    
//    NSString * serverId = [self.listData.serverid stringValue];
//    NSString * orderSN = self.listData.game_ordersn;
    NSString * txtValue = self.cbgList.detailWebUrl;
    CGFloat txtHeight = FLoatChange(300);
    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT - txtHeight , 100, txtHeight)];
    [bgView addSubview:txt];
    txt.text = txtValue;
    self.txtView = txt;
    txt.userInteractionEnabled = NO;
    
    CGFloat boundHeight = self.payBtn.bounds.size.height;
    [bgView addSubview:self.payBtn];
    
    CGPoint pt = txt.center;
    pt.y = SCREEN_HEIGHT - boundHeight/2.0;
    pt.x = SCREEN_WIDTH - self.payBtn.bounds.size.width/2.0;
    self.payBtn.center = pt;
    
    pt.y -= boundHeight;
    [bgView addSubview:self.saveBtn];
    self.saveBtn.center = pt;
    
    if(YES)
    {
        pt.y -= boundHeight;
        [bgView addSubview:self.refreshBtn];
        self.refreshBtn.center = pt;
    }
    
    //有详情的展示，没详情的请求
    if(self.detailModel)
    {
//        EquipModel * detail = self.detailModel;
//        EquipExtraModel * detailExtra = detail.equipExtra;
        
    }else{
//        [self startRefreshDataModelRequest];
    }
    
    if(self.cbgList)
    {
        NSString * prePrice = nil;
        CBGListModel * list = self.cbgList;
        NSMutableString * edit = [NSMutableString string];
        [edit appendFormat:@"总价 %.0ld \n",(long)list.plan_total_price];
        if(list.plan_rate > 0)
        {
            [edit appendFormat:@"收益 %.0ld(%.0ld) \n",(long)[list price_earn_plan],(long)list.plan_rate];
        }
        [edit appendFormat:@"修炼 %.0ld \n",(long)list.plan_xiulian_price];
        [edit appendFormat:@"宠修 %.0ld \n",(long)list.plan_chongxiu_price];
        [edit appendFormat:@"技能 %.0ld \n",(long)list.plan_jineng_price];
        [edit appendFormat:@"经验 %.0ld \n",(long)list.plan_jingyan_price];
        [edit appendFormat:@"潜能 %.0ld \n",(long)list.plan_qiannengguo_price];
        [edit appendFormat:@"乾元丹 %.0ld \n",(long)list.plan_qianyuandan_price];
        [edit appendFormat:@"等级 %.0ld \n",(long)list.plan_dengji_price];
        [edit appendFormat:@"机缘 %.0ld \n",(long)list.plan_jiyuan_price];
        [edit appendFormat:@"门派 %.0ld \n",(long)list.plan_menpai_price];
        [edit appendFormat:@"房屋 %.0ld \n",(long)list.plan_fangwu_price];
        [edit appendFormat:@"现金 %.0ld \n",(long)list.plan_xianjin_price];
        [edit appendFormat:@"孩子 %.0ld \n",(long)list.plan_haizi_price];
        [edit appendFormat:@"祥瑞 %.0ld \n",(long)list.plan_xiangrui_price];
        [edit appendFormat:@"坐骑 %.0ld \n",(long)list.plan_zuoji_price];
        [edit appendFormat:@"法宝 %.0ld \n",(long)list.plan_fabao_price];
        [edit appendFormat:@"装备 %.0ld \n",list.plan_zhuangbei_price];
        [edit appendFormat:@"召唤 %.0ld \n",list.plan_zhaohuanshou_price];
        prePrice = edit;
        
        if(self.cbgList.equip_eval_price > 0){
            prePrice = [prePrice stringByAppendingFormat:@"  系统:%ld\n",self.cbgList.equip_eval_price/100];
        }
//        prePrice = [prePrice stringByAppendingFormat:@"\n估价:%@",txtValue];
        txt.text = prePrice;
    }
    
    [self resizeCBGListTableViewForSmall];

}

-(void)refreshCurrentTitleVLableWithServerId
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger compareId = total.minServerId;
    
    BOOL buyEnable = YES;
    NSString * create = self.cbgList.sell_create_time;
    if(compareId <= self.cbgList.server_id)
    {
        buyEnable = NO;
        self.titleV.text = @"三年内!";
    }else if(compareId == 45){
        buyEnable = NO;
        self.titleV.text = @"限时区！";
    }else if([create length] > 0)
    {
        NSString * todayDate = [NSDate unixDate];
        if(todayDate)
        {
            todayDate = [todayDate substringToIndex:[@"2017" length]];
        }
        if(![create hasPrefix:todayDate])
        {
            self.titleV.text = [create substringToIndex:[@"2017-03-29" length]];
        }
    }
    
    if(self.cbgList.appointed)
    {
        buyEnable = NO;
        self.titleV.text = @"指定ID";
    }
    
    
//    self.payBtn.hidden = buyEnable;
    self.payBtn.userInteractionEnabled = buyEnable;
    self.payBtn.enabled = buyEnable;
}

-(void)submit
{
    NSString * string = [self.detailModel.equipExtra createExtraPrice];
    
    if(TARGET_IPHONE_SIMULATOR)
    {
        UIPasteboard * board = [UIPasteboard generalPasteboard];
        NSString * detailString = board.string;
        
        NSString * path = @"/Users/apple/desktop/current.txt";
        [detailString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        CBGNearHistoryVC  * list = [[CBGNearHistoryVC alloc] init];
        list.cbgList = self.cbgList;
        list.detailModel = self.detailModel;
        [[self rootNavigationController] pushViewController:list animated:YES];
        
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_dpModel;
    [model cancel];
    [model removeSignalResponder:self];
    _dpModel = nil;
}

-(void)copyToLocalForPasteWithString:(NSString *)url
{
    if(!url) return;
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = url;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }

    NSArray * array = @[self.cbgList.detailDataUrl];
    
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
            baseList.equipModel = detailEve;
            baseList.listSaveModel = nil;
            
            NSString * urlString = self.cbgList.detailWebUrl;
            CBGListModel * list = [baseList listSaveModel];
            
            NSString * prePrice = nil;
            NSMutableString * edit = [NSMutableString string];
            [edit appendFormat:@"总价 %.0ld \n",(long)list.plan_total_price];
            if(list.plan_rate > 0)
            {
                [edit appendFormat:@"收益 %.0ld(%.0ld) \n",(long)[list price_earn_plan],(long)list.plan_rate];
            }
            [edit appendFormat:@"修炼 %.0ld \n",(long)list.plan_xiulian_price];
            [edit appendFormat:@"宠修 %.0ld \n",(long)list.plan_chongxiu_price];
            [edit appendFormat:@"技能 %.0ld \n",(long)list.plan_jineng_price];
            [edit appendFormat:@"经验 %.0ld \n",(long)list.plan_jingyan_price];
            [edit appendFormat:@"潜能 %.0ld \n",(long)list.plan_qiannengguo_price];
            [edit appendFormat:@"乾元丹 %.0ld \n",(long)list.plan_qianyuandan_price];
            [edit appendFormat:@"等级 %.0ld \n",(long)list.plan_dengji_price];
            [edit appendFormat:@"机缘 %.0ld \n",(long)list.plan_jiyuan_price];
            [edit appendFormat:@"门派 %.0ld \n",(long)list.plan_menpai_price];
            [edit appendFormat:@"房屋 %.0ld \n",(long)list.plan_fangwu_price];
            [edit appendFormat:@"现金 %.0ld \n",(long)list.plan_xianjin_price];
            [edit appendFormat:@"孩子 %.0ld \n",(long)list.plan_haizi_price];
            [edit appendFormat:@"祥瑞 %.0ld \n",(long)list.plan_xiangrui_price];
            [edit appendFormat:@"坐骑 %.0ld \n",(long)list.plan_zuoji_price];
            [edit appendFormat:@"法宝 %.0ld \n",(long)list.plan_fabao_price];
            [edit appendFormat:@"装备 %.0ld \n",list.plan_zhuangbei_price];
            [edit appendFormat:@"召唤 %.0ld \n",list.plan_zhaohuanshou_price];
            
            prePrice = edit;
            if(self.cbgList.equip_eval_price > 0){
                prePrice = [prePrice stringByAppendingFormat:@"  系统:%ld\n",self.cbgList.equip_eval_price/100];
            }
//            prePrice = [prePrice stringByAppendingFormat:@"\n估价:%@",urlString];
            self.txtView.text = prePrice;
            
        }
    }
    
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * absStr = request.URL.absoluteString;
    NSString * compareStr = @"http://xyq.cbg.163.com/cgi-bin/usertrade.py?act=cross_server_buy_order_info&orderid=";
    if([absStr containsString:compareStr])
    {
        NSString * order = [absStr stringByReplacingOccurrencesOfString:compareStr withString:@""];
        NSArray * orderArr = [order componentsSeparatedByString:@"&"];
        NSString * realId = [orderArr firstObject];
        self.orderId = realId;
        
        [self.payBtn setTitle:@"取消" forState:UIControlStateNormal];
        
    }
    
    return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //检查出orderid
    NSString * absStr = [webView request].URL.absoluteString;
    if([absStr containsString:@"cross_server_buy_order_info"] && [self.orderId length] > 0)
    {//下单成功
        if(self.latestFunc == CBGDetailWebFunction_PayInScan || self.latestFunc == CBGDetailWebFunction_PayOrder)
        {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [self runDetailJSWithFunctionType:self.latestFunc];
//            });
        }
        
    }
    
    NSLog(@"webViewDidFinishLoad %@",absStr);
//    NSString * compareStr = @"http://xyq.cbg.163.com/cgi-bin/usertrade.py?act=cross_server_buy_order_info&orderid=";
//
//    

    
    
}

-(void)runDetailJSWithFunctionType:(CBGDetailWebFunction)function
{
    self.latestFunc = function;
    NSString * funcJS = [self detailRunJSForDetailWebFunction:function];
    if(funcJS){
        [self.showWeb stringByEvaluatingJavaScriptFromString:funcJS];
    }
}
-(NSString * )detailRunJSForDetailWebFunction:(CBGDetailWebFunction)function
{
    NSString * runJs = nil;
    switch (function)
    {
        case CBGDetailWebFunction_None:
        {
            
        }
            break;
        case CBGDetailWebFunction_Order:
        {
            runJs = @"window.document.getElementById('btn_buy').click();";
        }
            break;
        case CBGDetailWebFunction_Cancel:
        {
            if(self.orderId)
            {
                runJs = @"window.document.getElementById('pay_form_box').getElementsByTagName('a')[1].click();";
                self.orderId = nil;
            }
        }
            break;
        case CBGDetailWebFunction_PayOrder:
        {
            if(self.orderId)
            {
                runJs = @"window.document.getElementById('pay_form_box').getElementsByTagName('a')[0].click();";
            }else{
                runJs = [self detailRunJSForDetailWebFunction:CBGDetailWebFunction_Order];
            }
        }
            break;
        case CBGDetailWebFunction_PayInScan:
        {
            if(self.orderId)
            {
                runJs = @"window.document.getElementById('qr_pay_entry').click();";
            }else{
                runJs = [self detailRunJSForDetailWebFunction:CBGDetailWebFunction_Order];
            }
        }
            break;
            
        default:
            break;
    }
    return runJs;
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
