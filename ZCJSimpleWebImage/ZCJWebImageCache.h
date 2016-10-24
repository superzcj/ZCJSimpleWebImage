//
//  ZCJWebImageCache.h
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZCJWebImageCache : NSObject

+(instancetype)sharedCache;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key;
-(UIImage *)imageFromCacheForKey:(NSString *)key;

@end
