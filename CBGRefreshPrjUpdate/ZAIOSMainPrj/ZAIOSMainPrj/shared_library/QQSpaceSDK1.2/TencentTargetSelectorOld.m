//
//  TencentTargetSelectorOld.m
//  TencentOAuthOldDemo
//
//  Created by cloudxu on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TencentTargetSelectorOld.h"


@implementation TencentTargetSelectorOld

@synthesize target = _target;
@synthesize selector = _selector;

+ (TencentTargetSelectorOld *) target:(id)target selector:(SEL)selector {
	TencentTargetSelectorOld *aQTagertSelector = [[[TencentTargetSelectorOld alloc] init] autorelease];
	aQTagertSelector.target = target;
	aQTagertSelector.selector = selector;
	return aQTagertSelector;
}

@end
