//
//  DeviceAdapter.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileDeviceAccess.h"

@interface DeviceAdapter : NSObject
<MobileDeviceAccessListener>
{
    AMDevice *iosDevice;
}

@property (nonatomic, strong) AMDevice *iosDevice;

- (BOOL)isDeviceConnected;

- (NSString *)getAppIdForName:(NSString *)appName;

@end
