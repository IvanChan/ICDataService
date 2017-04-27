//
//  ICDataService.m
//  ICDataService
//
//  Created by _ivanC on 09/11/2016.
//  Copyright © 2017 _ivanC. All rights reserved.
//

#import "ICDataService.h"
#import "ICDataFetcher.h"

@interface ICDataService () <ICDataFetcherDataSource>

@property (nonatomic, strong) NSMutableDictionary *taskHash;

@end

@implementation ICDataService

#pragma mark - Getters
- (NSMutableDictionary *)taskHash
{
    if (_taskHash == nil)
    {
        _taskHash = [[NSMutableDictionary alloc] initWithCapacity:7];
    }
    return _taskHash;
}

#pragma mark - Public
- (NSString *)requestWithSubApi:(NSString *)subApi
                queryDictionary:(NSDictionary *)queryDict
                     HTTPMethod:(NSString *)HTTPMethod
                       HTTPBody:(NSData *)HTTPBody
                     completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;
{
    NSString *taskID = nil;

    do
    {
        if ([subApi length] <= 0)
        {
            break;
        }
        
        // Append queries
        NSMutableDictionary *finalQueriesDict = [NSMutableDictionary dictionary];
        {
            NSDictionary *basicQueryDict = [self basicRequestQueryDictionary];
            if (basicQueryDict.count > 0)
            {
                [finalQueriesDict addEntriesFromDictionary:basicQueryDict];
            }
            if (queryDict.count > 0)
            {
                [finalQueriesDict addEntriesFromDictionary:queryDict];
            }
        }
        
        // Build task
        ICDataFetcher *task = [self taskForSubApi:subApi queryDictionary:finalQueriesDict];
        if (task == nil)
        {
            task = [[ICDataFetcher alloc] initWithSubApi:subApi queryDictionary:queryDict];
            task.dataSource = self;
            [self addTask:task];
            
            task.HTTPMethod = HTTPMethod;
            task.HTTPBody = HTTPBody;
            [task resume:completion];
        }

        taskID = [NSString stringWithFormat:@"%p", task];
        
    } while (0);

    
    return taskID;
}

- (NSString *)requestWithSubApi:(NSString *)subApi
                queryDictionary:(NSDictionary *)queryDict
                     completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion
{
    return [self requestWithSubApi:subApi queryDictionary:queryDict HTTPMethod:nil HTTPBody:nil completion:completion];
}

#pragma mark - Subclass Implement
- (NSString *)mainServiceURL
{
    assert(0);
    return nil;
}

- (NSDictionary *)basicRequestQueryDictionary
{
    // for subclass implement
    return nil;
}

#pragma mark - Private
- (NSString *)keyForTask:(ICDataFetcher *)task
{
    if (task == nil)
    {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%p", task];
}

- (ICDataFetcher *)taskForSubApi:(NSString *)subApi queryDictionary:(NSDictionary *)queryDict
{
    if ([subApi length] <= 0)
    {
        return nil;
    }
    
    __block ICDataFetcher *result = nil;
    @synchronized (self)
    {
        NSMutableArray *taskToRemove = [NSMutableArray arrayWithCapacity:3];
        [self.taskHash enumerateKeysAndObjectsUsingBlock:^(NSString *key, ICDataFetcher *task, BOOL *stop) {
            
            if ([task isServiceInvalid])
            {
                [taskToRemove addObject:[self keyForTask:task]];
            }
            else
            {
                if ([task.subApi isEqualToString:subApi]
                    &&  ( (queryDict == nil && task.queryDict == nil)
                            || (queryDict != nil && [task.queryDict isEqual:queryDict])))
                {
                    result = task;
                    *stop = YES;
                }
            }
        }];
        
        if ([taskToRemove count] > 0)
        {
            [self.taskHash removeObjectsForKeys:taskToRemove];
        }
    }
    
    return result;
}

- (void)cancelRequest:(NSString *)taskID
{
    if ([taskID length] <= 0)
    {
        return;
    }
    
    @synchronized (self)
    {
        ICDataFetcher *task = self.taskHash[taskID];
        if (task)
        {
            [task cancel];
            [self.taskHash removeObjectForKey:taskID];
        }
    }
}

- (void)addTask:(ICDataFetcher *)task
{
    if (task == nil)
    {
        return;
    }
    
    @synchronized (self)
    {
        NSString *taskKey = [self keyForTask:task];
        if (taskKey)
        {
            [self.taskHash setObject:task forKey:taskKey];
        }
    }
}

- (void)removeTask:(ICDataFetcher *)task
{
    if (task == nil)
    {
        return;
    }
    
    @synchronized (self)
    {
        NSString *taskKey = [self keyForTask:task];
        if (taskKey)
        {
            [self.taskHash removeObjectForKey:taskKey];
        }
    }
}

@end
