//
//  ZWTopRefreshModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/12/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWTopRefreshModel.h"

@implementation ZWTopRefreshModel

-(NSArray *)defaultSortArray
{
    NSArray * arr = @[
                      //未登录刷新数据
                      @"https://www.91zhiwang.com/api/product/list?device_guid=FD75E44A-B582-4A15-BC83-A176D2AD6C08&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&sn=a0f1bceafb522bd32f71cd0ba3675764&timestamp=1480582983160.324&user_id=0",
                      //冯废弃账号刷新数据
                      @"https://www.91zhiwang.com/api/product/list?device_guid=47590D3D-FDD5-49EB-A292-8FE733282562&device_model=iPhone6%2C2&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&session_id=dbb2b4c4759da891b302357a51e1fb8920341501a07e2f45784b9ab70d5f772168fc7293c7b0794d5badf672fcaae28c584a1fc40b3d8543&sn=66fc77708967cdd756b5e6e2f8373185&timestamp=1471228775365.419&user_id=10990659",
                      //未登录第一页数据
                      @"https://www.91zhiwang.com/api/liquidate/product?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&page_no=0&page_size=20&sn=1e80f08301d28e257f09d769e44797bc&sort_order=descend&sort_rule=default&timestamp=1472088446813.252&type=liquidate&user_id=0"
                      ];
    return arr;
}

@end
