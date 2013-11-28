//
//  AFCApplicationDirectory.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCDirectoryAccess.h"

/// This class represents an AFC connection that is rooted to a single
/// application's sandbox.  You must know the \p CFBundleIdentifier value
/// from the application's \p Info.plist
///
/// To create one, send the \p -newAFCApplicationDirectory: message to an instance of AMDevice.
///
/// The current user will be 'mobile' and will only be able to
/// access files within the sandbox.  The root directory will appear to contain
/// - the application
/// - Documents
/// - Library
/// - tmp
///
/// Under the covers, it is implemented as a service called \p "com.apple.mobile.house_arrest" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/mobile_house_arrest
/// </PRE>
@interface AFCApplicationDirectory : AFCDirectoryAccess {
}

- (id)initWithAMDevice:(AMDevice*)device
               andName:(NSString*)identifier;
@end
