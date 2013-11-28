//
//  AMFileRelay.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMFileRelay.h"

@implementation AMFileRelay

- (bool)slurpInto:(NSOutputStream*)writestream
{
    bool result = NO;
	@autoreleasepool {
        
        UInt8 buf[1024];
        
        // make sure they remembered to open the stream
        bool opened = NO;
        if ([writestream streamStatus] == NSStreamStatusNotOpen) {
            [writestream open];
            opened = YES;
        }
        
        // create an input stream to read from the socket
        // loop around reading till its all done
        NSInputStream *readstream = [self inputStreamFromSocket];
        [readstream open];
        for (;;) {
            NSInteger nr = [readstream read:buf maxLength:sizeof(buf)];
            if (nr > 0) {
                NSInteger nw = [writestream write:buf maxLength:nr];
                if (nw != nr) {
                    [self setLastError:[NSString stringWithFormat:@"File truncated on write, nr=%ld nw=%ld",(long)nr,(long)nw]];
                    break;
                }
            } else if (nr < 0) {
                [self setLastError:[[readstream streamError] localizedDescription]];
                break;
            } else {
                [self clearLastError];
                result = YES;
                break;
            }
        }
        [readstream close];
        
        // if we opened the stream, we close it as well
        if (opened) [writestream close];
    }
	
	return(result);
}

- (id)initWithAMDevice:(AMDevice*)device
{
	if (self = [super initWithName:@"com.apple.mobile.file_relay" onDevice:device]) {
		_used = NO;
	}
	return self;
}

- (bool)getFileSets:(NSArray*)set into:(NSOutputStream*)output
{
	if (_used) {
		[self setLastError:@"AlreadyUsed"];
		return NO;
	}
	_used = YES;
    
	NSDictionary *message;
	message = [NSDictionary dictionaryWithObject:set forKey:@"Sources"];
	if ([self sendXMLRequest:message]) {
		NSDictionary *reply = [self readXMLReply];
		if (reply) {
			// If the reply contains an "Error" item, we failed
			id err = [reply objectForKey:@"Error"];
			if (err) {
				[self setLastError:[NSString stringWithFormat:@"%@",err]];
				return NO;
			}
			// We could check for "Status = Acknowledged" but why bother
			return [self slurpInto:output];
		}
	}
	return NO;
}

- (bool)getFileSet:(NSString*)name into:(NSOutputStream*)output
{
	return [self getFileSets:[NSArray arrayWithObject:name] into:output];
}

@end
