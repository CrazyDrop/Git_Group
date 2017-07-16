//
//  AllEquipModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "AllEquipModel.h"
#import "ExtraModel.h"


@implementation AllEquipModel
-(instancetype)init
{
    self = [super init];
    self.modelsArray = [NSMutableArray array];
    return self;
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    /*  [Example] change property id to productID
     *
     *  if([key isEqualToString:@"id"]) {
     *
     *      self.productID = value;
     *      return;
     *  }
     */
    
    // show undefined key
//    NSLog(@"%@.h have undefined key '%@', the key's type is '%@'.", NSStringFromClass([self class]), key, [value class]);
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    // ignore null value
    if ([value isKindOfClass:[NSNull class]]) {
        
        return;
    }
    if ([key isEqualToString:@"modelsArray"] && [value isKindOfClass:[NSArray class]])
    {
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            ExtraModel *model = [[ExtraModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    if ([value isKindOfClass:[NSDictionary class]]) {
        
        ExtraModel * model = [[ExtraModel alloc] initWithDictionary:value];
        [self.modelsArray addObject:model];
        model.extraTag = key;
    }

    

    [super setValue:value forKey:key];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self.modelsArray = [NSMutableArray array];

    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    
    return self;
}
//1 头盔  2衣服  3鞋子 4链子 5腰带 6武器
-(NSArray *)equipAddedSkillsNumberArrayFromEquipModel
{
    NSArray * equipArr = self.modelsArray;
    NSMutableDictionary * equipDic = [NSMutableDictionary dictionary];
    for (ExtraModel * eve in equipArr)
    {
        [equipDic setObject:eve forKey:eve.extraTag];
    }
    
    NSMutableArray * numberArr = [NSMutableArray array];
    for (NSInteger index = 1;index < 7 ;index ++ )
    {
        NSString * keyIndex = [NSString stringWithFormat:@"%ld",index];
        ExtraModel * eve = [equipDic objectForKey:keyIndex];
        NSInteger skillNum = [[self class] equipAddedSkillNumberForExtraModel:eve];
        [numberArr addObject:[NSNumber numberWithInteger:skillNum]];
    }
    [numberArr addObject:[NSNumber numberWithInt:0]];
    return numberArr;
}
+(NSInteger)equipAddedSkillNumberForExtraModel:(ExtraModel * )equipModel
{
    if(!equipModel) return 0;
    NSString * des = equipModel.cDesc;
    NSInteger number = 0;
    NSString * sepStr = @"增加门派技能";
    if([des containsString:sepStr])
    {
        NSArray * desArr = [des componentsSeparatedByString:sepStr];
        NSString * numStr = [desArr lastObject];
        numStr = [numStr stringByReplacingOccurrencesOfString:@"等级" withString:@""];
        NSArray * skillNumArr = [numStr componentsSeparatedByString:@"级"];
        numStr = [skillNumArr firstObject];
        numStr = [numStr substringFromIndex:[numStr length] - 1];
        number = [numStr intValue];
    }
    
    return number;
}


@end

