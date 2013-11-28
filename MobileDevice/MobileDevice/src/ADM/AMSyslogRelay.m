//
//  AMSyslogRelay.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMSyslogRelay.h"

@implementation AMSyslogRelay

// This gets called back whenever there is data in the socket that we need
// to read out of it.
static
void AMSyslogRelayCallBack (
                            CFReadStreamRef stream,
                            CFStreamEventType eventType,
                            void *clientCallBackInfo )
{
	AMSyslogRelay *relay = (__bridge AMSyslogRelay*)clientCallBackInfo;
    
	switch (eventType) {
        case kCFStreamEventNone:
        case kCFStreamEventOpenCompleted:
        case kCFStreamEventCanAcceptBytes:
        case kCFStreamEventErrorOccurred:
        case kCFStreamEventEndEncountered:
            break;
            
        case kCFStreamEventHasBytesAvailable:
		{
			// The relay has a maximum buffer size of 0x4000, so we might as
			// well match it.  The buffer consists of multiple syslog records
			// which are \0 terminated - they may contain \n characters within
			// a record, and they never seem to send us an unterminated message
			// (again, the server code seems to preclude it)
			//
			// Control characters seem to be escaped with \ - ie, tab comes through as \ followed by t
			UInt8 buffer[0x4000];
			const CFIndex len = CFReadStreamRead(stream,buffer,sizeof(buffer));
			if (len) {
				UInt8 *p, *q;
				CFIndex left = len;
				p = buffer;
				buffer[sizeof(buffer)-1] = '\000';
				while (left>0) {
					// remove leading newlines
					while (*p == '\n') {
						if (--left) p++;
						else break;
					}
					q = p;
					while (*q && left>0) {q++;left--;}
					if (left) {
						// occasionally we encounter a null record - no need
						// to pass that on and confuse our listener.  Also, sometimes
						// the relay seems to pass us lines of the form "> ".  It looks
						// like thats the 'end' marker that the syslog daemon on the
						// device uses to communicate with the relay to tell it "thats
						// all for now".
						if (q-p) {
							NSString *s = [[NSString alloc] initWithBytesNoCopy:p length:q-p encoding:NSUTF8StringEncoding freeWhenDone:NO];
							[relay->_listener performSelector:relay->_message withObject:s];
//							[s release];
						}
						p = q+1;
						left--;
					}
				}
			}
		}
	}
}

//- (void)dealloc
//{
//	if (_service) {
//		if (_readstream) {
//			CFReadStreamUnscheduleFromRunLoop (_readstream,CFRunLoopGetMain(),kCFRunLoopCommonModes);
//			CFReadStreamClose(_readstream);
//			CFRelease(_readstream);
//		}
//	}
//	[super dealloc];
//}

- (id)initWithAMDevice:(AMDevice*)device listener:(id)listener message:(SEL)message
{
	if (self = [super initWithName:@"com.apple.syslog_relay" onDevice:device]) {
		_listener = listener;
		_message = message;
		int sock = (int)((uint32_t)_service);
		CFSocketNativeHandle s = (CFSocketNativeHandle)sock;
		CFStreamCreatePairWithSocket ( 0, s, &_readstream, NULL);
		if (_readstream) {
			CFStreamClientContext ctx = { 0,(__bridge void *)(self),0,0,0 };
			int flags = kCFStreamEventHasBytesAvailable;
			flags = 31;
			if (CFReadStreamSetClient (_readstream,flags, &AMSyslogRelayCallBack, &ctx )) {
				CFReadStreamScheduleWithRunLoop (_readstream,CFRunLoopGetMain(),kCFRunLoopCommonModes);
				if (CFReadStreamOpen(_readstream)) {
					// NSLog(@"stream opened ok");
				} else {
					NSLog(@"stream did not open");
				}
			} else {
				NSLog(@"couldn't set client");
			}
		} else {
			NSLog(@"couldn't create read stream");
		}
	}
	return self;
}

@end
