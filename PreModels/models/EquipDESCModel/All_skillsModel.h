//
//  All_skillsModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
//师门当前技能有7个   school5 对应70-76
// school15  对应105-111
// school1  对应 1-8  没有3
// school2  对应 16-24 没有21 22  迷糊了。
//一共有15个门派  至多 15*7  135个
//150以下为师门技能
@interface All_skillsModel : NSObject

//@property (nonatomic, strong) NSNumber *408;
//@property (nonatomic, strong) NSNumber *304;
//@property (nonatomic, strong) NSNumber *416;
//@property (nonatomic, strong) NSNumber *325;
//@property (nonatomic, strong) NSNumber *403;
//@property (nonatomic, strong) NSNumber *571;
//@property (nonatomic, strong) NSNumber *301;


//217熔炼  231淬灵 230强壮  209追捕技巧  216巧匠之术   204打造技巧  205裁缝技巧  207炼金之术  212健身  206中药医理
//211养生之道  210逃离技巧 237神速 203暗器技巧  202冥想 208烹饪技巧  218灵石技巧 201强身
//154变化之术  153丹元济会   160仙灵店铺  158奇门遁甲 161宝石工艺  （155 220 164)火眼金睛  154打坐 170妙手空空


//""19":150,"20":150,"52016":1,"211":35,"21807":1,"197":1,"17":165,"218":10,"216":10,"173":1,"175":1,"202":120,"158":3,"168":1,"154":5,"21817":1,"24":122,"206":77,"21804":1,"204":20,"23":169,"210":20,"16":130,"170":2,"208":84,"231":30,"160":3,"196":1,"212":45,"52031":1,"21814":1,"162":1,"217":10,"198":1,"18":150,"21801":1

@property (nonatomic, strong) NSMutableArray * skillsArray;
@property (nonatomic, strong) NSNumber * value;
@property (nonatomic, strong) NSString * name;
/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

