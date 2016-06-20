//
//  DPCHTTPRequest.h
//  RobotClient
//
//  Created by hanarobot on 16/3/31.
//  Copyright © 2016年 hanarobot. All rights reserved.
//

#import "ASIFormDataRequest.h"

typedef void(^SuccessBlock) (id successBlock);
typedef void(^FailBlock) (NSString *failBlock);

@interface DPCHTTPRequest : NSObject<ASIHTTPRequestDelegate>
{
    void (^CompletionBlock)(id resp);
    void (^FailedErrorBlock)(NSString *resultMsg);
}
+(instancetype)shareInstance;
/*
 *基于ASI框架的封装方法
 */
-(void)getAddByUrlPath:(NSString*)path addParams:(NSString*)params completion:(SuccessBlock)successBlock failedError:(FailBlock)failBlock;
/*
 *基于ASI框架的封装方法
 */
-(void)postAddByUrlPath:(NSString*)path addParams:(NSDictionary*)params completion:(SuccessBlock)successBlock failedError:(FailBlock)failBlock;
@end
