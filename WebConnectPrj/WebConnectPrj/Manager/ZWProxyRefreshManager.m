//
//  ZWProxyRefreshManager.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWProxyRefreshManager.h"
#import "VPNProxyModel.h"
#import "SessionReqModel.h"
@interface ZWProxyRefreshManager()
@property (nonatomic, strong) NSArray * proxySubCache;
@property (nonatomic, strong) NSArray * sessionSubCache;
@end
@implementation ZWProxyRefreshManager

+(instancetype)sharedInstance
{
    static ZWProxyRefreshManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}

-(NSArray *)proxySubCache
{
    if(!_proxySubCache)
    {
        NSMutableArray * edit = [NSMutableArray arrayWithArray:self.proxyArrCache];
        [edit sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber * number1 = [NSNumber numberWithInteger:[(VPNProxyModel * )obj1 errorNum]];
            NSNumber * number2 = [NSNumber numberWithInteger:[(VPNProxyModel * )obj2 errorNum]];
            
            return [number1 compare:number2];
        }];
        
        NSArray * sub = nil;
        if([edit count] > 300){
           sub = [edit subarrayWithRange:NSMakeRange(0, 300)];
        }else{
            sub = edit;
        }
        _proxySubCache = edit;
    }
    return _proxySubCache;
}

-(NSArray *)sessionSubCache
{
    if(!_sessionSubCache)
    {
        NSMutableArray * edit = [NSMutableArray arrayWithArray:self.sessionArrCache];
        
        [edit sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
         {
             SessionReqModel * req1 = (SessionReqModel *)obj1;
             SessionReqModel * req2 = (SessionReqModel *)obj2;
             
            NSNumber * number1 = [NSNumber numberWithInteger:[req1.proxyModel errorNum]];
            NSNumber * number2 = [NSNumber numberWithInteger:[req2.proxyModel errorNum]];
            
             if(req1.proxyModel.errored){
                 number1 = [NSNumber numberWithInteger:NSIntegerMax - 100];
             }
             
             if(req2.proxyModel.errored){
                 number2 = [NSNumber numberWithInteger:NSIntegerMax - 100];
             }
             
            return [number1 compare:number2];
        }];
        
        NSArray * sub = nil;
        NSInteger edintNum = 100;//3s内，100个代理分派请求
        if([edit count] > edintNum){
            sub = [edit subarrayWithRange:NSMakeRange(0, edintNum)];
        }else{
            sub = edit;
        }
        _sessionSubCache = sub;
    }
    return _sessionSubCache;
}
-(void)refreshLatestSessionArrayWithCurrentProxyArr
{
    [self clearProxySubCache];
    
    NSMutableDictionary * editDic = [NSMutableDictionary dictionary];
    NSArray * current = self.sessionArrCache;
    for (NSInteger index = 0;index < [current count] ;index ++ )
    {
        SessionReqModel * req = [current objectAtIndex:index];
        [editDic setObject:req forKey:req.proxyModel.idNum];
    }
    
    NSArray * proArr = self.proxyArrCache;
    for (NSInteger index = 0;index < [proArr count] ;index ++ )
    {
        VPNProxyModel * model = [proArr objectAtIndex:index];
        SessionReqModel * req = [editDic objectForKey:model.idNum];
        if(!req)
        {
            SessionReqModel * reqModel = [[SessionReqModel alloc] initWithProxyModel:model];
            [editDic setObject:reqModel forKey:model.idNum];
        }
    }
    self.sessionArrCache = [editDic allValues];
}

-(void)refreshLatestSessionArrayWithReplaceArray:(NSArray *)array
{
    
    [self clearProxySubCache];

    if(!array || [array count] == 0) return;
    
    NSMutableDictionary * editDic = [NSMutableDictionary dictionary];
    NSArray * current = self.sessionArrCache;
    for (NSInteger index = 0;index < [current count] ;index ++ )
    {
        SessionReqModel * req = [current objectAtIndex:index];
        [editDic setObject:req forKey:req.proxyModel.idNum];
    }
    
    NSArray * proArr = array;
    for (NSInteger index = 0;index < [proArr count] ;index ++ )
    {
        VPNProxyModel * model = [proArr objectAtIndex:index];
        model.errored = NO;
        model.errorNum = 0;
        SessionReqModel * reqModel = [[SessionReqModel alloc] initWithProxyModel:model];
        [editDic setObject:reqModel forKey:model.idNum];
    }
    
    self.sessionArrCache = [editDic allValues];
}

-(void)clearProxySubCache
{
    self.proxySubCache = nil;
    self.sessionSubCache = nil;
}
//-(NSArray *)proxySessionModelArray
//{
//    NSMutableArray * models = [NSMutableArray array];
//    NSArray * dicArr = self.proxyArrCache;
//    if(dicArr)
//    {
//        for (NSInteger index =0; index < [dicArr count]; index ++)
//        {
//            NSDictionary * eve = [dicArr objectAtIndex:index];
//            VPNProxyModel * model = [[VPNProxyModel alloc] initWithDetailDic:eve];
//            SessionReqModel * req = [[SessionReqModel alloc] initWithProxyModel:model];
//            [models addObject:req];
//        }
//    }
//    return models;
//}


-(NSString *)proxyFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * proxyPath = [documentsDirectory stringByAppendingPathComponent:@"localProxy.plist"];
    return proxyPath;
}
-(NSArray *)readLocalFileProxyList
{
    NSString * proxyPath = [self proxyFilePath];
    NSArray * array = [NSArray arrayWithContentsOfFile:proxyPath];
    
    NSMutableArray * editArr = [NSMutableArray array];
    NSArray * dicArr = array;
    if(dicArr)
    {
        for (NSInteger index =0; index < [dicArr count]; index ++)
        {
            NSDictionary * eve = [dicArr objectAtIndex:index];
            VPNProxyModel * model = [[VPNProxyModel alloc] initWithDetailDic:eve];
            [editArr addObject:model];
        }
    }
    return editArr;
}
-(void)localRefreshListFileWithLatestProxyList
{
    NSString * proxyPath = [self proxyFilePath];
    NSFileManager *defaultFileManager=[NSFileManager defaultManager];
    BOOL isExit=[defaultFileManager fileExistsAtPath:proxyPath];
    if (!isExit)
    {
        [defaultFileManager createFileAtPath:proxyPath contents:nil attributes:nil];
    }
    
    NSArray * data = self.proxyArrCache;
    NSArray * fileArr = [VPNProxyModel proxyDicArrayFromDetailProxyArray:data];
    [fileArr writeToFile:proxyPath atomically:YES];
}

@end
