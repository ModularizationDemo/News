//
//  SXNewsViewModel.m
//  SXNews
//
//  Created by dongshangxian on 16/3/8.
//  Copyright © 2016年 ShangxianDante. All rights reserved.
//

#import "SXNewsViewModel.h"
#import "SXNewsEntity.h"
#import <HLNetworking/HLNetworking.h>
#import <YYModel/YYModel.h>

@implementation SXNewsViewModel
- (instancetype)init
{
    if (self = [super init]) {
        [self setupRACCommand];
    }
    return self;
}

- (void)setupRACCommand
{
    @weakify(self);
    _fetchNewsEntityCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self requestForNewsEntityWithUrl:input success:^(NSArray *array) {
                NSArray *arrayM = [NSArray yy_modelArrayWithClass:[SXNewsEntity class] json:array];
                [subscriber sendNext:arrayM];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }];
}

- (void)requestForNewsEntityWithUrl:(NSString *)url success:(void (^)(NSArray *array))success failure:(void (^)(NSError *error))failure{
    NSString *fullUrl = [@"http://c.m.163.com/" stringByAppendingString:url];
    [[HLAPIRequest request]
     .setMethod(GET)
     .setCustomURL(fullUrl)
     .success(^(NSDictionary *response){
        NSString *key = [response.keyEnumerator nextObject];
        NSArray *tempArray = response[key];
        success(tempArray);
    })
     .failure(^(NSError *error){
        failure(error);
    })
     start];
}
@end
