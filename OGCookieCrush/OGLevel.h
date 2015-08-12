//
//  OGLevel.h
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCookie.h"
#import "OGTile.h"
#import "OGSwap.h"


static const NSInteger NumberOfRows = 9;
static const NSInteger NumberOfColumns = 9;

@interface OGLevel : NSObject

- (NSSet *)shuffle;

- (OGCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;

- (instancetype)initWithFile:(NSString *)filename;

- (OGTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;

- (void)performSwap:(OGSwap *)swap;

- (BOOL)isPossibleSwap:(OGSwap *)swap;


@end

