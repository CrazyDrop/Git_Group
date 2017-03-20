//
//  DPHttpClient.m
//  Photography
//
//  Created by jialifei on 15/4/14.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "DPHttpClient.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "MKNetworkKit.h"
@implementation DPHttpClient



-(id)init
{
    self = [super init];
    if (self) {

 
    }
      return self;
}

-(void)showLoading
{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView * showView = delegate.window;
    //进行提示
    [MBProgressHUD showHUDAddedTo:showView animated:YES];
}

-(void)hiddenLoading
{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView * showView = delegate.window;
    [MBProgressHUD hideHUDForView:showView animated:YES];
}
-(void)reloadData
{
    if ([_delegate respondsToSelector:_reloadViewData]) {
        [_delegate performSelector:_reloadViewData];
    }
}

-(void)showLoginView
{
    [DZUtils userLogout];
//    [[UserInfo sharedUser].minNavgation popToRootViewControllerAnimated:YES];
}

-(void)callSucessBack :(NSDictionary *)dic
{
    if ([_delegate respondsToSelector:_finishAction]) {
        [_delegate performSelector:_finishAction withObject:dic];
    }
}

-(void)callFailBack:(NSDictionary *)dic
{
    if ([_delegate respondsToSelector:_failAction]) {
        [_delegate performSelector:_failAction withObject:dic];
    }
//    if(![DZUtils isValidateDictionary:dic]){
//        [DZUtils noticeCustomerWithShowText:@"json解析错误"];
//    }
}
-(void)callCancelBack:(NSDictionary *)dic
{
    if ([_delegate respondsToSelector:_cancelAction]) {
        [_delegate performSelector:_cancelAction withObject:dic];
    }
}
-(void)manageData:(NSDictionary *)json
{
    if ([json[@"state"] isEqualToString:@"1"] && [DZUtils isValidateDictionary:json]) {
        [self callSucessBack:json];
    }
    if([json[@"state"] isEqualToString:@"0"]|| ![DZUtils isValidateDictionary:json]){
        [self callFailBack:json];
//        [DZUtils noticeCustomerWithShowText:json[@"info"]];
    }
    if([json[@"state"] isEqualToString:@"2"]){
        [self callFailBack:json];
        [self showLoginView];
    }
}

-(void)getData:(NSString *)url finish:(SEL)finishAction fail:(SEL)failACtion
{
    NSLog(@"---------url-----------------%@",url);
    self.failAction = failACtion;
    self.finishAction = finishAction;
    //网络请求的方法
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithURLString:url];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        [self hiddenLoading];
//   
//        NSError *error;
//        
//        
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        
        
        
        NSString * txt = [[operation responseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
        txt = [txt stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        
        NSDictionary *json = [txt objectFromJSONString];
        
       //NSDictionary *json = [[operation responseString] objectFromJSONStringWithParseOptions:JKParseOptionNone];

        [self manageData:json];
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        
        [self hiddenLoading];
        [self callFailBack:nil];
        [DZUtils noticeCustomerWithShowText:@"网络错误"];
    }];
    [engine enqueueOperation:op];
    [self showLoading];
}

-(void)postData:(NSString *)url params:(NSMutableDictionary *)dic file:(NSMutableArray *)array  finish:(SEL)finishAction fail:(SEL)failACtion andCancel:(SEL)cancelAction
{
    self.failAction = failACtion;
    self.finishAction = finishAction;
    self.cancelAction =cancelAction;
    //网络请求的方法
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithURLString:url params:dic httpMethod:@"POST"];

    if ([DZUtils isValidateArray:array]) {
        for (int i=0;i<[array count] ;i++ )
        {
            NSData * data = [array objectAtIndex:i];
            if(data)
            {
                [op addData:data forKey:@"files" mimeType:@"application/octet-stream" fileName:[NSString stringWithFormat:@"file%d.jpeg",i]];
            }
        }
    }
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];

        NSLog(@"%@",json);
        [self hiddenLoading];
        [self manageData:json];
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hiddenLoading];
        [self callCancelBack:nil];
    }];
    [self showLoading];
    [engine enqueueOperation:op];
}

-(void)postSingleImg:(NSString *)url params:(NSMutableDictionary *)dic file:(NSMutableArray *)array  finish:(SEL)finishAction fail:(SEL)failACtion andCancel:(SEL)cancelAction
{
    self.failAction = failACtion;
    self.finishAction = finishAction;
    self.cancelAction =cancelAction;
    //网络请求的方法
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithURLString:url params:dic httpMethod:@"POST"];
    
    if ([DZUtils isValidateArray:array]) {
        for (int i=0;i<[array count] ;i++ )
        {
            NSData * data = [array objectAtIndex:i];
            if(data)
            {
                [op addData:data forKey:@"file" mimeType:@"application/octet-stream" fileName:@"head.png"];
            }
        }
    }
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        [self hiddenLoading];
        [self manageData:json];
        
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hiddenLoading];
        [self callCancelBack:nil];
        
    }];
    [self showLoading];
    [engine enqueueOperation:op];
}


@end
