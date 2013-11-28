//
//  AFCDirectoryAccess.h
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMService.h"
#import "AFCFileReference.h"
/// This object manages a single file server connection to the connected device.
/// Using it, you can open files for reading or writing.  It also provides higher-order
/// functions such as directory scanning, directory creation and file copying.
///
/// You should not use these directly.  Instead, see AFCMediaDirectory, AFCApplicationDirectory
/// and AFCRootDirectory
@interface AFCDirectoryAccess : AMService
{
@protected
	afc_connection _afc;						///< the low-level connection
}

/**
 * Return a dictionary containing information about the connected device.
 *
 * Keys in the result dictionary include:
 *	- \p "Model"
 *	- \p "FSFreeBytes"
 *	- \p "FSBlockSize"
 *	- \p "FSTotalBytes"
 */
- (NSDictionary*)deviceInfo;

/**
 * Return a dictionary containing information about the specified file.
 * @param path Full pathname to the file to retrieve information for
 *
 * Keys in the result dictionary include:
 *	- \p "st_ifmt" - file type
 *		- \p "S_IFREG" - regular file
 *		- \p "S_IFDIR" - directory
 *		- \p "S_IFCHR" - character device
 *		- \p "S_IFBLK" - block device
 *		- \p "S_IFLNK" - symbolic link (see LinkTarget)
 *
 *	- \p "st_blocks" - number of disk blocks occupied by file
 *
 *	- \p "st_nlink" - number of "links" occupied by file
 *
 *	- \p "st_size" - number of "bytes" in file
 *
 *	- \p "LinkTarget" - target of symbolic link (only if st_ifmt="S_IFLNK")
 */
- (NSDictionary*)getFileInfo:(NSString*)path;

/**
 * Return YES if the specified file/directory exists on the device.
 * @param path Full pathname to file/directory to check
 */
- (BOOL)fileExistsAtPath:(NSString *)path;

/**
 * Return a array containing a list of simple filenames found
 * in the specified directory.  The entries for "." and ".." are
 * not included.
 * @param path Full pathname to the directory to scan
 */
- (NSArray*)directoryContents:(NSString*)path;

/**
 * Return a array containing a list of full pathnames found
 * in the specified directory, and all subordinate directories.
 * Entries for directories will end in "/"
 * The entries for "." and ".." are not included.
 * @param path Full pathname to the directory to scan
 */
- (NSArray*)recursiveDirectoryContents:(NSString*)path;

/**
 * Open a file for reading.
 * @param path Full pathname to the file to open
 */
- (AFCFileReference*)openForRead:(NSString*)path;

/**
 * Open a file for writing.
 * @param path Full pathname to the file to open
 */
- (AFCFileReference*)openForWrite:(NSString*)path;

/**
 * Open a file for reading or writing.
 * @param path Full pathname to the file to open
 */
- (AFCFileReference*)openForReadWrite:(NSString*)path;

/**
 * Create a new directory on the device.
 * @param path Full pathname of the directory to create
 */
- (BOOL)mkdir:(NSString*)path;

/**
 * Unlink a file or directory on the device.  If a directory is specified, it must
 * be empty.
 * @param path Full pathname of the directory to delete
 */
- (BOOL)unlink:(NSString*)path;

/**
 * Rename a file or directory on the device.
 * @param oldpath Full pathname of file or directory to rename
 * @param newpath Full pathname to rename file or directory to
 */
- (BOOL)rename:(NSString*)oldpath to:(NSString*)newpath;

/**
 * Create a hard link on the device.
 * @param linkname Full pathname of link to create
 * @param target Target of link
 */
- (BOOL)link:(NSString*)linkname to:(NSString*)target;

/**
 * Create a symbolic link on the device.
 * @param linkname Full pathname of symbolic link to create
 * @param target Target of symbolic link
 */
- (BOOL)symlink:(NSString*)linkname to:(NSString*)target;

/**
 * Copy the contents of a local file or directory (on the Mac) to
 * a directory on the device.  The copy is recursive (for directories)
 * and will copy symbolic links as links.
 * @param frompath Full pathname of the local file/directory
 * @param topath Full pathname of the device directory to copy into
 */
- (BOOL)copyLocalFile:(NSString*)frompath toRemoteDir:(NSString*)topath;

/**
 * Copy the contents of a local file (on the Mac) to the device.
 * @param frompath Full pathname of the local file
 * @param topath Full pathname of the device file to copy into
 */
- (BOOL)copyLocalFile:(NSString*)frompath  toRemoteFile:(NSString*)topath;

/**
 * Copy the contents of a device file to a file on the Mac.
 * @param frompath Full pathname of the device file
 * @param topath Full pathname of the local file to copy into
 */
- (BOOL)copyRemoteFile:(NSString*)frompath toLocalFile:(NSString*)topath;

/**
 * Close this connection.  From this point on, none of the other functions
 * will run correctly.
 */
- (void)close;

//- (id)initWithAMDevice:(AMDevice*)device;
//- (id)initWithAMDevice:(AMDevice*)device
//               andName:(NSString*)identifier;

@end