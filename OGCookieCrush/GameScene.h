//
//  GameScene.h
//  OGCookieCrush
//

//  Copyright (c) 2015 Oktay Bahceci. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class OGLevel;
@class OGSwap;


@interface GameScene : SKScene

@property (nonatomic, strong) OGLevel *level;
@property (copy, nonatomic) void (^swipeHandler)(OGSwap *swap);

- (void)addSpritesForCookies:(NSSet *)cookies;

- (void)addTiles;

- (void)animateSwap:(OGSwap *)swap completion:(dispatch_block_t)completion;

- (void)animateInvalidSwap:(OGSwap *)swap completion:(dispatch_block_t)completion;

- (void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion;

- (void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion;

- (void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion;

@end
