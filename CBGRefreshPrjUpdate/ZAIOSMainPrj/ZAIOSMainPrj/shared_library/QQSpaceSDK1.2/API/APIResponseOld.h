//
//  APIResponseOld.h
//  TencentOAuthOldDemo
//
//  Created by cloudxu on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*!
 @header APIResponseOld
 
 */

#import <Foundation/Foundation.h>




/*!
 @class       APIResponseOld 
 @superclass  NSObject { int _retCode; int _seq; NSString *_errorMsg; NSDictionary *_jsonResponse; NSString *_message; }
 
 */
@interface APIResponseOld : NSObject {
	int		 _retCode;
	int		 _seq;
	NSString *_errorMsg;
	NSDictionary *_jsonResponse;
	NSString *_message;
}

@property (nonatomic) int retCode;
@property (nonatomic) int seq;
@property (nonatomic, retain) NSString *errorMsg;
@property (nonatomic, retain) NSDictionary *jsonResponse;
@property (nonatomic, retain)  NSString *message;

@end
