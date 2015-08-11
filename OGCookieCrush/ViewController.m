//
//  GameViewController.m
//  OGCookieCrush
//
//  Created by Oktay Bahceci on 11/08/2015.
//  Copyright (c) 2015 Oktay Bahceci. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "OGLevel.h"

@interface ViewController ()

@property (nonatomic, strong) OGLevel *level;
@property (nonatomic, strong) GameScene *scene;

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
 
	// Configure the view.
	SKView *skView = (SKView *)self.view;
	skView.multipleTouchEnabled = NO;
 
	// Create and configure the scene.
	self.scene = [GameScene sceneWithSize:skView.bounds.size];
	self.scene.scaleMode = SKSceneScaleModeAspectFill;
 
	// Load the level.
	self.level = [[OGLevel alloc] initWithFile:@"Level_1"];
	self.scene.level = self.level;
	
	[self.scene addTiles];
 
	// Present the scene.
	[skView presentScene:self.scene];
 
	// Let's start the game!
	[self beginGame];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)beginGame {
	[self shuffle];
}

- (void)shuffle {
	NSSet *newCookies = [self.level shuffle];
	[self.scene addSpritesForCookies:newCookies];
}


@end
