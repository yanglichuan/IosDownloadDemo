//
//  HMViewController.m
//  01-基本的HTTP请求
//
//  Created by apple on 14-9-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMViewController.h"
#import "MBProgressHUD+MJ.h"
#import "NSString+Hash.h"

@interface HMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
- (IBAction)login;
@end

@implementation HMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)login {
    // 1.用户名
    NSString *usernameText = self.username.text;
    if (usernameText.length == 0) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }
    
    // 2.密码
    NSString *pwdText = self.pwd.text;
    if (pwdText.length == 0) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    
    // 增加蒙板
    [MBProgressHUD showMessage:@"正在拼命登录中...."];
    
    // 3.发送用户名和密码给服务器(走HTTP协议)
    // 创建一个URL ： 请求路径
    NSURL *url = [NSURL URLWithString:@"http://192.168.15.172:8080/MJServer/login"];
    
    // 创建一个请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 5秒后算请求超时（默认60s超时）
    request.timeoutInterval = 15;
    
    request.HTTPMethod = @"POST";
    
#warning 对pwdText进行加密
    pwdText = [self MD5Reorder:pwdText];
    
    // 设置请求体
    NSString *param = [NSString stringWithFormat:@"username=%@&pwd=%@", usernameText, pwdText];
    
    NSLog(@"%@", param);
    
    // NSString --> NSData
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    
    // 设置请求头信息
    [request setValue:@"iPhone 6" forHTTPHeaderField:@"User-Agent"];
    
    // 发送一个同步请求(在主线程发送请求)
    // queue ：存放completionHandler这个任务
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         // 隐藏蒙板
         [MBProgressHUD hideHUD];
     
        // 这个block会在请求完毕的时候自动调用
        if (connectionError || data == nil) { // 一般请求超时就会来到这
            [MBProgressHUD showError:@"请求失败"];
            return;
        }
        
        // 解析服务器返回的JSON数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString *error = dict[@"error"];
        if (error) {
            [MBProgressHUD showError:error];
        } else {
            NSString *success = dict[@"success"];
            [MBProgressHUD showSuccess:success];
        }
     }];
}

/**
 *  MD5($pass.$salt)
 *
 *  @param text 明文
 *
 *  @return 加密后的密文
 */
- (NSString *)MD5Salt:(NSString *)text
{
    // 撒盐：随机地往明文中插入任意字符串
    NSString *salt = [text stringByAppendingString:@"aaa"];
    return [salt md5String];
}

/**
 *  MD5(MD5($pass))
 *
 *  @param text 明文
 *
 *  @return 加密后的密文
 */
- (NSString *)doubleMD5:(NSString *)text
{
    return [[text md5String] md5String];
}

/**
 *  先加密，后乱序
 *
 *  @param text 明文
 *
 *  @return 加密后的密文
 */
- (NSString *)MD5Reorder:(NSString *)text
{
    NSString *pwd = [text md5String];
    
    // 加密后pwd == 3f853778a951fd2cdf34dfd16504c5d8
    NSString *prefix = [pwd substringFromIndex:2];
    NSString *subfix = [pwd substringToIndex:2];
    
    // 乱序后 result == 853778a951fd2cdf34dfd16504c5d83f
    NSString *result = [prefix stringByAppendingString:subfix];
    
    NSLog(@"\ntext=%@\npwd=%@\nresult=%@", text, pwd, result);
    
    return result;
}
@end
