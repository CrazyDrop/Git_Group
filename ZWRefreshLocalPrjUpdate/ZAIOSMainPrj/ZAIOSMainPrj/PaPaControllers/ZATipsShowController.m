//
//  ZATipsShowController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/25.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATipsShowController.h"

@interface ZATipsShowController ()

@property (nonatomic,strong) UIButton * coverBtn;
@property (nonatomic,strong) UIImageView * showImg;

@property (nonatomic,strong) NSArray * tipImgsArr;
@property (nonatomic,strong) NSArray * coverBtnPtArr;

@property (nonatomic,assign) NSInteger currentIndex;

@end

@implementation ZATipsShowController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.startIndex = NSNotFound;
    }
    return self;
}

-(UIImageView *)showImg
{
    if(!_showImg)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
        self.showImg = img;
    }
    return _showImg;
}
-(UIButton *)coverBtn
{
    if(!_coverBtn)
    {
        CGFloat btnWidth = FLoatChange(180);
        CGFloat btnHeight = FLoatChange(70);
        CGRect rect = CGRectZero;
        rect.size.width = btnWidth;
        rect.size.height = btnHeight;
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = rect;
        [btn addTarget:self action:@selector(tapedOnCoverBtn:) forControlEvents:UIControlEventTouchUpInside];

        self.coverBtn = btn;
    }
    return _coverBtn;
}

-(void)tapedOnCoverBtn:(id)btn
{
    NSInteger index = self.currentIndex;
    if(self.TapedOnCoverBtnBlock)
    {
        self.TapedOnCoverBtnBlock(index);
    }
    
    index ++;
    [self refreshCoverBtnCenterForIndex:index];
    self.currentIndex = index;

//    if(index==2 && self.TapedOnEndFinishedBtnBlock)
//    {
//        self.TapedOnEndFinishedBtnBlock();
//    }
    
}
-(void)refreshCoverBtnCenterForIndex:(NSInteger)index
{
    if(!self.coverBtnPtArr || [self.coverBtnPtArr count]==0) return;
    if([self.coverBtnPtArr count]<=index) return;
    if(index<0) return;
    
    NSString * imgName = [self.tipImgsArr objectAtIndex:index];
    UIImage * img = [UIImage imageNamed:imgName];
    self.showImg.image = img;
    
    NSNumber * num = [self.coverBtnPtArr objectAtIndex:index];
    CGPoint pt = CGPointZero;
    pt.x = SCREEN_WIDTH/2.0;
    pt.y = num.floatValue;
    
    self.coverBtn.center = pt;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat centerY1 = FLoatChange(510);
    CGFloat centerY2 = FLoatChange(360);
    CGFloat centerY3 = FLoatChange(345);
    
    if(SCREEN_HEIGHT == 480){
        centerY1 = FLoatChange(430);
        centerY2 = FLoatChange(303);
        centerY3 = FLoatChange(255);
    }
    
    NSArray * pointXArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:centerY1],[NSNumber numberWithFloat:centerY2],[NSNumber numberWithFloat:centerY3],nil];
    self.coverBtnPtArr = pointXArr;
    
    
    
    NSArray * names = [NSArray arrayWithObjects:@"cover_tips_1",@"cover_tips_2",@"cover_tips_3", nil];
    if(SCREEN_HEIGHT == 480){
        names = [NSArray arrayWithObjects:@"cover_tips_1_480",@"cover_tips_2_480",@"cover_tips_3_480", nil];
    }
    self.tipImgsArr = names;
    
    
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.showImg];
    [self.view addSubview:self.coverBtn];
    
    NSInteger index = 0;
    if(self.startIndex != NSNotFound && self.startIndex>=0 && self.startIndex<[names count])
    {
        index = self.startIndex;
    }
    
    self.currentIndex = index;
    [self refreshCoverBtnCenterForIndex:self.currentIndex];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
