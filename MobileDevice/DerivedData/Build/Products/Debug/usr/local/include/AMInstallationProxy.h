//
//  AMInstallationProxy.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"

/// This protocol describes the messages that will be sent by AMInstallationProxy
/// to its delegate.
@protocol AMInstallationProxyDelegate
@optional

/// A new current operation is beginning.
-(void)operationStarted:(NSDictionary*)info;

/// The current operation is continuing.
-(void)operationContinues:(NSDictionary*)info;

/// The current operation finished (one way or the other)
-(void)operationCompleted:(NSDictionary*)info;

@end

/// This class communicates with the mobile_installation_proxy.  It can be used
/// to retrieve information about installed applications on the device (as well as other
/// installation operations that are not supported by this framework).
///
/// Under the covers, it is implemented as a service called \p "com.apple.mobile.installation_proxy" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/mobile_installation_proxy
/// </PRE>
/// That binary seems to vet the incoming requests, then pass them to the installd process
/// for execution.
///
/// The protocol also seems to be a one-shot.  That is, you need to establish multiple connections
/// if you want to perform multiple operations.
///
/// See also: http://iphone-docs.org/doku.php?id=docs:protocols:installation_proxy
@interface AMInstallationProxy : AMService

/// Return an array of all installed applications (see AMApplication) matching the input type.
/// @param type may be "User", "System" or "Internal".  If specified as \p nil, it is ignored
/// and all application types are returned.
///
/// This is used indirectly by [AMDevice installedApplications] which may be a more convenient
/// interface.
- (NSArray *)browse:(NSString*)type;

/// Returns an array of all installed applications (see AMApplication) that match the input predicate.
/// @param filter defines the conditions for accepting an application.
- (NSArray *)browseFiltered:(NSPredicate*)filter;

/// Return a dictionary (indexed by bundleid) of all installed applications (see AMApplication) matching the input type,
/// and optionally filtering those that have a specific attribute in their Info.plist.
/// @param type may be "User", "System", "Internal" or "Any"
/// @param attr can be any attribute (like CFBundlePackageType, etc).  Note, however that
/// you can't filter on the value of the attribute, just its existance.
///
/// You probably don't want to use lookupType:withAttribute - see browseFiltered: instead.
- (NSDictionary*)lookupType:(NSString*)type
			  withAttribute:(NSString*)attr;

/// Ask the installation daemon on the device to create an archive of a specific
/// application.  Once finished a corresponding
/// zip file will be present in the Media/ApplicationArchives directory where it could
/// be retrieved via AFCMediaDirectory.
/// The contents of the archive depends on the values of the container: and payload:
/// arguments.
/// If the uninstall: argument is YES, the application will also be uninstalled.
- (BOOL)archive:(NSString*)bundleid
	  container:(BOOL)container
		payload:(BOOL)payload
	  uninstall:(BOOL)uninstall;

/// Ask the installation daemon on the device to restore a previously archived application.
/// The .zip file must be placed in the Media/ApplicationArchives directory.
- (BOOL)restore:(NSString*)bundleid;

/// Ask the installation daemon on the device what application archives are
/// available.  Return an array of bundle ids which can be passed to functions
/// like restore:
- (NSArray*)archivedAppBundleIds;

/// Ask the installation daemon on the device what application archives are
/// available.  Return a dictionary keyed by application bundle id.
///
/// This seems to be reading the file /var/mobile/Library/MobileInstallation/ArchivedApplications.plist
/// which is not otherwise accessible (except using AFCRootDirectory on jailbreaked devices)
- (NSDictionary*)archivedAppInfo;

/// Remove the archive for a given bundle id.  Note that this is more than just removing
/// the .zip file from the Media/ApplicationArchives directory - if you do that, the
/// archive remains "known to" the installation daemon and future requests to archive
/// this bundle will fail.  Sadly, explicit requests to removeArchive: will file if the
/// .zip file has been removed as well. (The simplest fix for this scenario is to create
/// a dummy file before calling removeArchive:)
- (BOOL)removeArchive:(NSString*)bundleid;

/// Ask the installation daemon on the device to install an application.  pathname
/// must be the name of a directory located in /var/mobile/Media and must contain
/// a pre-expanded .app which must not already exist on the device
- (BOOL)install:(NSString*)pathname;

/// Ask the installation daemon on the device to upgrade an application.  pathname
/// must be the name of a directory located in /var/mobile/Media and must contain
/// a pre-expanded .app which already exists on the device
- (BOOL)upgrade:(NSString*)bundleId from:(NSString*)pathname;

/*
 FIX public functions
 */
- (id)initWithAMDevice:(AMDevice*)device;

@end
