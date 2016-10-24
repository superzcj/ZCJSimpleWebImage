//
//  UIImageView+ZCJWebImage.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "UIImageView+ZCJWebImage.h"
#import "ZCJWebImageManager.h"
#import "ZCJWebImageDownloader.h"

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@implementation UIImageView (ZCJWebImage)

- (void)zcj_setImageUrlWith:(NSString *)urlStr placeholderImage:(UIImage *)placeholder;
{
    if (!urlStr) {
        return;
    }
    
    if (placeholder) {
        self.image = placeholder;
    }
    __weak __typeof(self)wself = self;
    
    [[ZCJWebImageManager sharedManager] loadImageWithUrl:urlStr completeBlock:^(UIImage *image, NSError *error, BOOL isFinished) {
        __strong __typeof (wself) sself = wself;

           dispatch_sync(dispatch_get_main_queue(), ^{
               
           if (image && !error && isFinished) {
               
               UIImageView *imageView = (UIImageView *)sself;
               imageView.image = image;
               imageView.backgroundColor = [UIColor redColor];
               [sself setNeedsLayout];
           } else {

           }
       });
     
     }];
    
}

@end
