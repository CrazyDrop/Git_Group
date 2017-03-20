//
//  ZAContactListController+DataSource.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController.h"
#import "SWTableViewCell.h"
#import "JZSwipeCell.h"
//完成视图的展示，根据数据

@interface ZAContactListController (DataSource)<UITableViewDataSource,
SWTableViewCellDelegate,
JZSwipeCellDelegate,
UITableViewDelegate>

@property (nonatomic,strong) NSArray * dataList;    //全部列表，排序顺序，先有效，后无效

@property (nonatomic,strong) NSArray * effectiveList;   //有效的列表
@property (nonatomic,strong) NSArray * deletedList;     //无效的列表

-(BOOL)showNoneView;

//刷新列表
-(void)refreshLocalTableView;

//取出数据
-(id)contactModelForIndexPath:(NSIndexPath *)indexPath;


@end
