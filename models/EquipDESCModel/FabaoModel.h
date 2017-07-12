//
//  FabaoModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>

@interface FabaoModel : NSObject

//@property (nonatomic, strong) 3Model *3;
//@property (nonatomic, strong) 12Model *12;
//@property (nonatomic, strong) 21Model *21;
//@property (nonatomic, strong) 4Model *4;
//@property (nonatomic, strong) 30Model *30;
//@property (nonatomic, strong) 13Model *13;
//@property (nonatomic, strong) 22Model *22;
//@property (nonatomic, strong) 14Model *14;
//@property (nonatomic, strong) 23Model *23;
//@property (nonatomic, strong) 32Model *32;
//@property (nonatomic, strong) 15Model *15;
//@property (nonatomic, strong) 41Model *41;
//@property (nonatomic, strong) 24Model *24;
//@property (nonatomic, strong) 50Model *50;
//@property (nonatomic, strong) 33Model *33;
//@property (nonatomic, strong) 16Model *16;
//@property (nonatomic, strong) 25Model *25;
//@property (nonatomic, strong) 34Model *34;
//@property (nonatomic, strong) 43Model *43;
//@property (nonatomic, strong) 26Model *26;
//@property (nonatomic, strong) 18Model *18;
//@property (nonatomic, strong) 44Model *44;
//@property (nonatomic, strong) 27Model *27;
//@property (nonatomic, strong) 19Model *19;
//@property (nonatomic, strong) 45Model *45;
//@property (nonatomic, strong) 28Model *28;
//@property (nonatomic, strong) 46Model *46;
//@property (nonatomic, strong) 29Model *29;
//@property (nonatomic, strong) 47Model *47;
//@property (nonatomic, strong) 48Model *48;
//@property (nonatomic, strong) 49Model *49;
//@property (nonatomic, strong) 1Model *1;
//@property (nonatomic, strong) 2Model *2;
//@property (nonatomic, strong) 20Model *20;

@property (nonatomic,strong) NSMutableArray * fabaoModelsArray;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

