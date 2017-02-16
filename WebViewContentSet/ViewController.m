//
//  ViewController.m
//  WebViewContentSet
//
//  Created by rocky on 2017/2/15.
//  Copyright © 2017年 RockyFung. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"
#import "UIImageView+WebCache.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, strong) UIView *hoverView;
@property (nonatomic, strong) UIImageView *bigImg;
@property (nonatomic, strong) NSMutableDictionary *temImgPara;
@end

@implementation ViewController

- (UIWebView *)webview{
    if (!_webview) {
        _webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 150, SCREEN_W, SCREEN_H - 150)];
        
    }
    return _webview;
}

- (ViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[ViewModel alloc]init];
    }
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(30, 80, SCREEN_W - 60, 30)];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"加载内容到网页" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    self.webview.delegate = self;
    [self.view addSubview:self.webview];
    
    
    self.hoverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
    self.hoverView.backgroundColor = [UIColor blackColor];
    
    UIButton *downLoad = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 60, SCREEN_H - 60, 50, 50)];
    [downLoad setImage:[UIImage imageNamed:@"203"] forState:UIControlStateNormal];
    [downLoad addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.hoverView addSubview:downLoad];
    
    
    
}
- (void)downloadAction:(UIButton *)btn{
    NSLog(@"下载图片");
}

- (void)btnAction:(UIButton *)btn{
    // 加载数据
    [self.viewModel loadDataModelSuccess:^(DataModel *model) {
        [self.webview loadHTMLString:[self.viewModel getHtmlString] baseURL:nil];
    } faile:^(NSError *error) {
        
    }];
}


#pragma mark -webviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *url = request.URL.absoluteString;
    if ([url hasPrefix:@"rf:"]) {
        [self showPicInfoWithUrl:url];
        return NO;
    }
    return YES;
}

- (void)showPicInfoWithUrl:(NSString *)url{
    self.view.userInteractionEnabled = NO;
    
    // url rf://github.com/RockyFung?src=http://cms-bucket.nosdn.127.net/fbf6d59aae174277b6ce058719dc275f20170215110357.jpeg&top=113&whscale=1.6901408450704225
    
    // 取“？”以后的参数
    NSString *para = [url componentsSeparatedByString:@"?"].lastObject;
    
    // 参数分割
    NSArray *paraArray = [para componentsSeparatedByString:@"&"];
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionary];
    for (NSString *paraStr in paraArray) {
        NSString *key = [paraStr componentsSeparatedByString:@"="].firstObject;
        NSString *value = [paraStr componentsSeparatedByString:@"="].lastObject;
        [paraDic setObject:value forKey:key];
    }
    
    NSLog(@"点击的图片参数 :%@",paraDic);
    
    NSURLCache *cache =[NSURLCache sharedURLCache];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:paraDic[@"src"]]];
    NSData *imgData = [cache cachedResponseForRequest:request].data;
    UIImage *image = [UIImage imageWithData:imgData];
    
    // 重新赋值top height
    CGFloat top = self.webview.frame.origin.y +[paraDic[@"top"]floatValue];
    CGFloat height = (SCREEN_W - 15) / [paraDic[@"whscale"] floatValue];
    [paraDic setValue:@(top) forKey:@"top"];
    [paraDic setValue:@(height) forKey:@"height"];
    self.temImgPara = paraDic;
    
    // 显示点击图片
    UIImageView *imgView = [[UIImageView alloc]initWithImage:image];
    imgView.frame = CGRectMake(8, [paraDic[@"top"]floatValue], SCREEN_W-15, height);
    self.bigImg = imgView;
    self.hoverView.alpha = 0.0f;
    [self.view addSubview:self.hoverView];
    [self.view addSubview:imgView];
    
    if (!image) {
        [imgView sd_setImageWithURL:[NSURL URLWithString:paraDic[@"src"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self moveToCenter];
        }];
    }else{
        [self moveToCenter];
    }
    
    // 给图片添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(moveToOrigin)];
    imgView.userInteractionEnabled = YES;
    [imgView addGestureRecognizer:tap];
}


- (void)moveToOrigin
{
    [UIView animateWithDuration:0.5 animations:^{
        self.hoverView.alpha = 0.0f;
        self.bigImg.frame = CGRectMake(8, [self.temImgPara[@"top"] floatValue], SCREEN_W-15, [self.temImgPara[@"height"] floatValue]);
    } completion:^(BOOL finished) {
        [self.hoverView removeFromSuperview];
        [self.bigImg removeFromSuperview];
        self.bigImg = nil;
    }];
}

- (void)moveToCenter
{
    CGFloat w = SCREEN_W;
    CGFloat h = SCREEN_W / [self.temImgPara[@"whscale"] floatValue];
    CGFloat x = 0;
    CGFloat y = (SCREEN_H - h)/2;
    [UIView animateWithDuration:0.5 animations:^{
        self.hoverView.alpha = 1.0f;
        self.bigImg.frame = CGRectMake(x, y, w, h);
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
}


















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
