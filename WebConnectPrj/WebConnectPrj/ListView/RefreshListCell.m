//
//  RefreshListCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshListCell.h"

@implementation RefreshListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.coverBtn.hidden = YES;
    [self.coverBtn addTarget:self
                      action:@selector(tapedONCopyBtn:)
            forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)tapedONCopyBtn:(id)sender
{
    if(self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(tapedOnRefreshCellCopyDelegateWithIndex:)])
    {
        [self.cellDelegate tapedOnRefreshCellCopyDelegateWithIndex:self.indexPath];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
