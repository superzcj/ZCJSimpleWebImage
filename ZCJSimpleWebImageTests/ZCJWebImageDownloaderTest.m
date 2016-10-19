//
//  ZCJWebImageDownloaderTest.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/19.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCJWebImageDownloader.h"

@interface ZCJWebImageDownloaderTest : XCTestCase

@end

@implementation ZCJWebImageDownloaderTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
- (void)test01ThatSharedDownloaderIsNotEqualToInitDownloader {
    ZCJWebImageDownloader *downloader = [[ZCJWebImageDownloader alloc] init];
    XCTAssertNotEqual(downloader, [ZCJWebImageDownloader sharedDownloader]);
}
*/

- (void)test04ThatASimpleDownloadWorks {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Simple download"];
    NSString *imageURL = @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage004.jpg";
    imageURL = @"http://i.stack.imgur.com/LqXFE.png";
    [[ZCJWebImageDownloader sharedDownloader] downloadImageWith:imageURL completeBlock:^(UIImage *image, NSError *error, BOOL isFinished) {
        
        if (image && !error && isFinished) {
            [expectation fulfill];
        } else {
            XCTFail(@"Something went wrong");
        }
    }];
    
    NSInteger count = [ZCJWebImageDownloader sharedDownloader].currentDownloadCount;
    
    XCTAssertEqual(count, 1, @"wrong");
    //[self waitForExpectationsWithTimeout:5 handler:nil];
}


@end
