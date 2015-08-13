//
//  OGLevel.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import "OGLevel.h"
#import "OGChain.h"

@interface OGLevel ()

@property (nonatomic, strong) NSSet *possibleSwaps;

@end

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
					self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
					self.maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
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
	NSSet *set;
	do {
		set = [self createInitialCookies];
		[self detectPossibleSwaps];
		NSLog(@"Possible swaps: %@", self.possibleSwaps);
	} while ([self.possibleSwaps count] == 0);
	
	return set;
}

- (void)calculateScores:(NSSet *)chains {
	for (OGChain *chain in chains) {
		chain.score = 60 * ([chain.cookies count] - 2);
	}
}

- (BOOL)isPossibleSwap:(OGSwap *)swap {
	return [self.possibleSwaps containsObject:swap];
}

- (NSSet *)detectHorizontalMatches {
	// 1
	NSMutableSet *set = [NSMutableSet set];
 
	// 2
	for (NSInteger row = 0; row < NumberOfRows; row++) {
		for (NSInteger column = 0; column < NumberOfColumns - 2; ) {
			
			// 3
			if (_cookies[column][row] != nil) {
				NSUInteger matchType = _cookies[column][row].cookieType;
				
				// 4
				if (_cookies[column + 1][row].cookieType == matchType
					&& _cookies[column + 2][row].cookieType == matchType) {
					// 5
					OGChain *chain = [[OGChain alloc] init];
					chain.chainType = ChainTypeHorizontal;
					do {
						[chain addCookie:_cookies[column][row]];
						column += 1;
					}
					while (column < NumberOfColumns && _cookies[column][row].cookieType == matchType);
					
					[set addObject:chain];
					continue;
				}
			}
			
			// 6
			column += 1;
		}
	}
	return set;
}

- (NSSet *)detectVerticalMatches {
	NSMutableSet *set = [NSMutableSet set];
 
	for (NSInteger column = 0; column < NumberOfColumns; column++) {
		for (NSInteger row = 0; row < NumberOfRows - 2; ) {
			if (_cookies[column][row] != nil) {
				NSUInteger matchType = _cookies[column][row].cookieType;
				
				if (_cookies[column][row + 1].cookieType == matchType
					&& _cookies[column][row + 2].cookieType == matchType) {
					
					OGChain *chain = [[OGChain alloc] init];
					chain.chainType = ChainTypeVertical;
					do {
						[chain addCookie:_cookies[column][row]];
						row += 1;
					}
					while (row < NumberOfRows && _cookies[column][row].cookieType == matchType);
					
					[set addObject:chain];
					continue;
				}
			}
			row += 1;
		}
	}
	return set;
}

- (NSSet *)removeMatches {
	NSSet *horizontalChains = [self detectHorizontalMatches];
	NSSet *verticalChains = [self detectVerticalMatches];
 
	[self removeCookies:horizontalChains];
	[self removeCookies:verticalChains];
	
	[self calculateScores:horizontalChains];
	[self calculateScores:verticalChains];
 
	return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (void)detectPossibleSwaps {
	
	NSMutableSet *set = [NSMutableSet set];
	
	for (NSInteger row = 0; row < NumberOfRows; row++) {
		for (NSInteger column = 0; column < NumberOfColumns; column++) {
			
			OGCookie *cookie = _cookies[column][row];
			if (cookie != nil) {
				
				// Is it possible to swap this cookie with the one on the right?
				if (column < NumberOfColumns - 1) {
					// Have a cookie in this spot? If there is no tile, there is no cookie.
					OGCookie *other = _cookies[column + 1][row];
					if (other != nil) {
						// Swap them
						_cookies[column][row] = other;
						_cookies[column + 1][row] = cookie;
						
						// Is either cookie now part of a chain?
						if ([self hasChainAtColumn:column + 1 row:row] ||
							[self hasChainAtColumn:column row:row]) {
							
							OGSwap *swap = [[OGSwap alloc] init];
							swap.cookieA = cookie;
							swap.cookieB = other;
							[set addObject:swap];
						}
						
						// Swap them back
						_cookies[column][row] = cookie;
						_cookies[column + 1][row] = other;
					}
				}
				
				if (row < NumberOfRows - 1) {
					
					OGCookie *other = _cookies[column][row + 1];
					if (other != nil) {
						_cookies[column][row] = other;
						_cookies[column][row + 1] = cookie;
						
						if ([self hasChainAtColumn:column row:row + 1] ||
							[self hasChainAtColumn:column row:row]) {
							
							OGSwap *swap = [[OGSwap alloc] init];
							swap.cookieA = cookie;
							swap.cookieB = other;
							[set addObject:swap];
						}
						
						_cookies[column][row] = cookie;
						_cookies[column][row + 1] = other;
					}
				}
			}
		}
	}
	
	self.possibleSwaps = set;
}

- (NSArray *)fillHoles {
	NSMutableArray *columns = [NSMutableArray array];
 
	// 1
	for (NSInteger column = 0; column < NumberOfColumns; column++) {
		
		NSMutableArray *array;
		for (NSInteger row = 0; row < NumberOfRows; row++) {
			
			// 2
			if (_tiles[column][row] != nil && _cookies[column][row] == nil) {
				
				// 3
				for (NSInteger lookup = row + 1; lookup < NumberOfRows; lookup++) {
					OGCookie *cookie = _cookies[column][lookup];
					if (cookie != nil) {
						// 4
						_cookies[column][lookup] = nil;
						_cookies[column][row] = cookie;
						cookie.row = row;
						
						// 5
						if (array == nil) {
							array = [NSMutableArray array];
							[columns addObject:array];
						}
						[array addObject:cookie];
						
						// 6
						break;
					}
				}
			}
		}
	}
	return columns;
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
	NSUInteger cookieType = _cookies[column][row].cookieType;
 
	NSUInteger horzLength = 1;
	for (NSInteger i = column - 1; i >= 0 && _cookies[i][row].cookieType == cookieType; i--, horzLength++) ;
	for (NSInteger i = column + 1; i < NumberOfColumns && _cookies[i][row].cookieType == cookieType; i++, horzLength++) ;
	if (horzLength >= 3) return YES;
 
	NSUInteger vertLength = 1;
	for (NSInteger i = row - 1; i >= 0 && _cookies[column][i].cookieType == cookieType; i--, vertLength++) ;
	for (NSInteger i = row + 1; i < NumberOfRows && _cookies[column][i].cookieType == cookieType; i++, vertLength++) ;
	return (vertLength >= 3);
}


- (NSSet *)createInitialCookies {
	NSMutableSet *set = [NSMutableSet set];
 
	for (NSInteger row = 0; row < NumberOfRows; row++) {
		for (NSInteger column = 0; column < NumberOfColumns; column++) {
			if (_tiles[column][row] != nil) {
				NSUInteger cookieType;
				do {
					 cookieType = arc4random_uniform(NumberOfCookieTypes) + 1;
				} while ((column >= 2 &&
						 _cookies[column - 1][row].cookieType == cookieType &&
						 _cookies[column - 2][row].cookieType == cookieType) ||
						 
						 (row >= 2 && _cookies[column][row - 1].cookieType == cookieType &&
						 _cookies[column][row - 2].cookieType == cookieType));
				
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

- (NSArray *)fillNewCookies {
	NSMutableArray *columns = [NSMutableArray array];
 
	NSUInteger cookieType = 0;
 
	for (NSInteger column = 0; column < NumberOfColumns; column++) {
		
		NSMutableArray *array;
		
		for (NSInteger row = NumberOfRows - 1; row >= 0 && _cookies[column][row] == nil; row--) {
			
			if (_tiles[column][row] != nil) {
				
				NSUInteger newCookieType;
				do {
					newCookieType = arc4random_uniform(NumberOfCookieTypes) + 1;
				} while (newCookieType == cookieType);
				cookieType = newCookieType;
				
				OGCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
				
				if (array == nil) {
					array = [NSMutableArray array];
					[columns addObject:array];
				}
				[array addObject:cookie];
			}
		}
	}
	return columns;
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

- (void)removeCookies:(NSSet *)chains {
	for (OGChain *chain in chains) {
		for (OGCookie *cookie in chain.cookies) {
			_cookies[cookie.column][cookie.row] = nil;
		}
	}
}

- (void)performSwap:(OGSwap *)swap {
	NSInteger columnA = swap.cookieA.column;
	NSInteger rowA = swap.cookieA.row;
	NSInteger columnB = swap.cookieB.column;
	NSInteger rowB = swap.cookieB.row;
 
	_cookies[columnA][rowA] = swap.cookieB;
	swap.cookieB.column = columnA;
	swap.cookieB.row = rowA;
 
	_cookies[columnB][rowB] = swap.cookieA;
	swap.cookieA.column = columnB;
	swap.cookieA.row = rowB;
}

@end
