//
//  AMSpringboardServices.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"
/// This class allows certain bits of information to be retrieved
/// from the springboard.
///
/// Under the covers, it is implemented as a service called \p "com.apple.springboardservices" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/springboardservicesrelay
/// </PRE>
@interface AMSpringboardServices : AMService {
    
}

/// This method seems to return an NSArray which contains one entry
/// per "page" on the iPod, though the first page appears to be for
/// the icons displayed in the dock.
///
/// Each page appears to be an NSArray of entries, each of which
/// describes an icon position on the page.  Each icon is represented
/// by an NSDictionary containing the following keys
/// -               bundleIdentifier = "com.apple.mobileipod";
/// -               displayIdentifier = "com.apple.mobileipod-AudioPlayer";
/// -               displayName = Music;
/// -               iconModDate = 2009-09-26 20:45:29 +1000;
///
/// If a position is unoccupied, the entry will be an NSInteger (0)
/// The array for each page appears to be padded to a multiple of
/// 4, rather than reserving a full 16 entries per page.
- (id)getIconState;

/// This method returns an NSDictionary containing a single entry with
/// the key "pngData", which contains an NSData holding the .png data
/// for the requested application.
///
/// The key required appears to be the displayIdentifier rather than
/// the bundleIdentifier.
- (id)getIconPNGData:(NSString*)displayIdentifier;

/// This method returns an NSImage holding the icon .png data
/// for the requested application.
///
/// The key required appears to be the displayIdentifier rather than
/// the bundleIdentifier.
- (NSImage*)getIcon:(NSString*)displayIdentifier;

- (id)initWithAMDevice:(AMDevice*)device;

@end