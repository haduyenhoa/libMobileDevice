//
//  AMApplication.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>

/// This class represents an installed application on the device.  To retrieve
/// the list of installed applications on a device use [AMDevice installedApplications]
/// or one of the methods on AMInstallationProxy.
///
/// Information about an application is derived from and maintained in an internal
/// dictionary similar to the following:
/// <PRE>
///    ApplicationType = System;
///    CFBundleDevelopmentRegion = English;
///    CFBundleExecutable = MobileSafari;
///    CFBundleIdentifier = "com.apple.mobilesafari";
///    CFBundleInfoDictionaryVersion = "6.0";
///    CFBundlePackageType = APPL;
///    CFBundleResourceSpecification = "ResourceRules.plist";
///    CFBundleSignature = "????";
///    CFBundleSupportedPlatforms = ( iPhoneOS );
///    CFBundleURLTypes = (
///        {
///            CFBundleURLName = "Web site URL";
///            CFBundleURLSchemes = ( http, https );
///        }, {
///            CFBundleURLName = "Radar URL";
///            CFBundleURLSchemes = ( rdar, radar );
///        }, {
///            CFBundleURLName = "FTP URL";
///            CFBundleURLSchemes = ( ftp );
///        }, {
///            CFBundleURLName = "RSS URL";
///            CFBundleURLSchemes = ( feed, feeds );
///        }
///    );
///    CFBundleVersion = "528.16";
///    DTPlatformName = iphoneos;
///    DTSDKName = "iphoneos3.1.2.internal";
///    LSRequiresIPhoneOS = 1;
///    MinimumOSVersion = "3.1.2";
///    Path = "/Applications/MobileSafari.app";
///    PrivateURLSchemes = ( webclip );
///    SBIsRevealable = 1;
///    SBUsesNetwork = 3;
///    SafariProductVersion = "4.0";
///    UIHasPrefs = 1;
///    UIJetsamPriority = 75;
/// </PRE>
/// The contents of the dictionary are key-value coded in a manner that allows
/// NSPredicate to be used to filter applications.
/// For example, to locate all applications which use networking, you could use
/// <PRE>
/// [NSPredicate predicateWithFormat:@"SBUsesNetwork != nil"]
/// </PRE>
/// To locate hidden applications, you could use:
/// <PRE>
/// [NSPredicate predicateWithFormat:@"SBAppTags contains 'hidden'" ];
/// </PRE>
@interface AMApplication : NSObject {
@private
	NSDictionary *_info;
	NSString *_appname;
	NSString *_bundleid;
}

/// Return the internal dictionary that contains all our information
- (NSDictionary*) info;

/// Return the name (usually) visible in the Springboard.  To get the actual name
/// being displayed, use AMSpringboardServices getIconState method and search
/// using the AMApplication's bundleid.
- (NSString*) appname;

/// Return the CFBundleID value from
/// the applications Info.plist.
- (NSString*) bundleid;

/// Return the full pathname of the directory that
/// the .app file is installed in
- (NSString*) appdir;

- (id)initWithDictionary:(NSDictionary*)info;

@end
