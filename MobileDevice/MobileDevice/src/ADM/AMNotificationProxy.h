//
//  AMNotificationProxy.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

/// This class represents the com.apple.mobile.notification_proxy service
/// running on the device.  It allows programs on the Mac to send simple
/// notifications to programs running on the device.
///
/// To create one, send the \p -newAMNotificationProxy message to an instance of AMDevice.
///
/// To receive notifications on the mobile device, add an observer to the
/// Darwin Notification Center as follows:
/// <pre>
/// static void gotNotification(
///    CFNotificationCenterRef center,
///    void                    *observer,
///    CFStringRef             name,
///    const void              *alwaysZero1,
///    CFDictionaryRef         alwaysZero2)
/// {
///     ...
/// }
/// ...
///    CFNotificationCenterAddObserver(
///        CFNotificationCenterGetDarwinNotifyCenter(),
///        observer,
///        &gotNotification,
///        name,			// eg, CFSTR("com.myapp.notification")
///        NULL,
///        0 );
/// </pre>
///
/// Alternately, use the AMNotificationCenter class defined in
/// "MobileDeviceAccessIPhone.h"
///
/// Under the covers, it is implemented as a service called \p "com.apple.mobile.notification_proxy" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/notification_proxy
/// </PRE>
#if 0
https://gist.github.com/149443/6a40bf5cb9e47abe8a4b406c6396940e8a30dc7a suggests

com.apple.language.changed
com.apple.AddressBook.PreferenceChanged
com.apple.mobile.data_sync.domain_changed
com.apple.mobile.lockdown.device_name_changed
com.apple.mobile.developer_image_mounted
com.apple.mobile.lockdown.trusted_host_attached
com.apple.mobile.lockdown.host_detached
com.apple.mobile.lockdown.host_attached
com.apple.mobile.lockdown.phone_number_changed
com.apple.mobile.lockdown.registration_failed
com.apple.mobile.lockdown.activation_state
com.apple.mobile.lockdown.brick_state
com.apple.itunes-client.syncCancelRequest
com.apple.itunes-client.syncSuspendRequest
com.apple.itunes-client.syncResumeRequest
com.apple.springboard.attemptactivation
com.apple.mobile.application_installed
com.apple.mobile.application_uninstalled
#endif




#import <Foundation/Foundation.h>
#import "AMService.h"

@interface AMNotificationProxy : AMService {
@private
    NSMutableDictionary *_messages;
}

/// Send the named notification to the
/// Darwin Notification Center on the device.  Note that there is no
/// possibility to send any information with the notification.
/// @param notification
- (void)postNotification:(NSString*)notification;

/// Add an observer for a specific message.  Whenever this message is
/// recieved by the proxy, it will be passed to all observers who
/// are registered, in an indeterminate order.
/// @param notificationObserver
/// @param notificationSelector
/// @param notificationName
- (void)addObserver:(id)notificationObserver
           selector:(SEL)notificationSelector
               name:(NSString *)notificationName;

/// Remove an observer for a specific message.  Once this message
/// is processed, the \p notificationObserver object will no longer
/// recieve notifications.
/// @param notificationObserver
/// @param notificationName
- (void)removeObserver:(id)notificationObserver
                  name:(NSString *)notificationName;

/// Remove an observer for all messages.
/// @param notificationObserver
- (void)removeObserver:(id)notificationObserver;

- (id)initWithAMDevice:(AMDevice*)device;

@end
