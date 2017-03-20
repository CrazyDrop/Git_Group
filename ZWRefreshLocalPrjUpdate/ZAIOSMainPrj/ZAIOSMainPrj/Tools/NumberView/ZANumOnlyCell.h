//
//  ZANumOnlyCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/22.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZANumOnlyCell : UICollectionViewCell

@property (nonatomic,strong) IBOutlet UIImageView * imgView;

@property (nonatomic,strong) IBOutlet UIView * bgView;
@property (nonatomic,strong) IBOutlet UILabel * numLbl;

@property (nonatomic,strong) IBOutlet UIView * topLine;
@property (nonatomic,strong) IBOutlet UIView * leftLine;


@end
