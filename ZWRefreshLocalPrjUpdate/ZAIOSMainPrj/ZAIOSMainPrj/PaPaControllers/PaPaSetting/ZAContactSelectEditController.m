//
//  ZAContactSelectEditController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactSelectEditController.h"
#import "ZAContactSelectCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "ZATfdLocalCheck.h"
@interface ZAContactSelectEditController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * selectTable;
    BOOL startWithSelect;
}
//当前选中文本
@property (nonatomic,strong) NSIndexPath * selectPath;
@property (nonatomic,strong) NSArray * selectArray;

@end

@implementation ZAContactSelectEditController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        startWithSelect = NO;
    }
    return self;
}

-(NSArray *)selectArray
{
    if(!_selectArray)
    {
        NSMutableArray * array = [NSMutableArray array];
        if(PaPaContact_Select_Relation == _selectType)
        {
//            [array addObjectsFromArray:[NSArray arrayWithObjects:@"父女",@"母女",@"姐妹",@"兄妹",@"亲戚",@"闺蜜",@"朋友",@"同事", nil]];
            [array addObjectsFromArray:[NSArray arrayWithObjects:@"爸妈",@"另一半",@"闺蜜",@"亲戚",@"同学",@"同事",@"朋友", nil]];
        }else
        {
            [array addObjectsFromArray:[NSArray arrayWithObjects:@"小时候一起折过千纸鹤",@"一起上过补习班",@"一起学过跆拳道",@"同住一个小区",@"一起学过绘画",@"经常到家里做客的邻居",@"隔壁楼下的大哥", nil]];

        }
        self.selectArray = array;
    }
    return _selectArray;
}


- (void)viewDidLoad
{
    self.selectArray = nil;
    if(PaPaContact_Select_None == self.selectType)
    {
        self.selectType = PaPaContact_Select_Relation;
    }
    PaPaContactSelectType type = self.selectType;
    if(type==PaPaContact_Select_Relation)
    {
        self.viewTtle = @"设定关系";
    }else
    {
        self.viewTtle = @"设定暗号";
    }
    self.rightTitle = @"完成";
    self.showRightBtn = YES;
    
    NSArray * titles = self.selectArray;
    NSString * current = _editText;
    
    //默认值
    self.selectPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if(current&&[current length]>0)
    {
        NSInteger index = [titles indexOfObject:current];
        if(index==NSNotFound)
        {
            startWithSelect = NO;
        }else
        {
            startWithSelect = YES;
            self.selectPath = [NSIndexPath indexPathForRow:index inSection:1];
            self.editText = nil;
        }
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height -= rect.origin.y;
    
    TPKeyboardAvoidingTableView * table = [[TPKeyboardAvoidingTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:table];
    table.dataSource = self;
    table.delegate = self;
    selectTable = table;
    //    table.rowHeight = FLoatChange(44);
    //    self.listTable = table;
//    [table registerClass:[ZAContactSelectCell class] forCellReuseIdentifier:@"ZAContactSelectCell"];
    
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.separatorColor = [UIColor clearColor];
    table.backgroundColor = [UIColor clearColor];
    
    CGFloat topSpace = FLoatChange(48);
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
    topView.backgroundColor = [UIColor clearColor];
    table.tableHeaderView = topView;
    
    CGFloat txtHeight = FLoatChange(30);
    CGFloat startX = FLoatChange(15);
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, txtHeight)];
    [topView addSubview:txtLbl];
    txtLbl.text = @"自定义";
    txtLbl.backgroundColor = [UIColor clearColor];
    txtLbl.font = [UIFont systemFontOfSize:FLoatChange(14)];
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0 + startX, topSpace/2.0);
    
//    UIView * line = [DZUtils ToolCustomLineView];
//    rect = line.frame;
//    rect.origin.y = topView.bounds.size.height - rect.size.height;
//    line.frame = rect;
//    [topView addSubview:line];
//    line.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
}

-(void)submit
{
    if(self.selectPath.section==0)
    {
        [selectTable setContentOffset:CGPointZero animated:NO];
        ZAContactSelectCell * cell = (ZAContactSelectCell *)[selectTable cellForRowAtIndexPath:self.selectPath];
        [cell.contactTxtTfd resignFirstResponder];
    }
    
    ZAContactSelectCell * cell = (ZAContactSelectCell *)[selectTable cellForRowAtIndexPath:self.selectPath];
    NSString * endTxt = cell.contactTxtTfd.text;
    NSString * errorStr = nil;
    errorStr = [ZATfdLocalCheck localCheckInputContactRelationNameWithText:endTxt];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    if([endTxt isEqualToString:ZA_Relation_Replace_TXT])
    {
        [DZUtils noticeCustomerWithShowText:[NSString stringWithFormat:@"\"%@\"为关键字,请设置其他文本",ZA_Relation_Replace_TXT]];
        return;
    }
    
    
    if(self.TapedOnFinishedBlock)
    {
        self.TapedOnFinishedBlock(_selectType,endTxt);
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0) return 1;
    return [self.selectArray count];
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//        if(indexPath.section!=0)
//            return FLoatChange(38.5);
    
    return FLoatChange(46);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.section;
    NSInteger indexNum = indexPath.row;
    
    //    if([self tableviewShowDetailWithSection:secNum])
    {
        static NSString *cellDetailIdentifier = @"ContactListDetailCell";
        ZAContactSelectCell *cell = (ZAContactSelectCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
        if (cell == nil)
        {
            cell = [[ZAContactSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        NSString * title = nil;
        NSString * placeHold = nil;
        if(secNum==0)
        {
            placeHold = @"请输入与联系人的关系";
            title = _editText;
        }else {
            
            if([self.selectArray count]>indexNum)
            {
                title = [self.selectArray objectAtIndex:indexNum];
            }
        }
        
        if(secNum != 0 )
        {
            cell.coverLbl.text = title;
        }
        cell.coverLbl.hidden = (secNum == 0);
        cell.contactTxtTfd.placeholder = placeHold;
        cell.contactTxtTfd.text = title;
        cell.contactTxtTfd.hidden = secNum!=0;
        cell.contactTxtTfd.enabled = (secNum == 0 && self.selectPath.section==0);
        cell.selectedArrow.hidden = ([indexPath compare:self.selectPath] != NSOrderedSame);
        cell.bottomLine.hidden = (secNum==0||indexNum==[self.selectArray count]-1);
        
        return cell;
    }
    
    NSAssert(YES, @"逻辑上不会到达");
    return  nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果之前是可编辑的，暂时先保留编辑的内容
    if(self.selectPath.section==0)
    {
        ZAContactSelectCell * cell = (ZAContactSelectCell *)[tableView cellForRowAtIndexPath:self.selectPath];
        if(cell){
            self.editText = cell.contactTxtTfd.text;
            startWithSelect = NO;
        }
    }
    
    //进行选中效果，刷新列表
    [self refreshTableViewCellWithTableView:tableView andCurrentPath:indexPath];
    
    if(indexPath.section==0)
    {
        ZAContactSelectCell * cell = (ZAContactSelectCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.contactTxtTfd becomeFirstResponder];;
    }
    
}

-(void)refreshTableViewCellWithTableView:(UITableView *)atable andCurrentPath:(NSIndexPath *)path
{
    NSIndexPath * current = self.selectPath;
    if([path compare:current]==NSOrderedSame||!path)
    {
        return;
    }
    
    NSMutableArray * array = [NSMutableArray array];
    [array addObject:path];
    
    if(current)
    [array addObject:current];
    
    self.selectPath = path;
    
    UITableView * table = atable;
    [table beginUpdates];
    [table reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    [table endUpdates];
}

//上下边线
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section==0) return FLoatChange(47);
    return 1.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section==0)
    {
        CGFloat topSpace = FLoatChange(47);
        UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
        footerView.backgroundColor = [UIColor clearColor];
        
        CGFloat txtHeight = FLoatChange(30);
        CGFloat startX = FLoatChange(15);
        UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, txtHeight)];
        [footerView addSubview:txtLbl];
        txtLbl.text = @"常用关系";
        if(_selectType == PaPaContact_Select_PWDString){
            txtLbl.text = @"推荐暗号";
        }
        txtLbl.backgroundColor = [UIColor clearColor];
        txtLbl.font = [UIFont systemFontOfSize:FLoatChange(14)];
        txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0 + startX, topSpace/2.0);
        
        UIView * line = [DZUtils ToolCustomLineView];
        [footerView addSubview:line];
        return footerView;
    }
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = Custom_Gray_Line_Color;
//    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return line;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = Custom_Gray_Line_Color;
//    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return line;
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
