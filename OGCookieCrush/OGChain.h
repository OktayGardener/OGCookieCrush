//
//  OGChain.h
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 12/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGCookie;

typedef NS_ENUM(NSUInteger, ChainType) {
	ChainTypeHorizontal,
	ChainTypeVertical,
};

@interface OGChain : NSObject

@property (nonatomic, strong, readonly) NSArray *cookies;

@property (nonatomic, assign) ChainType chainType;

@property (assign, nonatomic) NSUInteger score;

- (void)addCookie:(OGCookie *)cookie;

@end