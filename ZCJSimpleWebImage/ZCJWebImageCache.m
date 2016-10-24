//
//  ZCJWebImageCache.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "ZCJWebImageCache.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const kDefaultDiskPath = @"ZCJWebImageDiskCache";

@interface ZCJWebImageCache()

@property (nonatomic, strong)dispatch_queue_t ioQueue;

@property (nonatomic, strong)NSCache *memCache;
@property (nonatomic, strong)NSString *diskCachePath;

@property (nonatomic, strong)NSFileManager *fileManager;
@end

@implementation ZCJWebImageCache

+(instancetype)sharedCache {
    static dispatch_once_t once;
    static id cache;
    dispatch_once(&once, ^{cache = self.new;});
    return cache;
}

-(instancetype)init {
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths[0] stringByAppendingPathComponent:kDefaultDiskPath];
        
        NSString *fullName = [@"com.zcj.ZCJWebImageCache" stringByAppendingString:kDefaultDiskPath];
        
        _ioQueue = dispatch_queue_create("com.zcj.ZCJWebImageCache", DISPATCH_QUEUE_CONCURRENT);
        _memCache = [NSCache new];
        
        if (path != nil) {
            _diskCachePath = [path stringByAppendingPathComponent:fullName];
        }
        
        _fileManager = [NSFileManager new];
        
    }
    return self;
}

-(void)storeImage:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key) {
        return;
    }
    
    [self.memCache setObject:image forKey:key];
    
    dispatch_sync(_ioQueue, ^{
        NSData *imageData = UIImagePNGRepresentation(image);
        if (![_fileManager fileExistsAtPath:_diskCachePath]) {
            [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *imagePath = [_diskCachePath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
        [_fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
    });
    
}

-(UIImage *)imageFromCacheForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    
    UIImage *img = [self.memCache objectForKey:key];
    if (img) {
        return img;
    }
    
    NSString *imagePath = [_diskCachePath stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
    if ([_fileManager fileExistsAtPath:imagePath]) {
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        if (data) {
            img = [UIImage imageWithData:data];
            return img;
        }
    }
    return nil;
}

- (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [key.pathExtension isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", key.pathExtension]];
    
    return filename;
}
@end
