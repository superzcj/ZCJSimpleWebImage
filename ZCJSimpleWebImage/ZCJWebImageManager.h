//
//  ZCJWebImageManager.h
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ZCJWebImageCompleteBlock)(UIImage *image, NSError *error, BOOL isFinished);

@interface ZCJWebImageManager : NSObject

+(instancetype)sharedManager;

-(void)loadImageWithUrl:(NSString *)urlStr completeBlock:(ZCJWebImageCompleteBlock)completeBlock;

@end
