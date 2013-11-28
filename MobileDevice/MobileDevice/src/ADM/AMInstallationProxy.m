//
//  AMInstallationProxy.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMInstallationProxy.h"
#import "AMApplication.h"
@implementation AMInstallationProxy

#if 0
Yeah, I’ve just found out how to handle this and terminate sync when user slides cancel switch.

We need following functions (meta-language):

ERROR AMDObserveNotification(HANDLE proxy, CFSTR notification);

ERROR AMDListenForNotifications(HANDLE proxy, NOTIFY_CALLBACK cb, USERDATA data);

and callback delegate:

typedef void (*NOTIFY_CALLBACK)(CFSTR notification, USERDATA data);

First, we need AMDObserveNotification to subscribe notifications about “com.apple.itunes-client.syncCancelRequest”. Then we should start listening for notifications (second function) until we get “AMDNotificationFaceplant”.
That’s it. When notification got, you should unlock and close lock file handle (don’t sure if you need to post “syncDidFinish” to proxy, seems it doesn’t matter) and terminate sync gracefully.

P.S. The same notification is also got when you unplug your device, so you should always be ready for errors.
#endif

- (NSArray *)browse:(NSString*)type
{
	return [self browseFiltered:nil];
}

- (NSArray *)browseFiltered:(NSPredicate*)filter
{
	NSDictionary *message;
	NSArray *result = nil;
    
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value																key
               @"Browse",																@"Command",
               [NSDictionary dictionaryWithObject:@"Any" forKey:@"ApplicationType"],	@"ClientOptions",
               nil];
	if ([self sendXMLRequest:message]) {
		//
		// we return all applications in a single array.  However,
		// the protocol between ipod and mac does not - instead, the ipod only returns up to
		// about 20 at a time, passing a Status field as well which tells us whether the
		// transfer is finished or not.  This loop worries about gluing the responses
		// back together for you.
		//
		NSMutableArray *thelist = nil;
		for (;;) {
			// read next slab of information
			NSDictionary *reply = [self readXMLReply];
			if (!reply) break;
            
			// first time through, thelist will be nil so we'll allocate it.
			if (nil == thelist) {
				// each reply that comes back has a list size in the Total key, so we can
				// ask for an array of the correct size up front...  If we have a filter,
				// then we'll be over-estimating but thats not that big a deal...
				NSNumber *total = [reply objectForKey:@"Total"];
				if (total && [total isKindOfClass:[NSNumber class]]) {
					thelist = [[NSMutableArray alloc] initWithCapacity:[total intValue]];
				} else {
					// Hmmm, no Total, do it the hard way
					thelist = [[NSMutableArray alloc] init];
				}
			}
            
			// now, this reply might not have a current list in it so we need to be careful
			NSArray *currentlist = [reply objectForKey:@"CurrentList"];
			if (currentlist) {
				for (NSDictionary *appinfo in currentlist) {
					AMApplication *app = [[AMApplication alloc] initWithDictionary:appinfo];
					if (filter==nil || [filter evaluateWithObject:app]) {
						[thelist addObject:app];
					}
//					[app release];
				}
			}
            
			NSString *s = [reply objectForKey:@"Status"];
			if (![s isEqual:@"BrowsingApplications"]) break;
		}
        
		// all finished, make it immutable and return
		if (thelist) {
			result = [NSArray arrayWithArray:thelist];
//			[thelist release];
		}
	}
	return result;
}

- (BOOL)archive:(NSString*)bundleid
      container:(BOOL)container
		payload:(BOOL)payload
      uninstall:(BOOL)uninstall
{
	BOOL result = NO;
	NSDictionary *message;
	NSString *mode;
    
	if (container) {
		if (payload) {
			mode = @"All";
		} else {
			mode = @"DocumentsOnly";
		}
	} else {
		if (payload) {
			mode = @"ApplicationOnly";
		} else {
			return NO;
		}
	}
    
	// { "Command" => "Archive";	"ApplicationIdentifier" => ...; ClientOptions => ... }
	// it also takes {"ArchiveType" => oneof "All", "DocumentsOnly", "ApplicationOnly" }
	// it also takes {"SkipUninstall" => True / False}
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value																key
               @"Archive",																@"Command",
               bundleid,																@"ApplicationIdentifier",
               [NSDictionary dictionaryWithObjectsAndKeys:
                // value										key
                mode,											@"ArchiveType",
                uninstall ? kCFBooleanFalse : kCFBooleanTrue,	@"SkipUninstall",
                nil],																@"ClientOptions",
               nil];
    
	[self performDelegateSelector:@selector(operationStarted:) withObject:message];
	if ([self sendXMLRequest:message]) {
		for (;;) {
			// read next slab of information
			// The reply will contain an entry for Status, a string from the following:
			//	"TakingInstallLock"
			//	"EmptyingApplication"
			//	"ArchivingApplication"
			//	"RemovingApplication"			/__ only if the application was uninstalled
			//	"GeneratingApplicationMap"		\
			//	"Complete"
			// All except "Complete" also include PercentageComplete, an integer between 0 and 100 (but it goes up and down)
			//
			// If its already been archived, we might get:
			//    Error = AlreadyArchived;
			// If we keep listening we'll then get
			//    Error = APIInternalError;
			NSDictionary *reply = [self readXMLReply];
			if (!reply) break;
			[self performDelegateSelector:@selector(operationContinues:) withObject:reply];
            
			NSString *s = [reply objectForKey:@"Status"];
			if ([s isEqual:@"Complete"]) break;
		}
		result = YES;
	}
	[self performDelegateSelector:@selector(operationCompleted:) withObject:message];
	return result;
}

- (BOOL)restore:(NSString*)bundleid
{
	BOOL result = NO;
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value																key
               @"Restore",																@"Command",
               bundleid,																@"ApplicationIdentifier",
               nil];
	[self performDelegateSelector:@selector(operationStarted:) withObject:message];
	if ([self sendXMLRequest:message]) {
		for (;;) {
			// read next slab of information
			// The reply will contain an entry for Status, a string from the following:
			//	"TakingInstallLock"
			//	"RestoringApplication"
			//	"SandboxingApplication"
			//	"GeneratingApplicationMap"
			//	"Complete"
			// All except "Complete" also include PercentageComplete, an integer between 0 and 100 (but it goes up and down)
			//
			// Looks like instead of Status, we can get:
			// Error = APIInternalError
			// (that happened if I passed in ClientOptions.  Bad...
			// Error = APIEpicFail;
			// (that happened if I passed in a missing bundle-id
			NSDictionary *reply = [self readXMLReply];
			if (!reply) break;
			[self performDelegateSelector:@selector(operationContinues:) withObject:reply];
			NSString *s = [reply objectForKey:@"Status"];
			if ([s isEqual:@"Complete"]) break;
		}
		result = YES;
	}
	[self performDelegateSelector:@selector(operationCompleted:) withObject:message];
	return result;
}

- (NSArray*)archivedAppBundleIds
{
	NSDictionary *appInfo = [self archivedAppInfo];
	return [appInfo allKeys];
}

- (NSDictionary*)archivedAppInfo
{
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value					key
               @"LookupArchives",			@"Command",
               nil];
	if ([self sendXMLRequest:message]) {
		NSDictionary *reply = [self readXMLReply];
		if (reply) {
			return [reply objectForKey:@"LookupResult"];
		}
	}
	return nil;
}

/// Remove the archive for a given bundle id.
- (BOOL)removeArchive:(NSString*)bundleid
{
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value					key
               @"RemoveArchive",			@"Command",
               bundleid,					@"ApplicationIdentifier",
               nil];
    
	[self performDelegateSelector:@selector(operationStarted:) withObject:message];
	if ([self sendXMLRequest:message]) {
		for (;;) {
			// read next slab of information
			// The reply will contain an entry for Status, a string from the following:
			//	"RemovingArchive"
			//	"Complete"
			// All except "Complete" also include PercentageComplete, an integer between 0 and 100 (but it goes up and down)
			//
			// Looks like instead of Status, we can get:
			// Error = APIEpicFail;
			// (that happened if I passed in a missing bundle-id
			// Error = APIInternalError
			// (that happened if I kept reading?
			NSDictionary *reply = [self readXMLReply];
			if (!reply) break;
			[self performDelegateSelector:@selector(operationContinues:) withObject:reply];
			NSString *s = [reply objectForKey:@"Status"];
			if ([s isEqual:@"Complete"]) break;
		}
	}
	[self performDelegateSelector:@selector(operationCompleted:) withObject:message];
	return NO;
}

//
// lookup is similiar to browse - it looks like it has clever filtering
// capability but its not that useful.  You can look up all attributes that
// *have* an explicit value for a specific attribute - you can't filter on actual
// values, just on the presence/absence of the attribute - use browseFiltered:
// instead.
//
// note we return a DICTIONARY indexed by bundle id
//
- (NSDictionary*)lookupType:(NSString*)type withAttribute:(NSString*)attr
{
	NSDictionary *message;
	if (type == nil) type = @"Any";
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value					key
               @"Lookup",				@"Command",
               [NSDictionary dictionaryWithObjectsAndKeys:
                type, @"ApplicationType",
                attr, @"Attribute",
                nil],				@"ClientOptions",
               nil];
	[self performDelegateSelector:@selector(operationStarted:) withObject:message];
	if ([self sendXMLRequest:message]) {
		NSDictionary *reply = [self readXMLReply];
		if (reply) {
			[self performDelegateSelector:@selector(operationContinues:) withObject:reply];
			NSMutableDictionary *result = [NSMutableDictionary new] ;
			NSDictionary *lookup_result = [reply objectForKey:@"LookupResult"];
			for (NSString *key in lookup_result) {
				NSDictionary *info = [lookup_result objectForKey:key];
				AMApplication *app = [[AMApplication alloc] initWithDictionary:info];
				[result setObject:app forKey:key];
//				[app release];
			}
			return [NSDictionary dictionaryWithDictionary:result];
		}
	}
	[self performDelegateSelector:@selector(operationCompleted:) withObject:message];
	return nil;
}

- (id)initWithAMDevice:(AMDevice*)device
{
	if (self = [super initWithName:@"com.apple.mobile.installation_proxy" onDevice:device]) {
	}
	return self;
}
#if 0
http://libiphone.lighthouseapp.com/projects/27916/tickets/104/a/365185/0001-new-installation_proxy-interface.patch

// { "Command" => "Install";
//			"PackagePath" => "...";	// Will be prefixed with /var/mobile/Media/
//									// if PackageType="Developer", it should be a pointer to an expanded .app
//									// containing code signature stuff, etc.
//			"ClientOptions" = { "PackageType" = "Developer"; "ApplicationSINF" = ... "; "iTunesMetadata" = "...",  }
//							  { "PackageType" = "Customer";
//							  { "PackageType" = "CarrierBundle"; ...
//		<- { Status => Complete; }
//		<- { Status => "..."; PercentComplete = ... }
// { "Command" => "Upgrade"; "PackagePath" => "..." }
//

2010-06-08 20:01:34.628 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 0;
    Status = TakingInstallLock;
}
2010-06-08 20:01:34.640 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 5;
    Status = CreatingStagingDirectory;
}
2010-06-08 20:01:34.656 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 10;
    Status = StagingPackage;
}
2010-06-08 20:01:34.694 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 15;
    Status = ExtractingPackage;
}
2010-06-08 20:01:34.697 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 20;
    Status = InspectingPackage;
}
2010-06-08 20:01:34.701 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 30;
    Status = PreflightingApplication;
}
2010-06-08 20:01:34.704 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 30;
    Status = InstallingEmbeddedProfile;
}
2010-06-08 20:01:34.708 iPodBackup[40130:a0f] operationContinues::{
    PercentComplete = 40;
    Status = VerifyingApplication;
}
2010-06-08 20:01:34.722 iPodBackup[40130:a0f] operationContinues::{
    Error = BundleVerificationFailed;
}
2010-06-08 20:01:34.728 iPodBackup[40130:a0f] operationContinues::{
    Error = APIInternalError;
}
2010-06-08 20:01:34.730 iPodBackup[40130:a0f] operationCompleted::{
    ClientOptions =     {
        PackageType = Developer;
    };
    Command = Install;
    PackagePath = "PublicStaging/AncientFrogHD.app";
}

// { "Command" => "Uninstall";	"ApplicationIdentifier" => ...; ClientOptions => ... }

// { "Command" => "RemoveArchive";	"ApplicationIdentifier" => ...; ClientOptions => ... }
// { "Command" => "CheckCapabilitiesMatch"; Capabilities => ...; ClientOptions => ... }
//		<- { Status => Complete; LookupResult => ... }
//		<- { Error = APIInternalError; }
//

2010-06-08 20:16:59.431 iPodBackup[40417:a0f] operationStarted::{
    ClientOptions =     {
        PackageType = Developer;
    };
    Command = Install;
    PackagePath = "PublicStaging/Rooms.app";
}
2010-06-08 20:16:59.462 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 0;
    Status = TakingInstallLock;
}
2010-06-08 20:16:59.479 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 5;
    Status = CreatingStagingDirectory;
}
2010-06-08 20:16:59.488 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 10;
    Status = StagingPackage;
}
2010-06-08 20:16:59.504 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 15;
    Status = ExtractingPackage;
}
2010-06-08 20:16:59.511 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 20;
    Status = InspectingPackage;
}
2010-06-08 20:16:59.518 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 30;
    Status = PreflightingApplication;
}
2010-06-08 20:16:59.526 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 30;
    Status = InstallingEmbeddedProfile;
}
2010-06-08 20:16:59.533 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 40;
    Status = VerifyingApplication;
}
2010-06-08 20:17:02.915 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 50;
    Status = CreatingContainer;
}
2010-06-08 20:17:02.926 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 60;
    Status = InstallingApplication;
}
2010-06-08 20:17:02.935 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 70;
    Status = PostflightingApplication;
}
2010-06-08 20:17:02.939 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 80;
    Status = SandboxingApplication;
}
2010-06-08 20:17:02.977 iPodBackup[40417:a0f] operationContinues::{
    PercentComplete = 90;
    Status = GeneratingApplicationMap;
}
2010-06-08 20:17:04.943 iPodBackup[40417:a0f] operationContinues::{
    Status = Complete;
}
#endif

- (BOOL)install:(NSString*)pathname
{
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value					key
               @"Install",				@"Command",
               pathname,				@"PackagePath",
               [NSDictionary dictionaryWithObjectsAndKeys:
                @"Developer", @"PackageType",
                nil],				@"ClientOptions",
               nil];
	[self performDelegateSelector:@selector(operationStarted:) withObject:message];
	if ([self sendXMLRequest:message]) {
		for (;;) {
			// read next slab of information
			// The reply will contain an entry for Status, a string from the following:
			//	"RemovingArchive"
			//	"Complete"
			// All except "Complete" also include PercentageComplete, an integer between 0 and 100 (but it goes up and down)
			//
			// Looks like instead of Status, we can get:
			// Error = APIEpicFail;
			// (that happened if I passed in a missing bundle-id
			// Error = APIInternalError
			// (that happened if I kept reading?
			NSDictionary *reply = [self readXMLReply];
			if (!reply) break;
			[self performDelegateSelector:@selector(operationContinues:) withObject:reply];
			NSString *s = [reply objectForKey:@"Status"];
			if ([s isEqual:@"Complete"]) break;
		}
	}
	[self performDelegateSelector:@selector(operationCompleted:) withObject:message];
	return NO;
}

- (BOOL)upgrade:(NSString*)bundleId from:(NSString*)pathname;
{
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value					key
               @"Upgrade",				@"Command",
               pathname,				@"PackagePath",
               bundleId,				@"ApplicationIdentifier",
               [NSDictionary dictionaryWithObjectsAndKeys:
                @"Developer", @"PackageType",
                nil],				@"ClientOptions",
               nil];
	[self performDelegateSelector:@selector(operationStarted:) withObject:message];
	if ([self sendXMLRequest:message]) {
		for (;;) {
			// read next slab of information
			// The reply will contain an entry for Status, a string from the following:
			//	"RemovingArchive"
			//	"Complete"
			// All except "Complete" also include PercentageComplete, an integer between 0 and 100 (but it goes up and down)
			//
			// Looks like instead of Status, we can get:
			// Error = APIEpicFail;
			// (that happened if I passed in a missing bundle-id
			// Error = APIInternalError
			// (that happened if I kept reading?
			NSDictionary *reply = [self readXMLReply];
			if (!reply) break;
			[self performDelegateSelector:@selector(operationContinues:) withObject:reply];
			NSString *s = [reply objectForKey:@"Status"];
			if ([s isEqual:@"Complete"]) break;
		}
	}
	[self performDelegateSelector:@selector(operationCompleted:) withObject:message];
	return NO;
}
@end
