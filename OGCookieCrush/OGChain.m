//
//  OGChain.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 12/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import "OGChain.h"

@implementation OGChain {
	NSMutableArray *_cookies;
}

- (void)addCookie:(OGCookie *)cookie {
	if (_cookies == nil) {
		_cookies = [NSMutableArray array];
	}
	[_cookies addObject:cookie];
}

- (NSArray *)cookies {
	return _cookies;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"type:%ld cookies:%@", (long)self.chainType, self.cookies];
}

@end
