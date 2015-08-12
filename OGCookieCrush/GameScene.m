//
//  GameScene.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright (c) 2015 Oktay Bahceci. All rights reserved.
//

#import "GameScene.h"
#import "OGCookie.h"
#import "OGLevel.h"
#import "OGSwap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameScene ()

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *cookiesLayer;
@property (nonatomic, strong) SKNode *tilesLayer;
@property (nonatomic, assign) NSInteger swipeFromColumn;
@property (nonatomic, assign) NSInteger swipeFromRow;
@property (nonatomic, strong) SKSpriteNode *selectionSprite;



@end

@implementation GameScene

- (id)initWithSize:(CGSize)size {
	if ((self = [super initWithSize:size])) {
		
		self.anchorPoint = CGPointMake(0.5, 0.5);
		
		SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
		[self addChild:background];
		
		self.gameLayer = [SKNode node];
		[self addChild:self.gameLayer];
		
		CGPoint layerPosition = CGPointMake(-TileWidth*NumberOfRows/2, -TileHeight*NumberOfRows/2);
		
		self.tilesLayer = [SKNode node];
		self.tilesLayer.position = layerPosition;
		[self.gameLayer addChild:self.tilesLayer];
		
		self.cookiesLayer = [SKNode node];
		self.cookiesLayer.position = layerPosition;
		
		[self.gameLayer addChild:self.cookiesLayer];

		self.swipeFromColumn = self.swipeFromRow = NSNotFound;
		self.selectionSprite = [SKSpriteNode node];
	}
	
	return self;
}

- (void)addTiles {
	for (NSInteger row = 0; row < NumberOfRows; row++) {
		for (NSInteger column = 0; column < NumberOfColumns; column++) {
			if ([self.level tileAtColumn:column row:row] != nil) {
				SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
				tileNode.position = [self pointForColumn:column row:row];
				[self.tilesLayer addChild:tileNode];
			}
		}
	}
}

- (void)addSpritesForCookies:(NSSet *)cookies {
	for (OGCookie *cookie in cookies) {
		SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
		sprite.position = [self pointForColumn:cookie.column row:cookie.row];
		[self.cookiesLayer addChild:sprite];
		cookie.sprite = sprite;
	}
}


- (void)showSelectionIndicatorForCookie:(OGCookie *)cookie {
	if (self.selectionSprite.parent != nil) {
		[self.selectionSprite removeFromParent];
	}
 
	SKTexture *texture = [SKTexture textureWithImageNamed:[cookie highlightedSpriteName]];
	self.selectionSprite.size = texture.size;
	[self.selectionSprite runAction:[SKAction setTexture:texture]];
 
	[cookie.sprite addChild:self.selectionSprite];
	[UIView animateWithDuration:1.0 animations:^{
		self.selectionSprite.alpha = 1.0;
	}];
}


- (void)hideSelectionIndicator {
	[self.selectionSprite runAction:[SKAction sequence:@[
														 [SKAction fadeOutWithDuration:0.3],
														 [SKAction removeFromParent]]]
	 ];
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
	return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}


- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
	NSParameterAssert(column);
	NSParameterAssert(row);
 
	// Is this a valid location within the cookies layer? If yes,
	// calculate the corresponding row and column numbers.
	if (point.x >= 0 && point.x < NumberOfColumns*TileWidth &&
		point.y >= 0 && point.y < NumberOfRows*TileHeight) {
		
		*column = point.x / TileWidth;
		*row = point.y / TileHeight;
		return YES;
		
	} else {
		*column = NSNotFound;  // invalid location
		*row = NSNotFound;
		return NO;
	}
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self.cookiesLayer];
	NSInteger column, row;
	if ([self convertPoint:location toColumn:&column row:&row]) {
		OGCookie *cookie = [self.level cookieAtColumn:column row:row];
		if (cookie != nil) {
			[self showSelectionIndicatorForCookie:cookie];
			self.swipeFromColumn = column;
			self.swipeFromRow = row;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// 1
	if (self.swipeFromColumn == NSNotFound) return;
 
	// 2
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self.cookiesLayer];
 
	NSInteger column, row;
	if ([self convertPoint:location toColumn:&column row:&row]) {
		
		// 3
		NSInteger horzDelta = 0, vertDelta = 0;
		if (column < self.swipeFromColumn) {          // swipe left
			horzDelta = -1;
		} else if (column > self.swipeFromColumn) {   // swipe right
			horzDelta = 1;
		} else if (row < self.swipeFromRow) {         // swipe down
			vertDelta = -1;
		} else if (row > self.swipeFromRow) {         // swipe up
			vertDelta = 1;
		}
		
		// 4
		if (horzDelta != 0 || vertDelta != 0) {
			[self trySwapHorizontal:horzDelta vertical:vertDelta];
			[self hideSelectionIndicator];
			self.swipeFromColumn = NSNotFound;
		}
	}
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
	NSInteger toColumn = self.swipeFromColumn + horzDelta;
	NSInteger toRow = self.swipeFromRow + vertDelta;
	
	if (toColumn < 0 || toColumn >= NumberOfColumns) return;
	if (toRow < 0 || toRow >= NumberOfRows) return;
	
	OGCookie *toCookie = [self.level cookieAtColumn:toColumn row:toRow];
	if(toCookie == nil) return;
	
	OGCookie *fromCookie = [self.level cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
	
	NSLog(@"Swapping %@ with %@", fromCookie, toCookie);
	
	if (self.swipeHandler != nil) {
		OGSwap *swap = [[OGSwap alloc] init];
		swap.cookieA = fromCookie;
		swap.cookieB = toCookie;
		self.swipeHandler(swap);
	}
}

- (void)animateSwap:(OGSwap *)swap completion:(dispatch_block_t)completion {
	// Put the cookie you started with on top.
	swap.cookieA.sprite.zPosition = 100;
	swap.cookieB.sprite.zPosition = 90;
 
	const NSTimeInterval Duration = 0.3;
 
	SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:Duration];
	moveA.timingMode = SKActionTimingEaseOut;
	[swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
 
	SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:Duration];
	moveB.timingMode = SKActionTimingEaseOut;
	[swap.cookieB.sprite runAction:moveB];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.swipeFromColumn = self.swipeFromRow = NSNotFound;
	if (self.selectionSprite.parent != nil && self.swipeFromColumn != NSNotFound) {
		[self hideSelectionIndicator];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
}

@end
