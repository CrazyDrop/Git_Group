//
//  OLMainTopicListTableView.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-4.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLMainTopicListTableView.h"
#import "OLMainTopicListCell.h"
@interface OLMainTopicListTableView()<UITableViewDataSource>
@end
@implementation OLMainTopicListTableView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self =[super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.rowHeight = 320.0f;
        self.loadMoreType = OL_LIST_DATA_LOAD_TYPE_AUTO_LOAD;
    }
    return self;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArr count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"identifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[OLMainTopicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSInteger index = indexPath.row;
    id eveData = nil;
    if ([self.dataArr count]>index) {
        eveData = [self.dataArr objectAtIndex:index];
    }
    //根据data，对cell赋值
    [(OLMainTopicListCell *)cell refreshTopicListCellWithData:eveData];
    return cell;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
