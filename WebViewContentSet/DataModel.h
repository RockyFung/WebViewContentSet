//
//  DataModel.h
//  WebViewContentSet
//
//  Created by rocky on 2017/2/15.
//  Copyright © 2017年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject
/** 新闻标题 */
@property (nonatomic, copy) NSString *title;
/** 新闻发布时间 */
@property (nonatomic, copy) NSString *ptime;
/** 新闻内容 */
@property (nonatomic, copy) NSString *body;

@property (nonatomic, strong) NSMutableArray *imgs;

@end
