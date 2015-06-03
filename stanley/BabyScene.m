//
//  BabyScene.m
//  stanley
//
//  Created by Justin Yu on 6/2/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "BabyScene.h"
#import <HTPressableButton/UIColor+HTColor.h>

@interface BabyScene ()

@property (nonatomic, strong) SKSpriteNode *baby;

@end

@implementation BabyScene

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [UIColor ht_cloudsColor];
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    [super didMoveToView:view];
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    title.fontColor = [UIColor blackColor];
    title.text = @"Tap to save the baby!";
    title.fontSize = 20.0;
    title.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    title.position = CGPointMake(0, 230);
    [self addChild:title];
    
    SKSpriteNode *baby = [[SKSpriteNode alloc] initWithImageNamed:@"baby"];
    baby.size = CGSizeMake(200., 120.);
    baby.position = CGPointMake(0, 200);
    [self addChild:baby];
    _baby = baby;
    
    SKAction *moveDown = [SKAction moveToY:-200 duration:3.0f];
    [baby runAction:moveDown completion:^{
        [self done];
    }];
    
    SKSpriteNode *fire = [[SKSpriteNode alloc] initWithImageNamed:@"fire"];
    fire.size = CGSizeMake(300, 80);
    fire.position = CGPointMake(0, -200);
    [self addChild:fire];
    
//    SKAction *audio = [SKAction playSoundFileNamed:@"baby.mp3" waitForCompletion:YES];
//    [self runAction:[SKAction repeatActionForever:audio] withKey:@"audio"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [_baby removeAllActions];
    SKAction *moveDown = [SKAction moveToY:-200 duration:3.0f];
    SKAction *moveToTop = [SKAction moveTo:CGPointMake(0, 200) duration:0.3f];
    [_baby runAction:[SKAction sequence:@[moveToTop, moveDown]] completion:^{
        [self done];
    }];
}

- (void)done {
    
    [self removeActionForKey:@"audio"];
    [self.babyDelegate didFinish];
}

@end
