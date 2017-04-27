//
//  ICDataService.h
//  ICDataService
//
//  Created by _ivanC on 09/11/2016.
//  Copyright © 2017 _ivanC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICDataService : NSObject

/**
 * Create a service for pulling data
 *
 * @param subApi subapi for service URL
 *
 * @param queryDict extra queries due to specific need
 *
 * @return taskID for this task
 */
- (NSString *)requestWithSubApi:(NSString *)subApi
                queryDictionary:(NSDictionary *)queryDict
                     completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (NSString *)requestWithSubApi:(NSString *)subApi
                queryDictionary:(NSDictionary *)queryDict
                     HTTPMethod:(NSString *)HTTPMethod
                       HTTPBody:(NSData *)HTTPBody
                     completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

/**
 * Cancel previous request
 *
 * @param taskID task identifier generated when request is called
 */
- (void)cancelRequest:(NSString *)taskID;

#pragma mark - Subclass Implement
- (NSString *)mainServiceURL;
- (NSDictionary *)basicRequestQueryDictionary;

@end
