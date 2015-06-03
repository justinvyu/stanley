//
//  JYMonitorMessage.m
//  stanley
//
//  Created by Justin Yu on 6/2/15.
//  Copyright (c) 2015 Justin Yu. All rights reserved.
//

#import "JYMonitorMessage.h"

@implementation JYMonitorMessage

- (instancetype)initWithSuperview:(UIView *)view {
    
    if (self = [super init]) {
        
        self.numberOfLines = 0;
        self.frame = CGRectMake(5, 5, view.frame.size.width - 10, view.frame.size.height - 10);
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"Courier" size:20.];
        self.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

@end
