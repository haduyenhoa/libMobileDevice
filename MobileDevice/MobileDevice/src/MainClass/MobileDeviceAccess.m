//
//  MobileDeviceAccess.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "MobileDeviceAccess.h"

@implementation MobileDeviceAccess

// this is (indirectly) called back by AMDeviceNotificationSubscribe()
// whenever something interesting happens
- (void)Notify:(struct am_device_notification_callback_info*)info
{
	AMDevice *d;
    
	switch (info->msg) {
        default:
            NSLog(@"Ignoring unknown message: %d",info->msg);
            return;
            
        case ADNCI_MSG_UNSUBSCRIBED:
            return;
            
        case ADNCI_MSG_CONNECTED:
            d = [AMDevice deviceFrom:info->dev];
            [_devices addObject:d];
            if (_listener && [_listener respondsToSelector:@selector(deviceConnected:)]) {
                [_listener deviceConnected:d];
            }
            break;
            
        case ADNCI_MSG_DISCONNECTED:
            for (d in _devices) {
                if ([d isDevice:info->dev]) {
                    [d forgetDevice];
                    if (_listener && [_listener respondsToSelector:@selector(deviceDisconnected:)]) {
                        [_listener deviceDisconnected:d];
                    }
                    [_devices removeObject:d];
                    break;
                }
            }
            break;
	}
    
	// if he's waiting for us to do something, break him
	if (_waitingInRunLoop) CFRunLoopStop(CFRunLoopGetCurrent());
}

// someone outside us wants to detach a device - perhaps they've closed the window.
//
- (void)detachDevice:(AMDevice*)d
{
	[_devices removeObject:d];
}

// this is called back by AMDeviceNotificationSubscribe()
// we just punt back into a regular method
static
void notify_callback(struct am_device_notification_callback_info *info, void* arg)
{
	[(__bridge MobileDeviceAccess*)arg Notify:info];
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
	for (AMDevice *device in _devices) {
		[device applicationWillTerminate:notification];
	}
}

- (id)init
{
	if (self=[super init]) {
		_subscribed = NO;					// we are not subscribed yet
		_devices = [NSMutableArray new];	// we have no device connected
		_waitingInRunLoop = NO;			// we are not currently waiting in a runloop
        
		// we opened, we need to ensure that we get closed or our
		// services stay running on the ipod
		[[NSNotificationCenter defaultCenter]
         addObserver: self
         selector: @selector(applicationWillTerminate:)
         name: NSApplicationWillTerminateNotification
         object: nil];
    }
	return self;
}

- (bool)setListener:(id<MobileDeviceAccessListener>)listener
{
	_listener = listener;
	if (_listener) {
		// if we are not subscribed yet, do it now
		if (!_subscribed) {
			// try to subscribe for notifications - pass self as the callback_data
			int ret = AMDeviceNotificationSubscribe(notify_callback, 0, 0, (__bridge void *)(self), &_notification);
			if (ret == 0) {
				_subscribed = YES;
			} else {
				// we should throw or something in here...
				NSLog(@"AMDeviceNotificationSubscribe failed: %d", ret);
			}
		}
	}
	return YES;
}

//- (void)dealloc
//{
//	NSLog(@"deallocating %@",self);
//    
//	// we must stop observing everything before we evaporate
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//	// if we are currently waiting, stop now
//	if (_waitingInRunLoop) CFRunLoopStop(CFRunLoopGetCurrent());
//    
////	[_devices release];
//	[super dealloc];
//}

- (bool)waitForConnection
{
	// we didn't manage to subscribe for notifications so there is no
	// point waiting
	if (!_subscribed) return NO;
    
	NSLog(@"calling CFRunLoopRun(), plug iPod in now!!!");
	_waitingInRunLoop = YES;
	CFRunLoopRun();
	_waitingInRunLoop = NO;
	NSLog(@"back from calling CFRunLoopRun()");
    
    // while (something?) {
    // 		_waitingInRunLoop = YES;
    //		CFRunLoopRunInMode (@"waiting for connection", 5/*seconds*/, NO/*returnAfterSourceHandled*/);
    //		_waitingInRunLoop = NO;
    //		if (_device) return YES;
    // }
	return YES;
}

- (NSString*)clientVersion
{
	return [NSString stringWithUTF8String:AFCGetClientVersionString()];
}

+ (MobileDeviceAccess*)singleton
{
	static MobileDeviceAccess *_singleton = nil;
	@synchronized(self) {
		if (_singleton == nil) {
			_singleton = [[MobileDeviceAccess alloc] init];
			
		}
	}
	return _singleton;
}

@end
