//
//  ZAAnnotationModel.h
//  ZAIOSMainPrj
//
//  Created by 赵宪云 on 15/12/31.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ZAAnnotationModel : NSObject<MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
//自定义大头针图片
@property(nonatomic,copy) NSString *icon;
@end
