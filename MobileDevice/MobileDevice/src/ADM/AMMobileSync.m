//
//  AMMobileSync.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMMobileSync.h"

#if 0
misagent
__cfstring:000020B0 cfstr_Profiletype __CFString <0, 0x7C8, aProfiletype, 0xB> ; "ProfileType"
__cfstring:000020C0 cfstr_Provisioning __CFString <0, 0x7C8, aProvisioning, 0xC> ; "Provisioning"
__cfstring:000020D0 cfstr_Messagetype __CFString <0, 0x7C8, aMessagetype, 0xB> ; "MessageType"
__cfstring:000020E0 cfstr_Install   __CFString <0, 0x7C8, aInstall, 7> ; "Install"
__cfstring:000020F0 cfstr_Profile   __CFString <0, 0x7C8, aProfile, 7> ; "Profile"
__cfstring:00002100 cfstr_Remove    __CFString <0, 0x7C8, aRemove, 6> ; "Remove"
__cfstring:00002110 cfstr_Profileid __CFString <0, 0x7C8, aProfileid, 9> ; "ProfileID"
__cfstring:00002120 cfstr_Copy      __CFString <0, 0x7C8, aCopy, 4> ; "Copy"
__cfstring:00002130 cfstr_Status    __CFString <0, 0x7C8, aStatus, 6> ; "Status"
__cfstring:00002140 cfstr_Payload   __CFString <0, 0x7C8, aPayload, 7> ; "Payload"
__cfstring:00002150 cfstr_Response  __CFString <0, 0x7C8, aResponse, 8> ; "Response"

#endif

@implementation AMMobileSync

- (id)initWithAMDevice:(AMDevice*)device
{
	if (self = [super initWithName:@"com.apple.mobilesync" onDevice:device]) {
		// wait for the version exchange
		NSLog(@"waiting for the version exchange");
		NSLog(@"%@", [self readXMLReply]);
		NSLog(@"sending OK");
		[self sendXMLRequest:[NSArray arrayWithObjects:@"DLMessageVersionExchange", @"DLVersionsOk",
                              [NSNumber numberWithInt:100],[NSNumber numberWithInt:100],nil]];
		NSLog(@"%@", [self readXMLReply]);
	}
	return self;
}

//- (void)dealloc
//{
//	[self sendXMLRequest:[NSArray arrayWithObjects:@"DLMessageDisconnect", @"So long and thanks for all the fish",nil]];
//	[super dealloc];
//}

- (id)getContactData
{
	NSDictionary *message;
	message = [NSArray arrayWithObjects:
               @"DLMessageProcessMessage",
               [NSArray arrayWithObjects:
				@"SDMessageGetAllRecordsFromDevice",
				@"com.apple.Contacts",
				@"---",
				[NSDate date],
				[NSNumber numberWithInt:106],		// protocol version 106
				@"___EmptyParameterString___",
				nil ],
               nil];
	NSLog(@"sending %@",message);
	if ([self sendXMLRequest:message]) {
		NSLog(@"waiting reply");
		NSLog(@"%@", [self readXMLReply]);
	}
	return nil;
}

#if 0

http://github.com/MattColyer/libiphone/blob/master/src/MobileSync.c

http://iphone-docs.org/doku.php?id=docs:protocols:screenshot

http://libimobiledevice.org/docs/mobilesync.html

Like other DeviceLink protocols, it starts with a simple handshake (binary plists represented as ruby objects):

< ["DLMessageVersionExchange", 100, 0]
> ["DLMessageVersionExchange", "DLVersionsOk"]
< ["DLMessageDeviceReady"]
After which it will accept commands (in the form [“DLMessageProcessMessage”, {“MessageType” ⇒ commandname}]).

< ["DLMessageProcessMessage", {"MessageType" => "ScreenShotRequest"}]
> ["DLMessageProcessMessage", {"MessageType" => "ScreenShotReply", "ScreenShotData" => png_data}]

message = [NSArray arrayWithObjects:
           @"SDMessageGetAllRecordsFromDevice",
           @"com.apple.Contacts",
           @"---",
           [NSDate date],
           [NSNumber numberWithInt:106],		// protocol version 106
           @"___EmptyParameterString___",
           nil ];

__cstring:00007008 aSyncsubscribed DCB "SyncSubscribedCalendars",0

__cstring:00006FF4 aCom_apple_cale DCB "com.apple.Calendars",0
__cstring:00007020 aCom_apple_devi DCB "com.apple.DeviceLink",0
__cstring:00007038 aCom_apple_book DCB "com.apple.Bookmarks",0
__cstring:0000704C aCom_apple_note DCB "com.apple.Notes",0



Notifications:
com.apple.MobileSync.SyncAgent.kSyncAgentSyncEnded
com.apple.MobileSync.SyncAgent.kSyncAgentSyncStarted

Commands:
__text:000068EC						; "SDMessageSyncDataClassWithDevice"
__text:000068F0						; "SDMessageSyncDataClassWithComputer"
__text:000068F4						; "SDMessageRefuseToSyncDataClassWithComputer"
__text:000068F8						; "SDMessageClearAllRecordsOnDevice"
__text:000068FC						; "SDMessageDeviceWillClearAllRecords"
__text:00006900						; "SDMessageGetChangesFromDevice"
__text:00006904						; "SDMessageGetAllRecordsFromDevice"
__text:00006908						; "SDMessageProcessChanges"
__text:00006910						; "SDMessageAcknowledgeChangesFromDevice"
__text:00006914						; "SDMessageDeviceReadyToReceiveChanges"
__text:00006918						; "SDMessageRemapRecordIdentifiers"
__text:0000691C						; "SDMessageFinishSessionOnDevice"
__text:00006920						; "SDMessageDeviceFinishedSession"
__text:00006924						; "SDMessageCancelSession"


plist_t array = build_contact_hello_msg(env);
ret = iphone_msync_send(env->msync, array);
plist_free(array);
array = NULL;
ret = iphone_msync_recv(env->msync, &array);

array = plist_new_array();
plist_add_sub_string_el(array, "SDMessageAcknowledgeChangesFromDevice");
plist_add_sub_string_el(array, "com.apple.Contacts");

ret = iphone_msync_send(env->msync, array);
plist_free(array);
array = NULL;


array = plist_new_array();
plist_add_sub_string_el(array, "DLMessagePing");
plist_add_sub_string_el(array, "Preparing to get changes for device");

ret = iphone_msync_send(env->msync, array);
plist_free(array);
array = NULL;

array = plist_new_array();
plist_add_sub_string_el(array, "SDMessageFinishSessionOnDevice");
plist_add_sub_string_el(array, "com.apple.Contacts");

ret = iphone_msync_send(env->msync, array);
plist_free(array);
array = NULL;

ret = iphone_msync_recv(env->msync, &array);

plist_t build_contact_hello_msg(iphone_env *env)
{
	plist_t array = NULL;
    
	array = plist_new_array();
	plist_add_sub_string_el(array, "SDMessageSyncDataClassWithDevice");
	plist_add_sub_string_el(array, "com.apple.Contacts");
    
	//get last anchor and send new one
	OSyncError *anchor_error;
	char *timestamp = NULL;
	timestamp = osync_anchor_retrieve(osync_objtype_sink_get_anchor(env->contact_sink),
                                      &anchor_error);
    
	if (timestamp && strlen(timestamp) > 0)
		osync_trace(TRACE_INTERNAL, "timestamp is: %s\n", timestamp);
	else {
		if (timestamp)
			free(timestamp);
		timestamp = strdup("---");
		osync_trace(TRACE_INTERNAL, "first sync!\n");
	};
    
	time_t t = time(NULL);
    
	char* new_timestamp = osync_time_unix2vtime(&t);
    
	plist_add_sub_string_el(array, timestamp);
	plist_add_sub_string_el(array, new_timestamp);
    
	plist_add_sub_uint_el(array, 106);
	plist_add_sub_string_el(array, "___EmptyParameterString___");
    
	return array;
}

#endif

@end
