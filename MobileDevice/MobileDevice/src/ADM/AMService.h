//
//  MDevice.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

/*! \mainpage MobileDeviceAccess
 *
 * This module is intended to provide access to the iPhone and iPod Touch file systems.
 * It achieves this via the same mechanism that iTunes uses, relying on direct entry
 * points into an undocumented private framework provided by Apple.
 *
 * It will be necessary to include /System/Library/PrivateFrameworks/MobileDevice.framework
 * in any project using this library
 *
 * \author Jeff Laing
 * <br>
 * Copyright 2010 Tristero Computer Systems. All rights reserved.
 * \section intro_sec Typical Usage
 *
 * The application delegate will usually register itself as a listener to the MobileDeviceAccess
 * singleton.  It will then be called back for every iPhone and iPod Touch that connects.  To access
 * files on the AMDevice, create one of the subclasses AFCDirectoryAccess using the
 * corresponding \p -newAFCxxxDirectory: method.
 *
 * \section refs_sec References
 *
 * This is based on information extracted from around the Internet, by people
 * who wanted to look a lot further under the covers than I did.  I've deliberately
 * pushed all Apple's datatypes back to being opaque, since there is nothing
 * to be gained by looking inside them, and everything to lose.
 *
 * This library doesn't contain any of the 'recovery-mode' or other 'jailbreak-related' stuff
 *
 * Some of the places I looked include:
 * - http://iphonesvn.halifrag.com/svn/iPhone/
 * - http://www.theiphonewiki.com/wiki/index.php?title=MobileDevice_Library
 * - http://code.google.com/p/iphonebrowser/issues/detail?id=52
 * - http://www.koders.com/csharp/fidE79340F4674D47FFF3EFB6F949A1589D942798F3.aspx
 * - http://iphone-docs.org/doku.php?id=docs:protocols:screenshot
 * I can't guarantee that they're still there.
 */

#import "BaseObject.h"
#include <sys/socket.h>

@class AMDevice;

#ifdef __cplusplus
extern "C" {
#endif
    
    /// This class represents a service running on the mobile device.  To create
    /// an instance of this class, send the \p -startService: message to an instance
    /// of AMDevice.
    ///
    /// On a jailbroken 3.1.2 iPod Touch, the file
    /// \p /System/Library/Lockdown/Services.plist lists the following as
    /// valid service names:
    /// - \p "com.apple.afc" - see AFCMediaDirectory
    /// - \p "com.apple.crashreportcopymobile" - see AFCCrashLogDirectory
    /// - \p "com.apple.mobile.house_arrest" - see AFCApplicationDirectory
    /// - \p "com.apple.mobile.installation_proxy" - see AMInstallationProxy
    /// - \p "com.apple.syslog_relay" - see AMSyslogRelay
    /// - \p "com.apple.mobile.file_relay" - see AMFileRelay
    /// - \p "com.apple.springboardservices" - see AMSpringboardServices
    /// - \p "com.apple.mobile.notification_proxy" - see AMNotificationProxy
    /// - \p "com.apple.mobilesync" - see AMMobileSync
    ///			(implemented as /usr/libexec/SyncAgent --lockdown --oneshot -v)
    /// - \p "com.apple.crashreportcopy"
    ///			(implemented as /usr/libexec/CrashReportCopyAgent --lockdown --oneshot)
    /// - \p "com.apple.crashreportcopymover"
    ///			(renamed to com.apple.crashreportmover at 3.1.2)
    ///			(implemented as /usr/libexec/crash_mover --lockdown)
    /// - \p "com.apple.misagent"
    ///			(implemented as /usr/libexec/misagent)
    /// - \p "com.apple.debug_image_mount"
    ///			(renamed to com.apple.mobile.debug_image_mount at 3.1.2)
    ///			(implemented as /usr/libexec/debug_image_mount)
    /// - \p "com.apple.mobile.integrity_relay"
    ///			(implemented as /usr/libexec/mobile_integrity_relay)
    /// - \p "com.apple.mobile.MCInstall"
    ///			(implemented as /usr/libexec/mc_mobile_tunnel)
    /// - \p "com.apple.mobile.mobile_image_mounter"
    ///			(implemented as /usr/libexec/mobile_image_mounter)
    ///			(see also http://iphone-docs.org/doku.php?id=docs:protocols:mobile_image_mounter)
    /// - \p "com.apple.mobilebackup"
    ///			(implemented as /usr/libexec/BackupAgent --lockdown)
    ///
    /// If you use pwnage you get these as well - blackra1n doesn't
    /// set them up
    /// - \p "com.apple.afc2" - see AFCRootDirectory
    /// - \p "org.devteam.utility"
    ///			(implemented as ??????)
    ///
    /// The following are mentioned in \p Services.plist but the corresponding binaries
    /// do not appear to be installed.
    ///
    /// - \p "com.apple.purpletestr"
    ///			(implemented as /usr/libexec/PurpleTestr --lockdown --oneshot)
    /// - \p "com.apple.mobile.diagnostics_relay"
    ///			(implemented as /usr/libexec/mobile_diagnostics_relay)
    /// - \p "com.apple.mobile.factory_proxy"
    ///			(implemented as /usr/libexec/mobile_factory_proxy)
    /// - \p "com.apple.mobile.software_update"
    ///			(implemented as /usr/libexec/software_update)
    /// - \p "com.apple.mobile.system_profiler"
    ///			(implemented as /usr/sbin/system_profiler)
    ///
    /// The Internet suggests that the following existed in the past:
    /// - \p "com.apple.screenshotr"
    /// or that its available IFF you are have the Developer disk image
    /// mounted

    @interface AMService : NSObject {
    @protected
        am_service _service;
        NSString *_lasterror;
        __unsafe_unretained id _delegate;
    }

/// The last error that occurred on this service
///
/// The object remembers the last error that occurred, which allows most other api's
/// to return YES/NO as their failure condition.  If no error occurred,
/// this property will be nil.
@property (readonly) NSString *lasterror;

/// The delegate for this service.  Whilst AMService does not use it directly,
/// some of the subclasses (like AMInstallationProxy) do.  The delegate is
/// *not* retained - it is the callers responsibility to ensure it remains
/// valid for the life of the service.
@property (assign) id delegate;

/**
    public functions
 */
- (void)setLastError:(NSString*)msg;
- (void)clearLastError;
- (id)initWithName:(NSString*)name onDevice:(AMDevice*)device;
- (bool)sendXMLRequest:(id)message;
- (id)readXMLReply;
- (NSInputStream*)inputStreamFromSocket;
- (void)performDelegateSelector:(SEL)sel
			  		 withObject:(id)info;

@end
    
#ifdef __cplusplus
}
#endif
