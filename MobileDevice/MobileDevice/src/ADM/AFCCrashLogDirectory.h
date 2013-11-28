//
//  AFCCrashLogDirectory.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCDirectoryAccess.h"

/// This class represents an AFC connection that is rooted to the devices
/// crash-log directory (/var/mobile/Library/Logs/CrashReporter).
///
/// To create one, send the \p -newAFCCrashLogDirectory message to an instance of AMDevice.
///
/// Under the covers, it is implemented as a service called \p "com.apple.crashreportcopymobile" which
/// executes the following command on the device:
/// <PRE>
/// /usr/libexec/afcd --lockdown -d /var/mobile/Library/Logs/CrashReporter -u mobile
/// </PRE>
@interface AFCCrashLogDirectory : AFCDirectoryAccess {
}

- (id)initWithAMDevice:(AMDevice*)device;

@end
