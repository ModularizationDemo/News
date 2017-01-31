//
//  Target_News.m
//  SXNews
//
//  Created by wangshiyu13 on 2017/1/31.
//  Copyright © 2017年 ShangxianDante. All rights reserved.
//

#import "Target_News.h"
#import "SXNewsTableViewPage.h"

@implementation Target_News
- (UIViewController *)Action_aViewController:(NSDictionary *)params {
    SXNewsTableViewPage *vc = [UIStoryboard storyboardWithName:@"News" bundle:nil].instantiateInitialViewController;
    vc.index = [params[@"index"] integerValue];
    vc.urlString = params[@"urlString"];
    return vc;
}
@end
