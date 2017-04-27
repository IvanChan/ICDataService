//
//  ICDataFetcher.m
//  XimalayaSDK
//
//  Created by _ivanC on 09/11/2016.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICDataFetcher.h"

@interface ICDataFetcher ()

@property (nonatomic, copy) NSString *subApi;
@property (nonatomic, copy) NSDictionary <NSString *, NSString *> *queryDict;
@property (nonatomic, copy) NSString *requestURL;

@property (nonatomic, strong) NSURLSessionTask *dataTask;

@property (nonatomic, assign) BOOL isServiceInvalid;

@end

@implementation ICDataFetcher

#pragma mark - Lifecycle
- (instancetype)initWithSubApi:(NSString *)subApi queryDictionary:(NSDictionary <NSString *, NSString *> *)queryDict
{
    if (self = [super init])
    {
        self.subApi = subApi;
        self.queryDict = queryDict;
    }
    return self;
}

#pragma mark - Public
- (BOOL)isEqual:(ICDataFetcher *)object
{
    if (![object isKindOfClass:[ICDataFetcher class]])
    {
        return NO;
    }
    
    if (self.subApi && object.subApi == nil)
    {
        return NO;
    }
    
    if (self.queryDict && object.queryDict == nil)
    {
        return NO;
    }
    
    if ([self.subApi isEqualToString:object.subApi]
         && [self.queryDict isEqual:object.queryDict])
    {
        return YES;
    }

    return NO;
}

- (void)resume:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion
{
    @synchronized (self)
    {
        if (self.dataTask || [self.subApi length] <= 0)
        {
            // Already running or wait for retry
            return;
        }
        
        [self _resume:completion];
    }
}

- (void)cancel
{
    [self.dataTask cancel];
    [self _reset];
}

- (BOOL)isServiceInvalid
{
    return (self.dataSource.mainServiceURL.length <= 0 || self.subApi.length <= 0);
}

#pragma mark - Private
- (void)_reset
{
    self.dataTask = nil;
    
    self.subApi = nil;
    self.queryDict = nil;
    
    self.isServiceInvalid = YES;
}

// TODO: should always _resume in mainThread?
- (void)_resume:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion
{
    do
    {
        if ([self isServiceInvalid])
        {
            break;
        }
        
        // Format queries
        NSMutableDictionary *allQueryDict = [NSMutableDictionary dictionaryWithCapacity:7];
        if ([self.queryDict count] > 0)
        {
            [allQueryDict addEntriesFromDictionary:self.queryDict];
        }
        
        NSString *queryStr = nil;
        if (allQueryDict.count > 0)
        {
            NSMutableArray *queryArray = [NSMutableArray arrayWithCapacity:allQueryDict.count];
            [allQueryDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
                
                if ([key isKindOfClass:[NSString class]]
                    && key.length > 0
                    && [obj isKindOfClass:[NSString class]])
                {
                    NSString *qStr = [NSString stringWithFormat:@"%@=%@", key, obj];
                    [queryArray addObject:qStr];
                }
            }];
            
            queryStr = [queryArray componentsJoinedByString:@"&"];
        }
        
        // Append subApi & query
        NSString *serviceURL = [self.dataSource.mainServiceURL stringByAppendingPathComponent:self.subApi];
        if (queryStr.length > 0)
        {
            if ([serviceURL rangeOfString:@"?"].location != NSNotFound)
            {
                serviceURL = [serviceURL stringByAppendingFormat:@"&%@", queryStr];
            }
            else
            {
                serviceURL = [serviceURL stringByAppendingFormat:@"?%@", queryStr];
            }
        }
        
        // Build NSURL
        NSURL *requestURL = [NSURL URLWithString:serviceURL];
        if (requestURL == nil)
        {
            assert(0);
            break;
        }
        
        // Build request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        if (self.HTTPMethod)
        {
            request.HTTPMethod = self.HTTPMethod;
        }
        
        if (self.HTTPBody)
        {
            request.HTTPBody = self.HTTPBody;
        }
        
        if (self.headerField)
        {
            [self.headerField enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
               
                [request setValue:obj forHTTPHeaderField:key];

            }];
        }

        self.dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            
                                                            if (completion)
                                                            {
                                                                completion(data, response, error);
                                                            }
                                                            
                                                            [self _reset];
                                                            
                                                        }];
        
        [self.dataTask resume];
        
    } while (0);
}

@end
