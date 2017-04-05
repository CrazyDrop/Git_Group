//
//  BaseRequestModel.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "Samurai_ModelInstance.h"

@interface BaseRequestModel : SamuraiModel


@signal(requestLoading)
@signal(requestLoaded)
@signal(requestError)

- (void)sendRequest;

@end
