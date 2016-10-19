//
//  ZCJWebImageDownloadOperation.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/17.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "ZCJWebImageDownloadOperation.h"

static NSString *const kCompletedBlock = @"kCompletedBlock";

@interface ZCJWebImageDownloadOperation()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong)NSMutableArray *callbackBlocks;

@property (nonatomic, strong)NSMutableData *imageData;

@property (nonatomic, assign)BOOL isExecuting;
@property (assign, nonatomic) BOOL isFinished;

@property (nonatomic, strong)NSURLSession *unownedSession;

@property (nonatomic, strong)NSURLSession *ownSession;

@property (nonatomic, strong)dispatch_queue_t barrierQueue;

@end

@implementation ZCJWebImageDownloadOperation


-(instancetype)initWithRequest:(NSURLRequest *)request session:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _request = [request copy];
        _callbackBlocks = [NSMutableArray new];
        _isExecuting = NO;
        //_unownedSession = session;
        _barrierQueue = dispatch_queue_create("com.zcj.ZCJWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)addCompletedBlock:(ZCJWebImageDownCompleteBlock)completeBlock;
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if (completeBlock) {
        [dic setObject:completeBlock forKey:kCompletedBlock];
    }
    dispatch_barrier_async(_barrierQueue, ^{
        [self.callbackBlocks addObject:dic];
    });
    
}

- (NSArray *)callbackForKey:(NSString *)key {
    __block NSMutableArray *callbackArr = nil;
    //dispatch_barrier_async(_barrierQueue, ^{
        callbackArr = [self.callbackBlocks valueForKey:key];
        //[callbackArr removeObjectIdenticalTo:[NSNull null]];
    //});
    return [callbackArr copy];
}

-(void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.isFinished = YES;
            [self reset];
            return;
        }
        
        NSURLSession *session = self.unownedSession;
        if (!session) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            self.ownSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
            session = self.ownSession;
        }
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.isExecuting = YES;
    }
    
    [self.dataTask resume];

    if (!self.dataTask) {
        NSLog(@"Connection can't be initialized:");
    }
}

-(void)cancel {
    @synchronized (self) {
        if (_isFinished) {
            return;
        }
        [super cancel];
        if (self.dataTask) {
            [self.dataTask cancel];
            if (_isExecuting) {
                _isExecuting = NO;
            }
            if (!_isFinished) {
                _isFinished = YES;
            }
            
        }
        [self reset];
    }
}

- (void)done {
    _isExecuting = NO;
    _isFinished = YES;
    [self reset];
}

-(void)reset{
    dispatch_barrier_sync(_barrierQueue, ^{
        [self.callbackBlocks removeAllObjects];
    });
    self.dataTask = nil;
    self.imageData = nil;
    if (self.ownSession) {
        [self.ownSession invalidateAndCancel];
        self.ownSession = nil;
    }
}


#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304)) {
        
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.imageData = [[NSMutableData alloc] initWithCapacity:expected];

    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    @synchronized(self) {
        self.dataTask = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            /*[[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadFinishNotification object:self];
            }*/
        });
    }
    
    if (error) {
        NSLog(@"Task data error:%@", [error description]);
        //[self callCompletionBlocksWithError:error];
    } else {
        if ([self callbackForKey:kCompletedBlock].count > 0) {
            if (self.imageData) {
                UIImage *image = [UIImage imageWithData:self.imageData];
                
                
                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    //[self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}]];
                } else {
                    [self callCompletionBlocksWithImage:image imageData:self.imageData error:nil finished:YES];
                }
            } else {
                //[self callCompletionBlocksWithError:[NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
            }
        }
    }
    [self done];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbackForKey:kCompletedBlock];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZCJWebImageDownCompleteBlock completedBlock in completionBlocks) {
            completedBlock(image, error, finished);
        }
    });
}

@end
