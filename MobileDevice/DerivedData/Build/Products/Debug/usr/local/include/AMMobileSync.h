//
//  AMMobileSync.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"

/// This class communicates with the MobileSync service.  There is a fairly complicated protocol
/// required.
///
/// Under the covers, it is implemented as a service called \p "com.apple.mobilesync" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/SyncAgent --lockdown --oneshot -v
/// </PRE>
@interface AMMobileSync : AMService
- (id)getContactData;

- (id)initWithAMDevice:(AMDevice*)device;
@end