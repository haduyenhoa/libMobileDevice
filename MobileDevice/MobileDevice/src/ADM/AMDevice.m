//
//  AMDevice.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMDevice.h"

#import "AFCMediaDirectory.h"

@implementation AMDevice

- (void)clearLastError
{
	_lasterror = nil;
}

- (void)setLastError:(NSString*)msg
{
	[self clearLastError];
	_lasterror = msg;
}

- (bool)checkStatus:(int)ret from:(const char *)func
{
	if (ret != 0) {
		[self setLastError:[NSString stringWithFormat:@"%s failed: %x",func,ret]];
		return NO;
	}
	[self clearLastError];
	return YES;
}

- (bool)isDevice:(am_device) d
{
	return _device == d;
}

- (void)forgetDevice
{
	_device = nil;
}

- (am_service)_startService:(NSString*)name
{
	am_service result;
	uint32_t dummy;
	mach_error_t ret = AMDeviceStartService(_device,(__bridge CFStringRef)name, &result, &dummy);
	if (ret == 0) return result;
	NSLog(@"AMDeviceStartService <%@> failed: %#x,%#x,%#x",name, err_get_system(ret), err_get_sub(ret), err_get_code(ret));
	return 0;
}

- (bool)deviceConnect
{
	if (![self checkStatus:AMDeviceConnect(_device) from:"AMDeviceConnect"]) return NO;
	_connected = YES;
	[self clearLastError];
	return YES;
}

- (bool)deviceDisconnect
{
	if ([self checkStatus:AMDeviceDisconnect(_device) from:"AMDeviceDisconnect"]) {
		_connected = NO;
		return YES;
	}
	return NO;
}

- (bool)startSession
{
	if ([self checkStatus:AMDeviceStartSession(_device) from:"AMDeviceStartSession"]) {
		_insession = YES;
		return YES;
	}
	return NO;
}

- (bool)stopSession
{
	if ([self checkStatus:AMDeviceStopSession(_device) from:"AMDeviceStopSession"]) {
		_insession = NO;
		return YES;
	}
	return NO;
}
//
//- (void)dealloc
//{
//	if (_device) {
//		if (_insession) [self stopSession];
//		if (_connected) [self deviceDisconnect];
//	}
//	[_deviceName release];
//	[_udid release];
//	[_lasterror release];
//	[super dealloc];
//}

// the application is dying, time to shut down - can't rely on
// dealloc because of reference counting
- (void)applicationWillTerminate:(NSNotification*)notification
{
	if (_device) {
		if (_insession) [self stopSession];
		if (_connected) [self deviceDisconnect];
	}
}

- (id)deviceValueForKey:(NSString*)key inDomain:(NSString*)domain
{
	BOOL opened_connection = NO;
	BOOL opened_session = NO;
	id result = nil;
    
	// first, check for a connection
	if (!_connected) {
		if (![self deviceConnect]) goto bail;
		opened_connection = YES;
	}
    
	// one way or another, we have a connection, look for a session
	if (!_insession) {
		if (![self startSession]) goto bail;
		opened_session = YES;
	}
    
	// ok we have a session running, just query and set up to return
	result = (__bridge id)AMDeviceCopyValue(_device,(__bridge CFStringRef)domain,(__bridge CFStringRef)key);
    
bail:
	if (opened_session) [self stopSession];
	if (opened_connection) [self deviceDisconnect];
	return result ;
}

- (id)deviceValueForKey:(NSString*)key
{
	return [self deviceValueForKey:key inDomain:nil];
}

- (id)allDeviceValuesForDomain:(NSString*)domain
{
	return [self deviceValueForKey:nil inDomain:domain];
}

- (NSString*)productType
{
	return [self deviceValueForKey:@"ProductType"];
}

- (NSString*)deviceClass
{
	return [self deviceValueForKey:@"DeviceClass"];
}

- (NSString*)serialNumber
{
	return [self deviceValueForKey:@"SerialNumber"];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"AMDevice('%@')", _deviceName];
}

- (id)initWithDevice:(am_device)device orBust:(NSString**)msg
{
	if (self=[super init]) {
		_device = device;
		if (![self deviceConnect]) {
			*msg = self.lasterror;
			_device = nil;
			return nil;
		}
        
		// we can access device values once we are connected
		_deviceName = (__bridge NSString*)AMDeviceCopyValue(_device, 0, CFSTR("DeviceName"));
		_udid = (__bridge NSString*)AMDeviceCopyValue(_device, 0, CFSTR("UniqueDeviceID"));
        
		// NSLog(@"AMDeviceGetInterfaceType() returns %d",AMDeviceGetInterfaceType(device));
		// NSLog(@"AMDeviceGetInterfaceSpeed() returns %.0fK",AMDeviceGetInterfaceSpeed(device)/1024.0);
		// NSLog(@"AMDeviceGetConnectionID() returns %d",AMDeviceGetConnectionID(device));
        
		// apparently we need to disconnect whenever we aren't doing anything or
		// the connection will time-out at the other end???
		[self deviceDisconnect];
	}
	return self;
}

+ (AMDevice*)deviceFrom:(am_device)device
{
	NSString *msg = nil;
	AMDevice *result = [[[self class] alloc] initWithDevice:device orBust:&msg];
	if (result) return result;
	NSLog(@"Failed to create AMDevice: %@", msg);
	return nil;
}

- (AFCMediaDirectory*)newAFCMediaDirectory
{
	AFCMediaDirectory *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AFCMediaDirectory alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

-(AFCDirectoryAccess*)newAFCDirectoryAccess {
    AFCDirectoryAccess *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AFCDirectoryAccess alloc] initWithName:@"com.apple.afc" onDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

-(AFCGeneralDirectory*)newAFCGeneralDirectory {
    AFCGeneralDirectory *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AFCGeneralDirectory alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AFCCrashLogDirectory*)newAFCCrashLogDirectory
{
	AFCCrashLogDirectory *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AFCCrashLogDirectory alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AFCRootDirectory*)newAFCRootDirectory
{
	AFCRootDirectory *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AFCRootDirectory alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AFCApplicationDirectory*)newAFCApplicationDirectory:(NSString*)name
{
	AFCApplicationDirectory *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AFCApplicationDirectory alloc] initWithAMDevice:self andName:name];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMInstallationProxy*)newAMInstallationProxyWithDelegate:(id<AMInstallationProxyDelegate>)delegate
{
	AMInstallationProxy *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AMInstallationProxy alloc] initWithAMDevice:self];
			result.delegate = delegate;
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMNotificationProxy*)newAMNotificationProxy
{
	AMNotificationProxy *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AMNotificationProxy alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMSpringboardServices*)newAMSpringboardServices
{
	AMSpringboardServices *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AMSpringboardServices alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMSyslogRelay*)newAMSyslogRelay:(id)listener message:(SEL)message
{
	AMSyslogRelay *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AMSyslogRelay alloc] initWithAMDevice:self listener:listener message:message];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMFileRelay*)newAMFileRelay
{
	AMFileRelay *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AMFileRelay alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMMobileSync*)newAMMobileSync
{
	AMMobileSync *result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			result = [[AMMobileSync alloc] initWithAMDevice:self];
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (NSArray*)installedApplications
{
	NSMutableArray* result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			CFDictionaryRef dict = nil;
			if (
				[self checkStatus:AMDeviceLookupApplications(_device, nil, &dict)
							 from:"AMDeviceLookupApplications"]
                ) {
				result = [NSMutableArray new];
				for (NSString *key in (__bridge NSDictionary*)dict) {
					NSDictionary *info = [(__bridge NSDictionary*)dict objectForKey:key];
					// "User", "System", "Internal" ??
					if ([[info objectForKey:@"ApplicationType"] isEqual:@"User"]) {
						AMApplication *newapp = [[AMApplication alloc] initWithDictionary:info];
						[result addObject:newapp];
//						[newapp release];
					}
				}
				CFRelease(dict);
				result = [NSMutableArray arrayWithArray:result];
			}
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

- (AMApplication*)installedApplicationWithId:(NSString*)id
{
	AMApplication* result = nil;
	if ([self deviceConnect]) {
		if ([self startSession]) {
			CFDictionaryRef dict = nil;
			if (
				[self checkStatus:AMDeviceLookupApplications(_device, nil, &dict)
							 from:"AMDeviceLookupApplications"]
                ) {
				NSDictionary *info = [(__bridge NSDictionary*)dict objectForKey:id];
				if (info) {
					result = [[AMApplication alloc] initWithDictionary:info] ;
				}
				CFRelease(dict);
			}
			[self stopSession];
		}
		[self deviceDisconnect];
	}
	return result;
}

@end
