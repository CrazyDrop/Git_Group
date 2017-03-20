//
//  ZAContactListController+DataSource.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController+DataSource.h"
#import "ZAContactEditCell.h"
#import "ZAContactListCell.h"
#import "JZSwipeCell.h"
#import "ZASwipePartCell.h"
#import "ZAContactListController+Event.h"
#import "ZAContactListController+DataRequest.h"

#define ZA_Contact_List_Section_Height  FLoatChange(9)
#define ZA_Contact_List_Cell_Height  FLoatChange(47)
#define ZA_Contact_List_NoneData_Height  FLoatChange(120)
@implementation ZAContactListController (DataSource)

ADD_DYNAMIC_PROPERTY(NSArray*, OBJC_ASSOCIATION_RETAIN, dataList, setDataList);
ADD_DYNAMIC_PROPERTY(NSArray*, OBJC_ASSOCIATION_RETAIN, effectiveList, setEffectiveList);
ADD_DYNAMIC_PROPERTY(NSArray*, OBJC_ASSOCIATION_RETAIN, deletedList, setDeletedList);

-(BOOL)showNoneView
{
    if(!self.dataList) return YES;
    return [self.dataList count]==0;
}

-(void)refreshLocalTableView
{
    
    [self splitForEffectiveWithContactList:self.dataList];
    
    //隐藏添加按钮
    noticeLbl.hidden = [self.deletedList count]==0;
    
    //创建table
    UITableView * table = self.listTable;
    table.tableHeaderView = [self topHeaderView];
    [table reloadData];
}

-(BOOL)addContactButtonHiddenState
{
    return NO;//修改为始终展示
//    if([self.effectiveList count]>=[ZA_Contacts_List_Max_Effective_Num intValue]) return YES;
//    if([self.dataList count]>=[ZA_Contacts_List_Max_Num intValue]) return YES;
//    
    return NO;
}
-(void)splitForEffectiveWithContactList:(NSArray *)array
{
    NSMutableArray * deleted = [NSMutableArray array];
    NSMutableArray * effective = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ContactsModel * contact = (ContactsModel *)obj;
        NSString * tag = contact.isDeleted;
        if(tag && [tag boolValue])
        {
            [deleted addObject:obj];
        }else{
            [effective addObject:obj];
        }
    }];
    
    self.effectiveList = effective;
    self.deletedList = deleted;
}
-(ZAWebErrorView *)errorView
{
    if (!_errorView)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
        rect.size.height -= rect.origin.y;
        
        __weak typeof(self) weakSelf = self;
        ZAWebErrorView * error = [[ZAWebErrorView alloc] initWithFrame:rect];
        error.ZAWebRequestRetryBlock = ^()
        {
            [weakSelf requestForContactList];
        };
        self.errorView = error;
    }
    return _errorView;
}

-(UIView *)topHeaderView
{
    if([self showNoneView])
    {
        CGFloat topSpace = ZA_Contact_List_NoneData_Height;
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
        topView.backgroundColor = [UIColor clearColor];
        topView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        CGFloat imgWidth = FLoatChange(55);
        CGFloat imgHeight = imgWidth * 133.0/123.0;
        UIImage * image = [UIImage imageNamed:@"contact_list_none"];
        UIImageView * img = [[UIImageView alloc] initWithImage:image];
        img.frame = CGRectMake(0, 0, imgWidth, imgHeight);
        [topView addSubview:img];
        img.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(70));
        
        CGFloat startX = FLoatChange(14);
        CGRect rect = topView.bounds;
        rect.origin.x = startX;
        rect.size.width -= startX;
        
        UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
        [topView addSubview:aLbl];
        aLbl.text = @"建议您最少设置两个联系人";
        aLbl.textAlignment = NSTextAlignmentCenter;
        aLbl.font =[UIFont systemFontOfSize:FLoatChange(11)];
        aLbl.textColor = [UIColor lightGrayColor];
        aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, ZA_Contact_List_NoneData_Height);
        
        return topView;
    }
    return nil;
}

-(UITableView *)listTable
{
    if (!_listTable)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
        rect.size.height -= rect.origin.y;
        
        UITableView * table = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        table.dataSource = self;
        table.delegate = self;
        table.rowHeight = ZA_Contact_List_Cell_Height;
        self.listTable = table;
        [table registerClass:[ZAContactEditCell class] forCellReuseIdentifier:@"ContactListDetailCell"];
        
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.separatorColor = [UIColor clearColor];
        table.backgroundColor = [UIColor clearColor];
        
        
        rect = table.bounds;
        CGFloat bottomHeight = FLoatChange(92);
        rect.size.height = bottomHeight;
        UIView * bottom = [[UIView alloc] initWithFrame:rect];
        bottom.backgroundColor = [UIColor clearColor];
        
        
        CGFloat startX = FLoatChange(14);

        UILabel * noneLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,rect.size.width - startX*2 , rect.size.height)];
        noneLbl.backgroundColor = [UIColor clearColor];
        [bottom addSubview:noneLbl];
        noneLbl.textColor = [UIColor lightGrayColor];
//        noneLbl.textColor = Custom_Blue_Button_BGColor;
        noneLbl.textAlignment = NSTextAlignmentLeft;
        noneLbl.text =@"说明：联系人明确表示不认识您，或号码有误时，将被置为无效";
        noneLbl.hidden = YES;
        noneLbl.numberOfLines = 0;
        noneLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
        [noneLbl sizeToFit];
        noticeLbl = noneLbl;
        
        rect.size.width *=  (255/320.0);
        rect.size.height *= (40/92.0);
        
        UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addMoreBtn.tag = 1001;
        addMoreBtn.frame = rect;
        addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, bottomHeight*2.5/3.0);
        [addMoreBtn setTitle:@" + 添加新的联系人" forState:UIControlStateNormal];
        [addMoreBtn addTarget:self action:@selector(tapedOnAddMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
        [bottom addSubview:addMoreBtn];
        [addMoreBtn setBackgroundColor:Custom_Blue_Button_BGColor];
        [addMoreBtn refreshButtonSelectedBGColor];
        
        noneLbl.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMinY(addMoreBtn.frame)/2.0);
        
        CALayer * layer = addMoreBtn.layer;
        [layer setCornerRadius:5];
        
        table.tableFooterView = bottom;
        
        
        addMoreBtn.hidden = [self addContactButtonHiddenState];
        noticeLbl.hidden = [self.deletedList count]==0;
    }

    return _listTable;
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.effectiveList count] + [self.deletedList count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ZA_Contact_List_Cell_Height;
}

//增加cell上下边距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([self.deletedList count]>0 && section == [self.effectiveList count])
    {
        return ZA_Contact_List_Cell_Height;
    }
    return ZA_Contact_List_Section_Height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if([self.deletedList count]>0 && section == [self.effectiveList count])
    {
        CGFloat topSpace = ZA_Contact_List_Cell_Height;
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
        topView.backgroundColor = Custom_View_Gray_BGColor;
        topView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        CGFloat startX = FLoatChange(14);
        CGRect rect = topView.bounds;
        rect.origin.x = startX;
        rect.size.width -= startX;
        
        UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
        [topView addSubview:aLbl];
        aLbl.text = @"无效联系人";
        aLbl.font =[UIFont systemFontOfSize:FLoatChange(14)];
        aLbl.textColor = Custom_Blue_Button_BGColor;
        
        return topView;
    }
    //有一处需要展示  无效联系人
    CGFloat topSpace = ZA_Contact_List_Section_Height;
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return topView;
}


-(id)contactModelForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secIndex = indexPath.section;
    ContactsModel * contact = nil;
    if (secIndex < [self.effectiveList count])
    {
        if([self.effectiveList count]>secIndex){
            contact = [self.effectiveList objectAtIndex:secIndex];
        }
    }else
    {
        secIndex -= [self.effectiveList count];
        if([self.deletedList count]>secIndex){
            contact = [self.deletedList objectAtIndex:secIndex];
        }
    }
    return contact;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.section;
    ContactsModel * contact = [self contactModelForIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"ZASwipePartCell";
    ZASwipePartCell *cell = (ZASwipePartCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        //            cell = [[ZAContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andTableView:tableView];
        //            cell.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        
        ZASwipePartCell * swipeCell = [[ZASwipePartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        swipeCell.TapedOnNotificationForUser =^(UITableViewCell * cell){
            [weakSelf refreshContactNumForCell:cell];
        };
        swipeCell.delegate = self;
        
        cell = swipeCell;
    }
    
    NSString * numberStr  = @"一二三四五六七八九十";
    NSString * select = @"一";
    if([numberStr length]>secNum)
    {
        select = [numberStr substringWithRange:NSMakeRange(secNum, 1)];
    }
    
    
    NSString * showStr = [NSString stringWithFormat:@"第%@紧急联系人  :  %@",select,contact.contactName];
    if([contact.isDeleted boolValue]){
        showStr = [NSString stringWithFormat:@"紧急联系人  :  %@",contact.contactName];
    }
    cell.textLabel.text = showStr;
    cell.textLabel.font = [UIFont systemFontOfSize:FLoatChange(14)];
    
    CGSize txtSize = [showStr sizeWithFont:cell.textLabel.font];
    UIView * red = cell.noUseRedCircle;
    red.center = CGPointMake(txtSize.width + red.bounds.size.width/2.0, red.center.y);
    
    cell.noticeBtn.hidden = [contact.isDeleted boolValue];
    cell.noticeRedCircle.hidden = [contact.isContacted boolValue];
    cell.noUseRedCircle.hidden = !([contact.isDeleted boolValue]  && ![contact.isLocalNoticed boolValue]);
    
    return cell;
}
#pragma mark -----
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //当前选中，是否为indexPath
    //进入二级界面
    
    
    [self tapedOnCellForNextEditViewWithIndexPath:indexPath];
    
}


#pragma mark - SWTableViewDelegate
- (void)swipeCell:(JZSwipeCell*)cell tipedOnDeleteBtnOnIndex:(NSInteger)index
{
    NSIndexPath *cellIndexPath = [self.listTable indexPathForCell:cell];
    ContactsModel * contact = [self contactModelForIndexPath:cellIndexPath];

    
    if(![contact.isDeleted boolValue] && [self.effectiveList count]==1)
    {
        [DZUtils noticeCustomerWithShowText:@"无法删除您当前的最后一位紧急联系人"];
        [self.listTable reloadData];
        return;
    }
    // Delete button was pressed
    [self deleteContactObjectWithIndexPath:cellIndexPath];
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    //    switch (index) {
    //        case 0:
    //            NSLog(@"left button 0 was pressed");
    //            break;
    //        case 1:
    //            NSLog(@"left button 1 was pressed");
    //            break;
    //        case 2:
    //            NSLog(@"left button 2 was pressed");
    //            break;
    //        case 3:
    //            NSLog(@"left btton 3 was pressed");
    //        default:
    //            break;
    //    }
}


- (void)swipeCell:(JZSwipeCell*)cell triggeredSwipeWithType:(JZSwipeType)swipeType{
    
}
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.listTable indexPathForCell:cell];
            ContactsModel * contact = [self contactModelForIndexPath:cellIndexPath];
            
            if(![contact.isDeleted boolValue]&&[self.effectiveList count]==1)
            {
                [DZUtils noticeCustomerWithShowText:@"无法删除您当前的最后一位紧急联系人"];
                [self.listTable reloadData];
                return;
            }
            // Delete button was pressed
            [self deleteContactObjectWithIndexPath:cellIndexPath];
            
            break;
        }
        case 1:
        {
            
            break;
        }
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
