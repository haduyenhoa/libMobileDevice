//
//  AMService.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"
#import "AMDevice.h"

#import "BaseObject.h"

@implementation AMService

- (void)clearLastError
{
	_lasterror = nil;
}

- (void)setLastError:(NSString*)msg
{
	[self clearLastError];
	_lasterror = msg;
}

- (void)performDelegateSelector:(SEL)sel
			  		 withObject:(id)info
{
	if (_delegate) {
		if ([_delegate respondsToSelector:sel]) {
			[_delegate performSelector:sel withObject:info];
		}
	}
}

- (id)initWithName:(NSString*)name onDevice:(AMDevice*)device
{
	if ((self = [super init])) {
		_delegate = nil;
		_service = [device _startService:name];
		if (_service == 0) {
			return nil;
		}
		
	}
	return self;
}

+ (AMService*)serviceWithName:(NSString *)name onDevice:(AMDevice*)device
{
	return [[AMService alloc] initWithName:name onDevice:device] ;
}

- (bool)sendXMLRequest:(id)message
{
	bool result = NO;
	CFPropertyListRef messageAsXML = CFPropertyListCreateXMLData(NULL, (__bridge CFPropertyListRef)(message));
	if (messageAsXML) {
		CFIndex xmlLength = CFDataGetLength(messageAsXML);
		uint32_t sz;
		int sock = (int)_service;
		sz = htonl(xmlLength);
		if (send(sock, &sz, sizeof(sz), 0) != sizeof(sz)) {
			[self setLastError:@"Can't send message size"];
		} else {
			if (send(sock, CFDataGetBytePtr(messageAsXML), xmlLength,0) != xmlLength) {
				[self setLastError:@"Can't send message text"];
			} else {
				[self clearLastError];
				result = YES;
			}
		}
		CFRelease(messageAsXML);
	} else {
		[self setLastError:@"Can't convert request to XML"];
	}
	return(result);
}

- (id)readXMLReply
{
	id result = nil;
	int sock = (int)((uint32_t)_service);
	uint32_t sz;
    
	/* now wait for the reply */
    
	if (sizeof(uint32_t) != recv(sock, &sz, sizeof(sz), 0)) {
		[self setLastError:@"Can't receive reply size"];
	} else {
		sz = ntohl(sz);
		if (sz) {
			// we need to be careful in here, because there is a fixed buffer size in the
			// socket, and it may be smaller than the message we are going to recieve.  we
			// need to allocate a buffer big enough for the final result, but loop calling
			// recv() until we recieve the complete reply.
			unsigned char *buff = malloc(sz);
			unsigned char *p = buff;
			uint32_t left = sz;
			while (left) {
				size_t rc = recv(sock, p, left,0);
				if (rc==0) {
					[self setLastError:[NSString stringWithFormat:@"Reply was truncated, expected %d more bytes",left]];
					free(buff);
					return(nil);
				}
				left -= rc;
				p += rc;
			}
			CFDataRef r = CFDataCreateWithBytesNoCopy(0,buff,sz,kCFAllocatorNull);
			CFPropertyListRef reply = CFPropertyListCreateFromXMLData(0,r,0,0);
            //			CFPropertyListRef reply = CFPropertyListCreateWithData(0,(CFDataRef)plistdata, kCFPropertyListImmutable, NULL, NULL);
			CFRelease(r);
			free(buff);
			result = [(__bridge id)reply copy] ;
			CFRelease(reply);
			[self clearLastError];
		}
	}
    
	return(result);
}

- (NSInputStream*)inputStreamFromSocket
{
	CFReadStreamRef s;
	int sock = (int)((uint32_t)_service);
    
	CFStreamCreatePairWithSocket(
                                 kCFAllocatorDefault, (CFSocketNativeHandle)sock, &s, NULL);
	return (__bridge NSInputStream*)s;
}

/*
 am_service socket;
 AMDeviceStartService(dev, CFSTR("com.apple.mobile.notification_proxy"), &socket, NULL);
 AMDPostNotification(socket, CFSTR("com.apple.itunes-mobdev.syncWillStart"), NULL);
 AMDPostNotification(socket, &CFSTR("com.apple.itunes-mobdev.syncDidFinish"), NULL);
 AMDShutdownNotificationProxy(socket);
 */

@end
