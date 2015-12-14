//
//  HMViewController.m
//  03-小文件下载（了解）
//
//  Created by apple on 14-9-22.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMViewController.h"

@interface HMViewController ()

@end

@implementation HMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 下载小文件的方式
    // 1.NSData dataWithContentsOfURL
    // 2.NSURLConnection
}

// 1.NSData dataWithContentsOfURL
- (void)downloadFile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 其实这就是一个GET请求
        NSURL *url = [NSURL URLWithString:@"http://localhost:8080/MJServer/resources/images/minion_01.png"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSLog(@"%d", data.length);
    });
}

// 2.NSURLConnection
- (void)downloadFile2
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/MJServer/resources/images/minion_01.png"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"%d", data.length);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self downloadFile2];
}

@end
