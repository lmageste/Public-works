//
//  Constants.h
//  Demo
//
//  Created by Lucas Mageste on 4/10/14.
//  Copyright (c) 2014 Lucas Mageste. All rights reserved.
//

#ifndef Demo_Constants_h
#define Demo_Constants_h

#define heroCategory 0x1 << 0
#define enemyCategory 0x1 << 1
#define floorCategory 0x1 << 2
#define powerUpCategory 0x1 << 3

#define HERO_IMAGE_PATH @"cat%d-%d"
#define HERO_SIZE 50
#define NUMBER_OF_HERO_ACTIONS 5
#define HERO_VELOCITY 100

#define GROUND_LEVEL 100

typedef enum {walkAction = 0, idleAction = 1, deadAction = 2, powerShotAction = 3, superUppercutAction = 4} HERO_ACTION;

#endif
