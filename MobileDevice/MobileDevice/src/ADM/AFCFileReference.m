//
//  AFCFileReference.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCFileReference.h"

@implementation AFCFileReference
- (void)clearLastError
{
	_lasterror = nil;
}

- (void)setLastError:(NSString*)msg
{
	[self clearLastError];
	_lasterror = msg;
}

- (bool)checkStatus:(afc_error_t)ret from:(const char *)func
{
	if (ret != 0) {
		[self setLastError:[NSString stringWithFormat:@"%s failed: %x",func,ret]];
		return NO;
	}
	[self clearLastError];
	return YES;
}

- (bool)ensureFileIsOpen
{
	if (_ref) return YES;
	[self setLastError:@"File is not open"];
	return NO;
}
//
//- (void)dealloc
//{
//	[self closeFile];
//}

- (id)initWithPath:(NSString*)path reference:(afc_file_ref)ref afc:(afc_connection)afc
{
	if (self=[super init]) {
		_ref = ref;
		_afc = afc;
	}
	return self;
}

- (bool)closeFile
{
	if (![self ensureFileIsOpen]) return NO;
	if (![self checkStatus:AFCFileRefClose(_afc, _ref) from:"AFCFileRefClose"]) return NO;
	_ref = 0;
	return YES;
}

- (bool)seek:(int64_t)offset mode:(int)m
{
	if (![self ensureFileIsOpen]) return NO;
	return [self checkStatus:AFCFileRefSeek(_afc, _ref, offset, m) from:"AFCFileRefSeek"];
}

- (bool)tell:(uint64_t*)offset
{
	if (![self ensureFileIsOpen]) return NO;
	return [self checkStatus:AFCFileRefTell(_afc, _ref, offset) from:"AFCFileRefTell"];
}

- (uint32_t)readN:(uint32_t)n bytes:(char *)buff
{
	if (![self ensureFileIsOpen]) return NO;
	uint32_t afcSize = n;
	if (![self checkStatus:AFCFileRefRead(_afc, _ref, buff, &afcSize) from:"AFCFileRefRead"]) return 0;
	return afcSize;
}

- (bool)writeN:(uint32_t)n bytes:(const char *)buff
{
	if (![self ensureFileIsOpen]) return NO;
	if (n>0) {
		return [self checkStatus:AFCFileRefWrite(_afc, _ref, buff, n) from:"AFCFileRefWrite"];
	}
	return YES;
}

- (bool)writeNSData:(NSData*)data
{
	return [self writeN:[data length] bytes:[data bytes]];
}

- (bool)setFileSize:(uint64_t)size
{
	if (![self ensureFileIsOpen]) return NO;
	return [self checkStatus:AFCFileRefSetFileSize(_afc, _ref, size) from:"AFCFileRefSetFileSize"];
}
@end
