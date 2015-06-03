//
//  ViewController.m
//  stanley
//
//  Created by Justin Yu on 6/1/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "ViewController.h"
#import <HTPressableButton/HTPressableButton.h>
#import <HTPressableButton/UIColor+HTColor.h>
#import "JYMonitorMessage.h"
#import <SpriteKit/SpriteKit.h>
#import "BabyScene.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic) NSInteger choice; // the choice you are currently on

@property (nonatomic, strong) UIView *monitor;

@property (nonatomic, strong) HTPressableButton *yes;
@property (nonatomic, strong) HTPressableButton *no;

@property (nonatomic, strong) UILabel *message;
@property (nonatomic) NSInteger tapCount;
@property (nonatomic) BOOL countingTaps;

@property (nonatomic) NSInteger error;

@property (nonatomic, strong) SKView *skView;

@property (nonatomic, strong) AVAudioPlayer *player;

@end

#define BUTTON_SIZE 80.

#define FADE_DURATION 0.5f
#define DELAY_DURATION 2.5f

@implementation ViewController

#pragma mark - Animation

+ (void)fadeInView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion {
    
    view.alpha = 0;
    [UIView animateWithDuration:duration delay:delay
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         view.alpha = 1;
                     }
                     completion:completion];
}

+ (void)fadeOutView:(UIView *)view withDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay {
    
    [UIView animateWithDuration:duration delay:delay
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

- (void)clearViewWithDelay:(NSTimeInterval)delay {
    
    for (id object in self.items) {
        if ([object isKindOfClass:[UIView class]]) {
            [ViewController fadeOutView:(UIView *)object withDuration:FADE_DURATION withDelay:delay];
        }
    }
    
    _items = [[NSMutableArray alloc] init];

}

- (void)showInstructions {
    
    JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
    message.text = @"Your job is to press buttons. \nFurther instructions will come from this monitor...";
    [_monitor addSubview:message];
    [_items addObject:message];
    [ViewController fadeInView:message withDuration:FADE_DURATION withDelay:0.5f completion:^(BOOL finished) {
        [self clearViewWithDelay:2.5f];
        [self showChoice:_choice previousDecision:nil];
    }];
}

- (void)showChoice:(NSInteger)choice previousDecision:(BOOL)decision { // true = follow, false = no follow
    
    NSLog(@"Choice: %d, Decision: %@", (int)choice, decision ? @"FOLLOW" : @"NOT FOLLOW");
    if (choice == 0) {
        
        [self clearViewWithDelay:0.5f];
        JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
        message.text = @"Press the green button.";
        [_monitor addSubview:message];
        [_items addObject:message];
        [ViewController fadeInView:message withDuration:0.5f withDelay:2.5f + 1.0f completion:nil];
        _message = message;
        
        HTPressableButton *no = [[HTPressableButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE) buttonStyle:HTPressableButtonStyleCircular];
        no.center = CGPointMake(self.view.center.x + 80, self.view.center.y);
        no.buttonColor = [UIColor ht_alizarinColor];
        no.shadowColor = [UIColor ht_pomegranateColor];
        no.tag = 1;
        _no = no;
        
        [self.view addSubview:no];
        [no addTarget:self action:@selector(makeChoice:) forControlEvents:UIControlEventTouchUpInside];
        [ViewController fadeInView:no withDuration:FADE_DURATION withDelay:3.5 completion:nil];
        
        HTPressableButton *yes = [[HTPressableButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE) buttonStyle:HTPressableButtonStyleCircular];
        yes.center = CGPointMake(self.view.center.x - 80, self.view.center.y);
        yes.buttonColor = [UIColor ht_emeraldColor];
        yes.shadowColor = [UIColor ht_nephritisColor];
        yes.tag = 0;
        _yes = yes;
        
        [yes addTarget:self action:@selector(makeChoice:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:yes];
        [ViewController fadeInView:yes withDuration:FADE_DURATION withDelay:3.5 completion:nil];
        _choice++;
        
    } else if (choice == 1) {
        
        if (decision) { //follow
            [self clearViewWithDelay:0.5f];
            JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
            message.text = @"Good, good! Now, press the red button.";
            [_monitor addSubview:message];
            [_items addObject:message];
            [ViewController fadeInView:message withDuration:0.5f withDelay:1.0f completion:nil];
            _choice++;
        } else { // no follow
            _error++;
            
            NSLog(@"Error: %d", (int)_error);
            if (_error == 1) {
                
                _message.text = @"Press the GREEN button.";
            } else if (_error == 2) {
                CGSize newSize = CGSizeMake(_yes.frame.size.width + 20., _yes.frame.size.height + 20.);
                _yes.frame = CGRectMake(_yes.frame.origin.x, _yes.frame.origin.y, newSize.width, newSize.height);
                _yes.center = CGPointMake(self.view.center.x - 80, self.view.center.y);
            } else if (_error == 3) {
                CGSize newSize = CGSizeMake(_yes.frame.size.width + 40., _yes.frame.size.height + 40.);
                _yes.frame = CGRectMake(_yes.frame.origin.x - newSize.width / 2, _yes.frame.origin.y - newSize.height / 2, newSize.width, newSize.height);
                CGSize newSizeN = CGSizeMake(_no.frame.size.width - 30., _no.frame.size.height - 30.);
                _no.frame = CGRectMake(_no.frame.origin.x - newSizeN.width / 2, _no.frame.origin.y - newSizeN.height / 2, newSizeN.width, newSizeN.height);
                _no.center = CGPointMake(self.view.center.x + 80, self.view.center.y);
                _yes.center = CGPointMake(self.view.center.x - 80, self.view.center.y);
            } else if (_error == 4) {
                _yes.center = self.view.center;
                _no.frame = CGRectMake(self.view.center.x + 120., self.view.center.y + 120., 20., 20.);
            } else if (_error == 5) {
                
                [self clearViewWithDelay:0.2f];

                JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
                message.text = @"OK.\nSince you're so bad at pressing buttons, lets do something that we'll both find a little more productive.";
                [_monitor addSubview:message];
                [_items addObject:message];
                [ViewController fadeInView:message withDuration:0.5f withDelay:1.0f completion:^(BOOL finished) {
                    [self performSelector:@selector(presentBabyGame) withObject:nil afterDelay:2.0];
                }];
                [ViewController fadeOutView:_yes withDuration:0.5f withDelay:0];
                [ViewController fadeOutView:_no withDuration:0.5 withDelay:0];
            }
            
        }
    } else if (choice == 2) {
        
        if (!decision) { //follow
            [self clearViewWithDelay:0.5];
            JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
            message.text = @"Now you're getting the hang of it. Go back to the green button!";
            [_monitor addSubview:message];
            [_items addObject:message];
            [ViewController fadeInView:message withDuration:0.5f withDelay:1.0f completion:nil];
            _choice++;
        }
    } else if (choice == 3) {
        
        if (!_tapCount) {
            [self clearViewWithDelay:0.5f];
        }
        if (decision) { //follow
            
            _countingTaps = YES;
            JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
            message.text = @"Again! 3 times on the green button!";
            [_monitor addSubview:message];
            [_items addObject:message];
            if (_tapCount == 0) {
                [ViewController fadeInView:message withDuration:0.5f withDelay:1.0f completion:nil];
            }
            NSLog(@"TapCount: %d", (int)_tapCount);
            
            if (_tapCount == 3) {
                _choice++;
                _tapCount = 0;
                NSLog(@"3 times");
                [self showChoice:4 previousDecision:YES];
                return;
            }
        }
    } else if (choice == 4) {
        _countingTaps = YES;
        
        if (!_tapCount) {
            [self clearViewWithDelay:0.5f];
        }
        JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
        message.text = @"You're almost done! 10 TIMES ON THE RED BUTTON!";
        [_monitor addSubview:message];
        [_items addObject:message];
        if (!_tapCount) {
            [ViewController fadeInView:message withDuration:0.5f withDelay:1.0f completion:nil];
        }
        if (!decision) {
            _countingTaps = YES;
            if (_tapCount == 10) {
                [self showLoseScreen];
            }
            NSLog(@"TapCount: %d", (int)_tapCount);
        }
    }
}

- (void)presentBabyGame {
    [self clearViewWithDelay:0];

    BabyScene *scene = [[BabyScene alloc] initWithSize:_skView.frame.size];
    _skView.hidden = NO;
    scene.babyDelegate = self;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"baby" ofType:@"mp3"]];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_player play];
    [_skView presentScene:scene];
}

- (void)showLoseScreen {
    
    [self clearViewWithDelay:0.2f];
    
    JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
    message.text = @"YOU LOSE\n\nCongratulations on accomplishing absolutely nothing. Good luck next time!";
    message.font = [UIFont fontWithName:@"Courier-Bold" size:30.0];
    [ViewController fadeInView:message withDuration:0.5f withDelay:0.8f completion:nil];
    [_monitor addSubview:message];
    [_items addObject:message];

    [self restart];
}

- (void)restart {
    
    
}

- (void)makeChoice:(id)sender {
    
    if (_countingTaps) {
        _tapCount++;
    } else {
        _tapCount = 0;
    }
    if ([sender isKindOfClass:[HTPressableButton class]]) {
        HTPressableButton *button = (HTPressableButton *)sender;
        if (button.tag == 0) { // correct
            [self showChoice:_choice previousDecision:YES];
        } else if (button.tag == 1) {
            [self showChoice:_choice previousDecision:NO];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _items = [[NSMutableArray alloc] init];
    _tapCount = 0;
    _countingTaps = NO;
    _choice = 0;
    _error = 0;
    
    _skView = [[SKView alloc] initWithFrame:self.view.frame];
    _skView.hidden = YES;

    self.view.backgroundColor = [UIColor ht_leadDarkColor];
    
    _monitor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    _monitor.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_monitor];
    [self.view addSubview:_skView];
    [self showInstructions];
}

- (void)didFinish {
    [_player stop];
    [_skView removeFromSuperview];
    _skView = [[SKView alloc] init];
    _skView.hidden = YES;

    JYMonitorMessage *message = [[JYMonitorMessage alloc] initWithSuperview:_monitor];
    message.text = @"You heartless person.\n\nIf you keep intentionally screwing up every aspect of this game, why play at all?\nHow about this, YOU WIN. Thanks for playing.";
    message.font = [UIFont fontWithName:@"Courier" size:20.0];
    [ViewController fadeInView:message withDuration:0.8f withDelay:0 completion:nil];
    [_monitor addSubview:message];
    [_items addObject:message];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
