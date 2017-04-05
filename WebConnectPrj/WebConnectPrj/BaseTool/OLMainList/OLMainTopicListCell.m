//
//  OLMainTopicListCell.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-4.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLMainTopicListCell.h"
#import "OLTopicListDataModel.h"
#import "UIImageView+WebCache.h"
@interface OLMainTopicListCell()
@property (nonatomic,strong) UIImageView * topImgView;
@end
@implementation OLMainTopicListCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView * img = [[UIImageView alloc] initWithFrame:self.bounds];
        img.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:img];
        
        self.topImgView  = img;
    }
    return self;
}

-(void)refreshTopicListCellWithData:(id)obj{
    if (![obj isKindOfClass:[OLTopicListDataModel class]]) {
        return;
    }
    OLTopicListDataModel * eve = (OLTopicListDataModel *)obj;
    [self.topImgView sd_setImageWithURL:[NSURL URLWithString:eve.imgUrlStr]];
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
