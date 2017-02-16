//
//  ViewModel.h
//  WebViewContentSet
//
//  Created by rocky on 2017/2/15.
//  Copyright © 2017年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModel.h"


@interface ViewModel : NSObject
@property (nonatomic, strong) DataModel *model;
/**
 *  将拼接html的操作在业务逻辑层做
 *
 *  @return 将拼好后的html字符串返回
 */
- (NSString *)getHtmlString;
- (void)loadDataModelSuccess:(void(^)(DataModel *model))success faile:(void(^)(NSError *error))faile;
@end
