//
//  ZAPasswordController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAPasswordController.h"
#import "PWDTimeManager.h"
#import "ZANumberView.h"
#import "ZALineNumberView.h"
#import "ZANumberCollectionCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ZAWarnCancelTopVC.h"
#import "ZANumOnlyCell.h"
#import "LocalTimingRefreshManager.h"
#import "ZAPWDNumLineView.h"
#import "AppDelegate.h"
#import "DPViewController+WebCheck.h"
#import "ZARecorderManager.h"
#import "ZAQuickCancelController.h"
@interface ZAPasswordController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableString * password;
    UILabel * redLbl;
    ZAPWDNumLineView * inputNum;
    
    BaseRequestModel * _startModel;
    
    BOOL needRunWarning;
    BOOL showNumTxt;
}
@property (nonatomic,strong) ZAWarnCancelTopVC * saveCancel;
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) AVAudioPlayer *player;
@end

@implementation ZAPasswordController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        password = [NSMutableString string];
        needRunWarning = YES;
        showNumTxt = YES;
    }
    return self;
}

-(void)startGoBack:(id)sender
{
    NSArray * arr = [self.navigationController viewControllers];
    if(arr&&[arr count]>1)
    {
        UIViewController * vc = (UIViewController *)[arr firstObject];
        if([vc isKindOfClass:[ZAQuickCancelController class]])
        {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController * vc = appDel.homeCon.viewDeckController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    self.viewTtle = @"请输入密码";
    self.showLeftBtn = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    self.titleBar.hidden = YES;
    
    UIView * bgView = self.view;
    
    CGFloat startY = FLoatChange(55);
    
    NSString * str = @"请输入密码验证身份";
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize topSize = [str sizeWithFont:[UIFont systemFontOfSize:FLoatChange(18)]];
    topSize.width = SCREEN_WIDTH * 0.8;
    rect.size = topSize;
    UILabel * titleLbl = [[UILabel alloc] initWithFrame:rect];
    titleLbl.font = [UIFont systemFontOfSize:FLoatChange(18)];
    titleLbl.text = str;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLbl];
    titleLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, startY);
    titleLbl.textColor = [UIColor whiteColor];

    
    if(_showBack)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bgView addSubview:btn];
        [btn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startGoBack:) forControlEvents:UIControlEventTouchUpInside];
        
        //统一处理返回按钮大小
        CGPoint pt = btn.center;
        CGFloat btnWidth = SCREEN_WIDTH * 65.0/750.0;
        CGRect rect = btn.frame;
        rect.size = CGSizeMake(btnWidth, btnWidth);
        btn.frame = rect;
        pt.x = SCREEN_WIDTH * 0.1;
        pt.y = startY;
        btn.center = pt;

        CALayer * layer = btn.layer;
        [layer setCornerRadius:btn.bounds.size.height/2.0];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
        

    }
    
    startY = CGRectGetMaxY(titleLbl.frame);
    CGFloat sepY = FLoatChange(20) ;
    if(SCREEN_Check_Special) sepY = 3;
    rect = [[UIScreen mainScreen] bounds];
    titleLbl = [[UILabel alloc] initWithFrame:rect];
    titleLbl.font = [UIFont systemFontOfSize:FLoatChange(43)];
    titleLbl.text = @"10";
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLbl];
    [titleLbl sizeToFit];
    titleLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, startY + sepY + titleLbl.bounds.size.height /2.0);
    
    startY = CGRectGetMaxY(titleLbl.frame);
    
    sepY = FLoatChange(35);
    ZAPWDNumLineView * line = [[ZAPWDNumLineView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [bgView addSubview:line];
//    line.radius = 8;
    line.currentIndex = 0;
    line.center = CGPointMake(SCREEN_WIDTH / 2.0, startY + sepY + line.bounds.size.height / 2.0);
    inputNum = line;
    
    CGFloat numWidth = SCREEN_WIDTH;
    CGFloat numHeight = SCREEN_WIDTH;
    
    if(SCREEN_HEIGHT==480) numHeight = SCREEN_WIDTH * 0.8;
//    CGFloat insetX = 0.15 * SCREEN_WIDTH / 2.0;
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    CGFloat itemNormal = numWidth/3;
    NSInteger itemLeng = (int) itemNormal;
    if((int)numWidth%3!=0) itemLeng ++;
    
    flowLayout.itemSize = CGSizeMake(itemLeng,(numHeight)/4.0);
    flowLayout.minimumInteritemSpacing = 0;
//    CGFloat insetY = (numHeight / 4.0 - itemLeng ) /2.0;
//    insetX = insetX/2.0;
//    ZANumberView
    
    //分割线位于cell内，不改变
    ZANumberView * num = [[ZANumberView alloc] initWithFrame:CGRectMake(0, 0, itemLeng * 3, numHeight) collectionViewLayout:flowLayout];
    num.scrollEnabled = NO;
    num.backgroundColor = [UIColor clearColor];
    num.delegate = self;
    num.dataSource = self;
    [num registerNib:[UINib nibWithNibName:@"ZANumberCollectionCell" bundle:nil]
          forCellWithReuseIdentifier:@"ZANumberView_Cell"];
    [num registerNib:[UINib nibWithNibName:@"ZANumOnlyCell" bundle:nil]
forCellWithReuseIdentifier:@"ZANumOnlyCell"];
    
    [bgView addSubview:num];
//    num.backgroundColor = [UIColor clearColor];
//    num.scrollEnabled = NO;
    
//    num.backgroundColor = [UIColor redColor];

    startY = CGRectGetMaxY(line.frame);
    num.center = CGPointMake(SCREEN_WIDTH / 2.0, (SCREEN_HEIGHT - numHeight/2.0));
    
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0,startY, 100, 100);
//    [btn setTitle:@"正确密码" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(tapedOnFinishBtn:) forControlEvents:UIControlEventTouchDown];
//    [bgView addSubview:btn];
//    btn.backgroundColor = [UIColor greenColor];
//    CALayer * layer = btn.layer;
//    [layer setCornerRadius:btn.bounds.size.height/2.0];
//    
//    startY += 100;
//    btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0, startY, 100, 100);
//    [btn setTitle:@"错误密码" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(tapedOnErrorBtn:) forControlEvents:UIControlEventTouchDown];
//    [bgView addSubview:btn];
//    btn.backgroundColor = [UIColor redColor];
//    layer = btn.layer;
//    [layer setCornerRadius:btn.bounds.size.height/2.0];
    
    
//    UILabel * numLbl = [[UILabel alloc] initWithFrame:self.view.bounds];
//    numLbl.text = @"10";
//    numLbl.font = [UIFont systemFontOfSize:20];
//    [numLbl sizeToFit];
//    [bgView addSubview:numLbl];
//    numLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, 10 + numLbl.bounds.size.height / 2.0);
//    redLbl = numLbl;
//    numLbl.textAlignment = NSTextAlignmentCenter;
    
    titleLbl.hidden = YES;
    redLbl = titleLbl;
    
    //如果没有展示返回按钮
    if(!_showBack)
    {
        
    }else
    {
        UILabel * subLbl = [[UILabel alloc] initWithFrame:titleLbl.bounds];
        [bgView addSubview:subLbl];
        subLbl.textColor = [UIColor whiteColor];
        subLbl.text = @"输入安全码解除防护";
        subLbl.font = [UIFont systemFontOfSize:FLoatChange(15)];
        [subLbl sizeToFit];
        subLbl.center = titleLbl.center;
        subLbl.hidden = YES;
    }
    
    if(self.needTimer)
    {
        [self restartPWDTimerRefresh];
    }
    
    //背景图
    rect = [[UIScreen mainScreen] bounds];
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"dark_blue_total"];
    img.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];
    
    //保存参数
    
    [self prepAudio];
//    [self refreshWebListenForSpecialController];
}
-(void)effectiveForWebStateCheck:(BOOL)connect
{
    if(!connect)
    {
        [self showDialogForWebConnectError];
    }else{
        [self.diaAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}
-(void)showDialogForWebConnectError
{
    if(!self.diaAlert)
    {
        NSString * log = @"当前无网络，无法解除预警。我们会在解除预警之前和您联系，并将情况通知您的联系人";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"当前无网络"
                                                         message:log
                                                        delegate:nil
                                               cancelButtonTitle:@"确认"
                                               otherButtonTitles:nil, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
    
}
-(void)stopPWDTimerAndHiddenLbl
{
    UILabel * titleLbl = redLbl;
    titleLbl.hidden = YES;
    PWDTimeManager * manager = [PWDTimeManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
}
-(void)startNextRequestWithDelay
{
    __weak typeof(self) weakSelf = self;
    NSTimeInterval number = 10;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(number * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf startWebStateStartWarningRequest];
    });
}

-(void)restartPWDTimerRefresh
{
    UILabel * titleLbl = redLbl;
    PWDTimeManager * manager = [PWDTimeManager sharedInstance];
    __weak ZAPasswordController * weakSelf = self;
    manager.refreshInterval = 1;
    manager.functionInterval = 1;
    manager.funcBlock = ^()
    {
        [weakSelf localSecondTimeDidChange:nil];
    };
    
    titleLbl.text = @"10";
    titleLbl.hidden = NO;
    [manager saveCurrentAndStartAutoRefresh];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZANumOnlyCell *cell = (ZANumOnlyCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString * txt = cell.numLbl.text;
    
    UIColor * color = Password_White_Selected_BG_Color;//白色
    if([txt length]>1)
    {
        color = Password_Red_Selected_BG_Color;
//        if (_showBack) color = Password_White_BG_Color;
    }
    cell.bgView.backgroundColor = color;
    

}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    ZANumOnlyCell *cell = (ZANumOnlyCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString * txt = cell.numLbl.text;
    
    UIColor * color = Password_White_BG_Color;//白色
    if([txt length]>1)
    {
        color = Password_Red_BG_Color;
//        if (_showBack) color = Password_White_BG_Color;
    }
    cell.bgView.backgroundColor = color;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZANumOnlyCell *cell = (ZANumOnlyCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZANumOnlyCell" forIndexPath:indexPath];
//    cell.bgView.backgroundColor = [UIColor redColor];
//    cell.numberStr = [NSString stringWithFormat:@"%ld",indexPath.section];
    NSInteger secNum = indexPath.section;
    NSInteger rowNum = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    cell.bgView.backgroundColor = Password_White_BG_Color;
    cell.numLbl.textColor = [DZUtils colorWithHex:@"00344F"];
    
    UIColor * lineColor = [DZUtils colorWithHex:@"9AAAB4"];
    cell.leftLine.backgroundColor = lineColor;
    cell.topLine.backgroundColor = lineColor;
    
    cell.leftLine.hidden = rowNum == 0;
    cell.topLine.hidden = secNum == 0;
    cell.numLbl.font = [UIFont systemFontOfSize:FLoatChange(30)];
    cell.numLbl.hidden = NO;
    cell.imgView.hidden = YES;
    if(secNum==3)
    {
        NSString * iconName = nil;
        UIColor * bgColor = Password_Red_BG_Color;
        NSString * lblTxt = @"0";
        switch (rowNum)
        {
            case 0:
                bgColor = Password_Red_BG_Color;
                lblTxt = @"110";
                cell.numLbl.textColor = [UIColor whiteColor];
                iconName = @"password_110";
                break;
            case 2:
                bgColor = Password_Red_BG_Color;
                lblTxt = @"120";
                cell.numLbl.textColor = [UIColor whiteColor];
                iconName = @"password_120";
                
                cell.imgView.hidden = NO;
                cell.numLbl.hidden = YES;
                break;
            case 1:
                lblTxt = @"0";
                bgColor = Password_White_BG_Color;
                break;
            default:
                break;
        }
        
//        if(_showBack)
//        {
//            //隐藏文本展示区域
//            bgColor = Password_White_BG_Color;
//        }

        cell.bgView.backgroundColor = bgColor;
        cell.numLbl.text = lblTxt;
        
//        BOOL hideEnd = rowNum!=1&&_showBack;
//        cell.numLbl.hidden = hideEnd;
        return cell;
    }
    
    cell.hidden = NO;
//    NSString * subStr = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger number = rowNum + secNum * 3 + 1;
//    cell.numberStr = [NSString stringWithFormat:@"%ld",(long)number];
//    NSString* eveStr = [self eveSubStringFromStr:subStr andNum:number];
//    cell.subStr = eveStr;
////    cell.circleColor = [DZUtils colorWithHex:@"969696"];
//    cell.redIconImg.hidden = YES;
    cell.numLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //进行补全
    NSInteger secNum = indexPath.section;
    NSInteger rowNum = indexPath.row;
    ZANumOnlyCell *cell = (ZANumOnlyCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if(secNum==3&&rowNum!=1)
    {
//        if(_showBack)
//        {
//            return;
//        }
        NSString * number = cell.numLbl.text;
        [self tapedOnBottomTwoButtonWithString:number];
        return;
    }
    
    NSString * numStr = cell.numLbl.text;
    [password appendString:numStr];
    
    [inputNum refreshCurrentIndex:[password length] WithTempTxt:numStr];
    
    [self checkCurrentPWDWith:password];
}
-(void)tapedOnDeleteBtn
{
    if(password && [password length]>0)
    {
        NSInteger index = [password length] - 1;
        NSRange range = NSMakeRange(index, 1);
        
        [password deleteCharactersInRange:range];
    }
    [inputNum refreshCurrentIndex:[password length] WithTempTxt:nil];
}
-(void)tapedOnBottomTwoButtonWithString:(NSString *)str
{
    if([str isEqualToString:@"120"])
    {
        [self tapedOnDeleteBtn];
        return;
    }
    
    NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",str];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    
    
    
//    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
//    manager.priority = @"2";
//
//
//    [self startWebStateStartWarningRequest];

}

-(NSString * )eveSubStringFromStr:(NSString *)total andNum:(NSInteger)num
{
    if(num<=1||num>9) return nil;
    
    NSInteger startIndex = 0;
    NSInteger startNum = num - 2;
    
    NSInteger subNum = 3;
    if(num==7||num==9) subNum = 4;
    
    for (int i=0;i<startNum;i++)
    {
        NSInteger subNum = 3;
        if(i==7-2||i==9-2) subNum = 4;
        startIndex += subNum;
    }
    
    NSString * str = [total substringWithRange:NSMakeRange(startIndex, subNum)];
    //添加空格
    NSString * space = @" ";
    NSMutableString * result = [NSMutableString stringWithString:str];
    for (int i= 0;i<[str length]-1; i++)
    {
        NSInteger j = [str length] - i - 1;
        [result insertString:space atIndex:j];
    }
    
    return result;
    return nil;
}

-(void)localSecondTimeDidChange:(id)sender
{
    [[PWDTimeManager sharedInstance] finishFunctionAndSaveCurrentTime];
    
    NSString * time =  redLbl.text;
    NSInteger number = NSNotFound;
    number = [time intValue];
    
    number --;
    
    if(number>=0)
    {
        redLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
        [self.player play];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }

    if(number == 0)
    {
        //倒计时结束，关闭
        [[PWDTimeManager sharedInstance] endAutoRefreshAndClearTime];
        
        //提高等级
        LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
        manager.priority = @"1";
        [manager refreshRefreshTimeWithHeighPriority];
        
        
        //如果，用户设置的倒计时结束，则不调用立即预警  任由服务器判定
        if(self.timeEndState||!needRunWarning)
        {
            //进入下一界面
            [self showStateWarningWaitingWithRecorderState:NO];
            return;
        }
        [self startWebStateStartWarningRequest];
    }
}


-(void)tapedOnFinishBtn:(id)sender
{
    [self checkCurrentPWDWith:password];
    
}

-(void)tapedOnErrorBtn:(id)sender
{
    [self checkCurrentPWDWith:password];


}

static SystemSoundID shake_sound_male_id = 0;
- (BOOL) prepAudio
{
    NSError *error;
    NSString * path = nil;
    
//    path = [[NSBundle mainBundle] pathForResource:@"shake_sound_male" ofType:@"wav"];
//    if (path) {
//        //注册声音到系统
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
//        AudioServicesPlaySystemSound(shake_sound_male_id);
//        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
//    }
//    return YES;

    path = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"mp3"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    if (!self.player)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    [self.player prepareToPlay];
    [self.player setNumberOfLoops:1];
    return YES;
}

-(void)checkCurrentPWDWith:(NSString *)str
{
    if(!str) return;
    if([str length]!=4) return;
    
    
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        [self showDialogForWebConnectError];
        [password setString:@""];
        inputNum.currentIndex = 0;
        return;
    }
    
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * savePwd = local.password;
    if(!savePwd) savePwd = @"1111";
    savePwd = [savePwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL success = [str isEqualToString:savePwd];
    if(!success)
    {
        [password setString:@""];
        inputNum.currentIndex = 0;
        
        [self.player play];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        NSString * notice = [NSString stringWithFormat:@"密码错误，请重新输入"];
        NSLog(@"%s %@",__FUNCTION__,savePwd);
#ifdef  USERDEFAULT_DEBUG_FOR_COMPANY
        notice = [NSString stringWithFormat:@"(密码%@)密码错误，请重新输入",savePwd];
#endif
        
        [DZUtils noticeCustomerWithShowText:notice];
        //进行错误提示，清空密码
        return;
    }
    
    //密码校验通过
    //暂停计时器、取消之前网络请求，在取消失败时，重启倒计时
    [[PWDTimeManager sharedInstance] endAutoRefreshAndClearTime];
    _startModel = nil;
    

    [self startWebStateCancelRequest];
    //自身界面发送
//    //改为发送通知,结束界面
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    [notificationCenter postNotificationName:NOTIFICATION_CANCEL_WARNING object:nil];
    
}
-(void)startWebStateStartWarningRequest
{
    
    //发送立即启动请求，网络不畅时，之前的发送未成功
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    WarnTimingModel * local = total.timeModel;
    
    //之前有发起过，结束之前不操作
    if(_startModel) return;
    
    
    WarningModel * model = (WarningModel *) _startModel;
    if(!model){
        model = [[WarningModel alloc] init];
        [model addSignalResponder:self];
        _startModel = model;
    }
    model.timingId = local.timeId;
    model.scene = local.scene;
    model.type = WarningModel_TYPE_START;
    [model sendRequest];
}

-(void)startWebStateCancelRequest
{
    //网络请求，通知服务器,如果本地没有保存的倒计时数据,直接返回
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    WarnTimingModel * local = total.timeModel;
    
    //数据上传，通知解除
    WarningModel * model = (WarningModel *) _dpModel;
    if(!model){
        model = [[WarningModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.timingId = local.timeId;
    model.scene = local.scene;
    model.type = WarningModel_TYPE_STOP;
    [model sendRequest];
}
#pragma mark -
-(void)showStateWarningWaitingWithRecorderState:(BOOL)recorder
{
    UINavigationController * naVC = self.navigationController;
    UIViewController * vc = nil;
    if([naVC.viewControllers count]>0)
    {
        vc = [naVC.viewControllers objectAtIndex:0];
    }
    
    if (vc&&[vc isKindOfClass:[ZAWarnCancelTopVC class]])
    {
        [naVC popViewControllerAnimated:YES];
    }else
    {
        ZAWarnCancelTopVC * warn = self.saveCancel;
        if(!warn)
        {
            warn = [[ZAWarnCancelTopVC alloc] init];
            warn.startRecorder = recorder;
            __weak typeof(self) weakSelf = self;
            warn.TapedCancelWarnBlock = ^()
            {
                [weakSelf.navigationController popViewControllerAnimated:YES];
                //            [weakSelf restartPWDTimerRefresh];
                [weakSelf stopPWDTimerAndHiddenLbl];
            };
            
            if(self.needTimer)
            {
                self.saveCancel = warn;
            }
        }
        [self.navigationController pushViewController:warn animated:YES];

    }

}

-(void)stopTimerAndClearLocalData
{
    
    //关闭可能的本地通知
    [DZUtils localTimeNotificationCancel];
    
    
    //关闭可能的倒计时
//    [DZUtils saveCurrentTimingWithEndTime:nil andTotalSecond:0];
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    
    WarnTimingModel * pre = total.timeModel;
    WarnTimingModel * model = [[WarnTimingModel alloc] init];
    
    //截止时间
    NSDate * localEndDate = total.endDate;
    
    
    NSString * scene = nil;
    if(pre && [pre isKindOfClass:[WarnTimingModel class]])
    {
        scene = [pre.scene copy];
        model.timeId = pre.timeId;
        model.scene = pre.scene;
        model.duration = pre.duration;
    }
    
    total.endDate = nil;
    total.totalTime = 0;
    total.showPWD = NO;
    total.timeModel = nil;
    total.warningId = nil;
    total.runErr = NO;
    [total localSave];
    
    ZARecorderManager * recorder = [ZARecorderManager sharedInstanceManager];
    BOOL inRecorder = [recorder isInRecordering];
    
    [TimeRefreshManager stopCurrentAllRefreshManager];
//    //预警解除，关闭数据上传
//    [[LocationTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
//    
//    
//    //倒计时结束，关闭
//    [[PWDTimeManager sharedInstance] endAutoRefreshAndClearTime];

     //本应在此界面完成界面回收，但新增了分享后
    [self runForPwdCheckSuccessBlock];
    
//    NOTIFICATION_RECORDER_CANCEL_STATE
    //进行录音取消提示
    if(inRecorder)
    {
        recorder.DoneRecorderAndFinishedExchangeBlock = nil;
        [recorder stopRecorder];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECORDER_CANCEL_STATE object:nil];
    }

    
    
    //弹出分享界面，仅针对
    //当倒计时模式，主动密码关闭，启动分享页面
    if(scene && [scene intValue]==1)
    {
        //按照服务器返回数据比对
        
        
        //发送分享的消息
        //剩余秒数date,与当前时间比较得出
        NSDate * startDate = nil;
        
        if(!localEndDate)
        {
            //虚假时间
            NSTimeInterval total = [model.duration doubleValue];
            startDate = [[NSDate date] dateByAddingTimeInterval:-total];
        }else
        {
            NSTimeInterval total = [model.duration doubleValue];
            startDate = [localEndDate dateByAddingTimeInterval:-total];
        }
        
        //截止时间
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMING_SUCCESS_SHARING_STATE object:startDate];
    }
}
-(void)runForPwdCheckSuccessBlock
{
    if(self.PWDCheckSuccessBlock)
    {
        self.PWDCheckSuccessBlock(PWDCheckFinishType_PWD);
    }
}


#pragma mark WarnTimingModel
handleSignal( WarningModel, requestError )
{
    [self hideLoading];
    WarningModel * model = (WarningModel *)signal.source;
    if(model.type == WarningModel_TYPE_START)
    {
        _startModel = nil;
        [DZUtils noticeCustomerWithShowText:@"网络异常，预警失败，系统将自动重试"];
        //刷新重启倒计时
//        [self restartPWDTimerRefresh];
        
        //当启动失败时，展示此条件
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.runErr = YES;
        [total localSave];
        
        [self startNextRequestWithDelay];
        return;
    }
    if(model.type == WarningModel_TYPE_STOP)
    {
        //取消失败，倒计时继续
        [[PWDTimeManager sharedInstance] saveCurrentAndStartAutoRefresh];
        _dpModel = nil;
        [password setString:@""];
        inputNum.currentIndex = 0;
        
        NSString * errStr = kAppNone_Service_Error;
        if([DZUtils deviceWebConnectEnableCheck])
        {
            [self showDialogForWebConnectError];
            return;
        }
        [DZUtils noticeCustomerWithShowText:errStr];
        return;
    }
    
//    [self stopTimerAndClearLocalData];
}
handleSignal( WarningModel, requestLoading )
{
//    WarningModelTYPE type = [(WarningModel *)_dpModel type];
//    if(type==WarningModel_TYPE_START)
//    {//后台预警的，暂不加等待框
//        return;
//    }
    [self showLoading];
}
handleSignal( WarningModel, requestLoaded )
{
    [self hideLoading];
    [password setString:@""];
    inputNum.currentIndex = 0;
    
    WarningModel * model = (WarningModel *)signal.source;
    if(model.type == WarningModel_TYPE_START)
    {
        //成功启动后，不再启动
        needRunWarning = NO;
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.runErr = NO;
        [total localSave];
        
        _startModel = nil;
        //去掉提示，改为界面跳转
        //提示用户已经通知服务器启动预警
//        [DZUtils noticeCustomerWithShowText:@"怕怕客服部门已经获知您的求助需求，很快会和您联系"];
        if([DZUtils checkAndNoticeErrorWithSignal:signal])
        {
             [self showStateWarningWaitingWithRecorderState:YES];
        }
        return;
    }
    _dpModel = nil;
    
    __weak typeof(self) weakSelf = self;
    
    BOOL result =[DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        if(!netEnable)
        {
            [weakSelf showDialogForWebConnectError];
            return ;
        }
        [DZUtils noticeCustomerWithShowText:kAppNone_Service_Error];
    }];
    
    if(result)
    {
        [self stopTimerAndClearLocalData];
    }


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
