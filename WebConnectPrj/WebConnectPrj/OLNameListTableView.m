//
//  OLNameListTableView.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-11.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLNameListTableView.h"
@interface OLNameListTableView()<UITableViewDataSource,UITableViewDelegate>
{
    
}
@end

@implementation OLNameListTableView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.dataArr = [NSMutableString string];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    static int number = 0;
    number = number+3;
//    number++;
//    number+=3;
    [self.dataArr appendString:[NSString stringWithFormat:@"%d",number]];
//    [self.dataArr appendString:[NSString stringWithFormat:@"%d",number]];
    return 30+number;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * nameListCellIdentify = @"nameListCellIdentify";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:nameListCellIdentify];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameListCellIdentify];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
