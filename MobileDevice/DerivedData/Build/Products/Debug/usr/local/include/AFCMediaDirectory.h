//
//  AFCMediaDirectory.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCDirectoryAccess.h"

/// This class represents an AFC connection that is rooted to the devices
/// Media directory (/var/mobile/Media).
///
/// To create one, send the \p -newAFCMediaDirectory message to an instance of AMDevice.
///
/// Under the covers, it is implemented as a service called \p "com.apple.afc" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/afcd --lockdown -d /var/mobile/Media -u mobile
/// </PRE>
///
/// Common subdirectories to access within the Media directory are:
/// - DCIM
/// - ApplicationArchives
/// - PublicStaging
@interface AFCMediaDirectory : AFCDirectoryAccess {
    
}

- (id)initWithAMDevice:(AMDevice*)device;
@end
