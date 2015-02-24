//
//  ViewController.m
//  SleepPainter
//
//  Created by Shanshan ZHAO on 24/02/15.
//  Copyright (c) 2015 Shanshan ZHAO. All rights reserved.
//

#import "ViewController.h"

#define CHANGE_SKY_INTERVAL 10

@interface ViewController ()
{
    int dummyToggle; // to test sky image changing
}

@property (weak, nonatomic) IBOutlet UILabel *clockLabel;

@end

@implementation ViewController


#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dummyToggle = 0;
    [self updateClock];
}


#pragma mark - update clock and background image
- (void)updateClock
{
    NSDateFormatter *clockFormat = [[NSDateFormatter alloc] init];
    [clockFormat setDateFormat:@"h mm ss a"];
    self.clockLabel.text = [clockFormat stringFromDate:[NSDate date]];
    
    // Test background image changing
    [clockFormat setDateFormat:@"s"];
    int seconds = [[clockFormat stringFromDate:[NSDate date]] intValue];
    if (seconds % CHANGE_SKY_INTERVAL == 0)
    {
        [self updateBackgroundImage];
    }
    //
    [self performSelector:@selector(updateClock) withObject:self afterDelay:1.0f];
}

- (void)updateBackgroundImage
{
    NSLog(@"Update background image");
    
    // Add animation
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.delegate = self;
    [self.view.layer addAnimation:animation forKey:nil];
    
    // Do dummy action, changing image every ten seconds
    switch (dummyToggle) {
        case 0:
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_backgroundlight.png"]]];
            break;
        case 1:
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_backgroundDark.png"]]];
            break;
        default:
            break;
    }
    dummyToggle = 1 - dummyToggle;
    
}

@end
