//
//  OGCookie.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import "OGCookie.h"

@implementation OGCookie

- (NSString *)spriteName {
	static NSString * const spriteNames[] = {
		@"Croissant",
		@"Cupcake",
		@"Danish",
		@"Donut",
		@"Macaroon",
		@"SugarCookie",
	};
	
	return spriteNames[self.cookieType - 1];
}

- (NSString *)highlightedSpriteName {
	static NSString * const highlightedSpriteNames[] = {
		@"Croissant-Highlighted",
		@"Cupcake-Highlighted",
		@"Danish-Highlighted",
		@"Donut-Highlighted",
		@"Macaroon-Highlighted",
		@"SugarCookie-Highlighted",
	};
	
	return highlightedSpriteNames[self.cookieType - 1];
}


- (NSString *)description {
	return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}


@end
