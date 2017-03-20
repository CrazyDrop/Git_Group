//
//  OLEGOFooterNoneControl.m
//  WebConnectPrj
//
//  Created by Apple on 15/2/11.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOFooterAndHeaderNoneControl.h"

@implementation OLEGOFooterAndHeaderNoneControl
-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    //	NSLog(@"egoRefreshScrollViewDidScroll scrollView.contentOffset.y= %f", scrollView.contentOffset.y);
    header.hidden = YES;
}

-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidEndDragingForScrollView:(UIScrollView *)scrollView
{

    
}

-(void)egoHeaderView:(OLEGORefreshView *)footer doneReloadingScrollView:(UIScrollView *)scrollView andEndString:(NSString *)str
{

}
@end
