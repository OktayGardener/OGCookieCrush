//
//  OGCookie.h
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright © 2015 Oktay Bahceci. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static const NSUInteger NumberOfCookieTypes = 6;

@interface OGCookie : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSUInteger cookieType;
@property (nonatomic, assign) SKSpriteNode *sprite;


- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end
