//
//  ZAContactListController+Event.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController.h"

//相关事件处理
@interface ZAContactListController (Event)

//1、删除事件
//3、添加紧急联系人事件
//4、通知他事件
//列表点击事件
    //2、重新刷新事件，直接调用网络请求
-(void)deleteContactObjectWithIndexPath:(NSIndexPath *)path;

-(void)tapedOnAddMoreBtn:(id)sender;

-(void)refreshContactNumForCell:(UITableViewCell *)cell;

-(void)tapedOnCellForNextEditViewWithIndexPath:(NSIndexPath *)path;




@end
