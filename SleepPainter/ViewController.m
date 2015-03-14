//
//  ViewController.m
//  SleepPainter
//
//  Created by Shanshan ZHAO on 24/02/15.
//  Copyright (c) 2015 Shanshan ZHAO. All rights reserved.
//

#import "ViewController.h"
#import "jellyEffectView.h"
#import "SleepPainterAlarmSlider.h"

#define CHANGE_SKY_INTERVAL              10
#define ALARM_HOUR_SLIDER_SIZE           140
#define ALARM_MINUTES_SLIDER_SIZE        240
#define ALARM_BUTTON_MARGIN              20
#define ALARM_BUTTON_HEIGHT              50

@interface ViewController ()
{
    int dummyToggle; // for background image change
}

@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UIButton *homeSetAlarmButton;

// jelly effect view with alarm
@property (strong, nonatomic) IBOutlet UIView *sideHelperView;
@property (strong, nonatomic) IBOutlet UIView *centerHelperView;
@property (weak, nonatomic) IBOutlet jellyEffectView *jellyEffectView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jellyViewTopConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideViewTopConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerViewTopConstrain;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property  NSInteger animationCount; // 动画的数量

//slider
@property (strong,nonatomic)SleepPainterAlarmSlider * hourSlider;
@property (strong,nonatomic)SleepPainterAlarmSlider * minutesSlider;
@property (nonatomic) int alarmDuration;
@property (nonatomic,strong) UILabel * wakeUpLabel;
@property (nonatomic,strong) NSString * hour;
@property (nonatomic,strong) NSString * min;

@property (weak, nonatomic) IBOutlet UILabel *drawYourDreamLabel;
@property (weak, nonatomic) IBOutlet UIButton *goImagesPageButton;


@end

@implementation ViewController


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.animationCount = 0;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.animationCount = 0;
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
    dummyToggle = 0;
    [self updateClock];
    [self configOwlButton];
    [self configureImageButton];
    
    self.sideViewTopConstrain.constant   = 0;
    self.centerViewTopConstrain.constant = 0;
    self.jellyViewTopConstrain.constant  = 0;
    
    self.sideHelperView.hidden   = YES;
    self.centerHelperView.hidden = YES;

}


#pragma mark - update clock and background image
- (void)updateClock
{
    NSDateFormatter *clockFormat = [[NSDateFormatter alloc] init];
    [clockFormat setDateFormat:@"HH:mm:ss a"];
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
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_5am.png"]]];
            break;
        case 1:
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
            break;
        default:
            break;
    }
    dummyToggle = 1 - dummyToggle;
}

#pragma mark - configure two owl buttons and jelly view

-(void)configOwlButton
{
    [self.homeSetAlarmButton setTitle:@" ,___,\n(︶,︶)..zZ\n /)__ )\n   \"  \"" forState:UIControlStateNormal];
}

-(void)configureImageButton
{
    [self.goImagesPageButton setTitle:@"        ,___,\n ★.*(⌒,⌒)‧:*‧°★*\n        /)__ )\n          \"  \"" forState:UIControlStateNormal];
}

#pragma mark - actions

- (IBAction)clickOwlToSetAlarm:(id)sender
{
    self.goImagesPageButton.hidden = YES;
    self.drawYourDreamLabel.hidden = YES;
    
    CGFloat actionSheetHeight = CGRectGetHeight(self.jellyEffectView.frame);
    CGFloat hiddenTopMargin   = 0;                  //隐藏在下面的时候，这个距离为0
    CGFloat showedTopMargin   = -actionSheetHeight; //滑到上面的时候，这个距离就是ActionSheet的高度
    CGFloat newTopMargin      = abs(self.centerViewTopConstrain.constant - hiddenTopMargin) < 1 ? showedTopMargin : hiddenTopMargin;
    if (newTopMargin == 0)
    {
        self.goImagesPageButton.hidden = NO;
        self.drawYourDreamLabel.hidden = NO;
    }
    //如果中间那个辅助小方块藏在下面时，那么它的下一个位置就是在（-actionSheetHeight）的位置，所以，设置新的约束值（newTopMargin = -actionSheetHeight）,即：（newTopMargin = showedTopMargin）;
    //只要小方块在上方，那么它的下一个位置就是回到底部隐藏的位置，也就是新的约束值newTopMargin ＝ hiddenTopMargin.
    
    //先处理旁边那个辅助方块的约束
    self.sideViewTopConstrain.constant = newTopMargin;
    [self beforeAnimation];
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.9f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.sideHelperView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    
    //再处理中间那个辅助方块的约束
    self.centerViewTopConstrain.constant = newTopMargin;
    [self beforeAnimation];
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:2.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.centerHelperView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    
    [self configureJellyView];
}

-(void)newHourValue
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSInteger hours = ABS(offset(self.hourSlider.angle)/30);
    
    NSDate * wakeTime = [localeDate dateByAddingTimeInterval:hours * 60 * 60];
    NSDateFormatter * hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH"];
    
    self.hour = [NSString stringWithFormat:@"%@",[hourFormatter stringFromDate:wakeTime]];
    self.wakeUpLabel.text = [NSString stringWithFormat:@"%@:%@",self.hour ,self.min? self.min :@""];
}

-(void)newMinsValue
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSInteger mins = ABS(offset(self.minutesSlider.angle)/6);
    
    NSDate * wakeTime = [localeDate dateByAddingTimeInterval:mins * 60];
    NSDateFormatter * minsFormatter = [[NSDateFormatter alloc] init];
    [minsFormatter setDateFormat:@"mm"];
    
    self.min = [NSString stringWithFormat:@"%@",[minsFormatter stringFromDate:wakeTime]];
    self.wakeUpLabel.text = [NSString stringWithFormat:@"%@:%@",self.hour ? self.hour : @"" ,self.min];
}


#pragma mark - configure jelly view and animations

-(void)configureJellyView
{
    if (!self.minutesSlider)
    {
        self.minutesSlider = [[SleepPainterAlarmSlider alloc] initWithFrame:CGRectMake((self.jellyEffectView.frame.size.width - ALARM_MINUTES_SLIDER_SIZE)/2, 40, ALARM_MINUTES_SLIDER_SIZE, ALARM_MINUTES_SLIDER_SIZE)];
        [self.jellyEffectView addSubview:self.minutesSlider];
        [self.minutesSlider addTarget:self action:@selector(newMinsValue) forControlEvents:UIControlEventValueChanged];
    }
    
    if (!self.hourSlider)
    {
        self.hourSlider = [[SleepPainterAlarmSlider alloc] initWithFrame:CGRectMake((self.jellyEffectView.frame.size.width - ALARM_HOUR_SLIDER_SIZE)/2, 90, ALARM_HOUR_SLIDER_SIZE, ALARM_HOUR_SLIDER_SIZE)];
        [self.jellyEffectView addSubview:self.hourSlider];
        [self.hourSlider addTarget:self action:@selector(newHourValue) forControlEvents:UIControlEventValueChanged];
    }
    
    if (!self.wakeUpLabel)
    {
        self.wakeUpLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.jellyEffectView.frame.size.width - 100)/2, 120, 85, 70)];
        self.wakeUpLabel.center = self.hourSlider.center;
        [self.wakeUpLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:23.]];
        self.wakeUpLabel.textColor = [UIColor whiteColor];
        self.wakeUpLabel.textAlignment = NSTextAlignmentCenter;
        [self.jellyEffectView addSubview:self.wakeUpLabel];
    }
    
    UIButton * setAlarmButton = [UIButton new];
    [setAlarmButton setFrame:CGRectMake(ALARM_BUTTON_MARGIN, ALARM_MINUTES_SLIDER_SIZE + ALARM_BUTTON_MARGIN*2, self.jellyEffectView.frame.size.width/2 - ALARM_BUTTON_MARGIN , ALARM_BUTTON_HEIGHT)];
    [setAlarmButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [setAlarmButton setTitle:@"Set Wake Time" forState:UIControlStateNormal];
    [setAlarmButton addTarget:self action:@selector(clickToSetAlarm) forControlEvents:UIControlEventTouchUpInside];
    
    [self.jellyEffectView addSubview:setAlarmButton];
    
    UIButton * cancelButton = [UIButton new];
    [cancelButton setFrame:CGRectMake(self.jellyEffectView.frame.size.width/2+2 , ALARM_MINUTES_SLIDER_SIZE + ALARM_BUTTON_MARGIN*2, self.jellyEffectView.frame.size.width/2 - ALARM_BUTTON_MARGIN, ALARM_BUTTON_HEIGHT)];
    [cancelButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(clickToCancelAlarm) forControlEvents:UIControlEventTouchUpInside];
    [self.jellyEffectView addSubview:cancelButton];
}

-(void)beforeAnimation
{
    if (self.displayLink == nil)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    self.animationCount ++;
}

//动画完成之后调用
-(void)finishAnimation
{
    self.animationCount --;
    if (self.animationCount == 0)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

//实时刷新路径
-(void)displayLinkAction:(CADisplayLink *)dis
{
    CALayer *sideHelperPresentationLayer   =  (CALayer *)[self.sideHelperView.layer presentationLayer];
    CALayer *centerHelperPresentationLayer =  (CALayer *)[self.centerHelperView.layer presentationLayer];
    
    CGPoint position = [[centerHelperPresentationLayer valueForKeyPath:@"position"]CGPointValue];
    
    CGRect centerRect = [[centerHelperPresentationLayer valueForKeyPath:@"frame"]CGRectValue];
    CGRect sideRect = [[sideHelperPresentationLayer valueForKeyPath:@"frame"]CGRectValue];
    
//    NSLog(@"Center:%@",NSStringFromCGRect(centerRect));
//    NSLog(@"Side:%@",NSStringFromCGRect(sideRect));
    
    CGFloat newJellyViewTopConstraint      =  position.y - CGRectGetMaxY(self.view.frame);
    
    self.jellyViewTopConstrain.constant = newJellyViewTopConstraint;
    [self.jellyEffectView layoutIfNeeded];
    
    self.jellyEffectView.sideToCenterDelta = centerRect.origin.y - sideRect.origin.y;
    [self.jellyEffectView setNeedsDisplay];
}


#pragma mark - alarm notificaion
-(void)clickToSetAlarm
{
    // this date will be replace by alarm user set
    NSDate *currentDate = [NSDate date];
    NSDate *datePlusOneMinute = [currentDate dateByAddingTimeInterval:60];
    
    [self configureLocalNotificationWithData:datePlusOneMinute];
    [self presentMessage:[NSString stringWithFormat:@"Go Sleep zZZZ.. Wake up at %@",currentDate]];
    
}

-(void)clickToCancelAlarm
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self presentMessage:@"Keep awake"];
}

- (void)configureLocalNotificationWithData:(NSDate*)date
{
    UILocalNotification * localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    
    localNotif.alertBody = @"Look at what you've done during sleeping..";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSLog(@"notification fire date %@",date);
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)presentMessage:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sleep Painter"
                                                     message:message delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
}


@end
