//
//  AMNotificationProxy.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMNotificationProxy.h"
#import "BaseObject.h"
#import "AMDevice.h"

@implementation AMNotificationProxy

/*
 
 http://matt.colyer.name/projects/iphone-linux/index.php?title=Banana's_lockdownd_session
 
 +// NotificationProxy related
 +// notifications for use with post_notification (client --> device)
 +#define NP_SYNC_WILL_START      "com.apple.itunes-mobdev.syncWillStart"
 +#define NP_SYNC_DID_START       "com.apple.itunes-mobdev.syncDidStart"
 +#define NP_SYNC_DID_FINISH      "com.apple.itunes-mobdev.syncDidFinish"
 +
 +// notifications for use with observe_notification (device --> client)
 +#define NP_SYNC_CANCEL_REQUEST  "com.apple.itunes-client.syncCancelRequest"
 +#define NP_SYNC_SUSPEND_REQUEST "com.apple.itunes-client.syncSuspendRequest"
 +#define NP_SYNC_RESUME_REQUEST  "com.apple.itunes-client.syncResumeRequest"
 +#define NP_PHONE_NUMBER_CHANGED "com.apple.mobile.lockdown.phone_number_changed"
 +#define NP_DEVICE_NAME_CHANGED  "com.apple.mobile.lockdown.device_name_changed"
 +#define NP_ATTEMPTACTIVATION    "com.apple.springboard.attemptactivation"
 +#define NP_DS_DOMAIN_CHANGED    "com.apple.mobile.data_sync.domain_changed"
 +#define NP_APP_INSTALLED        "com.apple.mobile.application_installed"
 +#define NP_APP_UNINSTALLED      "com.apple.mobile.application_uninstalled"
 +
 
 */
//- (void)dealloc
//{
//	NSLog(@"deallocating %@",self);
//	if (_service) {
//		AMDShutdownNotificationProxy(_service);
//		// don't nil it, superclass might need to do something?
//		[_messages release];
//	}
//	[super dealloc];
//}

// Note, sometimes we get called with "AMDNotificationFaceplant" - that happens
// when the connection to the device goes away.  We may have a race condition in
// here because we may have killed the AMDevice which will close all the services
static
void AMNotificationProxy_callback(CFStringRef notification, void* data)
{
	AMNotificationProxy *proxy = (__bridge AMNotificationProxy*)data;
	if (proxy->_messages) {
		NSMutableArray *message_observers = [proxy->_messages objectForKey:(__bridge NSString*)notification];
		for (NSArray *a in message_observers) {
			id observer = [a objectAtIndex:0];
			SEL message = NSSelectorFromString([a objectAtIndex:1]);
			[observer performSelector:message withObject:(__bridge NSString*)notification];
		}
	}
}

// AMDListenForNotification() is a bit stupid.  It creates a CFSocketRunloopSource but
// it hooks it up to the *current* runloop - we need it to be hooked to the *main*
// runloop.  Thus, we arrange for our registration to be punted across to the
// main thread, whose runloop should be the main one.
- (void)_amdlistenfornotifications
{
	mach_error_t status;
	status = AMDListenForNotifications(_service, AMNotificationProxy_callback, (__bridge void *)(self));
	if (status != ERR_SUCCESS) NSLog(@"AMDListenForNotifications returned %x",status);
}

- (id)initWithAMDevice:(AMDevice*)device
{
	if (self = [super initWithName:@"com.apple.mobile.notification_proxy" onDevice:device]) {
		_messages = [NSMutableDictionary new];
		[self performSelectorOnMainThread:@selector(_amdlistenfornotifications) withObject:nil waitUntilDone:YES];
	}
	return self;
}

- (void)postNotification:(NSString*)notification
{
	AMDPostNotification(_service, (__bridge CFStringRef)notification, (CFStringRef)NULL);
}

/// Add an observer for a specific message.
- (void)addObserver:(id)notificationObserver
           selector:(SEL)notificationSelector
               name:(NSString *)notificationName
{
	// make sure this method is appropriate
	NSMethodSignature *sig = [notificationObserver methodSignatureForSelector:notificationSelector];
	if (
		sig == nil
		||
		strcmp([sig methodReturnType],"v")!=0
		||
		[sig numberOfArguments] != 3
		||
		strcmp([sig getArgumentTypeAtIndex:2],"@")!=0
        ) {
		NSString *c = NSStringFromClass([notificationObserver class]);
		NSString *s = NSStringFromSelector(notificationSelector);
		NSLog(@"%@.%@ defined incorrectly for AMNotificationCenter.addObserver:selector:name:",c,s);
		NSLog(@"It should be:");
		NSLog(@"-(void)%@: (id)notificationname;",s);
		return;
	}
    
	if ([notificationObserver respondsToSelector:notificationSelector]) {
		// we keep an array of observers in a dictionary indexed by notificationName.
		// each observer is recorded as an array containing { object, "selector-as-string" }
		NSMutableArray *message_observers = [_messages objectForKey:notificationName];
		if (message_observers) {
			for (NSArray *a in message_observers) {
				// already here, just ignore it?
				if ([a objectAtIndex:0] == notificationObserver) return;
			}
		} else {
			// we aren't watching this one yet, so start it now
			mach_error_t status;
			status = AMDObserveNotification(_service, (__bridge CFStringRef)notificationName);
			if (status != ERR_SUCCESS) NSLog(@"AMDObserveNotification returned %x",status);
            
			message_observers = [NSMutableArray new];
			[_messages setObject:message_observers forKey:notificationName];
//			[message_observers release];
		}
		[message_observers addObject:[NSArray arrayWithObjects:notificationObserver,NSStringFromSelector(notificationSelector),nil]];
	} else {
		NSLog(@"%@ does not respond to %@",notificationObserver,NSStringFromSelector(notificationSelector));
	}
}

/// Remove an observer for a specific message.
- (void)removeObserver:(id)notificationObserver
                  name:(NSString *)notificationName
{
	NSMutableArray *message_observers = [_messages objectForKey:notificationName];
	if (message_observers) {
		for (NSArray *a in message_observers) {
			if ([a objectAtIndex:0] == notificationObserver) {
				[message_observers removeObject:a];
				// there is no mechanism for us to "unobserve" so we just leave
				// the listener in place
				break;
			}
		}
	}
}

/// Remove an observer for all messages.
- (void)removeObserver:(id)notificationObserver
{
	for (NSString *k in [_messages allKeys]) {
		[self removeObserver:notificationObserver name:k];
	}
}

@end
