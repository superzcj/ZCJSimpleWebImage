//
//  TableViewController.m
//  ZCJSimpleWebImage
//
//  Created by zhangchaojie on 16/10/19.
//  Copyright © 2016年 zhangchaojie. All rights reserved.
//

#import "TableViewController.h"
#import "ZCJWebImageDownloader.h"

@interface MyCustomTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *customTextLabel;
@property (nonatomic, strong) UIImageView *customImageView;

@end


@implementation MyCustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 2.0, 60.0, 40.0)];
        [self.contentView addSubview:_customImageView];
        _customTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 12.0, 200, 20.0)];
        [self.contentView addSubview:_customTextLabel];
        
        _customImageView.clipsToBounds = YES;
        _customImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

@end

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[MyCustomTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    MyCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    cell.customTextLabel.text = [NSString stringWithFormat:@"Image #%ld", (long)indexPath.row];

    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-%ld.jpg", indexPath.row+1];
    [[ZCJWebImageDownloader sharedDownloader] downloadImageWith:url completeBlock:^(UIImage *image, NSError *error, BOOL isFinished) {
        
        if (image && !error && isFinished) {
            //dispatch_sync(dispatch_get_main_queue(), ^{
                cell.imageView.image = image;
            //});
        } else {
            //XCTFail(@"Something went wrong");
            NSLog(@"wrong");
            
        }
    }];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
