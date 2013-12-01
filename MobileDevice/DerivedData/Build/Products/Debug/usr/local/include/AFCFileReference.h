//
//  AFCFileReference.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"

/// This class represents an open file on the device.
/// The caller can read from or write to the file depending on the
/// file open mode.
@interface AFCFileReference : NSObject
{
@private
	afc_file_ref _ref;
	afc_connection _afc;
	NSString *_lasterror;
}

/// The last error that occurred on this file
///
/// The object remembers the last error that occurred, which allows most other api's
/// to return YES/NO as their failure condition.  If no previous error occurred,
/// this property will be nil.
@property (readonly) NSString *lasterror;

/// Close the file.
/// Any outstanding writes are flushed to disk.
- (bool)closeFile;

/// Change the current position within the file.
/// @param offset is the number of bytes to move by
/// @param mode must be one of the following:
/// - \p SEEK_SET (0) - offset is relative to the start of the file
/// - \p SEEK_CUR (1) - offset is relative to the current position
/// - \p SEEK_END (2) - offset is relative to the end of the file
- (bool)seek:(int64_t)offset mode:(int)mode;

/// Return the current position within the file.
/// The position is suitable to be passed to \p seek: \p mode:SEEK_SET
- (bool)tell:(uint64_t*)offset;

/// Read \p n
/// bytes from the file into the nominated buffer (which must be at
/// least \p n bytes long).  Returns the number of bytes actually read.
- (uint32_t)readN:(uint32_t)n bytes:(char *)buff;

/// Write \p n bytes to the file.  Returns \p true if the write was
/// successful and \p false otherwise.
- (bool)writeN:(uint32_t)n bytes:(const char *)buff;

/// Write the contents of an NSData to the file.  Returns \p true if the
/// write was successful and \p false otherwise
- (bool)writeNSData:(NSData*)data;

/// Set the size of the file
///
/// Truncates the file to the specified size.
- (bool)setFileSize:(uint64_t)size;

/*
 FIX public function
 */

- (id)initWithPath:(NSString*)path reference:(afc_file_ref)ref afc:(afc_connection)afc;

@end