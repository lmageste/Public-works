//
//  Hero.h
//  Demo
//
//  Created by Lucas Mageste on 4/10/14.
//  Copyright (c) 2014 Lucas Mageste. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface Hero : SKSpriteNode

@property (nonatomic, strong) NSMutableArray *sprites;
@property (nonatomic, assign) BOOL isFacingRight;
@property (nonatomic, assign) BOOL isPerformingAction;

- (void) performAction: (HERO_ACTION) action;

@end
