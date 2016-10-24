//
//  ZCJWebImageDownloadOperation.h
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/17.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCJWebImageDownloader.h"

@interface ZCJWebImageDownloadOperation : NSOperation

@property (nonnull,strong)NSURLRequest *request;

@property (strong, nonatomic) NSURLSessionTask *dataTask;

-(instancetype)initWithRequest:(NSURLRequest *)request;

- (void)addCompletedBlock:(ZCJWebImageDownCompleteBlock)completeBlock;
- (BOOL)cancel:(nullable id)token;

@end
