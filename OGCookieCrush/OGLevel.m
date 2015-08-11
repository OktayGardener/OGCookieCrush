//
//  OGLevel.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import "OGLevel.h"

@implementation OGLevel

OGCookie *_cookies[NumberOfColumns][NumberOfRows];
OGTile *_tiles[NumberOfColumns][NumberOfRows];

- (instancetype)initWithFile:(NSString *)filename {
	self = [super init];
	if (self != nil) {
		NSDictionary *dictionary = [self loadJSON:filename];
		
		[dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
			[array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
				
				/* In spritekit, 0,0 is at the bottom. read file upside down */
				NSInteger tileRow = NumberOfRows - row - 1;
				if ([value integerValue] == 1) {
					_tiles[column][tileRow] = [[OGTile alloc] init];
				}
			}];
		}];
	}
	return self;
}

- (OGTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
	NSAssert1(column >= 0 && column < NumberOfColumns, @"Invalid column: %ld", (long)column);
	NSAssert1(row >= 0 && row < NumberOfRows, @"Invalid row: %ld", (long)row);

	return _tiles[column][row];
}

- (NSSet *)shuffle {
	return [self createInitialCookies];
}

- (NSSet *)createInitialCookies {
	NSMutableSet *set = [NSMutableSet set];
 
	for (NSInteger row = 0; row < NumberOfRows; row++) {
		for (NSInteger column = 0; column < NumberOfColumns; column++) {
			if (_tiles[column][row] != nil) {
				NSUInteger cookieType = arc4random_uniform(NumberOfCookieTypes) + 1;
				OGCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
				[set addObject:cookie];
			}
		}
	}
	return set;
}

- (NSDictionary *)loadJSON:(NSString *)filename {
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
	if (path == nil) {
		NSLog(@"Could not find level file: %@", filename);
		return nil;
	}
 
	NSError *error;
	NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
	if (data == nil) {
		NSLog(@"Could not load level file: %@, error: %@", filename, error);
		return nil;
	}
 
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
		NSLog(@"Level file '%@' is not valid JSON: %@", filename, error);
		return nil;
	}
 
	return dictionary;
}

#pragma mark - OGCookie

- (OGCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
	/* Protect the dear C-Arr for pointer errors with asserts */
	NSAssert1(column >= 0 && column < NumberOfColumns, @"Invalid column at: %ld", (long)column);
	NSAssert1(row >= 0 && row < NumberOfRows, @"Invalid row at: %ld", (long)row);
	
	return _cookies[column][row];
}

- (OGCookie *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType: (NSUInteger)cookieType {
	OGCookie *cookie = [[OGCookie alloc] init];
	
	cookie.cookieType = cookieType;
	cookie.column = column;
	cookie.row = row;
	
	_cookies[column][row] = cookie;
	
	return cookie;
}


@end
