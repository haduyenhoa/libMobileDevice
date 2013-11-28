//
//  AMSpringboardServices.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMSpringboardServices.h"

@implementation AMSpringboardServices

- (id)getIconState
{
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObject:@"getIconState" forKey:@"command"];
	if ([self sendXMLRequest:message]) {
		return [self readXMLReply];
	}
	return nil;
}

- (id)getIconPNGData:(NSString*)bundleId
{
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObjectsAndKeys:
               // value			key
               @"getIconPNGData",	@"command",
               bundleId,			@"bundleId",
               nil];
	if ([self sendXMLRequest:message]) {
		return [self readXMLReply];
	}
	return nil;
}

- (NSImage*)getIcon:(NSString*)displayIdentifier
{
	id reply = [self getIconPNGData:displayIdentifier];
	if (reply) {
		NSData *pngdata = [reply objectForKey:@"pngData"];
		if (pngdata) {
			return [[NSImage alloc] initWithData:pngdata];
		}
	}
	return nil;
}

- (id)initWithAMDevice:(AMDevice*)device
{
	if (self = [super initWithName:@"com.apple.springboardservices" onDevice:device]) {
		// nothing special
	}
	return self;
}

/*
 /// - \p "com.apple.mobile.springboardservices"
 ///			(implemented as /usr/libexec/springboardservicesrelay)
 
 {	"command" = "getIconState"; }
 - returns an NSArray() of pages
 -   page 0 is the dock
 -   each page is an NSArray() of icon entries
 -       each entry is an NSDictionary()
 -               bundleIdentifier = "com.apple.mobileipod";
 -               displayIdentifier = "com.apple.mobileipod-AudioPlayer";
 -               displayName = Music;
 -               iconModDate = 2009-09-26 20:45:29 +1000;
 -       or a zero (for an unused slot)
 -       padded to a multiple of four.
 
 {	"command" = "getIconPNGData"; "bundleId" = ... };
 
 {	"command" = "setIconState"; }
 perhaps expects to be passed a follow up plist with the new state
 */

@end
