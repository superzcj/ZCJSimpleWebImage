//
//  ViewController.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/14.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "ViewController.h"
#import "ZCJWebImageDownloader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *imageURL = @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage004.jpg";
    imageURL = @"http://i.stack.imgur.com/LqXFE.png";

    [[ZCJWebImageDownloader sharedDownloader] downloadImageWith:imageURL completeBlock:^(UIImage *image, NSError *error, BOOL isFinished) {
        
        if (image && !error && isFinished) {
            //[expectation fulfill];
            NSLog(@"ok");
        } else {
            //XCTFail(@"Something went wrong");
            NSLog(@"wrong");

        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
