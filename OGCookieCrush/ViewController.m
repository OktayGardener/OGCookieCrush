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
#import "OGChain.h"

@interface ViewController ()

@property (nonatomic, strong) OGLevel *level;
@property (nonatomic, strong) GameScene *scene;

@property (nonatomic, assign) NSUInteger movesLeft;
@property (nonatomic, assign) NSUInteger score;

@property (nonatomic, weak) IBOutlet UILabel *targetLabel;
@property (nonatomic, weak) IBOutlet UILabel *movesLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;

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
 
	id block = ^(OGSwap *swap) {
		self.view.userInteractionEnabled = NO;
		if ([self.level isPossibleSwap:swap]) {
			[self.level performSwap:swap];
			[self.scene animateSwap:swap completion:^{
				[self handleMatches];
				self.view.userInteractionEnabled = YES;
			}];
		} else {
			[self.scene animateInvalidSwap:swap completion:^{
			self.view.userInteractionEnabled = YES;
			}];
		}
	};

	self.scene.swipeHandler = block;
	
	// Present the scene.
	[skView presentScene:self.scene];
 
	// Let's start the game!
	[self beginGame];
}

- (void)updateLabels {
	self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
	self.movesLabel.text = [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
	self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)self.score];
}

- (BOOL)shouldAutorotate
{
    return NO;
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
	self.movesLeft = self.level.maximumMoves;
	self.score = 0;
	[self updateLabels];
	[self shuffle];
}

- (void)handleMatches {
	NSSet *chains = [self.level removeMatches];
	
	if ([chains count] == 0) {
		[self beginNextTurn];
		return;
	}
	
	[self.scene animateMatchedCookies:chains completion:^{
		for (OGChain *chain in chains) {
			self.score += chain.score;
		}
		[self updateLabels];
  NSArray *columns = [self.level fillHoles];
  [self.scene animateFallingCookies:columns completion:^{
	  NSArray *columns = [self.level fillNewCookies];
	  [self.scene animateNewCookies:columns completion:^{
		  [self handleMatches];
	  }];
  }];
	}];
}

- (void)shuffle {
	NSSet *newCookies = [self.level shuffle];
	[self.scene addSpritesForCookies:newCookies];
}

- (void)beginNextTurn {
	[self.level detectPossibleSwaps];
	self.view.userInteractionEnabled = YES;
}

@end
