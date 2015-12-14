//
//  HMViewController.m
//  05-大文件下载-合理（掌握）
//
//  Created by apple on 14-9-22.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMViewController.h"
#import "DACircularProgressView.h"

@interface HMViewController () <NSURLConnectionDataDelegate>
- (IBAction)download:(UIButton *)sender;

/**
 *  用来写数据的文件句柄对象
 */
@property (nonatomic, strong) NSFileHandle *writeHandle;
/**
 *  文件的总大小
 */
@property (nonatomic, assign) long long totalLength;
/**
 *  当前已经写入的文件大小
 */
@property (nonatomic, assign) long long currentLength;

/**
 *  连接对象
 */
@property (nonatomic, strong) NSURLConnection *conn;

@property (nonatomic, weak) DACircularProgressView *circleView;
@end

@implementation HMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    DACircularProgressView *circleView = [[DACircularProgressView alloc] init];
    circleView.frame = CGRectMake(100, 50, 100, 100);
    circleView.progressTintColor = [UIColor redColor];
    circleView.trackTintColor = [UIColor blueColor];
    circleView.progress = 0.0000001;
    [self.view addSubview:circleView];
    self.circleView = circleView;
}

#pragma mark - NSURLConnectionDataDelegate代理方法
/**
 *  请求失败时调用（请求超时、网络异常）
 *
 *  @param error      错误原因
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

/**
 *  1.接收到服务器的响应就会调用
 *
 *  @param response   响应
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (self.currentLength) return;
    
    // 文件路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filepath = [caches stringByAppendingPathComponent:@"videos.zip"];
    
    // 创建一个空的文件 到 沙盒中
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr createFileAtPath:filepath contents:nil attributes:nil];
    
    // 创建一个用来写数据的文件句柄
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    
    // 获得文件的总大小
    self.totalLength = response.expectedContentLength;
}

/**
 *  2.当接收到服务器返回的实体数据时调用（具体内容，这个方法可能会被调用多次）
 *
 *  @param data       这次返回的数据
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 移动到文件的最后面
    [self.writeHandle seekToEndOfFile];
    
    // 将数据写入沙盒
    [self.writeHandle writeData:data];
    
    // 累计文件的长度
    self.currentLength += data.length;
    
    self.circleView.progress = (double)self.currentLength/ self.totalLength;
}

/**
 *  3.加载完毕后调用（服务器的数据已经完全返回后）
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.currentLength = 0;
    self.totalLength = 0;
    
    // 关闭文件
    [self.writeHandle closeFile];
    self.writeHandle = nil;
}

- (IBAction)download:(UIButton *)sender {
    // 状态取反
    sender.selected = !sender.isSelected;
    
    // 断点续传
    // 断点下载
    
    if (sender.selected) { // 继续（开始）下载
        // 1.URL
        NSURL *url = [NSURL URLWithString:@"http://localhost:8080/MJServer/resources/videos.zip"];
        
        // 2.请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 3.下载(创建完conn对象后，会自动发起一个异步请求)
        self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    } else { // 暂停
        [self.conn cancel];
        self.conn = nil;
    }
}
@end
