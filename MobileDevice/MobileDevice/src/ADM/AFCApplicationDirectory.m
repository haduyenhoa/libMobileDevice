//
//  AFCApplicationDirectory.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCApplicationDirectory.h"

@implementation AFCApplicationDirectory

- (id)initWithAMDevice:(AMDevice*)device
               andName:(NSString*)identifier
{
	if (self = [super initWithName:@"com.apple.mobile.house_arrest" onDevice:device]) {
		NSDictionary *message;
		message = [NSDictionary dictionaryWithObjectsAndKeys:
                   // value			key
                   @"VendContainer",	@"Command",
                   identifier,			@"Identifier",
                   nil];
		if ([self sendXMLRequest:message]) {
			NSDictionary *reply = [self readXMLReply];
			if (reply) {
				// The reply will contain one of
				// "Error" => "the error message"
				// "Status" => "Complete"
				NSString *err = [reply objectForKey:@"Error"];
				if (err) {
					NSLog(@"House Arrest failed, %@", err);
					self = nil;
				} else {
					int ret = AFCConnectionOpen(_service, 0/*timeout*/, &_afc);
					if (ret != 0) {
						NSLog(@"AFCConnectionOpen failed: %x", ret);
						self = nil;
					}
				}
			} else {
				NSLog(@"%@",self.lasterror);
				self = nil;
			}
		} else {
			NSLog(@"%@",self.lasterror);
			self = nil;
		}
	}
	return self;
}

@end
