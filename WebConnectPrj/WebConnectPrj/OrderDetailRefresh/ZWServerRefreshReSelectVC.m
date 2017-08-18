//
//  ZWServerRefreshReSelectVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/18.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerRefreshReSelectVC.h"
#import "ZWServerEquipServerSelectedVC.h"
@interface ZWServerRefreshReSelectVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView * listTable;
@property (nonatomic,strong) UIView * tipsView;
@property (nonatomic, strong) NSArray * allKeys;
@property (nonatomic, strong) NSDictionary * serNameDic;
@property (nonatomic, strong) NSMutableArray * selectedArr;;
@end

@implementation ZWServerRefreshReSelectVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.selectedArr = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad
{
    self.showRightBtn = YES;
    self.rightTitle = @"默认";
    
    self.viewTtle = @"选择刷新";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * cacheStr = total.serverIDCache;
    NSArray * arr = [cacheStr componentsSeparatedByString:@","];
    [self.selectedArr addObjectsFromArray:arr];
    
    NSDictionary * serNameDic = total.serverNameDic;
    self.serNameDic = serNameDic;
    self.allKeys = [serNameDic allKeys];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    self.listTable = table;
    [self.view addSubview:table];
    
    //    [self.view addSubview:self.tipsView];
    //增加按钮开关，设定8000上、下、无区分
    //    [self refreshPriceStatusForTitleShow];
    
}
-(UIView *)tipsView{
    if(!_tipsView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"限定价格";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
//        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnExchangePriceStatusWithTapedBtn:)];
//        [aView addGestureRecognizer:tapGes];
//        self.tipsView = aView;
    }
    return _tipsView;
}



-(void)submit
{
    [DZUtils noticeCustomerWithShowText:@"使用默认"];
    
    [self.selectedArr removeAllObjects];
    NSArray * normalArr = @[
//                            @"蓬莱岛",
                            @"蝴蝶泉",
                            @"紫禁城",
                            @"钱塘江",
                            @"姑苏城",
                            @"西栅老街",
                            @"太和殿",
                            @"灵隐寺",
                            @"流花湖",
                            @"雄鹰岭",
                            @"逍遥城",
                            @"星海湾",
                            @"钓鱼岛",
                            @"沂水雪山",
                            @"绍兴兰亭",
                            @"珍宝阁",
                            @"绍兴鉴湖",
                            @"生日快乐",
                            ];
    
    NSArray * allNames = [self.serNameDic allValues];
    NSArray * idArr = [self.serNameDic allKeys];
    NSString * combineName = [allNames componentsJoinedByString:@","];
    for(NSInteger index = 0 ;index < [normalArr count]; index ++)
    {
        NSString * subStr = [normalArr objectAtIndex:index];
        NSRange range = [combineName rangeOfString:subStr];
        if(range.length > 0)
        {
            NSString * subName = [combineName substringWithRange:NSMakeRange(0, range.location)];
            NSArray * arr = [subName componentsSeparatedByString:@","];
            NSInteger keyIndex = [arr count] - 1;
            NSString * keyStr = [idArr objectAtIndex:keyIndex];
            [self.selectedArr addObject:keyStr];
        }
    }
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.serverIDCache = [self.selectedArr componentsJoinedByString:@","];
    [total localSave];

    
    [self.listTable reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.allKeys count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"ZAPanicSortSchoolVC_Panic_Style";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSInteger index = indexPath.section ;
    NSNumber * serverNum = [self.allKeys objectAtIndex:index];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.serNameDic objectForKey:serverNum];
    
    UIColor * txtColor = [UIColor blackColor];
    if([self.selectedArr containsObject:[serverNum stringValue]])
    {
        txtColor = [UIColor redColor];
    }
    cell.textLabel.textColor = txtColor;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.section ;
    NSNumber * serverNum = [self.allKeys objectAtIndex:index];
    NSString * serverKey = [serverNum stringValue];
    
    if([self.selectedArr containsObject:serverKey]){
        [self.selectedArr removeObject:serverKey];
    }else{
        [self.selectedArr addObject:serverKey];
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.serverIDCache = [self.selectedArr componentsJoinedByString:@","];
    [total localSave];
    
    [self.listTable reloadData];
    
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
