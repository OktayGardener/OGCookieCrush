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

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameScene ()

@property (nonatomic, strong) SKNode *gameLayer;
@property (nonatomic, strong) SKNode *cookiesLayer;
@property (nonatomic, strong) SKNode *tilesLayer;
@property (nonatomic, assign) NSInteger swipeFromColumn;
@property (nonatomic, assign) NSInteger swipeFromRow;


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

-(CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
	return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}

-(void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self.cookiesLayer];
	
	NSInteger column, row;
	
	if ([self convertPoint:location toColumn:&column row:&row]) {
		
		OGCookie *cookie = [self.level cookieAtColumn:column row:row];
		if (cookie != nil) {
			self.swipeFromColumn = column;
			self.swipeFromRow = row;
		}
	}
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
	NSParameterAssert(column);
	NSParameterAssert(row);
	
	if (point.x >= 0 && point.x < NumberOfColumns*TileWidth && point.y >= 0 && point.y < NumberOfRows * TileHeight) {
		*column = point.x / TileWidth;
		*row = point.y / TileHeight;
		return YES;
	} else {
		*column = NSNotFound;
		*row = NSNotFound;
		return NO;
	}
}

@end
