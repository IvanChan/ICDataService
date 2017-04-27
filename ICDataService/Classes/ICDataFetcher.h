//
//  ICDataFetcher.h
//  ICDataService
//
//  Created by _ivanC on 09/11/2016.
//  Copyright © 2017 _ivanC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICDataFetcherDataSource;
@interface ICDataFetcher : NSObject

@property (nonatomic, weak) id<ICDataFetcherDataSource> dataSource;

@property (nonatomic, copy, readonly) NSString *subApi;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *queryDict;

@property (nonatomic, strong) NSDictionary *headerField;

@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, strong) NSData *HTTPBody;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Create a service for pulling data
 *
 * @param subApi subapi for service URL
 *
 * @param queryDict extra queries due to specific need
 */
- (instancetype)initWithSubApi:(NSString *)subApi queryDictionary:(NSDictionary<NSString *, NSString *> *)queryDict;

/**
 * Start the current request
 */
- (void)resume:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

/**
 * Cancel the current request
 */
- (void)cancel;

/**
 * Service become invalid after finish or fail
 */
- (BOOL)isServiceInvalid;

@end

@protocol ICDataFetcherDataSource <NSObject>

- (NSString *)mainServiceURL;

@end
