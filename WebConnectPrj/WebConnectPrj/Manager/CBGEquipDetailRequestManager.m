//
//  CBGEquipDetailRequestManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/28.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "CBGEquipDetailRequestManager.h"
#import "Equip_listModel.h"
#import "RefreshEquipDetailDataManager.h"
#import "EquipExtraModel.h"
#import "JSONKit.h"
//#import "CreateModel.h"

@interface CBGEquipDetailRequestManager()
{
    BaseRequestModel * _dpModel;
    NSMutableDictionary * cacheUrlDic;//当前缓存的url
    NSMutableDictionary * operationUrlDic;//运行中的url
    NSMutableDictionary * requestModels;
}
@end

@implementation CBGEquipDetailRequestManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static CBGEquipDetailRequestManager  * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
-(instancetype)init
{
    self =  [super init];
    if(self)
    {
        cacheUrlDic  = [NSMutableDictionary dictionary];
        operationUrlDic = [NSMutableDictionary dictionary];
        requestModels = [NSMutableDictionary dictionary];
    }
    return self;
}


//启动
-(void)startDetailRequest
{
    RefreshEquipDetailDataManager * manager = [[RefreshEquipDetailDataManager alloc] init];
    [manager addSignalResponder:self];
    [manager sendRequest];
    
    _dpModel = manager;
    return;
    [self runForNextCacheUrl];
}

//取消全部
-(void)cancelAndClearTotal
{
    @synchronized (cacheUrlDic) {
        [cacheUrlDic removeAllObjects];
    }
    @synchronized (requestModels)
    {
        for (BaseRequestModel * eve  in requestModels) {
            [eve removeSignalResponder:self];
//            [eve cancel];
        }
        [requestModels removeAllObjects];
    }
    
    @synchronized (operationUrlDic) {
        [operationUrlDic removeAllObjects];
    }
}


//添加新请求，依据对应的model
-(void)addDetailEquipRequestUrlWithEquipModel:(id)request
{
//    Equip_listModel * listModel = (Equip_listModel *)request;
//    
//    RefreshEquipDetailDataManager * model = (RefreshEquipDetailDataManager *) _dpModel;
//    if(!model){
//        model = [[RefreshEquipDetailDataManager alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    
//    [model sendRequest];
//    
//    
//    return;
    
    Equip_listModel * listModel = (Equip_listModel *)request;
    NSString * url = listModel.detailDataUrl;
    @synchronized (cacheUrlDic)
    {
        [cacheUrlDic setObject:listModel forKey:url];
    }
    
    [self runForNextCacheUrl];
}
-(void)runForNextCacheUrl
{
    @synchronized (operationUrlDic)
    {
        if([operationUrlDic count] >= 5)
        {
            return;
        }
        
        if([cacheUrlDic count] == 0)
        {
            return;
        }
        
        NSArray * array = [cacheUrlDic allKeys];
        NSString * keyDic = nil;
        for (NSInteger index = 0;index < [array count] ;index++ )
        {
            keyDic = [array objectAtIndex:index];
            if(![operationUrlDic objectForKey:keyDic])
            {
                break;
            }
        }
        
        
        Equip_listModel * listModel = (Equip_listModel *)[cacheUrlDic objectForKey:keyDic];
        [operationUrlDic setObject:listModel forKey:keyDic];
        
        RefreshEquipDetailDataManager * request = [self requestModelFromWebUrl:listModel.detailDataUrl];
        [request sendRequest];
    }
}
-(RefreshEquipDetailDataManager *)requestModelFromWebUrl:(NSString *)url
{
    RefreshEquipDetailDataManager * request = [requestModels objectForKey:url];
    if(!request)
    {
        request = [[RefreshEquipDetailDataManager alloc] init];
        [request addSignalResponder:self];
        
        [requestModels setObject:request forKey:url];
    }
    request.listUrl = url;
    return request;
}
-(void)clearRequestModelsForRequestUrl:(NSString *)url restore:(BOOL)store
{
    @synchronized (requestModels)
    {
        BaseRequestModel * eve = [requestModels objectForKey:url];
        [eve removeSignalResponder:self];

        [requestModels removeObjectForKey:url];
    }
    if(store)
    {
        @synchronized (cacheUrlDic)
        {
            id model = [operationUrlDic objectForKey:url];
            [cacheUrlDic setObject:model forKey:url];
        }
    }else{
        [cacheUrlDic removeObjectForKey:url];
    }
    @synchronized (operationUrlDic)
    {
        [operationUrlDic removeObjectForKey:url];
    }
}


#pragma mark RefreshEquipDetailDataManager
handleSignal( RefreshEquipDetailDataManager, requestError )
{
    RefreshEquipDetailDataManager * obj = signal.source;
    NSString * url =  obj.listUrl;
    
    [self clearRequestModelsForRequestUrl:url restore:YES];
    [self runForNextCacheUrl];
}
handleSignal( RefreshEquipDetailDataManager, requestLoading )
{
}
handleSignal( RefreshEquipDetailDataManager, requestLoaded )
{
    RefreshEquipDetailDataManager *  obj = (RefreshEquipDetailDataManager *) signal.source;
    EquipModel * detail = obj.detailModel;
    NSString * keyUrl = obj.listUrl;
    
    Equip_listModel * list = [operationUrlDic objectForKey:keyUrl];
    list.equipModel = detail;
    list.createTime = detail.selling_time;
    
    EquipExtraModel * extra = nil;
    extra = [self extraModelFromLatestEquipDESC:detail];
    detail.equipExtra = extra;
    
    if(self.DoneDetailBlockForRequestSuccess)
    {
        self.DoneDetailBlockForRequestSuccess(list);
    }
    
    [self clearRequestModelsForRequestUrl:keyUrl restore:NO];

    [self runForNextCacheUrl];
}
#pragma mark ----
-(EquipExtraModel *)extraModelFromLatestEquipDESC:(EquipModel *)detail
{
    NSString * desStr = detail.equip_desc;
    desStr = [self equipExtraStringFromLatestString:desStr];
    
    NSDictionary * desDic = [desStr objectFromJSONString];
    if(!desDic)
    {
        return nil;
    }
//    [CreateModel createModelWithJsonData:desDic rootModelName:@"EquipModelDESDetail"];
    
//    NSLog(@"%s %@",__FUNCTION__,desStr);
    EquipExtraModel * extra = [[EquipExtraModel alloc] initWithDictionary:desDic];

    return extra;
}

-(NSString *)equipExtraStringFromLatestString:(NSString *)desString
{
    NSString * string = nil;
    string = [desString stringByReplacingOccurrencesOfString:@"])" withString:@"}"];
    string = [string stringByReplacingOccurrencesOfString:@"([" withString:@"{"];
    
    string = [string stringByReplacingOccurrencesOfString:@"})" withString:@"]"];
    string = [string stringByReplacingOccurrencesOfString:@"({" withString:@"["];
    
    string = [string stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    string = [string stringByReplacingOccurrencesOfString:@",}" withString:@"}"];
    
    string = [self completeStringFromLatest:string];
    
    return string;
}

-(NSString *)completeStringFromLatest:(NSString *)latest
{
    NSString * sepStr = @":";
    NSArray * array = [latest componentsSeparatedByString:sepStr];
    NSMutableArray * replaceArr = [NSMutableArray array];
    
    for (NSInteger index = 0; index < [array count]; index++)
    {
        NSString * eve = [array objectAtIndex:index];
        NSString * replace = [self eveCompareReplaceStringFrom:eve];
        [replaceArr addObject:replace];
    }
    
    NSString * total = [replaceArr componentsJoinedByString:sepStr];
    return total;
}
-(NSString *)eveCompareReplaceStringFrom:(NSString *)shortString
{
    NSString * last = [shortString substringFromIndex:[shortString length] - 1];
    BOOL isNumber =  [DZUtils checkSubCharacterIsNumberString:last];
    
    if(!isNumber)
    {
        return shortString;
    }
    //    18521,]),6:  这种数据，处理为     18521,]),"6"
    NSString * replace = [NSString stringWithString:shortString];
    NSMutableString * checkStr = [NSMutableString string];//数字字符
    
    //由后向前，取到非数字字符截止
    for (NSInteger index = 0; index < [shortString length]; index ++ )
    {
        NSInteger number = [shortString length] - index - 1;
        NSString * eve = [replace substringWithRange:NSMakeRange(number, 1)];
        BOOL realNumber = [DZUtils checkSubCharacterIsNumberString:eve];
        if(realNumber)
        {
            [checkStr insertString:eve atIndex:0];
        }else{
            break;
        }
    }
    NSRange  range = NSMakeRange([shortString length] - [checkStr length] , [checkStr length]);
    replace = [replace stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"\"%@\"",checkStr]];
    return replace;
}






@end
