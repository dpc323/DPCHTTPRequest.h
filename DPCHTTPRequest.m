//
//  DPCHTTPRequest.m
//  RobotClient
//
//  Created by hanarobot on 16/3/31.
//  Copyright © 2016年 hanarobot. All rights reserved.
//

#import "DPCHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "GlobalTool.h"

#define REQUEST_POST @"POST"

@implementation DPCHTTPRequest

-(void)dealloc
{
    [self clearBlock];
}

- (void)clearBlock
{
    if (CompletionBlock)
    {
        CompletionBlock = nil;
    }
    if (FailedErrorBlock)
    {
        FailedErrorBlock = nil;
    }
}

+(instancetype)shareInstance;
{
    static DPCHTTPRequest *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

-(void)getAddByUrlPath:(NSString*)path addParams:(NSString*)params completion:(SuccessBlock)successBlock failedError:(FailBlock)failBlock
{
    [self clearBlock];
    CompletionBlock = [successBlock copy];
    FailedErrorBlock = [failBlock copy];
    
    if (params)
    {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"?%@",params]];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"GET"];
    [request setValidatesSecureCertificate:NO];//请求为HTTPS时需要设置这个属性
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];//encoding
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void)postAddByUrlPath:(NSString*)path addParams:(NSDictionary*)params completion:(SuccessBlock)successBlock failedError:(FailBlock)failBlock;
{
    [self clearBlock];
    CompletionBlock = [successBlock copy];
    FailedErrorBlock = [failBlock copy];
    
    ASIFormDataRequest *request =  [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:path]];
    [request setValidatesSecureCertificate:NO];//请求https的时候，就要设置这个属性
    [request setRequestMethod:REQUEST_POST];
    [request addRequestHeader:@"Accept" value:@"text/html"];
    [request addRequestHeader:@"Content-Type" value:@"text/html;charset=UTF-8"];
    request.delegate = self;

    for (NSDictionary *subDic in params)
    {
        [request setPostValue:[NSString stringWithFormat:@"%@",[params objectForKey:subDic]] forKey:[NSString stringWithFormat:@"%@",subDic]];
        NSLog(@"%@,%@",subDic,[params objectForKey:subDic]);
    }
    
    [request startAsynchronous];
}

- ( void )requestFailed:( ASIHTTPRequest *)request
{
    if (FailedErrorBlock)
    {
        FailedErrorBlock(kNetworkError);
    }
}

// 请求结束，获取 Response 数据
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    
    NSLog(@"responseString = %@",responseString);

    NSDictionary *responseDictionary = [responseString JSONValue];
    NSString *errorcode = responseDictionary[@"cloudserver"][0][@"errorcode"];
    NSLog(@"responseDictionary = %@",responseDictionary);
    
    //000000返回成功  100007手机号未注册时需要
    if (responseDictionary && ([errorcode isEqualToString:@"000000"] || [errorcode isEqualToString:@"100007"] || [errorcode integerValue] == 0))
    {
        if (responseDictionary[@"cloudserver"][0])
        {
            CompletionBlock(responseDictionary[@"cloudserver"][0]);
            return;
        }
    }
    
    if (!responseDictionary)
    {
        //服务器关闭时
        if ([responseString rangeOfString:@"html"].location != NSNotFound)
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObject:@"8800404" forKey:@"errorcode"];
            CompletionBlock(dic);
            return;
        }
        
        CompletionBlock(responseString);
        return;
    }
    
    /*
    if (responseDictionary) 
    {
        CompletionBlock(responseDictionary[@"cloudserver"][0]);
        return;
    }
    */
    
    if (FailedErrorBlock)
    {
        if (responseDictionary)
        {
            if (errorcode != nil)
            {
                FailedErrorBlock(errorcode);
            }
            else
            {
                FailedErrorBlock(kGetDataError);
            }
        }
        else
        {
            FailedErrorBlock(kGetDataError);
        }
    }
}

@end
