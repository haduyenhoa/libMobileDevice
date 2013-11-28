//
//  AFCGeneralDirectory.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCGeneralDirectory.h"

@implementation AFCGeneralDirectory

-(id)initWithAMDevice:(AMDevice*)device {
    if (self = [super initWithName:@"com.apple.mobile.house_arrest" onDevice:device]) {
		int ret = AFCConnectionOpen(_service, 0/*timeout*/, &_afc);
		if (ret != 0) {
			NSLog(@"AFCConnectionOpen failed: %x", ret);
			self = nil;
		}
	}
	return self;
}

@end
