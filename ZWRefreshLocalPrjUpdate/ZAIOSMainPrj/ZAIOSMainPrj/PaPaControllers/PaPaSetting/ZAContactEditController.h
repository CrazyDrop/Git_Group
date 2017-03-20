//
//  ZAContactEditController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/17.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"
//增加删除功能
@interface ZAContactEditController : DPWhiteTopController

//不能移除提示
@property (nonatomic,assign) BOOL canNotRemove;

//不能编辑，无效的紧急联系人，且有效紧急联系人数量已满
@property (nonatomic,assign) BOOL editUnable;

//无效联系人，有修改的提示
@property (nonatomic,assign) BOOL unableAndCompare;


@property (nonatomic,strong) ContactsModel * editContact;

@end
