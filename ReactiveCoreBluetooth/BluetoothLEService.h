//
//  BluetoothService.h
//  Bluetooth Test App
//
//  Created by Matt Bowman on 7/23/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BluetoothLEService : NSObject <CBCentralManagerDelegate>
@property (nonatomic) RACSignal* availableDevicesSignal;
@property (nonatomic) RACSignal* scanningForDevicesSignal;
@property (nonatomic) RACSignal* bluetoothStateSignal;
@property (nonatomic) RACSignal* peripheralConnectedSignal;
@property (nonatomic) RACSignal* peripheralDisconnectedSignal;

@property (nonatomic) NSTimeInterval cacheDurationForDevices;
@property (nonatomic) NSTimeInterval cachePollingInterval;

@property (nonatomic) BOOL connectOnDiscovery;

-(void) stopScanningForDevices;
-(void) scanForAvailableDevices;
-(void) scanForAvailableDevicesWithServices:(NSArray *)serviceUUIDs;
-(void) connectDevice:(CBPeripheral *)device; 

@end

