//
//  Hero.m
//  Demo
//
//  Created by Lucas Mageste on 4/10/14.
//  Copyright (c) 2014 Lucas Mageste. All rights reserved.
//

#import "Hero.h"

int numberOfSpritesInAction[] = {4, 4, 10, 19, 18};

@implementation Hero

- (id) init
{
    self = [super init];
    [self customInitiation];
    return self;
}

- (id) initWithTexture:(SKTexture *)texture
{
    self = [super initWithTexture:texture];
    [self customInitiation];
    return self;
}

//CUSTOM_HERO_INIT
- (void) customInitiation
{
    if(self)
    {
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
        self.sprites = [[NSMutableArray alloc] init];
        self.isFacingRight = YES;
        self.isPerformingAction = NO;
        
        for(int i=0; i<NUMBER_OF_HERO_ACTIONS; i++)
        {
            NSMutableArray *temp = [NSMutableArray array];
            for(int j=0; j<numberOfSpritesInAction[i]; j++)
            {
                [temp addObject:[atlas textureNamed:[NSString stringWithFormat:HERO_IMAGE_PATH, i, j]]];
            }
            [self.sprites addObject:temp];
        }
    }
}

//PERFORM_HERO_ACTION
- (void) performAction: (HERO_ACTION) action
{
    if(action == superUppercutAction)
    {
        self.isPerformingAction = YES;
        self.physicsBody.affectedByGravity = NO;
        
        SKAction *uppercut = [SKAction animateWithTextures:self.sprites[action] timePerFrame:0.1];
        SKAction *jump = [SKAction moveByX:0 y:HERO_SIZE duration:0.6];
        SKAction *sound = [SKAction playSoundFileNamed:@"shoryuken.mp3" waitForCompletion:NO];
        jump.timingMode = SKActionTimingEaseOut;
        SKAction *wait = [SKAction waitForDuration:0.3];
        SKAction *go = [SKAction sequence:@[wait, [SKAction group:@[jump, sound]], jump.reversedAction]];
        
        [self runAction:[SKAction group:@[go, uppercut]] completion:^{
            self.physicsBody.affectedByGravity = YES;
            self.isPerformingAction = NO;
        }];
    }
    else if (action == powerShotAction)
    {
        self.isPerformingAction = YES;
        
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *move;
        if(self.isFacingRight)
            move = [SKAction moveByX:100 y:0 duration:0.9];
        else
            move = [SKAction moveByX:-100 y:0 duration:0.9];
        move.timingMode = SKActionTimingEaseInEaseOut;
        SKAction *sound = [SKAction playSoundFileNamed:@"hadouken.mp3" waitForCompletion:NO];
        SKAction *animate = [SKAction animateWithTextures:self.sprites[action] timePerFrame:0.1];
        
        [self runAction:[SKAction group:@[animate, [SKAction sequence:@[wait, [SKAction group:@[move, sound]]]]]] completion:^{
            self.isPerformingAction = NO;
        }];
    }
    else if(action == idleAction || action == walkAction)
        [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.sprites[action] timePerFrame:0.1]]];
    else
        [self runAction:[SKAction animateWithTextures:self.sprites[action] timePerFrame:0.1]];
}

@end
