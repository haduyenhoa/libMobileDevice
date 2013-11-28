//
//  DeviceAdapter.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "DeviceAdapter.h"

@implementation DeviceAdapter

@synthesize iosDevice;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        [[MobileDeviceAccess singleton] setListener:self];
    }
    
    return self;
}

//- (void)dealloc {
//    // Clean-up code here.
//    
//    self.iosDevice = nil;
//    
//    [super dealloc];
//}

#pragma mark -
#pragma mark MobileDeviceAccessListener

- (void)deviceConnected:(AMDevice*)device
{
	
    self.iosDevice = device;
    
    
    //	AFCApplicationDirectory *appDir = [self.iosDevice newAFCApplicationDirectory:@""];
    //	NSLog(@"app dir : %@", appDir);
    //
    //	NSArray *files = [appDir directoryContents:@"/Documents"];
    //	NSLog(@"app dir files: %@", files);
    //
    //	[appDir copyLocalFile:@"/desktop.p12" toRemoteDir:@"/Documents"];
    //
    //	files = [appDir directoryContents:@"/Documents"];
    //	NSLog(@"app dir files: %@", files);
    //
    AFCApplicationDirectory *afcService = [self.iosDevice newAFCApplicationDirectory:@"com.allocine.applifrance"];
    NSLog(@"%@",[afcService recursiveDirectoryContents:@"/"]);
    
    NSLog(@"serialnumber: %@",self.iosDevice.serialNumber);
    AMNotificationProxy *aProxy = self.iosDevice.newAMNotificationProxy;
    [aProxy postNotification:@"Hello !!!"];
}

- (void)deviceDisconnected:(AMDevice*)device
{
    self.iosDevice = nil;
}


- (BOOL)isDeviceConnected {
    
    if (self.iosDevice) return YES;
    
    return NO;
}

- (NSString *)getAppIdForName:(NSString *)appName
{
    NSArray *appList = [self.iosDevice installedApplications];
    for (AMApplication *app in appList) {
        //        NSLog(@"info: %@",app.info);
        if ([[app appname] isEqualToString:appName]) {
            return [app bundleid];
        }
        
    }
    
    
    
    return nil;
}

@end
