//
//  ZCJWebImageDownloader.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "ZCJWebImageDownloader.h"
#import "ZCJWebImageDownloadOperation.h"

@interface ZCJWebImageDownloader()

@property (nonatomic, strong) dispatch_queue_t barrierQueue;

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (nonatomic, strong) NSOperation *lastOperation;

@property (nonatomic, strong) NSMutableDictionary *URLoperations;


@end

@implementation ZCJWebImageDownloader

+ (instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id downloader;
    dispatch_once(&once, ^{downloader = self.new;});
    return downloader;
}


-(instancetype)init {
    self = [super init];
    if (self) {
        _barrierQueue = dispatch_queue_create("com.zcj.ZCJWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadQueue = [[NSOperationQueue alloc] init];
        //_downloadQueue.maxConcurrentOperationCount = 8;
        _downloadQueue.name = @"com.zcj.ZCJWebImageDownloader";
        
        _URLoperations = [NSMutableDictionary new];
    }
    return self;
}

- (void)downloadImageWith:(NSString *)urlStr completeBlock:(ZCJWebImageDownCompleteBlock)completeBlock {
    if (!urlStr) {
        if (completeBlock) {
            completeBlock(nil, nil, YES);
        }
        return;
    }
    
    ZCJWebImageDownloadOperation*(^createDownloaderOperation)() = ^(){
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
        request.HTTPShouldUsePipelining = YES;

        ZCJWebImageDownloadOperation *operation = [[ZCJWebImageDownloadOperation alloc] initWithRequest:request];
        operation.queuePriority = NSURLSessionTaskPriorityHigh;
        
        [self.downloadQueue addOperation:operation];
        
        [self.lastOperation addDependency:operation];
        self.lastOperation = operation;
        
        return operation;
    };
    [self addCompletedBlock:completeBlock forUrl:urlStr createCallback:createDownloaderOperation];
}

- (void)addCompletedBlock:(ZCJWebImageDownCompleteBlock)completeBlock forUrl:(NSString *)urlStr createCallback:(    ZCJWebImageDownloadOperation*(^)())createCallback {
    
    dispatch_barrier_sync(self.barrierQueue, ^{
        ZCJWebImageDownloadOperation *operation = self.URLoperations[urlStr];
        if (!operation) {
            operation = createCallback();
            self.URLoperations[urlStr] = operation;
            
            __weak ZCJWebImageDownloadOperation *wo = operation;
            operation.completionBlock = ^{
                ZCJWebImageDownloadOperation *so = wo;
                if (!so) {
                    return;
                }
                if (self.URLoperations[urlStr] == so) {
                    [self.URLoperations removeObjectForKey:urlStr];
                }
            };
            [operation addCompletedBlock:completeBlock];
        }
    });
}

- (void)cancel:(NSString *)url {
    dispatch_barrier_sync(_barrierQueue, ^{
        ZCJWebImageDownloadOperation *op = self.URLoperations[url];
        BOOL canceled = [op cancel:url];
        if (canceled) {
            [self.URLoperations removeObjectForKey:url];
        }
    });
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

@end
