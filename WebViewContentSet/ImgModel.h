//
//  ImgModel.h
//  WebViewContentSet
//
//  Created by rocky on 2017/2/15.
//  Copyright © 2017年 RockyFung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgModel : NSObject
@property (nonatomic, copy) NSString *src;
/** 图片尺寸 */
@property (nonatomic, copy) NSString *pixel;
/** 图片所处的位置 */
@property (nonatomic, copy) NSString *ref;


@end
