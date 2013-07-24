//
//  ViewController.h
//  ReactiveCoreBluetoothSampleApp
//
//  Created by Matt Bowman on 7/23/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
