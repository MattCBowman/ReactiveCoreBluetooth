//
//  BluetoothLEPeripheral.m
//  ReactiveCoreBluetooth
//
//  Created by Linlinqi on 13-11-19.
//  Copyright (c) 2013年 Linlinqi Studio. All rights reserved.
//

#import "BluetoothLEPeripheral.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BluetoothLEPeripheral()

@end

@implementation BluetoothLEPeripheral

- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        peripheral.delegate = self;
        _device = peripheral;
        [self setupSignals];
    }
    return self;
}

- (CBPeripheralState)state {
    return _device.state;
}

- (void)setupSignals {
    _discoveredServicesSignal           = [RACSubject subject];
    _discoveredCharacteristicsSignal    = [RACSubject subject];
    _wroteValueSignal                   = [RACSubject subject];
    _updatedValueSignal                 = [RACSubject subject];
}

#pragma mark - CBperipheral delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [_discoveredServicesSignal sendError:error];
    } else {
        [_discoveredServicesSignal sendNext:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [_discoveredCharacteristicsSignal sendError:error];
    } else {
        [_discoveredCharacteristicsSignal sendNext:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        [_wroteValueSignal sendError:error];
    } else {
        [_wroteValueSignal sendNext:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        [_updatedValueSignal sendError:error];
    } else {
        [_updatedValueSignal sendNext:characteristic];
    }
}

@end
