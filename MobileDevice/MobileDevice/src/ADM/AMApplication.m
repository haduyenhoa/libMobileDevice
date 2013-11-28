//
//  AMApplication.m
//  MobileDevice
//
//  Created by Duyen Hoa Ha on 28/11/2013.
//  Copyright (c) 2013 Duyen Hoa Ha. All rights reserved.
//

#import "AMApplication.h"

@implementation AMApplication
// we are immutable so it costs nothing to make copies
- (id)copyWithZone:(NSZone*)zone
{
	return self ;
}

// initialise a new installed app, based on the contents of the specified directory
- (id)initWithDictionary:(NSDictionary*)info
{
	if (self=[super init]) {
		_info = info;
		_bundleid = [_info objectForKey:@"CFBundleIdentifier"];
        
		// appname is harder than you think, for some reason many apps don't
		// seem to populate the correct keys.  Way to go, Apples validation team...
		_appname = nil;
		if (!_appname) _appname = [info objectForKey:@"CFBundleDisplayName"];
		if ([_appname compare:@""]==NSOrderedSame) _appname = nil;		// PuzzleManiak, I'm looking at you
		if (!_appname) _appname = [info objectForKey:@"CFBundleName"];
		if (!_appname) _appname = [info objectForKey:@"CFBundleExecutable"];
//		[_appname retain];
	}
	return self;
}

- (id)bundleid
{
	return _bundleid;
}

- (NSString*)appname
{
	return _appname;
}

- (NSDictionary*)info
{
	return _info;
}

// we fake out missing entries in our object with NSNull.  That way,
// I think NSPredicate can refer to "missing" entries without throwing exceptions
- (id)valueForKey:(NSString *)key
{
	if ([key isEqual:@"appname"]) return _appname;
	if ([key isEqual:@"bundleid"]) return _bundleid;
	id v = [_info valueForKey:key];
	if (v) return v;
	return [NSNull null];
}

- (id)appdir
{
	return [_info objectForKey:@"Container"];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<AMApplication name=%@ id=%@>",_appname,_bundleid];
}

- (NSUInteger)hash
{
	return [_bundleid hash];
}

- (NSComparisonResult)compare:(AMApplication *)other
{
	return [_appname caseInsensitiveCompare:other->_appname];
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[self class]]) return NO;
	return ([self compare:anObject] == NSOrderedSame);
}
@end
