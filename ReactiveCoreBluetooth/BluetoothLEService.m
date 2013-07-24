//
//  BluetoothService.m
//  Bluetooth Test App
//
//  Created by Matt Bowman on 7/23/13.
//  Copyright (c) 2013 Citrrus, LLC. All rights reserved.
//

#import "BluetoothLEService.h"
#import "CacheObject.h"
#import <libextobjc/EXTScope.h>

@interface BluetoothLEService()
{
    RACSubject* _availableDevicesSignal;
    RACSubject* _scanningForDevicesSignal;
    RACSubject* _bluetoothStateSignal;
    RACSubject* _peripheralConnectedSignal;
    RACSubject* _peripheralDisconnectedSignal;
}

@property (nonatomic) CBCentralManager*     cbManager;
@property (atomic) NSMutableArray*          pendingDevices;
@property (atomic) NSMutableArray*          connectedDevices;
@property (nonatomic) RACSignal*            expireKnownDevicesSignal;

@end

@implementation BluetoothLEService

@synthesize availableDevicesSignal =        _availableDevicesSignal;
@synthesize scanningForDevicesSignal =      _scanningForDevicesSignal;
@synthesize bluetoothStateSignal =          _bluetoothStateSignal;
@synthesize peripheralConnectedSignal =     _peripheralConnectedSignal;
@synthesize peripheralDisconnectedSignal =  _peripheralDisconnectedSignal;

#pragma mark -
#pragma mark NSObject Lifecycle Methods

-(id) init
{
    self = [super init];
    if (self)
    {
        self.pendingDevices =           [[NSMutableArray alloc] init];
        self.connectedDevices =         [[NSMutableArray alloc] init];
        self.cbManager =                [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.cacheDurationForDevices =  5;
        self.cachePollingInterval =     3;

        [self initializeSignals];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

-(void) stopScanningForDevices
{
    [self.cbManager stopScan];
    [_scanningForDevicesSignal sendNext:@(NO)];
}

-(void) scanForAvailableDevices
{
    [self scanForAvailableDevicesWithServices:nil];
}

-(void) scanForAvailableDevicesWithServices:(NSArray *)serviceUUIDs
{
    [_scanningForDevicesSignal sendNext:@(YES)];
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)};
    [self.cbManager scanForPeripheralsWithServices:serviceUUIDs
                                           options:options];
}


#pragma mark -
#pragma mark Internal Helper Methods

-(void) initializeSignals
{
    _availableDevicesSignal =       [RACSubject subject];
    _bluetoothStateSignal =         [RACSubject subject];
    _scanningForDevicesSignal =     [RACSubject subject];
    _peripheralConnectedSignal =    [RACSubject subject];
    _peripheralDisconnectedSignal = [RACSubject subject];
    self.expireKnownDevicesSignal = [[RACSignal interval:self.cachePollingInterval] deliverOn:[RACScheduler mainThreadScheduler]];
    
    @weakify(self)
    [self.expireKnownDevicesSignal subscribeNext:^(id x) {
        @strongify(self)
        NSMutableArray *devicesToKeep = [[NSMutableArray alloc] init];
        BOOL devicesExpired = NO;
        
        for (CacheObject* obj in self.pendingDevices)
        {
            if (!obj.isExpired)
            {
                [devicesToKeep addObject:obj];
            }
            else
            {
                devicesExpired = YES;
            }
        }
        
        if (devicesExpired)
        {
            self.pendingDevices = devicesToKeep;
        }

        devicesToKeep = [[NSMutableArray alloc] init];
        BOOL devicesDisconnected = NO;
        
        for (CacheObject* obj in self.connectedDevices)
        {
            CBPeripheral* p = (CBPeripheral*)obj.object;
            if (p.isConnected)
            {
                [devicesToKeep addObject:obj];
            }
            else
            {
                devicesDisconnected = YES;
            }
        }
        
        if (devicesDisconnected)
        {
            self.connectedDevices = devicesToKeep;
            [_availableDevicesSignal sendNext:[self devices]];
        }
    }];
}

-(NSArray*) devices
{
    NSMutableArray* devices = [[NSMutableArray alloc] init];
    for (CacheObject *obj in self.connectedDevices)
    {
        [devices addObject:obj.object];
    }
    
    return [NSArray arrayWithArray:devices];
}

-(CacheObject*) isDeviceConnected:(CBPeripheral*) peripheral
{
    return [self isPeripheral:peripheral inArray:self.connectedDevices];
}

-(CacheObject*) isDevicePendingConnection:(CBPeripheral*)peripheral
{
    return [self isPeripheral:peripheral inArray:self.pendingDevices];
}

-(CacheObject *) isPeripheral:(CBPeripheral *) peripheral inArray:(NSArray *)array
{
    for (CacheObject *obj in array)
    {
        CBPeripheral* p = (CBPeripheral*)obj.object;
        if (p.UUID == peripheral.UUID)
        {
            return obj;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark CBCentralManagerDelegate Methods

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [_bluetoothStateSignal sendNext:@(central.state)];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral)
    {
        CacheObject* pendingPeripheral = [self isDevicePendingConnection:peripheral];
        CacheObject* connectedPeripheral = [self isDeviceConnected:peripheral];
        if (!connectedPeripheral)
        {
            if (pendingPeripheral)
            {
                pendingPeripheral.expirationDate = [NSDate dateWithTimeIntervalSinceNow:self.cacheDurationForDevices];
            }
            else
            {
                CacheObject *obj = [[CacheObject alloc] initWithObject:peripheral andLifespan:self.cacheDurationForDevices];
                [self.pendingDevices addObject:obj];
                [self.cbManager connectPeripheral:peripheral options:nil];
            }
        }
    }
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [_peripheralConnectedSignal sendNext:peripheral];
    if (peripheral && peripheral.name)
    {
        CacheObject* pendingPeripheral = [self isDevicePendingConnection:peripheral];
        CacheObject* connectedPeripheral = [self isDeviceConnected:peripheral];

        if (pendingPeripheral)
        {
            [self.pendingDevices removeObject:pendingPeripheral];
        }
        
        if (connectedPeripheral)
        {
            connectedPeripheral.expirationDate = [NSDate dateWithTimeIntervalSinceNow:self.cacheDurationForDevices];
        }
        else
        {
            CacheObject *obj = [[CacheObject alloc] initWithObject:peripheral andLifespan:self.cacheDurationForDevices];
            [self.connectedDevices addObject:obj];
            [_availableDevicesSignal sendNext:[self devices]];
        }
    }
}

-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [_peripheralDisconnectedSignal sendNext:peripheral];
    if (peripheral && peripheral.name)
    {
        CacheObject* pendingPeripheral = [self isDevicePendingConnection:peripheral];
        CacheObject* connectedPeripheral = [self isDeviceConnected:peripheral];
        
        if (pendingPeripheral)
        {
            [self.pendingDevices removeObject:pendingPeripheral];
        }
        
        if (connectedPeripheral)
        {
            [self.connectedDevices removeObject:connectedPeripheral];
            [_availableDevicesSignal sendNext:[self devices]];
        }
    }
}

-(void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral && peripheral.name)
    {
        CacheObject* pendingPeripheral = [self isDevicePendingConnection:peripheral];
        CacheObject* connectedPeripheral = [self isDeviceConnected:peripheral];
        
        if (pendingPeripheral)
        {
            [self.pendingDevices removeObject:pendingPeripheral];
        }
        
        if (connectedPeripheral)
        {
            [self.connectedDevices removeObject:connectedPeripheral];
            [_availableDevicesSignal sendNext:[self devices]];
        }
    }
}

@end
