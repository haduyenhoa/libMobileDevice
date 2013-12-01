//
//  AMDevice.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"

#import "AMSpringboardServices.h"
#import "AFCGeneralDirectory.h"
#import "AFCMediaDirectory.h"
#import "AFCApplicationDirectory.h"
#import "AFCCrashLogDirectory.h"
#import "AFCRootDirectory.h"
#import "AMNotificationProxy.h"
#import "AMInstallationProxy.h"
#import "AMFileRelay.h"
#import "AMSyslogRelay.h"
#import "AMMobileSync.h"
#import "AMApplication.h"


/// This class represents a connected device
/// (iPhone or iPod Touch).
@interface AMDevice : NSObject {
@private
	am_device _device;
	NSString *_lasterror;
	NSString *_deviceName;
	NSString *_udid;
	
	bool _connected, _insession;
}

/// The last error that occurred on this device
///
/// The object remembers the last error that occurred, which allows most other api's
/// to return YES/NO as their failure condition.  If no previous error occurred,
/// this property will be nil.
@property (readonly) NSString *lasterror;

/// Returns the device name (the name visible in the Devices section
/// in iTunes and labelled as Name: in the Summary pane in iTunes).
///
/// The same value may be retrieved by passing \p "DeviceName" to \p -deviceValueForKey:
@property (readonly) NSString *deviceName;		// configured name

/// Returns the 40 character UDID (the field labeled as Identifier: in the Summary pane
/// in iTunes - if its not visible, click the Serial Number: label).
///
/// The same value may be retrieved by passing \p "UniqueDeviceID" to \p -deviceValueForKey:
@property (readonly) NSString *udid;			// "ed9896a213aa2341274928472234127492847211"

/// Specific class of device.  eg, "iPod1,1"
///
/// The same value may be retrieved by passing
/// \p "ProductType" to \p -deviceValueForKey:
@property (readonly) NSString *productType;		// eg, "iPod1,1"

/// General class of device.  eg, "iPod"
///
/// The same value may be retrieved by passing
/// \p "DeviceClass" to \p -deviceValueForKey:
@property (readonly) NSString *deviceClass;

/// Returns the serial number (the field labeled as Serial Number: in the Summary pane
/// in iTunes - if its not visible, click the Identifier: label)
///
/// The same value may be retrieved by passing \p "SerialNumber" to \p -deviceValueForKey:
@property (readonly) NSString *serialNumber;	// "5984999T14P"

/// Create a file service connection which can access the media directory.
/// This uses the service \p "com.apple.afc" which is present on all devices
/// and only allows access to the \p "/var/mobile/Media" directory structure
/// as the user 'mobile'
- (AFCMediaDirectory*)newAFCMediaDirectory;

/// Create a file service connection which can access the crash log directory.
/// This uses the service \p "com.apple.crashreportcopymobile" which is present on all devices
/// and only allows access to the \p "/var/mobile/Library/Logs/CrashReporter" directory structure
/// as the user 'mobile'
- (AFCCrashLogDirectory*)newAFCCrashLogDirectory;

-(AFCDirectoryAccess*)newAFCDirectoryAccess;

-(AFCGeneralDirectory*)newAFCGeneralDirectory;

/// Create a file service connection rooted in the sandbox for the nominated
/// application.  This uses the service \p "com.apple.mobile.house_arrest" which is
/// present on all devices
/// and only allows access to the applications directory structure
/// as the user 'mobile'
/// @param bundleId This is the identifier value for the application.
- (AFCApplicationDirectory*)newAFCApplicationDirectory:(NSString*)bundleId;

/// Create a file service connection which can access the entire file system.
/// This uses the service \p "com.apple.afc2" which is only present on
/// jailbroken devices (and may need to be added manually with Cydia if you used
/// blackra1n to jailbreak).
- (AFCRootDirectory*)newAFCRootDirectory;

/// Create a notification proxy service.
/// This allows notifications to be posted on the device.
- (AMNotificationProxy*)newAMNotificationProxy;

/// Create a springboard services relay.
/// This allows info about icons and png data to be retrieved
- (AMSpringboardServices*)newAMSpringboardServices;

/// Create an installation proxy relay.
/// If an object is passed for the delegate, it will be notified during some of the
/// operations performed by the proxy.
- (AMInstallationProxy*)newAMInstallationProxyWithDelegate:(id<AMInstallationProxyDelegate>)delegate;

/// Create a fileset relay.  This can be used to en-masse extract certain groups
/// of information from the device. For more information, see AMFileRelay.
- (AMFileRelay*)newAMFileRelay;

/// Create an instance of AMSyslogRelay which will relay us message
/// from the syslog daemon on the device.
/// @param listener This object will be notified for every message
/// recieved by the relay service from the syslog daemon
/// @param message This is the message sent to the \p listener object.
- (AMSyslogRelay*)newAMSyslogRelay:(id)listener message:(SEL)message;

/// Create a mobile sync relay.  Allows synchronisation of information
/// with the device. For more information, see AMMobileSync.
- (AMMobileSync*)newAMMobileSync;

/// Returns an informational value from the device's root domain.
/// @param key can apparently be any value from
/// the following:
/// <TABLE>
///		<TR><TH>Key</TH><TH>Typical value</TH></TR>
///     <TR><TD><TT>ActivationState</TT></TD><TD>"Activated"</TD></TR>
///     <TR><TD><TT>ActivationStateAcknowledged</TT></TD><TD>1</TD></TR>
///     <TR><TD><TT>BasebandBootloaderVersion</TT></TD><TD>"5.8_M3S2"</TD></TR>
///     <TR><TD><TT>BasebandVersion</TT></TD><TD>"01.45.00"</TD></TR>
///     <TR><TD><TT>BluetoothAddress</TT></TD><TD>?</TD></TR>
///     <TR><TD><TT>BuildVersion</TT></TD><TD>"7A341"</TD></TR>
///     <TR><TD><TT>DeviceCertificate</TT></TD><TD>lots of bytes</TD></TR>
///     <TR><TD><TT>DeviceClass</TT></TD><TD>"iPod"</TD></TR>
///     <TR><TD><TT>DeviceName</TT></TD><TD>"SmartArray"</TD></TR>
///     <TR><TD><TT>DevicePublicKey</TT></TD><TD>lots of bytes</TD></TR>
///     <TR><TD><TT>FirmwareVersion</TT></TD><TD>"iBoot-596.24"</TD></TR>
///     <TR><TD><TT>HostAttached</TT></TD><TD>1</TD></TR>
///     <TR><TD><TT>IntegratedCircuitCardIdentity</TT></TD><TD>?</TD></TR>
///     <TR><TD><TT>InternationalMobileEquipmentIdentity</TT></TD><TD>?</TD></TR>
///     <TR><TD><TT>InternationalMobileSubscriberIdentity</TT></TD><TD>?</TD></TR>
///     <TR><TD><TT>ModelNumber</TT></TD><TD>"MA627"</TD></TR>
///     <TR><TD><TT>PhoneNumber</TT></TD><TD>?</TD></TR>
///     <TR><TD><TT>ProductType</TT></TD><TD>"iPod1,1"</TD></TR>
///     <TR><TD><TT>ProductVersion</TT></TD><TD>"3.0"</TD></TR>
///     <TR><TD><TT>ProtocolVersion</TT></TD><TD>2</TD></TR>
///     <TR><TD><TT>RegionInfo</TT></TD><TD>"ZP/B"</TD></TR>
///     <TR><TD><TT>SBLockdownEverRegisteredKey</TT></TD><TD>0</TD></TR>
///     <TR><TD><TT>SIMStatus</TT></TD><TD>"kCTSIMSupportSIMStatusReady"</TD></TR>
///     <TR><TD><TT>SerialNumber</TT></TD><TD>"5282327"</TD></TR>
///     <TR><TD><TT>SomebodySetTimeZone</TT></TD><TD>1</TD></TR>
///     <TR><TD><TT>TimeIntervalSince1970</TT></TD><TD>1249723940</TD></TR>
///     <TR><TD><TT>TimeZone</TT></TD><TD>"Australia/Sydney"</TD></TR>
///     <TR><TD><TT>TimeZoneOffsetFromUTC</TT></TD><TD>36000</TD></TR>
///     <TR><TD><TT>TrustedHostAttached</TT></TD><TD>1</TD></TR>
///     <TR><TD><TT>UniqueDeviceID</TT></TD><TD>"ab9999db56f0c444441b1c3cf6bb6666c53eea47"</TD></TR>
///     <TR><TD><TT>Uses24HourClock</TT></TD><TD>0</TD></TR>
///     <TR><TD><TT>WiFiAddress</TT></TD><TD>"00:1e:a1:52:91:ed"</TD></TR>
///     <TR><TD><TT>iTunesHasConnected</TT></TD><TD>1</TD></TR>
///     <TR><TD><TT>HardwareModel</TT></TD><TD>???</TD></TR>
///     <TR><TD><TT>UniqueChipID</TT></TD><TD>???</TD></TR>
///     <TR><TD><TT>ProductionSOC</TT></TD><TD>???</TD></TR>
/// </TABLE>
- (id)deviceValueForKey:(NSString*)key;

/// Same as deviceValueForKey: but queries the specified domain.  According to
/// http://iphone-docs.org/doku.php?id=docs:protocols:lockdownd domains include:
/// - com.apple.springboard.curvedBatteryCapacity
/// - com.apple.mobile.debug
//EnableVPNLogs
//Enable8021XLogs
//EnableWiFiManagerLogs
//EnableLockdownLogToDisk
//EnableLockdownExtendedLogging
//RemoveVPNLogs
//Remove8021XLogs
//RemoveLockdownLog
//RemoveWiFiManagerLogs
/// - com.apple.mobile.lockdown
/// - com.apple.mobile.nikita
/// - com.apple.mobile.data_sync
/*
 extern CFStringRef kLockdownSyncSupportsCalDAV;
 extern CFStringRef kLockdownDeviceHandlesDefaultCalendar;
 extern CFStringRef kLockdownSupportsEncryptedBackups;
 #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_1
 extern CFStringRef kLockdownDeviceSupportsClearingDataKey;
 #endif
 */

/// - com.apple.fairplay
/*
 extern CFStringRef kLockdownFairPlayContextIDKey;
 extern CFStringRef kLockdownFairPlayKeyDataKey;	// ?
 extern CFStringRef kLockdownRentalBagRequestKey;
 extern CFStringRef kLockdownRentalBagRequestVersionKey;
 extern CFStringRef kLockdownRentalBagResponseKey;
 extern CFStringRef kLockdownRentalCheckinAckRequestKey;
 extern CFStringRef kLockdownRentalCheckinAckResponseKey;	// ?
 extern CFStringRef kLockdownFairPlayRentalClockBias;
 */
///
/// However, none of them return anything for me (on a 1st gen iPod Touch).  The following do:
/// - com.apple.mobile.iTunes.store
/*
 static const CFStringRef kLockdownSoftwareCUIDKey = CFSTR("SoftwareCUID");
 */
/// <PRE>
///    AccountKind = 0;
///    AppleID = stevejobs;
///    CreditDisplayString = "";
///    DSPersonID = 1;
///    KnownAccounts =     (
///                {
///            AccountKind = 0;
///            AppleID = stevejobs;
///            CreditDisplayString = "";
///            DSPersonID = 1;
///        }
///    );
///    PreferHQTracks = 1;
///    PurchaseTypes = 0;
///    Storefront = "1,1";
///    UserName = "Steve Jobs";
/// </PRE>
/// - com.apple.mobile.lockdown_cache
/// <PRE>
///    ActivationState = Activated;
/// </PRE>
/// - com.apple.mobile.mobile_application_usage
/// <PRE>
///    "01028E50-0F1B-409D-B39A-98151466B4BB" = 148302989;
///    "034052C6-0573-46EF-BE17-86622EEB2CE3" = 2832934;
///    "03F43111-D9C5-40D3-9B01-50DBD68D6C87" = 12780530;
///		...
///    "05DFBBF2-C3E6-413F-B466-D358BFD88054" = 3141019;
/// </PRE>
/// - com.apple.mobile.user_preferences
/// <PRE>
///    DiagnosticsAllowed = 0;
/// </PRE>
/// - com.apple.mobile.battery
/// <PRE>
///     BatteryCurrentCapacity = 100;
///     BatteryIsCharging = 0;
/// </PRE>
/// - com.apple.mobile.iTunes
/*
 static const CFStringRef kLockdownLibraryApplicationsKey = CFSTR("LibraryApplications");
 static const CFStringRef kLockdownSyncedApplicationsKey = CFSTR("SyncedApplications");
 */
/// <PRE>
///     64Bit = 3;
///     AlbumArt = (
///         3005,
///         {
///             AlignRowBytes = 1;
///             BackColor = 00000000;
///             ColorAdjustment = 0;
///             Crop = 0;
///             FormatId = 3005;
///             GammaAdjustment = 2.2;
///             Interlaced = 0;
///             OffsetAlignment = 4096;
///             PixelFormat = 4C353535;
///             RenderHeight = 320;
///             RenderWidth = 320;
///             RowBytesAlignment = 16;
///             Sizing = 1;
///         },
///         3006,
///		    ...
///     );
///     AppleDRMVersion = {
///         Format = 2;
///         Maximum = 4;
///         Minimum = 0;
///     };
///     AudioCodecs = {
///         AAC = {
///             AppleDRM = 1;
///             LC =             {
///                 PerceptualNoiseSubsitution = 1;
///                 VariableBitRate = 1;
///             };
///             MaximumSampleRate = 48000;
///         };
///         AIFF =         {
///             MaximumBitDepth = 16;
///             MaximumSampleRate = 48000;
///             Mono = 1;
///             Multichannel = 0;
///             Stereo = 1;
///         };
///         AppleLossless =         {
///             AppleDRM = 1;
///             MaximumBitDepth = 32;
///             MaximumBitDepthUntruncated = 16;
///             MaximumSampleRate = 48000;
///             Mono = 1;
///             Multichannel = 0;
///             Stereo = 1;
///         };
///         Audible =         {
///             AAC = 1;
///             Type1 = 0;
///             Type2 = 1;
///             Type3 = 1;
///             Type4 = 1;
///         };
///         MP3 =         {
///             MaximumDataRate = 320;
///             MaximumSampleRate = 48000;
///             Mono = 1;
///             Stereo = 1;
///         };
///         WAV =         {
///             MaximumBitDepth = 16;
///             MaximumSampleRate = 48000;
///             Mono = 1;
///             Multichannel = 0;
///             Stereo = 1;
///         };
///     };
///     BatteryPollInterval = 60;
///     ChapterImageSpecs =     (
///         3005,
///         {
///             AlignRowBytes = 1;
///             BackColor = 00000000;
///             ColorAdjustment = 0;
///             Crop = 0;
///             FormatId = 3005;
///             GammaAdjustment = 2.2;
///             Interlaced = 0;
///             OffsetAlignment = 4096;
///             PixelFormat = 4C353535;
///             RenderHeight = 320;
///             RenderWidth = 320;
///             RowBytesAlignment = 16;
///             Sizing = 1;
///         },
///         3006,
///         ...
///     );
///     ConnectedBus = USB;
///     CustomerRingtones = 1;
///     DBVersion = 4;
///     FairPlayCertificate = <308202c7  4224122a .... 757521>;
///     FairPlayGUID = db9999db56f0c2e2141b1c3cf6bb481dc53eea47;
///     FairPlayID = <db9999db 56f0c2e2 141b1c3c f6bb481d c53eea47>;
///     FamilyID = 10001;
///     GeniusConfigMaxVersion = 20;
///     GeniusConfigMinVersion = 1;
///     GeniusMetadataMaxVersion = 20;
///     GeniusMetadataMinVersion = 1;
///     GeniusSimilaritiesMaxVersion = 20;
///     GeniusSimilaritiesMinVersion = 1;
///     ImageSpecifications =     (
///         3004,
///         {
///             AlignRowBytes = 1;
///             BackColor = FFFFFFFF;
///             ColorAdjustment = 0;
///             Crop = 1;
///             FormatId = 3004;
///             GammaAdjustment = 2.2;
///             Interlaced = 0;
///             OffsetAlignment = 4096;
///             PixelFormat = 4C353535;
///             RenderHeight = 55;
///             RenderWidth = 55;
///             RowBytesAlignment = 16;
///         },
///         3011,
///			...
///     );
///     MinITunesVersion = "8.2";
///     OEMA = 1;
///     OEMID = 0;
///     PhotoVideosSupported = 1;
///     PodcastsSupported = 1;
///     RentalsSupported = 1;
///     SQLiteDB = 1;
///     SupportsAntiPhishing = 1;
///     SupportsApplicationInstall = 1;
///     SupportsConfigurationBlobs = 1;
///     SupportsDownloadedPodcasts = 1;
///     SupportsGenius = 1;
///     SupportsGeniusMixes = 1;
///     SupportsProvisioningBlobs = 1;
///     SyncDataClasses = (
///         Contacts,
///         Calendars,
///         Bookmarks,
///         "Mail Accounts",
///         Notes
///     );
///     UseVoiceMemosFolder = 1;
///     VideoCodecs =     {
///         "H.264" =         {
///             AAC =             {
///                 AppleDRM = 1;
///                 LC =                 {
///                     Multichannel = 0;
///                     VariableBitRate = 1;
///                 };
///                 MaximumBitRate = 256;
///                 MaximumSampleRate = 48000;
///             };
///             AppleVideoDRM =             {
///                 MaximumEncryptionPercentage = 12.5;
///             };
///             Level = 30;
///             MaximumHeight = 576;
///             MaximumPixelsPerSecond = 10368000;
///             MaximumResolution = 414720;
///             MaximumWidth = 720;
///             MinimumHeight = 32;
///             MinimumWidth = 32;
///             Profile = B;
///         };
///         "H.264LC" =         {
///             AAC =             {
///                 AppleDRM = 1;
///                 LC =                 {
///                     Multichannel = 0;
///                     VariableBitRate = 1;
///                 };
///                 MaximumBitRate = 256;
///                 MaximumSampleRate = 48000;
///             };
///             AppleVideoDRM =             {
///                 MaximumEncryptionPercentage = 6.25;
///             };
///             ComplexityLevel = 1;
///             Level = 30;
///             MaximumHeight = 480;
///             MaximumResolution = 307200;
///             MaximumWidth = 640;
///             MinimumHeight = 32;
///             MinimumWidth = 32;
///             Profile = B;
///         };
///         MPEG4 =         {
///             AAC =             {
///                 AppleDRM = 1;
///                 LC =                 {
///                     Multichannel = 0;
///                     VariableBitRate = 1;
///                 };
///                 MaximumBitRate = 256;
///                 MaximumSampleRate = 48000;
///             };
///             MaximumAverageBitRate = 5000;
///             MaximumHeight = 576;
///             MaximumResolution = 307200;
///             MaximumWidth = 720;
///             MinimumHeight = 16;
///             MinimumWidth = 16;
///             "Profile-Level-ID" = 3;
///         };
///     };
///     VideoPlaylistsSupported = 1;
///     VoiceMemosSupported = 1;
///     iPhoneCheckpointVersion = 1;
///     iTunesStoreCapable = 1;
/// }
/// </PRE>
/// - com.apple.disk_usage
/// <PRE>
///     AmountCameraAvailable = 556707840;
///     AmountCameraUsageChanged = -58721;
///     AmountDataAvailable = 556707840;
///     AmountDataReserved = 167772160;
///     CalendarUsage = 311296;
///     CameraUsage = 27063896;
///     MediaCacheUsage = 0;
///     MobileApplicationUsage = 5058054749;
///     NotesUsage = 40960;
///     PhotoUsage = 6096396;
///     TotalDataAvailable = 724480000;
///     TotalDataCapacity = 15715639296;
///     TotalDiskCapacity = 16239927296;
///     TotalSystemAvailable = 121962496;
///     TotalSystemCapacity = 524288000;
///     VoicemailUsage = 28672;
///     WebAppCacheUsage = 600064;
/// </PRE>
/// - com.apple.mobile.sync_data_class
/// <PRE>
///     Bookmarks =     {
///     };
///     Calendars =     {
///     };
///     Contacts =     {
///     };
///     DeviceHandlesDefaultCalendar = 1;
///     DeviceSupportsClearingData = 1;
///     "Mail Accounts" =     {
///         ReadOnly = 1;
///     };
///     Notes =     {
///     };
///     SupportsEncryptedBackups = 1;
///     SyncSupportsCalDAV = 1;
/// </PRE>
/// - com.apple.international
/// <PRE>
///     Keyboard = "en_AU";
///     Language = en;
///     Locale = "en_AU";
///     SupportedKeyboards =     (
///         "ar_YE",
///         "cs_CZ",
///         "da_DK",
/// 		...
///         "zh_Hant-HWR",
///         "zh_Hant-Pinyin"
///     );
///     SupportedLanguages =     (
///         en,
///         fr,
///         de,
/// 		...
///         id,
///         ms
///     );
///     SupportedLocales =     (
///         "ar_LY",
///         "kok_IN",
///         "mk_MK",
///         "ms_MY",
/// 		...
///         "nl_BE",
///         "af_NA"
///     );
/*
 extern CFStringRef kLockdownSupportsAccessibilityKey;
 */
/// </PRE>
/// - com.apple.xcode.developerdomain
/// <PRE>
///		DeveloperStatus = Development;
/// </PRE>
/// - com.apple.mobile.iTunes.SQLMusicLibraryPostProcessCommands
/// <PRE>
///    SQLCommands =     {
///        AddAlbumArtistBlankColumn = "ALTER TABLE item ADD COLUMN album_artist_blank INTEGER NOT NULL DEFAULT 0;";
///        AddAlbumArtistNameBlankColumn = "ALTER TABLE album_artist ADD COLUMN name_blank INTEGER NOT NULL DEFAULT 0;";
///        AddAlbumArtistSectionOrderColumn = "ALTER TABLE item ADD COLUMN album_artist_section_order BLOB;";
///        AddAlbumArtistSortNameSectionColumn = "ALTER TABLE album_artist ADD COLUMN sort_name_section INTEGER NOT NULL DEFAULT 0;";
///        ...
///        CreateItemArtistIndex = "CREATE INDEX IF NOT EXISTS item_idx_artist ON item (artist);";
///        CreateItemArtistPidIndex = "CREATE INDEX IF NOT EXISTS item_idx_artist_pid ON item (artist_pid);";
///        ...
///        UpdateItemArtistNameBlankColumn = "UPDATE item_artist SET name_blank = 1 WHERE (name = '' OR name IS NULL);";
///        UpdateItemInSongsCollectionBlankColumns = "UPDATE item SET title_blank = (title = '' OR title IS NULL), artist_blank = (artist = '' OR artist IS NULL), composer_blank = (composer = '' OR composer IS NULL), album_blank = (album = '' OR album IS NULL), album_artist_blank = (album_artist = '' OR album_artist IS NULL), in_songs_collection = ((media_kind&33) AND ((media_kind&2)=0 AND is_rental=0));";
///        Version = 19;
///    };
///    UserVersionCommandSets = {
///        8 = {
///            Commands = (
///                DropUpdateItemInSongsCollectionTrigger,
///                DropUpdateItemTitleBlankTrigger,
///                DropUpdateItemArtistBlankTrigger,
///                ...
///                "MarkITunesCommandsExecuted_CurrentVersion"
///            );
///            SchemaDependencies = {
///                artist = (
///                    DropItemArtistTable,
///                    DropAlbumArtistTable,
///                    Artist2RenameArtistTable,
///                    ...
///                    DeleteEmptyAlbumArtists
///                );
///            };
///        };
///    };
/// </PRE>
/// - com.apple.mobile.software_behavior
/// <PRE>
///		Valid = 0;
///		GoogleMail = ???;		// not observed, but deduced
///		VolumeLimit = ???;		//
///		ShutterClick = ???;		//
///		NTSC = ???;				//
///		NoWiFi = ???;			//
///		ChinaBrick = ???;		//
/// </PRE>
/// - com.apple.mobile.internal
/// <PRE>
///		VoidWarranty = ???;					// not observed but deduced
///		IsInternal = ???;					//
///		PasswordProtected = ???;			//
///		ActivationStateAcknowledged = ???;	//
/// </PRE>
///	- com.apple.mobile.lockdownd
/// <PRE>
///		LogToDisk = ???;				// not observed but deduced
///		ExtendedLogging	= ???;			//
/// </PRE>
///	- com.apple.mobile.restriction
/// <PRE>
///		ProhibitAppInstall = ???;		// not observed but deduced
/// </PRE>
- (id)deviceValueForKey:(NSString*)key inDomain:(NSString*)domain;

/// Returns a dictionary of "most" informational values for the device.  If called
/// with a nil domain value, the keys
/// correspond to those shown in the table for \ref deviceValueForKey: but it appears
/// that it doesn't always return *all* values.
- (id)allDeviceValuesForDomain:(NSString*)domain;

/// Return a array of applications, each of which is represented by an instance
/// of AMApplication.  Note that this only returns details for applications installed
/// by iTunes.  For other (system) applications, use NSInstallationProxy to browse.
- (NSArray*)installedApplications;

/// Check whether the specified bundleId corresponds to an application
/// installed on the device.  If so, return an appropriate AMApplication.
/// Otherwise return nil.
- (AMApplication*)installedApplicationWithId:(NSString*)bundleId;

/**
 FIX: change theses functions to public so that other classe can access
 */
- (am_service)_startService:(NSString*)name;
- (bool)isDevice:(am_device) d;
- (void)forgetDevice;
+ (AMDevice*)deviceFrom:(am_device)device;
- (void)applicationWillTerminate:(NSNotification*)notification;

@end
