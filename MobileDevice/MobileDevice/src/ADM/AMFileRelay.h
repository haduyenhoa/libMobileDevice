//
//  AMFileRelay.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"

/// This class copies back specific files or sets of files from
/// the device, in CPIO file format.  The file format is non-negotiable and individual files
/// cannot be requested.  Instead, the caller specifies one or more "fileset names" from the
/// following table.
/// <TABLE>
///		<TR><TH>Set Name</TH><TH>File/Directory</TH></TR>
///		<TR><TD>AppleSupport</TD><TD>/private/var/logs/AppleSupport</TD></TR>
///		<TR><TD>Caches</TD><TD>/private/var/mobile/Library/Caches</TD></TR>
///		<TR><TD>CrashReporter</TD><TD>/Library/Logs/CrashReporter<BR>/private/var/mobile/Library/Logs/CrashReporter</TD></TR>
///		<TR><TD>MobileWirelessSync</TD><TD>/private/var/mobile/Library/Logs/MobileWirelessSync</TD></TR>
///		<TR><TD>Lockdown</TD><TD>/private/var/root/Library/Lockdown/activation_records
/// <BR>/private/var/root/Library/Lockdown/data_ark.plist
/// <BR>/private/var/root/Library/Lockdown/pair_records
/// <BR>/Library/Logs/lockdownd.log</TD></TR>
///		<TR><TD>MobileInstallation</TD><TD>/var/mobile/Library/Logs/MobileInstallation
/// <BR>/var/mobile/Library/Caches/com.apple.mobile.installation.plist
/// <BR>/var/mobile/Library/MobileInstallation/ArchivedApplications.plist
/// <BR>/var/mobile/Library/MobileInstallation/ApplicationAttributes.plist
/// <BR>/var/mobile/Library/MobileInstallation/SafeHarbor.plist</TD></TR>
///		<TR><TD>SafeHarbor</TD><TD>/var/mobile/Library/SafeHarbor</TD></TR>
///		<TR><TD>Network</TD><TD>/private/var/log/ppp</TD></TR>
/// <BR>/private/var/log/racoon.log
/// <BR>/var/log/eapolclient.en0.log</TD></TR>
///		<TR><TD>SystemConfiguration</TD><TD>/Library/Preferences/SystemConfiguration</TD></TR>
///		<TR><TD>UserDatabases</TD><TD>/private/var/mobile/Library/AddressBook</TD></TR>
/// <BR>/private/var/mobile/Library/Calendar
/// <BR>/private/var/mobile/Library/CallHistory
/// <BR>/private/var/mobile/Library/Mail/Envelope Index
/// <BR>/private/var/mobile/Library/SMS</TD></TR>
///		<TR><TD>VPN</TD><TD>/private/var/log/racoon.log</TD></TR>
///		<TR><TD>WiFi</TD><TD>/var/log/wifimanager.log
/// <BR>/var/log/eapolclient.en0.log</TD></TR>
///		<TR><TD>tmp</TD><TD>/private/var/tmp</TD></TR>
/// </TABLE>
/// The special fileset name "All" includes the files from all the other sets.
///
/// Due to the protocol used by the "com.apple.mobile.file_relay" service, the AMFileRelay
/// can only be used once and must be released afterward.
///
/// Under the covers, it is implemented as a service called \p "com.apple.mobile.file_relay" which
/// executes the following command on the device:
/// <PRE>
///	/usr/libexec/mobile_file_relay
/// </PRE>
@interface AMFileRelay : AMService {
	bool _used;
}

/// Gets one or more filesets and writes the results to the nominated stream.
/// If a problem occurs during the request, the method returns NO and
/// lasterror will be set to an appropriate
/// error code / message.
/// - AlreadyUsed - AMFileRelay object has already been used
/// - InvalidSource	- fileset name is invalid
/// - StagingEmpty - fileset contains no files to transfer
/// - CreateStagingPathFailed - failed to create temporary work directory on device
/// - CopierCreationFailed - BOMCopierNew() failed (on device)
/// - PopulationFailed - BOMCopierCopy() failed (on device)
- (bool)getFileSets:(NSArray*)set into:(NSOutputStream*)output;

/// Gets a single fileset and writes the result to the nominated stream.  This is
/// a convenience wrapper around \p -getFileSets:
- (bool)getFileSet:(NSString*)name into:(NSOutputStream*)output;

- (id)initWithAMDevice:(AMDevice*)device;
@end
