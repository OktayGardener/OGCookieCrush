//
//  GameScene.h
//  OGCookieCrush
//

//  Copyright (c) 2015 Oktay Bahceci. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class OGLevel;

@interface GameScene : SKScene

@property (nonatomic, strong) OGLevel *level;

- (void)addSpritesForCookies:(NSSet *)cookies;

- (void)addTiles;

@end
