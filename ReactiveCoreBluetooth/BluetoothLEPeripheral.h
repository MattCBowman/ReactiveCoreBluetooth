//
//  BluetoothLEPeripheral.h
//  ReactiveCoreBluetooth
//
//  Created by Linlinqi on 13-11-19.
//  Copyright (c) 2013年 Linlinqi Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class RACSubject;

@interface BluetoothLEPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong) RACSubject* discoveredServicesSignal;
@property (nonatomic, strong) RACSubject* discoveredCharacteristicsSignal;
@property (nonatomic, strong) RACSubject* wroteValueSignal;
@property (nonatomic, strong) RACSubject* updatedValueSignal;

@property (nonatomic, strong) CBPeripheral* device;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;
- (CBPeripheralState)state;

@end

