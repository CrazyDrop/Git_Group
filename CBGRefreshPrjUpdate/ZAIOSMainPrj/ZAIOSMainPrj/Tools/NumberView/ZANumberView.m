//
//  ZANumberView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/24.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZANumberView.h"
#import "ZANumberCollectionCell.h"
@interface ZANumberView()<UICollectionViewDataSource>
{
    
}
@end

@implementation ZANumberView

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if(self)
    {
//        self.dataSource = self;

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//
//-(NSInteger)numberOfItemsInSection:(NSInteger)section
//{
//    return 4;
//}
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 3;
//}
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ZANumberCollectionCell *cell = (ZANumberCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZANumberView_Cell" forIndexPath:indexPath];
//    
//    cell.backgroundColor = [UIColor redColor];
//    //    cell.backgroundColor = [UIColor colorWithPatternImage:[self.results objectAtIndex:indexPath.row]];
//    return cell;
//}


@end
