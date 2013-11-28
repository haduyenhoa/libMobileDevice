//
//  AFCDirectoryAccess.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AFCDirectoryAccess.h"

#include <sys/stat.h>

@implementation AFCDirectoryAccess

//- (void)dealloc
//{
//	NSLog(@"deallocating %@",self);
//	if (_afc) [self close];
//	[super dealloc];
//}

- (bool)checkStatus:(int)ret from:(const char *)func
{
	if (ret != 0) {
		[self setLastError:[NSString stringWithFormat:@"%s failed: Return code = 0x%04X",func,ret]];
		return NO;
	}
	[self clearLastError];
	return YES;
}

- (bool)ensureConnectionIsOpen
{
	if (_afc) return YES;
	[self setLastError:@"Connection is not open"];
	return NO;
}

- (void)close
{
	if (_afc) {
		NSLog(@"disconnecting");
		int ret = AFCConnectionClose(_afc);
		if (ret != 0) {
			NSLog(@"AFCConnectionClose failed: %x", ret);
		}
		_afc = nil;
	}
}

- (NSMutableDictionary*)readAfcDictionary:(afc_dictionary)dict
{
	NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
	const char *k, *v;
	while (0 == AFCKeyValueRead(dict, &k, &v)) {
		if (!k) break;
		if (!v) break;
        
		// if all the characters in the value are digits, pass it back as
		// as 'long long' in a dictionary - else pass it back as a string
		const char *p;
		for (p=v; *p; p++) if (*p<'0' | *p>'9') break;
		if (*p) {
			/* its a string */
			[result setObject:[NSString stringWithUTF8String:v] forKey:[NSString stringWithUTF8String:k]];
		} else {
			[result setObject:[NSNumber numberWithLongLong:atoll(v)] forKey:[NSString stringWithUTF8String:k]];
		}
	}
	return result;
}

// retrieve a dictionary of information describing the device
// {
//		FSFreeBytes = 93876224
//		FSBlockSize = 4096
//		FSTotalBytes = 524288000
//		Model = iPod1,1
// }
- (NSDictionary*)deviceInfo
{
	if (![self ensureConnectionIsOpen]) return nil;
	afc_dictionary dict;
	if ([self checkStatus:AFCDeviceInfoOpen(_afc, &dict) from:"AFCDeviceInfoOpen"]) {
		NSMutableDictionary *result = [self readAfcDictionary:dict];
		AFCKeyValueClose(dict);
		[self clearLastError];
		return [NSDictionary dictionaryWithDictionary:result];
	}
	return nil;
}

/***
 
 /dev/console
 2009-08-07 20:10:11.331 MobileDeviceAccess[7284:10b]  st_blocks = 0
 2009-08-07 20:10:11.331 MobileDeviceAccess[7284:10b]  st_nlink = 1
 2009-08-07 20:10:11.332 MobileDeviceAccess[7284:10b]  st_size = 0
 2009-08-07 20:10:11.333 MobileDeviceAccess[7284:10b]  st_ifmt = S_IFCHR
 
 /dev/disk1
 2009-08-07 20:11:35.842 MobileDeviceAccess[7296:10b]  st_blocks = 0
 2009-08-07 20:11:35.843 MobileDeviceAccess[7296:10b]  st_nlink = 1
 2009-08-07 20:11:35.844 MobileDeviceAccess[7296:10b]  st_size = 0
 2009-08-07 20:11:35.844 MobileDeviceAccess[7296:10b]  st_ifmt = S_IFBLK
 
 ****/
// var/mobile/Media
// 2009-08-06 23:38:04.070 MobileDeviceAccess[1823:813]  st_blocks = 0
// 2009-08-06 23:38:04.071 MobileDeviceAccess[1823:813]  st_nlink = 11
// 2009-08-06 23:38:04.071 MobileDeviceAccess[1823:813]  st_size = 476
// 2009-08-06 23:38:04.072 MobileDeviceAccess[1823:813]  st_ifmt = S_IFDIR

// jailbreak.log
// 2009-08-06 23:37:23.089 MobileDeviceAccess[1800:813]  st_blocks = 64
// 2009-08-06 23:37:23.089 MobileDeviceAccess[1800:813]  st_nlink = 1
// 2009-08-06 23:37:23.090 MobileDeviceAccess[1800:813]  st_size = 29260
// 2009-08-06 23:37:23.091 MobileDeviceAccess[1800:813]  st_ifmt = S_IFREG

// /Applications
// 2009-08-06 23:39:01.872 MobileDeviceAccess[1864:813]  st_blocks = 8
// 2009-08-06 23:39:01.872 MobileDeviceAccess[1864:813]  st_nlink = 1
// 2009-08-06 23:39:01.876 MobileDeviceAccess[1864:813]  st_size = 27
// 2009-08-06 23:39:01.877 MobileDeviceAccess[1864:813]  st_ifmt = S_IFLNK
// 2009-08-06 23:39:01.873 MobileDeviceAccess[1864:813]  LinkTarget = /var/stash/Applications.pwn

- (NSDictionary*)getFileInfo:(NSString*)path
{
	if (!path) {
		[self setLastError:@"Input path is nil"];
		return nil;
	}
    
	if ([self ensureConnectionIsOpen]) {
		afc_dictionary dict;
		if ([self checkStatus:AFCFileInfoOpen(_afc, [path UTF8String], &dict) from:"AFCFileInfoOpen"]) {
			NSMutableDictionary *result = [self readAfcDictionary:dict];
			[result setObject:path forKey:@"path"];
			AFCKeyValueClose(dict);
			[self clearLastError];
			return [NSDictionary dictionaryWithDictionary:result];
		}
	}
	return nil;
}

- (BOOL)fileExistsAtPath:(NSString *)path
{
	if (!path) {
		[self setLastError:@"Input path is nil"];
		return NO;
	}
	if ([self ensureConnectionIsOpen]) {
		afc_dictionary dict;
		if (AFCFileInfoOpen(_afc, [path UTF8String], &dict)==0) {
			AFCKeyValueClose(dict);
			[self clearLastError];
			return YES;
		}
	}
	return NO;
}

- (NSArray*)directoryContents:(NSString*)path
{
	if (!path) {
		[self setLastError:@"Input path is nil"];
		return nil;
	}
    
	if (![self ensureConnectionIsOpen]) return nil;
	afc_directory dir;
	if ([self checkStatus:AFCDirectoryOpen(_afc,[path UTF8String],&dir) from:"AFCDirectoryOpen"]) {
		NSMutableArray *result = [NSMutableArray new];
		while (1) {
			char *d = NULL;
			AFCDirectoryRead(_afc,dir,&d);
			if (!d) break;
			if (*d=='.') {
				if (d[1]=='\000') continue;			// skip '.'
				if (d[1]=='.') {
					if (d[2]=='\000'); continue;	// skip '..'
				}
			}
			[result addObject:[NSString stringWithUTF8String:d]];
		}
		AFCDirectoryClose(_afc,dir);
		[self clearLastError];
		return [NSArray arrayWithArray:result];
	}
    
	// ret=4: path is a file
	// ret=8: can't open path
	return nil;
}

static BOOL read_dir( AFCDirectoryAccess *self, afc_connection afc, NSString *path, NSMutableArray *files )
{
	BOOL result;
    
	afc_directory dir;
	int ret = AFCDirectoryOpen(afc,[path UTF8String],&dir);
    
	if (ret == 4) {
		// its a file, so add it in and return
		[files addObject:path];
		return YES;
	}
    
	if (ret != 0) {
		// something other than a file causes us to fail
		return [self checkStatus:ret from:"AFCDirectoryOpen"];
	}
    
	// collect us, with a trailing slash, since we are a directory
	[files addObject:[NSString stringWithFormat:@"%@/",path]];
    
	// build a list of all the files located here.
	NSMutableArray *here = [NSMutableArray new];
	while (1) {
		char *d = NULL;
		AFCDirectoryRead(afc,dir,&d);
		if (!d) break;
		if (*d=='.') {
			if (d[1]=='\000') continue;			// skip '.'
			if (d[1]=='.') {
				if (d[2]=='\000'); continue;	// skip '..'
			}
		}
		[here addObject:[NSString stringWithFormat:@"%@/%s",path,d]];
	}
	AFCDirectoryClose(afc,dir);
    
	// step through everything we found and add to the array
	result = YES;
	for (NSString *f in here) {
		if (!read_dir(self, afc, f, files)) {
			result = NO;
			break;
		}
	}
    
	return result;
}

- (NSArray*)recursiveDirectoryContents:(NSString*)path
{
	if (!path) {
		[self setLastError:@"Input path is nil"];
		return nil;
	}
    
	if (![self ensureConnectionIsOpen]) return nil;
    
	NSMutableArray *unsorted = [NSMutableArray new];
	if (read_dir(self, _afc, path, unsorted)) {
		[unsorted sortUsingSelector:@selector(compare:)];
		NSArray *result = [NSArray arrayWithArray:unsorted];
		return result;
	}
	return nil;
}

- (BOOL)mkdir:(NSString*)path
{
	if (!path) {
		[self setLastError:@"Input path is nil"];
		return NO;
	}
	if (![self ensureConnectionIsOpen]) return NO;
	return [self checkStatus:AFCDirectoryCreate(_afc, [path UTF8String]) from:"AFCDirectoryCreate"];
}

- (BOOL)unlink:(NSString*)path
{
	if (!path) {
		[self setLastError:@"Input path is nil"];
		return NO;
	}
	if (![self ensureConnectionIsOpen]) return NO;
	return [self checkStatus:AFCRemovePath(_afc, [path UTF8String]) from:"AFCRemovePath"];
}

- (BOOL)rename:(NSString*)path1 to:(NSString*)path2
{
	if (!path1) {
		[self setLastError:@"Old path is nil"];
		return NO;
	}
	if (!path2) {
		[self setLastError:@"New path is nil"];
		return NO;
	}
	if (![self ensureConnectionIsOpen]) return NO;
	return [self checkStatus:AFCRenamePath(_afc, [path1 UTF8String], [path2 UTF8String]) from:"AFCRenamePath"];
}

- (BOOL)link:(NSString*)path to:(NSString*)target
{
	if (!path) {
		[self setLastError:@"Path is nil"];
		return NO;
	}
	if (!target) {
		[self setLastError:@"Target is nil"];
		return NO;
	}
	if (![self ensureConnectionIsOpen]) return NO;
	return [self checkStatus:AFCLinkPath(_afc, 1, [target UTF8String], [path UTF8String]) from:"AFCLinkPath"];
}


- (BOOL)symlink:(NSString*)path to:(NSString*)target
{
	if (!path) {
		[self setLastError:@"Path is nil"];
		return NO;
	}
	if (!target) {
		[self setLastError:@"Target is nil"];
		return NO;
	}
	if (![self ensureConnectionIsOpen]) return NO;
	return [self checkStatus:AFCLinkPath(_afc, 2, [target UTF8String], [path UTF8String]) from:"AFCLinkPath"];
}

- (AFCFileReference*)openForRead:(NSString*)path
{
	if (![self ensureConnectionIsOpen]) return nil;
	afc_file_ref ref;
	if ([self checkStatus:AFCFileRefOpen(_afc, [path UTF8String], 1, &ref) from:"AFCFileRefOpen"]) {
		return [[AFCFileReference alloc] initWithPath:path reference:ref afc:_afc] ;
	}
	// if mode==0, ret=7
	// if file does not exist, ret=8
	return nil;
}

- (AFCFileReference*)openForWrite:(NSString*)path
{
	if (![self ensureConnectionIsOpen]) return nil;
	afc_file_ref ref;
	if ([self checkStatus:AFCFileRefOpen(_afc, [path UTF8String], 2, &ref) from:"AFCFileRefOpen"]) {
		return [[AFCFileReference alloc] initWithPath:path reference:ref afc:_afc] ;
	}
	// if mode==0, ret=7
	// if file does not exist, ret=8
	return nil;
}

- (AFCFileReference*)openForReadWrite:(NSString*)path
{
	if (![self ensureConnectionIsOpen]) return nil;
	afc_file_ref ref;
	if ([self checkStatus:AFCFileRefOpen(_afc, [path UTF8String], 3, &ref) from:"AFCFileRefOpen"]) {
		return [[AFCFileReference alloc] initWithPath:path reference:ref afc:_afc] ;
	}
	// if mode==0, ret=7
	// if file does not exist, ret=8
	return nil;
}

- (BOOL)copyLocalFile:(NSString*)path1 toRemoteFile:(NSString*)path2
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	BOOL result = NO;
	if ([self ensureConnectionIsOpen]) {
		// make sure remote file doesn't exist
		if ([self fileExistsAtPath:path2]) {
			[self setLastError:@"Won't overwrite existing file"];
		} else {
			// ok, make sure the input file opens before creating the
			// output file
			NSFileHandle *in = [NSFileHandle fileHandleForReadingAtPath:path1];
			if (in) {
				NSMutableDictionary *info = [NSMutableDictionary new] ;
				struct stat s;
				stat([path1 fileSystemRepresentation],&s);
				[info setObject:path1 forKey:@"Source"];
				[info setObject:path2 forKey:@"Target"];
				[info setObject:[NSNumber numberWithInt:s.st_size] forKey:@"Size"];
				[nc postNotificationName:@"AFCFileCopyBegin" object:self userInfo:info];
				// open remote file for write
				AFCFileReference *out = [self openForWrite:path2];
				if (out) {
					// copy all content across 10K at a time
					const uint32_t bufsz = 10240;
					uint32_t done = 0;
					while (1) {
						[info setObject:[NSNumber numberWithInt:done] forKey:@"Done"];
						[nc postNotificationName:@"AFCFileCopyProgress" object:self userInfo:info];
						NSData *nextblock = [in readDataOfLength:bufsz];
						uint32_t n = [nextblock length];
						if (n==0) break;
						[out writeNSData:nextblock];
						done += n;
					}
					[out closeFile];
					result = YES;
					[nc postNotificationName:@"AFCFileCopyDone" object:self userInfo:info];
				}
				// close input file regardless
				[in closeFile];
			} else {
				// hmmm, failed to open
				[self setLastError:@"Can't open input file"];
			}
		}
	}
	return result;
}

- (BOOL)copyLocalFile:(NSString*)path1 toRemoteDir:(NSString*)path2
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *fname;
	BOOL isdir;
	isdir = NO;
	if ([fm fileExistsAtPath:path1 isDirectory:&isdir]) {
		if (isdir) {
			// create the target directory
			NSString *basename = [path2 stringByAppendingPathComponent:[path1 lastPathComponent]];
			if (![self mkdir:basename]) return NO;
			for (fname in [fm contentsOfDirectoryAtPath:path1 error:nil]) {
				BOOL worked;
				worked = [self copyLocalFile:[path1 stringByAppendingPathComponent:fname]
                                 toRemoteDir:basename];
				if (!worked) {
					NSLog(@"failed on %@/%@: %@",path1,fname,self.lasterror);
					return NO;
				}
			}
			return YES;
		} else {
			fname = [path1 lastPathComponent];
			NSString *dest = [path2 stringByAppendingPathComponent:fname];
			char buff[PATH_MAX+1];
			ssize_t buflen = readlink([path1 UTF8String], buff, sizeof(buff));
			if (buflen>0) {
				buff[buflen] = 0;
				return [self symlink:dest to:[NSString stringWithUTF8String:buff]];
			} else {
				return [self copyLocalFile:path1 toRemoteFile:dest];
			}
		}
	}
    
	return NO;
}

- (BOOL)copyRemoteFile:(NSString*)path1 toLocalFile:(NSString*)path2
{
	BOOL result = NO;
	if ([self ensureConnectionIsOpen]) {
		NSFileManager *fm = [NSFileManager defaultManager];
		// make sure local file doesn't exist
		if ([fm fileExistsAtPath:path2]) {
			[self setLastError:@"Won't overwrite existing file"];
		} else {
			// open remote file for read
			AFCFileReference *in = [self openForRead:path1];
			if (in) {
				// open local file for write - stupidly we need to create it before
				// we can make an NSFileHandle
				[fm createFileAtPath:path2 contents:nil attributes:nil];
				NSFileHandle *out = [NSFileHandle fileHandleForWritingAtPath:path2];
				if (!out) {
					[self setLastError:@"Can't open output file"];
				} else {
					// copy all content across 10K at a time...
					const uint32_t bufsz = 10240;
					NSMutableData *buff = [[NSMutableData alloc] initWithLength:bufsz];
					while (1) {
						uint32_t n = [in readN:bufsz bytes:[buff mutableBytes]];
						if (n==0) break;
						[out writeData:[NSData dataWithBytesNoCopy:[buff mutableBytes] length:n freeWhenDone:NO]];
					}

					[out closeFile];
					[self clearLastError];
					result = YES;
				}
				// close output file
				[in closeFile];
			}
		}
	}
	return result;
}

@end
