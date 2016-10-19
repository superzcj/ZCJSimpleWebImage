//
//  ZCJWebImageDownloader.h
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ZCJWebImageDownCompleteBlock)(UIImage *image, NSError *error, BOOL isFinished);

@interface ZCJWebImageDownloader : NSObject
@property (readonly, nonatomic) NSUInteger currentDownloadCount;

+ (instancetype)sharedDownloader;

- (void)downloadImageWith:(NSString *)urlStr completeBlock:(ZCJWebImageDownCompleteBlock)completeBlock;
@end
