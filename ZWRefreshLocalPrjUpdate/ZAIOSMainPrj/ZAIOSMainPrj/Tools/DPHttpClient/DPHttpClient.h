//
//  DPHttpClient.h
//  Photography
//
//  Created by jialifei on 15/4/14.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@interface DPHttpClient : NSObject

@property (nonatomic,retain) id delegate;

@property (nonatomic) SEL finishAction;
@property (nonatomic) SEL failAction;
@property (nonatomic) SEL cancelAction;
@property (nonatomic) MBProgressHUD *myHud;
@property (nonatomic,retain) UINavigationController *myNav;
@property (nonatomic) SEL reloadViewData;

-(void)getData:(NSString *)url finish:(SEL)finishAction fail:(SEL)failACtion;
-(void)postData:(NSString *)url params:(NSMutableDictionary *)dic file:(NSMutableArray *)array  finish:(SEL)finishAction fail:(SEL)failACtion andCancel:(SEL)cancelAction;


-(void)postSingleImg:(NSString *)url params:(NSMutableDictionary *)dic file:(NSMutableArray *)array  finish:(SEL)finishAction fail:(SEL)failACtion andCancel:(SEL)cancelAction;

-(void)showLoginView;
@end
