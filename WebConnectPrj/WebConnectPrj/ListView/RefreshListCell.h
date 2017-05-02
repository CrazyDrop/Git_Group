//
//  RefreshListCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RefreshCellCopyDelgate <NSObject>

-(void)tapedOnRefreshCellCopyDelegateWithIndex:(NSIndexPath *)indexPath;

@end

@interface RefreshListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalNumLbl;
@property (weak, nonatomic) IBOutlet UILabel *latestMoneyLbl;

@property (weak, nonatomic) IBOutlet UILabel *sellRateLbl;
@property (weak, nonatomic) IBOutlet UILabel *sellTimeLbl;

@property (weak, nonatomic) IBOutlet UILabel *sellDateLbl;
@property (weak, nonatomic) IBOutlet UIButton *coverBtn;

@property (weak, nonatomic) NSIndexPath * indexPath;
@property (weak, nonatomic) id<RefreshCellCopyDelgate> cellDelegate;

@end
