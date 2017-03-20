//
//  TencentTargetSelectorOld.h
//  TencentOAuthOldDemo
//
//  Created by cloudxu on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>


/*!
    @class       TencentTargetSelectorOld 
    @superclass  NSObject { id _target; SEL _selector; }
*/
@interface TencentTargetSelectorOld : NSObject {
	id _target;
	SEL _selector;
}

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

/*!
    @method     target:selector:
    @param      target target
    @param      selector selector
*/
+ (TencentTargetSelectorOld *) target:(id)target selector:(SEL)selector;

@end

