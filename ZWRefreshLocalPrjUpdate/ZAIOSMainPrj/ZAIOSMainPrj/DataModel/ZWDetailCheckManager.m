//
//  ZWDetailCheckManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDetailCheckManager.h"
#import "ZWDataDetailModel.h"
#import "ZALocationLocalModel.h"
@interface ZWCheckModel : NSObject
@property (nonatomic,strong) NSArray * preArr;
@property (nonatomic,strong) NSArray * createArr;
@property (nonatomic,assign) CGFloat minSellRate;
@property (nonatomic,assign) CGFloat maxSellRate;
@end

@implementation ZWCheckModel

@end


@interface ZWDetailCheckManager()
@property (nonatomic,strong) NSMutableDictionary * checkDic;
@end

@implementation ZWDetailCheckManager
+(instancetype)sharedInstance
{
    static ZWDetailCheckManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self){
        self.checkDic = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)refreshLatestCheckArray:(NSArray *)array withSecond:(NSInteger)index
{
    NSString * keyId = [NSString stringWithFormat:@"checkKey%ld",(long)index];
    ZWCheckModel * preModel = [self.checkDic objectForKey:keyId];
    if(!preModel){
        preModel = [self checkModelFromDataArr:array];
        [self.checkDic setObject:preModel forKey:keyId];
        return;
    }
    
    //新老数据的差异  缺少数据  新增数据
    //当前全部数据
    
    ZWCheckModel * latestModel = [self checkModelFromDataArr:array];
    NSMutableArray * totalArr = [NSMutableArray arrayWithArray:preModel.preArr];
    
    //在新的里面遍历，老的不存在的，添加到totalArr
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * detail = (ZWDataDetailModel *)obj;
        NSString * create = detail.created_at;
        if(![preModel.createArr containsObject:create]){
            //查找，之前不存在即添加
            [totalArr addObject:detail];
        }

    }];
    
    
    
    //合并新出现数据和老数据，以便当前数据为全部数据
    NSMutableArray * total = [NSMutableArray array];
    
    //全部里面遍历，不在新的里面的，且sellrate在区间内的标记为有可能售罄的
    [totalArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * detail = (ZWDataDetailModel *)obj;
        NSString * create = detail.created_at;
        if([latestModel.createArr containsObject:create])
        {
            detail.disappearNum = 0;
            detail.finishedDate = nil;
            return ;
        }
        CGFloat sellRate = [detail.annual_rate_str floatValue];
        if( sellRate > latestModel.minSellRate)
        {
            if(index == 0 || sellRate < latestModel.maxSellRate)
            {
                //detail进行处理
                detail.disappearNum ++;
                if(!detail.finishedDate){
                    detail.finishedDate = [NSDate unixDate];
                }
                
                if(detail.disappearNum >= 5)
                {
                    [total addObject:detail];
                }
            }
            
        }

    }];
    
    if([total count]>0)
    {
        [total enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([totalArr containsObject:obj])
            {
                [totalArr removeObject:obj];
            }
        }];
    }

    //替换当前的历史缓存
    preModel = [self checkModelFromDataArr:totalArr];
    [self.checkDic setObject:preModel forKey:keyId];


    if([total count]>0)
    {
        [self localSaveModelArray:total];
    }
    
}
-(void)localSaveModelArray:(NSArray *)disArr
{
    if(!disArr || [disArr count] == 0) return;
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    [disArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [manager localSaveDisappearLocation:obj];
    }];
}
-(void)localRemoveModelArray:(NSArray *)disArr
{
    if(!disArr || [disArr count] == 0) return;
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    [manager clearUploadedLocations:disArr];
}

-(ZWCheckModel * )checkModelFromDataArr:(NSArray *)array
{
    ZWCheckModel * model = [[ZWCheckModel alloc] init];
    NSMutableArray * createArray = [NSMutableArray array];
    __block CGFloat minSell = MAX_INPUT;
    __block CGFloat maxSell = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * detail = (ZWDataDetailModel *)obj;
        [createArray addObject:detail.created_at];
        
        CGFloat eveRate =[detail.annual_rate_str floatValue];
        if(eveRate<minSell){
            minSell = eveRate;
        }
        if(eveRate>maxSell){
            maxSell = eveRate;
        }
    }];
    model.preArr = array;
    model.createArr = createArray;
    model.minSellRate = minSell;
    model.maxSellRate = maxSell;
    return model;
}
-(NSArray *)productsIdFromLastestModelArray:(NSArray *)arr
{
    NSMutableArray * data = [NSMutableArray array];
    for (NSInteger index = 0; index < [arr count]; index ++ )
    {
        ZWDataDetailModel * detail = (ZWDataDetailModel *)[arr objectAtIndex:index];
        if(detail && detail.product_id)
        {
            [data addObject:detail.product_id];
        }else{
            [data addObject:@""];
        }
    }
    return data;
}

//刷新是否售罄，标识存储，缓存上次数据
-(void)refreshLatestTotalArray:(NSArray *)inputArray
{
    ZWCheckModel * pre = self.localCheck;
    
    if(!pre)
    {
        ZWCheckModel * model = [[ZWCheckModel alloc] init];
        model.createArr = [self productsIdFromLastestModelArray:inputArray];
        model.preArr = inputArray;
        self.localCheck = model;
        return;
    }
    
    
    NSMutableArray * disappearArr = [NSMutableArray array];
    NSMutableArray * addArr = [NSMutableArray array];
    
    //标识号id数组
    NSArray * currentIdArr = [self productsIdFromLastestModelArray:inputArray];
    NSArray * preIdArr = pre.createArr;
    
    NSInteger changeNum  = [currentIdArr count] - [preIdArr count];
    if(ABS(changeNum) > 10)
    {
        pre.preArr = inputArray;
        pre.createArr = currentIdArr;
        return;
    }
    
    
    //找出之前有，现在没有的  以便标识购买//之前数组里有，现在数组里没有的   标识为已经购买
    [preIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![currentIdArr containsObject:obj])
        {
            ZWDataDetailModel * dataObj = [pre.preArr objectAtIndex:idx];
            dataObj.disappearNum = 1;//一次增加2
            if(!dataObj.finishedDate)
            {
                dataObj.finishedDate = [NSDate unixDate];
            }
            [disappearArr addObject:dataObj];
        }
    }];
    
    
    
    //找出新增部分，检查数据库是否之前标识过已购买,暂无数据库查询
    [currentIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![preIdArr containsObject:obj])
        {
            //之前没有的  现在重新复活  时间不变  次数改为 1次
            ZWDataDetailModel * dataObj = [inputArray objectAtIndex:idx];
            [addArr addObject:dataObj];
        }else{
            ZWDataDetailModel * dataObj = [inputArray objectAtIndex:idx];
            if(dataObj && [dataObj.left_money floatValue] == 0)
            {
                ZWDataDetailModel * dataObj = [inputArray objectAtIndex:idx];
                dataObj.disappearNum = 1;//一次增加2
                if(!dataObj.finishedDate)
                {
                    dataObj.finishedDate = [NSDate unixDate];
                }
                [disappearArr addObject:dataObj];
            }
        }
    }];
    
    [self localSaveModelArray:disappearArr];
    [self localRemoveModelArray:addArr];
    

    
    
    ZWCheckModel * latest = [[ZWCheckModel alloc] init];
    latest.preArr = inputArray;
    latest.createArr = currentIdArr;
    self.localCheck = latest;

}




@end
