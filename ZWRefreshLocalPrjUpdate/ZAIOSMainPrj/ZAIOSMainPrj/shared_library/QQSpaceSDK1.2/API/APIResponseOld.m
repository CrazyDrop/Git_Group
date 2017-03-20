//
//  APIResponseOld.m
//  TencentOAuthOldDemo
//
//  Created by cloudxu on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*!
    @header APIResponseOld.m
    @abstract   <#abstract#>
    @discussion <#description#>
*/

#import "APIResponseOld.h"


@implementation APIResponseOld

@synthesize retCode = _retCode;
@synthesize seq = _seq;
@synthesize errorMsg = _errorMsg;
@synthesize jsonResponse = _jsonResponse;
@synthesize message=_message;

- (void)dealloc {
	[_errorMsg release];
	[_jsonResponse release];
	[super dealloc];
}

@end