//
//  WebConnectPrjTests.m
//  WebConnectPrjTests
//
//  Created by Apple on 17/4/19.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EquipExtraModel.h"
@interface WebConnectPrjTests : XCTestCase

@end

@implementation WebConnectPrjTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    EquipExtraModel * model = [[EquipExtraModel alloc] init];
    [model detailSubCheck];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
