//
//  MyScene.m
//  Demo
//
//  Created by Lucas Mageste on 4/10/14.
//  Copyright (c) 2014 Lucas Mageste. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
#import <AVFoundation/AVFoundation.h>

@interface MyScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) Hero *hero;
@property (nonatomic, strong) SKTextureAtlas *atlas;

@property (nonatomic, strong) SKNode *enemyParentNode;
@property (nonatomic, strong) SKLabelNode *label;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int monsterSpawnRate;
@property (nonatomic, assign) int powerUpSpawnRate;

@property (nonatomic, strong) AVAudioPlayer *backgroundMusicPlayer;
@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        //SCENE_INITIALIZING
        self.physicsWorld.gravity = CGVectorMake(0, -1);
        self.physicsWorld.contactDelegate = self;
        self.monsterSpawnRate = 100;
        self.powerUpSpawnRate = 500;
        self.atlas = [SKTextureAtlas atlasNamed:@"sprites"];
        
        //BACKGROUND_IMAGE
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"8bitBackground"]];
        background.position = CGPointMake(size.width/2, 2*size.height/3);
        [self addChild:background];
        
        //BACKGROUND_MUSIC
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background" withExtension:@"mp3"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
        
        //ENEMY_PARENT_NODE
        self.enemyParentNode = [[SKNode alloc] init];
        [self addChild:self.enemyParentNode];
        
        //SCORE_LABEL
        self.score = 0;
        self.label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.label.position = CGPointMake(size.width/2, size.height-100);
        self.label.text = [NSString stringWithFormat:@"Score: %d", self.score];
        [self addChild:self.label];

        
        //BUTTON_MAKING
        SKSpriteNode *uppercutButton = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"uppercut.png"]];
        uppercutButton.position = CGPointMake(size.width-uppercutButton.size.width, uppercutButton.size.height);
        uppercutButton.name = @"uppercutAction";
        
        SKSpriteNode *fistButton = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"fist.png"]];
        fistButton.position = CGPointMake(size.width-uppercutButton.size.width-fistButton.size.width, fistButton.size.height);
        fistButton.name = @"fistAction";
        
        [self addChild:fistButton];
        [self addChild:uppercutButton];
        
        //BOX_MAKING
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(self.frame.origin.x, self.frame.origin.y + GROUND_LEVEL, self.frame.size.width, self.frame.size.height)];
        self.physicsBody.friction = 0;
        self.physicsBody.categoryBitMask = floorCategory;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsBody.collisionBitMask = 0;
        
        //HERO_MAKING
        self.hero = [[Hero alloc] initWithTexture:[self.atlas textureNamed:[NSString stringWithFormat:HERO_IMAGE_PATH, 0, 0]]];
        self.hero.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        SKAction *idle = [SKAction animateWithTextures:self.hero.sprites[idleAction] timePerFrame:0.2];
        [self.hero runAction:[SKAction repeatActionForever:idle]];
        
        self.hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.hero.size.width/2, self.hero.size.height/2)];
        self.hero.physicsBody.affectedByGravity = YES;
        self.hero.physicsBody.categoryBitMask = heroCategory;
        self.hero.physicsBody.contactTestBitMask = powerUpCategory;
        self.hero.physicsBody.collisionBitMask = floorCategory;
        self.hero.physicsBody.usesPreciseCollisionDetection = NO;
        
        [self addChild:self.hero];

    }
    return self;
}

# pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //TOUCH_HANDLING
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //UPPERCUT_ACTION
    if([node.name isEqualToString:@"uppercutAction"])
    {
        [self.hero performAction:superUppercutAction];
        
    }
    
    //FIST_ACTION
    else if([node.name isEqualToString:@"fistAction"])
    {
        [self.hero performAction:powerShotAction];
    }
    
    //WALK_ACTION
    else if(location.x > self.frame.size.width/2)
    {
        if(!self.hero.isFacingRight)
        {
            self.hero.xScale *= -1;
            //COMENTAR DO BUG DA APPLE
        }
        self.hero.isFacingRight = YES;
        
        self.hero.physicsBody.velocity = CGVectorMake(HERO_VELOCITY, 0);
        [self.hero performAction:walkAction];
    }
    else
    {
        if(self.hero.isFacingRight)
        {
            self.hero.xScale *= -1;
            //COMENTAR DO BUG DA APPLE
        }
        
        self.hero.isFacingRight = NO;
        
        self.hero.physicsBody.velocity = CGVectorMake(-HERO_VELOCITY, 0);
        [self.hero performAction:walkAction];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //TOUCHES_ENDED
    if(!self.hero.isPerformingAction)
    {
        self.hero.physicsBody.velocity = CGVectorMake(0, 0);
        [self.hero performAction:idleAction];
    }
    
}

#pragma Update

-(void)update:(CFTimeInterval)currentTime {
    //ENEMY_SPAWN
    if(arc4random()%self.monsterSpawnRate == 0)
    {
        [self callEnemy];
    }

    //POWER_UP_SPAWN
    if(arc4random()%self.powerUpSpawnRate == 0)
    {
        [self powerUpPopUp];
    }
    
}

#pragma contact

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    //HERO_VS_ENEMY
    if ((firstBody.categoryBitMask & heroCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0)
    {
        Hero *hero = (Hero *)[firstBody node];
        
        if(hero.isPerformingAction)
        {
            [secondBody applyImpulse:CGVectorMake((arc4random()%5 - 2)/10, 5)];
            secondBody.contactTestBitMask = 0;
            
            [secondBody.node runAction:[SKAction group:@[
                                                         [SKAction fadeAlphaBy:-1 duration:0.5],
                                                         [SKAction playSoundFileNamed:@"punch.wav" waitForCompletion:YES]]] completion:^{
                [[secondBody node] removeFromParent];
            }];
            self.score++;
            self.label.text = [NSString stringWithFormat:@"Score: %d", self.score];
        }
        else
        {
            [self presentGameOver];
        }
    }
    
    //HERO_VS_POWERUP
    else if ((firstBody.categoryBitMask & heroCategory) != 0 && (secondBody.categoryBitMask & powerUpCategory) !=0)
    {
        SKAction *fadeOut = [SKAction fadeAlphaBy:-1 duration:0.3];
        
        [self.enemyParentNode runAction:fadeOut completion:^{
            [self.enemyParentNode removeAllChildren];
            self.enemyParentNode.alpha = 1;
        }];
        
        [secondBody.node runAction: [SKAction group:@[[SKAction playSoundFileNamed:@"powerUp.mp3" waitForCompletion:YES],
                                                      [SKAction rotateByAngle:7 duration:2],
                                                      [SKAction fadeAlphaBy:-1 duration:2],
                                                      [SKAction moveByX:0 y:20 duration:2]
                                                      ]]  completion:^{
            [secondBody.node removeFromParent];
        }];
    }
    
}

#pragma mark - GameOver
- (void) presentGameOver
{
    //PRESENT_GAME_OVER
    self.hero.physicsBody.velocity = CGVectorMake(0, 0);
    self.hero.isPerformingAction = YES;
    [self.hero performAction:deadAction];
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:0.6], loseAction]]];

}

#pragma mark - Spawners

- (void) powerUpPopUp
{
    //POWER_UP_CREATION
    SKSpriteNode *powerUp;
    powerUp = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"star.png"]];
    powerUp.position = CGPointMake(arc4random()%(int)self.frame.size.width, GROUND_LEVEL+powerUp.size.height/2 + self.hero.size.height);
    powerUp.alpha = 0;
    
    [self addChild:powerUp];
    
    //POWER_UP_PHYSICS
    powerUp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(powerUp.size.width/2, powerUp.size.height/2)];
    powerUp.physicsBody.categoryBitMask = powerUpCategory;
    powerUp.physicsBody.collisionBitMask = 0;
    powerUp.physicsBody.contactTestBitMask = heroCategory;
    powerUp.physicsBody.affectedByGravity = NO;
    
    //POWER_UP_ACTION
    SKAction *shrink = [SKAction scaleBy:0.5 duration:0.4];
    SKAction *fadeIn = [SKAction fadeAlphaBy:1 duration:0.4];
    SKAction *appear = [SKAction group:@[shrink, fadeIn]];
    
    SKAction *timeToBeViewed = [SKAction waitForDuration:5];
    
    SKAction *enlarge = [SKAction scaleBy:2 duration:0.4];
    SKAction *fadeOut = [SKAction fadeAlphaBy:-1 duration:0.4];
    SKAction *disappear = [SKAction group:@[enlarge, fadeOut]];
    
    
    SKAction *action = [SKAction sequence:@[appear, timeToBeViewed, disappear]];
    [powerUp runAction:action completion:^{
        [powerUp removeFromParent];
    }];
}

- (void) callEnemy
{
    //ENEMY_CREATION
    if(self.monsterSpawnRate>50)
    {
        self.monsterSpawnRate-=5;
    }
    SKSpriteNode *enemy;
    enemy = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"sword.png"]];
    enemy.position = CGPointMake(arc4random()%(int)(self.frame.size.width), arc4random()%(int)(self.frame.size.height-300)+300);
    
    [self.enemyParentNode addChild:enemy];
    
    //ENEMY_PHYSICS
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.affectedByGravity = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.collisionBitMask = 0;
    enemy.physicsBody.contactTestBitMask = heroCategory;
    
    //ENEMY_ACTION
    enemy.anchorPoint = CGPointMake(0.2, 0.5);
    SKAction *rotate = [SKAction rotateByAngle:3 duration:0.5];
    
    [enemy runAction:[SKAction repeatActionForever:rotate]];
    
}

@end
