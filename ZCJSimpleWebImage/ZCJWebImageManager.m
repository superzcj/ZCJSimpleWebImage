//
//  ZCJWebImageManager.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "ZCJWebImageManager.h"
#import "ZCJWebImageCache.h"
#import "ZCJWebImageDownloader.h"

@interface ZCJWebImageManager()

@property (nonatomic, strong)ZCJWebImageDownloader *downloader;

@property (nonatomic, strong)ZCJWebImageCache *cache;

@end

@implementation ZCJWebImageManager

+(instancetype)sharedManager {
    static dispatch_once_t once;
    static id manager;
    dispatch_once(&once, ^{manager = self.new;});
    return manager;
}

-(instancetype)init {
    if (self = [super init]) {
        _downloader = [ZCJWebImageDownloader sharedDownloader];
        _cache = [ZCJWebImageCache sharedCache];
    }
    return self;
}

-(void)loadImageWithUrl:(NSString *)urlStr completeBlock:(ZCJWebImageCompleteBlock)completeBlock {
    if (!urlStr) {
        completeBlock(nil,nil,NO);
        return;
    }
    UIImage *image = [self.cache imageFromCacheForKey:urlStr];
    if (!image) {
        [self.downloader downloadImageWith:urlStr completeBlock:^(UIImage *image, NSError *error, BOOL isFinished) {
            
            if (image && !error && isFinished) {
                //[self.cache storeImage:image forKey:urlStr];
                completeBlock(image, error, isFinished);
            } else {
                completeBlock(image, error, isFinished);
            }
        }];
    }
    else {
        completeBlock(image, nil, YES);
    }
}

@end
