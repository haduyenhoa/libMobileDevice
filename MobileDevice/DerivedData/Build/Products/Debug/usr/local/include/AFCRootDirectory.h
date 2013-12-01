//
//  AFCRootDirectory.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCDirectoryAccess.h"

/// This class represents an AFC connection on a jail-broken device.  It has
/// full access to the devices filesystem.
///
/// To create one, send the \p -newAFCRootDirectory message to an instance of AMDevice.
///
/// Note, instances of this class will only operate correctly on devices that are
/// running the \p "com.apple.afc2" service.  If your device was jailbroken with
/// blackra1n this service may be missing in which case it can be installed via
/// Cydia.
///
/// Under the covers, it is implemented as a service called \p "com.apple.afc2" which
/// executes the following command on the device:
/// <PRE>
/// /usr/libexec/afcd --lockdown -d /
/// </PRE>
@interface AFCRootDirectory : AFCDirectoryAccess {
}

- (id)initWithAMDevice:(AMDevice*)device;
@end
