//
//  MobileDeviceAccess.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#ifdef __cplusplus
extern "C" {
#endif

#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "AMDevice.h"

/// An object must implement this protocol if it is to be passed as a listener
/// to the MobileDeviceAccess singleton object.
@protocol MobileDeviceAccessListener
@optional
/// This method will be called whenever a device is connected
- (void)deviceConnected:(AMDevice*)device;
/// This method will be called whenever a device is disconnected
- (void)deviceDisconnected:(AMDevice*)device;
@end

/// This class provides the high-level interface onto the MobileDevice
/// framework.  Instances of this class should not be created directly;
/// instead, use \ref singleton "+singleton"
@interface MobileDeviceAccess : NSObject {
@private
	id _listener;
	BOOL _subscribed;
	am_device_notification _notification;
	NSMutableArray *_devices;
	BOOL _waitingInRunLoop;
}

/// Returns an array of AMDevice objects representing the currently
/// connected devices.
@property (readonly) NSArray *devices;

/// Returns the one true instance of \c MobileDeviceAccess
+ (MobileDeviceAccess*)singleton;

/// Nominate the entity that will recieve notifications about device
/// connections and disconnections.  The listener object must implement
/// the MobileDeviceAccessListener protocol.
- (bool)setListener:(id<MobileDeviceAccessListener>)listener;

/// \deprecated
///
/// This method allows the caller to wait till a connection has been
/// made.  It sits in a run loop and does not return till a device
/// connects.
- (bool)waitForConnection;

/// Call this method to treat the nominated device as "disconnected".  Note,
/// this does not disconnect the device from Mac OS X - only from the
/// MobileDeviceAccess singleton
/// @param device The device to disconnect.
- (void)detachDevice:(AMDevice*)device;

/// Returns the client-library version string.  On my MacOSX machine, the
/// value returned was "@(#)PROGRAM:afc  PROJECT:afc-84"
- (NSString*)clientVersion;

@end

#ifdef __cplusplus
}
#endif
