//
//  APIBaseOld.m
//  TencentOAuthOldDemo
//
//  Created by cloudxu on 11-8-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "APIBaseOld.h"
#import <TencentOpenAPI/TencentOAuth.h>

@implementation APIBaseOld

@synthesize target = _target;
@synthesize selector = _selector;
@synthesize httpMethod = _httpMethod;
@synthesize seq = _seq;


- (id)initWithTarget:(id)target
		 andSelector:(SEL)selector
	   andHttpMethod:(NSString*)method
{
	if (self = [super init])
	{
		self.target = target;
		self.selector = selector;
		self.httpMethod = method;
		static int nStartSeq = 1000;
		self.seq = nStartSeq++;
	}
	return self;
}

- (TencentRequestOld*)openUrl:(NSString *)url
					 token:(NSString *)token
					openid:(NSString *)openid
					 appid:(NSString *)appid
					params:(NSMutableDictionary *)params
{
	
	[params setValue:@"json" forKey:@"format"];
	[params setValue:appid forKey:@"oauth_consumer_key"];
	[params setValue:token forKey:@"access_token"];
	[params setValue:openid forKey:@"openid"];
	
	[_request release];
	_request = [[TencentRequestOld getRequestWithParams:params
										  httpMethod:self.httpMethod
											delegate:self
										  requestURL:url] retain];
	[_request connect];
	return _request;
}


/**
 * Override NSObject : free the space
 */
- (void)dealloc {
	[_request release];
	[_httpMethod release];
	[super dealloc];
}


//TencentRequestOldDelegate

- (void)request:(TencentRequestOld*)request didFailWithError:(NSError*)error{
	NSLog(@"APIBaseOld request didFailWithError");
	// 将对应的结果抛出来
	APIResponseOld *response = [[[APIResponseOld alloc] init] autorelease];
	response.retCode = URLREQUEST_FAILED;
	response.errorMsg = [error localizedDescription];
	response.seq = _seq;
	if (_selector) 
		[_target performSelector:_selector withObject:response];
}

- (void)request:(TencentRequestOld *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"APIBaseOld request didReceiveResponse");
}

- (void)request:(TencentRequestOld *)request didLoad:(id)result dat:(NSData *)data {
	NSLog(@"APIBaseOld request didLoad");
	
	APIResponseOld *response = [[[APIResponseOld alloc] init] autorelease];
	response.seq = _seq;
	response.message=[[[NSString alloc] initWithData:data
											encoding:NSUTF8StringEncoding]
					  autorelease];
	
	NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

	
	if (!response.message) {
		response.message=[[NSString alloc]initWithData:data encoding:enc];
	}
	
	
	
	
	if ([result isKindOfClass:[NSDictionary class]]) {
		NSDictionary *root = (NSDictionary *)result;
		if ([[root allKeys] count] == 0) {
			NSLog(@"received didLoad error");
			response.retCode = URLREQUEST_FAILED;
			response.errorMsg = @"服务器返回内容不正确";
		}
		else {
			response.retCode = URLREQUEST_SUCCEED;
			response.jsonResponse = root;
			
		}
	}
	else {
		response.retCode = URLREQUEST_FAILED;
		response.errorMsg = @"服务器返回内容不正确";
	}

		// 将对应的结果抛出来
	if (_selector) {
		[_target performSelector:_selector withObject:response];
	}
};

@end
