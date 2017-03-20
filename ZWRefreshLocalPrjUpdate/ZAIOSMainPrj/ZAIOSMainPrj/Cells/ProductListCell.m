//
//  ProductListCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ProductListCell.h"
@interface ProductListCell()
@property (nonatomic,strong) UIImageView * imgView;
@end


@implementation ProductListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)     [self createCellViews];
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self createCellViews];
}

-(void)createCellViews
{
    UIImageView * img = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:img];
    img.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.imgView = img;
}

-(void)loadCellData:(id)sender
{
    if([DZUtils isValidateString:sender])
    {
        UIImage * img = [UIImage imageNamed:sender];
        _imgView.image = img;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
