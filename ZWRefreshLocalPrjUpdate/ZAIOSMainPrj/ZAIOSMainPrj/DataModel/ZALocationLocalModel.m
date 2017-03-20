//
//  ZALocationLocalModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationLocalModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "AutoCoding.h"
#import "NSObject+AutoCoding.h"
#import "ZWDataDetailModel.h"
#import "ZWSysSellModel.h"
#define ZADATABASE_NAME @"zadatabase.db" //缓存的数据库名称
#define ZADATABASE_NAME_READ @"zadatabase2.db" //缓存的数据库名称

#define ZADATABASE_TABLE_LOCATIONS @"ZADATABASE_TABLE_LOCATIONS" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_HISTORY @"ZADATABASE_TABLE_LOCATIONS_HISTORY" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL @"ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL" //系统销售数据


#define ZADATABASE_TABLE_LOCATIONS_KEY_TIME @"ZADATABASE_TABLE_LOCATIONS_KEY_TIME" //缓存的数据库名称
#define ZADATABASE_TABLE_LOCATIONS_KEY_DIC  @"ZADATABASE_TABLE_LOCATIONS_KEY_DIC" //缓存的数据库名称
@implementation ZALocationLocalModel


@end

@interface ZALocationLocalModelManager()
{
    FMDatabaseQueue * databaseQueue;
    FMDatabaseQueue * databaseQueue_read;
}
@property (nonatomic,copy) ZALocationLocalModel * latestLocation;
@end
@implementation ZALocationLocalModelManager

+(instancetype)sharedInstance
{
    static ZALocationLocalModelManager *shareZALocationLocalModelManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZALocationLocalModelManagerInstance = [[[self class] alloc] init];
    });
    return shareZALocationLocalModelManagerInstance;
}
//最近的一个model
-(ZWDataDetailModel *)latestLocationModel
{
    //两种可能1、位置信息库表有数据
    //2、库表里数据刚好全部上传清空了
    
    //取当前最近的一个进行保存  有则返回
//    没有最近的保存记录，由数据库获取，数据库为空，返回空
//    @property (nonatomic, copy) NSString *longtitude;
//    @property (nonatomic, copy) NSString *latitude;
    
    ZWDataDetailModel * model = (ZWDataDetailModel *)self.latestLocation;
    DetailModelSaveType type = [model currentModelState];
    if(model && (type == DetailModelSaveType_Notice || type == DetailModelSaveType_Buy)){
        return model;
    }
    
    
    NSArray * array = [self localLocationsArrayForCurrent];
    if(array && [array count]>0)
    {
        model = [array lastObject];
        return model;
    }
    
    return nil;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME];
        
        databaseQueue= [[FMDatabaseQueue alloc]initWithPath:databasePath];
        
        
//        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//        databasePath=[path stringByAppendingPathComponent:ZADATABASE_NAME_READ];
//        
//        databaseQueue_read= [[FMDatabaseQueue alloc]initWithPath:databasePath];
        [self checkLocalTables];
    }
    return self;
}
-(void)checkLocalTables
{
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        //******************************
        //*-begin-- 创建相关的表
        //******************************
        if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS])
        {
            NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text);",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
            [fmdatabase executeUpdate:createSql];
            //建完文章表，顺便处理下文件不备份到icloud
            NSString *databasePath=[fmdatabase databasePath];
            NSFileManager *defaultFileManager=[NSFileManager defaultManager];
            BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
            
            if (!isExit)
            {
                [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
            }
            
        }
         if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS_HISTORY])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text);",ZADATABASE_TABLE_LOCATIONS_HISTORY,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
             [fmdatabase executeUpdate:createSql];
             //建完文章表，顺便处理下文件不备份到icloud
             NSString *databasePath=[fmdatabase databasePath];
             NSFileManager *defaultFileManager=[NSFileManager defaultManager];
             BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
             
             if (!isExit)
             {
                 [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
             }
             
         }
         if(![fmdatabase tableExists:ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL])
         {
             NSString *createSql=[NSString stringWithFormat:@"create table %@(%@ text primary key,%@ text);",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
             [fmdatabase executeUpdate:createSql];
             //建完文章表，顺便处理下文件不备份到icloud
             NSString *databasePath=[fmdatabase databasePath];
             NSFileManager *defaultFileManager=[NSFileManager defaultManager];
             BOOL isExit=[defaultFileManager fileExistsAtPath:databasePath];
             
             if (!isExit)
             {
                 [defaultFileManager createFileAtPath:databasePath contents:nil attributes:nil];
             }
             
         }

         
         
     }];
    
}
-(void)clearTotalLocations
{

    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         //******************************
         //*-begin-- 创建相关的表
         //******************************
         NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",ZADATABASE_TABLE_LOCATIONS];
         BOOL isSuccessed = [fmdatabase executeUpdate:deleteSql];
         if (isSuccessed == NO) {
             //更新语句执行失败
             NSLog(@"delete from --删除语句执行失败:%@",fmdatabase.lastErrorMessage);
         }
         
         [fmdatabase close];
     }];
}
-(void)clearUploadedLocations:(NSArray *)current
{
    [current enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteLocationWithCurrentObj:obj];
    }];
    

}
-(void)deleteLocationWithCurrentObj:(id)obj
{
    ZWDataDetailModel * model = (ZWDataDetailModel *)obj;

    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         BOOL isAlreadyIn = NO;
         NSString * time = model.product_id;
         //检查使用
//         NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = '%@';",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
//         FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
//         
//         if ([resultSet next])
//         {
//             isAlreadyIn=YES;
//         }
         
//         NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
//         NSString * valueStr = [data base64Encoding];

//         if (isAlreadyIn)
         {
             NSString *deleteArticleString=[NSString stringWithFormat:@"delete from %@ where %@ = '%@';",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
             BOOL isSuccessed = [fmdatabase executeUpdate:deleteArticleString];
             if (isSuccessed == NO) {
                 //更新语句执行失败
                 NSLog(@"insert error--删除语句执行失败:%@",fmdatabase.lastErrorMessage);
             }
         }

         
         [fmdatabase close];
     }];
}

-(void)localSaveDetailUpdateArray:(NSArray *)arr
{
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self localSaveDisappearLocation:obj];
    }];
}

-(BOOL)localSaveCurrentLocation:(id)obj
{
    
    ZWDataDetailModel * model = (ZWDataDetailModel *)obj;
    
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.product_id;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
            firstSave = NO;
        }
        

        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
    if(firstSave){
        self.latestLocation = obj;
    }
    
    return firstSave;
}
-(void)localSaveDisappearLocation:(id)obj{
    ZWDataDetailModel * model = (ZWDataDetailModel *)obj;
    
    __block BOOL success = NO;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.product_id;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
        }
        
        
        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
}
-(NSArray *)localLocationsArrayForCurrent
{
    NSMutableArray *totalArray=[NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
//        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS];

        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            ZWDataDetailModel *location=[self createArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];

    }];
    return totalArray;
}
-(NSArray *)localLocationsArrayForAppendingDB
{
    NSMutableArray *totalArray=[NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS_HISTORY];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            ZWDataDetailModel *location=[self createArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;
}
-(void)exchangeLocalSaveLocationsToSave
{
    //遍历当前列表，存储到中read中
    NSArray * array = [self localLocationsArrayForCurrent];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self readDBlocalSaveCurrentLocation:obj];
    }];
    
}
-(BOOL)readDBlocalSaveCurrentLocation:(id)obj
{
    
    ZWDataDetailModel * model = (ZWDataDetailModel *)obj;
    
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.product_id;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS_HISTORY,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
            firstSave = NO;
        }
        
        
        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS_HISTORY,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS_HISTORY];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
    
    return firstSave;
}


-(ZWDataDetailModel*)createArticleWithResultSet:(FMResultSet*)resultSet
{//从记录集中的一条创建一个文章
    NSString * valueStr = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
    NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
    ZWDataDetailModel * model = [ZWDataDetailModel objectWithContentsOfData:data];
    NSDictionary * dic = [model dictionaryRepresentation];
    ZWDataDetailModel * backModel = [ZWDataDetailModel ac_objectWithAny:dic];
    
    return backModel;
}

-(NSArray *)localSystemSellArray
{
    NSMutableArray *totalArray=[NSMutableArray array];
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase){
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        NSMutableString *sqlMutableString=[[NSMutableString alloc]init];
        //是某分类的
        //        [sqlMutableString appendFormat:@"select * from %@ ORDER BY '%@' limit 50;",ZADATABASE_TABLE_LOCATIONS_KEY_TIME,ZADATABASE_TABLE_LOCATIONS];
        
        [sqlMutableString appendFormat:@"select * from %@ ;",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL];
        
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlMutableString];
        while ([resultSet next]) {
            ZWSysSellModel *location=[self createSysSellModelArticleWithResultSet:resultSet];
            [totalArray addObject:location];
        }
        
        [resultSet close];
        [fmdatabase close];
        
    }];
    return totalArray;

}
-(void)clearSystemSellArray:(NSArray *)current
{
    [current enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteSystemSellModelWithCurrentObj:obj];
    }];
}
-(void)deleteSystemSellModelWithCurrentObj:(id)obj
{
    ZWSysSellModel * model = (ZWSysSellModel *)obj;
    
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase)
     {
         if (!fmdatabase.open) {
             [fmdatabase open];
         }
         
         BOOL isAlreadyIn = NO;
         NSString * time = model.product_id;
         {
             NSString *deleteArticleString=[NSString stringWithFormat:@"delete from %@ where %@ = '%@';",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
             BOOL isSuccessed = [fmdatabase executeUpdate:deleteArticleString];
             if (isSuccessed == NO) {
                 //更新语句执行失败
                 NSLog(@"insert error--删除语句执行失败:%@",fmdatabase.lastErrorMessage);
             }
         }
         
         
         [fmdatabase close];
     }];
}

-(BOOL)localSaveSystemSellModel:(id)obj
{
    ZWSysSellModel * model = (ZWSysSellModel *)obj;
    
    __block BOOL success = NO;
    __block BOOL firstSave = YES;
    [databaseQueue inDatabase:^(FMDatabase *fmdatabase) {
        if (!fmdatabase.open) {
            [fmdatabase open];
        }
        
        BOOL isAlreadyIn = NO;
        NSString * time = model.product_id;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString * valueStr = [data base64Encoding];
        
        NSString *sqlGetArticle=[NSString stringWithFormat:@"select * from %@ where %@ = %@;",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,time];
        FMResultSet *resultSet=[fmdatabase executeQuery:sqlGetArticle];
        
        if ([resultSet next])
        {
            isAlreadyIn=YES;
            firstSave = NO;
        }
        
        
        NSString * sqlString = nil;
        if(isAlreadyIn)
        {
            sqlString=[NSString stringWithFormat:@"update %@ set %@=? where %@=?;",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL,ZADATABASE_TABLE_LOCATIONS_KEY_DIC,ZADATABASE_TABLE_LOCATIONS_KEY_TIME,nil];
            
            NSArray *sqlarray=[NSArray arrayWithObjects: valueStr,time,nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }else
        {
            sqlString=[NSString stringWithFormat:@"insert into %@ values(?,?);",ZADATABASE_TABLE_LOCATIONS_SYSTEM_SELL];
            NSArray *sqlarray=[NSArray arrayWithObjects:time,valueStr, nil];
            success=[fmdatabase executeUpdate:sqlString withArgumentsInArray:sqlarray];
        }
        
        [fmdatabase close];
        
    }];
    
    return firstSave;
}

-(ZWSysSellModel *)createSysSellModelArticleWithResultSet:(FMResultSet*)resultSet
{//从记录集中的一条创建一个文章
    NSString * valueStr = [resultSet stringForColumn:ZADATABASE_TABLE_LOCATIONS_KEY_DIC];
    NSData * data = [[NSData alloc] initWithBase64Encoding:valueStr];
    ZWSysSellModel * model = [ZWSysSellModel objectWithContentsOfData:data];
    NSDictionary * dic = [model dictionaryRepresentation];
    ZWSysSellModel * backModel = [ZWSysSellModel ac_objectWithAny:dic];
    
    return backModel;
}


@end
