## Synopsis

ReactiveCoreBluetooth is a library that wraps Apple's [CoreBluetooth](http://developer.apple.com/library/ios/#documentation/CoreBluetooth/Reference/CoreBluetooth_Framework/_index.html) framework by providing [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) signals instead of delegates. This library is currently a work-in-progress that provides basic Bluetooth LE device management. There is a sample app included in this repo that shows how to make use of this wrapper.

## Code Example

    #import "ReactiveCoreBluetooth.h"

	@property (nonatomic) BluetoothLEService* bluetoothLEService;

    -(void) viewDidLoad
    {
	    self.bluetoothLEService = [[BluetoothLEService alloc] init];

	    [bluetoothLEService.availableDevicesSignal subscribeNext:^(NSArray* devices) {
	        for (CBPeripheral* p in devices)
	        {
	        	NSLog(@"%@", p.name);
	        }
	    }];

	    [bluetoothLEService.peripheralConnectedSignal subscribeNext:^(CBPeripheral* device) {
        	NSLog(@"Connected to %@", device.name);
	    }];

	    [bluetoothLEService.peripheralDisconnectedSignal subscribeNext:^(CBPeripheral* device) {
        	NSLog(@"Disconnected from %@", device.name);
	    }];

	    [bluetoothLEService.scanningForDevicesSignal subscribeNext:^(NSNumber* x) {
	    	BOOL isScanning = [x boolValue];
	    	if (isScanning)
	    	{
	    		NSLog("Scanning for devices...");
	    	}
	    	else
	    	{
	    		NSLog("Not scanning for devices.");
	    	}
		}];

	    [bluetoothLEService.bluetoothStateSignal subscribeNext:^(NSNumber* x) {
	        CBCentralManagerState state = (CBCentralManagerState)[x integerValue];
	        NSString* status;
	        switch (state)
	        {
	            case CBCentralManagerStatePoweredOff:
	                status = @"Off";
	                break;
	            case CBCentralManagerStatePoweredOn:
	                status = @"On";
	                break;
	            case CBCentralManagerStateResetting:
	                status = @"Resetting";
	                break;
	            case CBCentralManagerStateUnauthorized:
	                status = @"Unauthorized";
	                break;
	            case CBCentralManagerStateUnknown:
	                status = @"Unknown";
	                break;
	            case CBCentralManagerStateUnsupported:
	                status = @"Unsupported";
	                break;
	            default:
	                status = @"Error: State Unknown";
	                break;
	        }

	        NSLog(@"Bluetooth status: %@", status);
	    }];

	    [bluetoothLEService scanForAvailableDevices];
    }

## Motivation

We prefer to use ReactiveCocoa signals and blocks to manage asynchronous eventing instead of delegates. If you don't like implementing delegates everywhere, this is the Bluetooth LE library for you!

## Installation

Add the following line to your Podfile:

	pod 'ReactiveCoreBluetooth'

Then run the following in the same directory as your Podfile:

	pod install

## API Reference

### Scanning for Devices

To start scanning for devices, call `scanForAvailableDevices`. You can listen on the `scanningForDevicesSignal` to determine if the device is currently scanning. To receive notifications about when the list of available devices changes, listen on the `availableDevicesSignal`. To stop scanning for devices, call `stopScanningForDevices`.

### Device Connect and Disconnect

To capture device connections, subscribe to the `peripheralConnectedSignal`. To capture device disconnections, subscribe to the `peripheralDisconnectedSignal`.

### Bluetooth Status

Listen on the `bluetoothStateSignal`.

### Manually set cache settings

The `cacheDurationForDevices` setting allows you to change how long to wait while trying to connect to a device. The default is 5 seconds.

The `cachePollingInterval` setting allows you to change how frequently the cache is polled for expired devices. The default is 3 seconds.

## Contributors

Matt Bowman (matt at citrrus dot com)

## License

Copyright 2013 Citrrus, LLC.

Licensed under the MIT license.