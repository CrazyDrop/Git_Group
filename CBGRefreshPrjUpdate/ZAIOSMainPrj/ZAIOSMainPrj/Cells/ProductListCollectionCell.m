//
//  ProductListCollectionCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/25.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ProductListCollectionCell.h"
//#import "ProductListDataModel.h"
@interface ProductListCollectionCell()
@property (nonatomic,strong) UILabel * nameLbl;
@property (nonatomic,strong) UILabel * titleLbl;
@property (nonatomic,strong) UIImageView * imgIcon;
@end

@implementation ProductListCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        CGRect rect = self.bounds;
        CGFloat boudsWidth = rect.size.width;
        CGFloat minWidth = MIN(rect.size.width, rect.size.height);
        
        CGFloat imgWidth = minWidth * 0.6;
//        if(minWidth!=rect.size.width)
//            imgWidth = minWidth * 0.6;
        
        UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgWidth)];
        [self addSubview:icon];
        icon.center = CGPointMake(boudsWidth/2.0, imgWidth/2.0);
        self.imgIcon = icon;
        
        CALayer * aLayer = icon.layer;
        aLayer.cornerRadius = imgWidth/2.0;
        aLayer.borderWidth = 0.5;
        aLayer.borderColor = [[UIColor clearColor] CGColor];
        
        
        rect.origin.y = imgWidth;
        rect.size.height -= imgWidth;
        UILabel * bottomLbl = [[UILabel alloc] initWithFrame:rect];
        bottomLbl.backgroundColor = [UIColor clearColor];
        [self addSubview:bottomLbl];
        bottomLbl.center = CGPointMake(boudsWidth/2.0, imgWidth + rect.size.height / 2.0 );
        self.nameLbl = bottomLbl;
        bottomLbl.textAlignment = NSTextAlignmentCenter;
        
        
        
        
        UILabel * titLbl = [[UILabel alloc] initWithFrame:rect];
        titLbl.backgroundColor = [UIColor clearColor];
        titLbl.textColor = [UIColor whiteColor];
        [icon addSubview:titLbl];
        titLbl.center = CGPointMake(imgWidth/2.0, imgWidth/2.0);
        self.titleLbl = titLbl;
        titLbl.textAlignment = NSTextAlignmentCenter;

        
        
        
        
        
    }
    return self;
}

-(void)loadCellData:(id)sender
{
//    if(![sender isKindOfClass:[ProductListDataModel class]])  return;
//    ProductListDataModel * eve = (ProductListDataModel *)sender;
//    BOOL noUse = eve.proType == TYPEPRODUCT_SHOW_TYPE_UNUSE;
//    self.nameLbl.text = eve.proName;
//    _titleLbl.text = eve.proDes;
    
    CALayer * aLayer = _imgIcon.layer;
//    if(noUse)
    {
        _imgIcon.backgroundColor = [UIColor grayColor];
        _nameLbl.textColor = [UIColor grayColor];
        aLayer.borderColor = [[UIColor redColor] CGColor];
        
    }
//    else
    {
        _imgIcon.backgroundColor = MAIN_LIST_BGCOLOR;
        _nameLbl.textColor = MAIN_LIST_BGCOLOR;
        aLayer.borderColor = [[UIColor clearColor] CGColor];
    }
    
    
    
}
@end