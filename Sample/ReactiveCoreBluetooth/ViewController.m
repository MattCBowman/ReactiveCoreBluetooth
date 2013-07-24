//
//  ViewController.m
//  ReactiveCoreBluetoothSampleApp
//
//  Created by Matt Bowman on 7/23/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCoreBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()

@property (nonatomic) NSArray* blueToothDevices;
@property (nonatomic) BluetoothLEService* bluetoothService;
@property (nonatomic) NSString* blueToothStatus;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.blueToothDevices = @[];
    
    self.bluetoothService = [[BluetoothLEService alloc] init];

    [RACAble(self.blueToothDevices) subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];
    
    [self.bluetoothService.availableDevicesSignal subscribeNext:^(NSArray* x) {
        self.blueToothDevices = x;
    }];
    
    [RACAble(self.blueToothStatus) subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];

    [self.bluetoothService.bluetoothStateSignal subscribeNext:^(NSNumber* x) {
        CBCentralManagerState state = (CBCentralManagerState)[x integerValue];
        
        switch (state)
        {
            case CBCentralManagerStatePoweredOff:
                self.blueToothStatus = @"Off";
                break;
            case CBCentralManagerStatePoweredOn:
                self.blueToothStatus = @"On";
                [self.bluetoothService scanForAvailableDevices];
                break;
            case CBCentralManagerStateResetting:
                self.blueToothStatus = @"Resetting";
                break;
            case CBCentralManagerStateUnauthorized:
                self.blueToothStatus = @"Unauthorized";
                break;
            case CBCentralManagerStateUnknown:
                self.blueToothStatus = @"Unknown";
                break;
            case CBCentralManagerStateUnsupported:
                self.blueToothStatus = @"Unsupported";
                break;
            default:
                self.blueToothStatus = @"Error: State Unknown";
                break;
        }
    }];
    
    [self.bluetoothService.peripheralConnectedSignal subscribeNext:^(CBPeripheral* device) {
        NSLog(@"Connected to %@", device.name);
    }];
    
    [self.bluetoothService.peripheralDisconnectedSignal subscribeNext:^(CBPeripheral* device) {
        NSLog(@"Disconnected from %@", device.name);
    }];
    
    [self.tableView reloadData];
}

#pragma mark - TableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return [self.blueToothDevices count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BluetoothDeviceCell"];

    if (indexPath.section == 0)
    {
        cell.textLabel.text = self.blueToothStatus;
        cell.detailTextLabel.text = @"";
    }
    else
    {
        CBPeripheral* peripheral = [self.blueToothDevices objectAtIndex:indexPath.row];
    
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", peripheral.isConnected ? @"Connected" : @""];
    }
    return cell;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Bluetooth Status";
    }
    else
    {
        return @"Bluetooth LE Devices";
    }
}

#pragma mark -
-(void) refreshData:(UIRefreshControl *)refreshControl
{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

@end
