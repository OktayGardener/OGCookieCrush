//
//  OGSwap.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import "OGSwap.h"
#import "OGCookie.h"

@implementation OGSwap

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

- (BOOL)isEqual:(id)object {
	// You can only compare this object against other RWTSwap objects.
	if (![object isKindOfClass:[OGSwap class]]) return NO;
 
	// Two swaps are equal if they contain the same cookie, but it doesn't
	// matter whether they're called A in one and B in the other.
	OGSwap *other = (OGSwap *)object;
	return (other.cookieA == self.cookieA && other.cookieB == self.cookieB) ||
	(other.cookieB == self.cookieA && other.cookieA == self.cookieB);
}

- (NSUInteger)hash {
	return [self.cookieA hash] ^ [self.cookieB hash];
}


@end
