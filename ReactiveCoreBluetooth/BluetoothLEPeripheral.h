//
//  BluetoothPeripheral.h
//  Bluetooth Test App
//
//  Created by Volca on 11/29/13.
//  Copyright (c) 2013 Volca All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class RACSubject;

@interface BluetoothLEPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic) RACSubject* discoveredServicesSignal;
@property (nonatomic) RACSubject* discoveredCharacteristicsSignal;
@property (nonatomic) RACSubject* wroteValueSignal;

@property (nonatomic, strong) CBPeripheral* device;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;
- (CBPeripheralState)state;

@end

