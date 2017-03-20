//
//     ____    _                        __     _      _____
//    / ___\  /_\     /\/\    /\ /\    /__\   /_\     \_   \
//    \ \    //_\\   /    \  / / \ \  / \//  //_\\     / /\/
//  /\_\ \  /  _  \ / /\/\ \ \ \_/ / / _  \ /  _  \ /\/ /_
//  \____/  \_/ \_/ \/    \/  \___/  \/ \_/ \_/ \_/ \____/
//
//	Copyright Samurai development team and other contributors
//
//	http://www.samurai-framework.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "STIHTTPSessionManager.h"
#import "STIHTTPNetwork.h"

NSString * STIHTTPRequestMethodString(STIHTTPRequestMethod method)
{
    NSString * methodString = nil;
    switch ( method ) {
        case STIHTTPRequestMethodGet:
            methodString = @"GET";
            break;
        case STIHTTPRequestMethodHead:
            methodString = @"HEAD";
            break;
        case STIHTTPRequestMethodPost:
            methodString = @"POST";
            break;
        case STIHTTPRequestMethodPut:
            methodString = @"PUT";
            break;
        case STIHTTPRequestMethodPatch:
            methodString = @"PATCH";
            break;
        case STIHTTPRequestMethodDelete:
            methodString = @"DELETE";
            break;
    }
    return methodString;
}

@implementation STIHTTPSessionManager

- (id)processedDataWithResponseObject:(id)responseObject task:(NSURLSessionDataTask *)task
{
    return responseObject;
}

- (void)handleError:(NSError *)error responseObject:(id)responseObject task:(NSURLSessionDataTask *)task failureBlock:(STIHTTPApiBlock)failureBlock
{
    if ( failureBlock ) {
        failureBlock(nil, error);
    }
}

- (NSURLSessionDataTask *)methodString:(NSString *)methodString
                        endpoint:(NSString *)endpoint
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, id responseObject, NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:methodString URLString:endpoint parameters:parameters success:success failure:failure];
    if(dataTask){
         NSLog(@"%s, %@ start ID %lu",__FUNCTION__,endpoint,(unsigned long)dataTask.taskIdentifier );
    }
    [dataTask resume];
    
    return dataTask;
}

- (NSURLSessionDataTask *)method:(STIHTTPRequestMethod)method
                        endpoint:(NSString *)endpoint
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, id responseObject, NSError *error))failure
{
    return [self methodString:STIHTTPRequestMethodString(method) endpoint:endpoint parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, id, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, responseObject, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    return dataTask;
}
//- (NSURLSessionDataTask *)method:(STIHTTPRequestMethod)method
//                        endpoint:(NSString *)endpoint
//                      parameters:(id)parameters
//                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
//                         failure:(void (^)(NSURLSessionDataTask *task, id responseObject, NSError *error))failure
//{
//    return [self methodString:STIHTTPRequestMethodString(method) endpoint:endpoint parameters:parameters success:success failure:failure];
//}
//
//- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
//                                       URLString:(NSString *)URLString
//                                      parameters:(id)parameters
//                                         success:(void (^)(NSURLSessionDataTask *, id))success
//                                         failure:(void (^)(NSURLSessionDataTask *, id, NSError *))failure
//{
//    NSError *serializationError = nil;
//    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
//    if (serializationError) {
//        if (failure) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wgnu"
//            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
//                failure(nil, nil, serializationError);
//            });
//#pragma clang diagnostic pop
//        }
//        
//        return nil;
//    }
//    
//    __block NSURLSessionDataTask *dataTask = nil;
//    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
//        if (error) {
//            if (failure) {
//                failure(dataTask, responseObject, error);
//            }
//        } else {
//            if (success) {
//                success(dataTask, responseObject);
//            }
//        }
//    }];
//    
//    return dataTask;
//}

@end



#pragma mark - Add AFHTTPRequestOperation Support by Joe Lai

@implementation STIHTTPRequestManager

- (id)processedDataWithResponseObject:(id)responseObject operation:(AFHTTPRequestOperation *)operation
{
    return responseObject;
}


- (void)handleError:(NSError *)error responseObject:(id)responseObject operation:(AFHTTPRequestOperation *)operation failureBlock:(void (^)(id, id))failureBlock
{
    if ( failureBlock ) {
        failureBlock(nil, error);
    }
}

- (AFHTTPRequestOperation *)method:(STIHTTPRequestMethod)method
                          endpoint:(NSString *)endpoint
                        parameters:(id)parameters
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSError *))failure
{
    NSError *serializationError = nil;
    NSString *methodString = STIHTTPRequestMethodString(method);
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:methodString URLString:[[NSURL URLWithString:endpoint relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block AFHTTPRequestOperation *operation = nil;
    operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
        {
            failure(operation, nil, error);
        }
    }];
    return operation;
}

@end