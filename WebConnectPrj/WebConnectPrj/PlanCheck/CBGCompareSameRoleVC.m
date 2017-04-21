//
//  CBGComareSameRoleVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGCompareSameRoleVC.h"
#import "CBGListModel.h"
#import "ZACBGDetailWebVC.h"

@interface CBGCompareSameRoleVC ()

@end

@implementation CBGCompareSameRoleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSArray * listArr = self.compareArr;
    NSInteger number = [listArr count];
    
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [bgView addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(rect.size.width * number, rect.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;

    CGFloat bgWidth = scrollView.bounds.size.width;
    
    for (NSInteger index = 0;index < number ; index ++)
    {
        CBGListModel * list = [listArr objectAtIndex:index];
        CGFloat start = bgWidth * index;
        rect.origin.x = start;
        
        ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
        [self addChildViewController:detail];
        detail.cbgList = list;
        [scrollView addSubview:detail.view];
        detail.view.frame = rect;
        
        if(index != 0)
        {
            detail.leftBtn.hidden = YES;
        }
    }
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
