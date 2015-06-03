//
//  BabyScene.h
//  stanley
//
//  Created by Justin Yu on 6/2/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol BabySceneDelegate <NSObject>

@optional
- (void)didFinish;

@end

@interface BabyScene : SKScene

@property (nonatomic, strong) id<BabySceneDelegate> babyDelegate;

@end
