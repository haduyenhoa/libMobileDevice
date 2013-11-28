//
//  AMSyslogRelay.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"

/// This class communicates with the syslog_relay.
///
/// To create one, send \p -newAMSyslogRelay:\p message: to an instance of AMDevice.
///
/// The message must conform to the prototype
/// <PRE>
/// -(void)syslogMessageRead:(NSString*)line
/// </PRE>
///
/// Under the covers, it is implemented as a service called \p "com.apple.syslog_relay" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/syslog_relay --lockdown
/// </PRE>
@interface AMSyslogRelay : AMService {
	CFReadStreamRef _readstream;
	id _listener;
	SEL _message;
}

- (id)initWithAMDevice:(AMDevice*)device listener:(id)listener message:(SEL)message;
@end
