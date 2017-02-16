//
//  ViewModel.m
//  WebViewContentSet
//
//  Created by rocky on 2017/2/15.
//  Copyright © 2017年 RockyFung. All rights reserved.
//

#import "ViewModel.h"
#import "ImgModel.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"


@implementation ViewModel



- (AFHTTPRequestOperationManager *)manager
{
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSMutableSet *mgrSet = [NSMutableSet set];
    mgrSet.set = mgr.responseSerializer.acceptableContentTypes;
    
    [mgrSet addObject:@"text/html"];
    
    mgr.responseSerializer.acceptableContentTypes = mgrSet;
    
    return mgr;
}

- (void)loadDataModelSuccess:(void(^)(DataModel *model))success faile:(void(^)(NSError *error))faile{
    // 网易新闻链接
    NSString *url = @"http://c.m.163.com/nc/article/CDAG0B3D000189FH/full.html";
    
    [[self manager]GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSDictionary *value = dic[@"CDAG0B3D000189FH"]; // 数据
            
            DataModel *model = [[DataModel alloc]init];
            model.body = value[@"body"];
            model.ptime = value[@"ptime"];
            model.title = value[@"title"];
            NSArray *imgArray = value[@"img"];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:imgArray.count];
            for (NSDictionary *imgDic in imgArray) {
                ImgModel *imgModel = [[ImgModel alloc]init];
                [imgModel setValuesForKeysWithDictionary:imgDic];
                [tempArray addObject:imgModel];
            }
            model.imgs = tempArray;
            self.model = model;
            success(model);
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        faile(error);
    }];
}


// 给html网页搭骨架
-(NSString *)getHtmlString{
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>"];
    [html appendString:@"<head>"];
    [html appendFormat:@"<link rel=\"stylesheet\" href=\"%@\">",[[NSBundle mainBundle] URLForResource:@"SXDetails.css" withExtension:nil]];
    [html appendString:@"</head>"];
    
    [html appendString:@"<body style=\"background:#f6f6f6\">"];
    [html appendString:[self getBodyString]];
    [html appendString:@"</body>"];
    
    [html appendString:@"</html>"];
    
    return html;
}

// 设置html的body标签内容
- (NSString *)getBodyString
{
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"<div class=\"title\">%@</div>",self.model.title];
    [body appendFormat:@"<div class=\"time\">%@</div>",self.model.ptime];
    if (self.model.body != nil) {
        [body appendString:self.model.body];
    }
    
    // 遍历加载图片数组
    for (ImgModel *detailImgModel in self.model.imgs) {
        NSMutableString *imgHtml = [NSMutableString string];
        // 设置img的div
        [imgHtml appendString:@"<div class=\"img-parent\">"];
        NSArray *pixel = [detailImgModel.pixel componentsSeparatedByString:@"*"];
        CGFloat width = [[pixel firstObject]floatValue];
        CGFloat height = [[pixel lastObject]floatValue];
        // 判断是否超过最大宽度
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width * 0.96;
        if (width > maxWidth) {
            height = maxWidth / width * height;
            width = maxWidth;
        }
        
        // 图片的点击方法,和图片大小链接
        // getBoundingClientRect用于获得页面中某个元素的左，上，右和下分别相对浏览器视窗的位置。
        // clientWidth 是对象可见的宽度，不包滚动条等边线，会随窗口的显示大小改变。
        
        NSString *onload = @"this.onclick = function() {"
        "  window.location.href = 'rf://github.com/RockyFung?src=' +this.src+'&top=' + this.getBoundingClientRect().top + '&whscale=' + this.clientWidth/this.clientHeight ;"
        "};";
        [imgHtml appendFormat:@"<img onload=\"%@\" width=\"%f\" height=\"%f\" src=\"%@\">",onload,width,height,detailImgModel.src];
        
        [imgHtml appendString:@"</div>"];
        [body replaceOccurrencesOfString:detailImgModel.ref withString:imgHtml options:NSCaseInsensitiveSearch range:NSMakeRange(0, body.length)];
    }
    return body;
}


@end
