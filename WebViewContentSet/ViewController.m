//
//  ViewController.m
//  WebViewContentSet
//
//  Created by rocky on 2017/2/15.
//  Copyright © 2017年 RockyFung. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) ViewModel *viewModel;
@end

@implementation ViewController

- (UIWebView *)webview{
    if (!_webview) {
        _webview = [[UIWebView alloc]initWithFrame:CGRectMake(10, 150, SCREEN_W - 20, SCREEN_H - 160)];
        
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
}





















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
