//
//  AlarmViewController.m
//  SleepPainter
//
//  Created by Shanshan ZHAO on 25/02/15.
//  Copyright (c) 2015 Shanshan ZHAO. All rights reserved.
//

#import "AlarmViewController.h"
#import "SleepPainterAlarmSlider.h"

#define CHANGE_SKY_INTERVAL 10

@interface AlarmViewController ()
{
    int dummyToggle; // to test sky image changing
}


@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *AlarmInfoLabel;

@property (strong,nonatomic)SleepPainterAlarmSlider * alarmSlider;
@property (nonatomic) int alarmDuration;
@property (nonatomic, strong)NSDateFormatter * alarmPannelFormatter;

- (IBAction)setAlarmAction:(id)sender;
- (IBAction)cancelAlarmAction:(id)sender;
- (void)configureLocalNotificationWithData:(NSDate*)date;
- (void)presentMessage:(NSString *)message;


@end

@implementation AlarmViewController


#pragma view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    dummyToggle = 0;
    [self updateClockLabel];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_backgroundDark.png"]]];
    
    // Set up alarm panel
    NSDateFormatter *alarmFormat = [[NSDateFormatter alloc] init];
    [alarmFormat setDateFormat:@"h m  a"];
    self.AlarmInfoLabel.text = [NSString stringWithFormat:@"WAKE UP AT TODAY %@\n\nYOU HAVE %d hr %d min\n\nGOOD NIGHT", [alarmFormat stringFromDate:[NSDate date]], 0, 0];
    
    self.alarmSlider = [[SleepPainterAlarmSlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - ALARM_SLIDER_SIZE)/2, self.AlarmInfoLabel.frame.origin.y+ self.AlarmInfoLabel.frame.size.height + 30, ALARM_SLIDER_SIZE, ALARM_SLIDER_SIZE)];
    
    [self.alarmSlider addTarget:self action:@selector(newAlarmValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.alarmSlider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - update clock and background image
- (void)updateClockLabel
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
    [self performSelector:@selector(updateClockLabel) withObject:self afterDelay:1.0f];
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

- (void)newAlarmValue
{
    //NSLog(@"New Alarm Value %d", self.alarmSlider.angle);
    
    self.alarmDuration = 1440 - offset2(self.alarmSlider.angle) * 4;
    NSDate * wakeTime = [[NSDate date] dateByAddingTimeInterval:self.alarmDuration * 60];
    
    self.alarmPannelFormatter = [[NSDateFormatter alloc] init];
    [self.alarmPannelFormatter setDateFormat:@"h mm  a"];
    
    NSString *dayDescription = @"TODAY";
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"d"];
    if ([[dayFormat stringFromDate:[NSDate date]] intValue] != [[dayFormat stringFromDate:wakeTime] intValue])
    {
        dayDescription = @"TOMORROW";
    }
    
    self.AlarmInfoLabel.text = [NSString stringWithFormat:@"WAKE ME UP AT \n\n%@ %@\n\nYOU HAVE %d hr %d min", dayDescription,[self.alarmPannelFormatter stringFromDate:wakeTime], self.alarmDuration/60, self.alarmDuration % 60];
}

#pragma set alarm actions
- (IBAction)setAlarmAction:(id)sender
{
    NSInteger interval = [[NSTimeZone localTimeZone] secondsFromGMTForDate: [NSDate date]];
    NSDate *localDate = [[NSDate date] dateByAddingTimeInterval: interval];
    NSDate * alarmTime = [localDate dateByAddingTimeInterval:self.alarmDuration * 60];

    [self configureLocalNotificationWithData:alarmTime];
    NSLog(@"alarm time %@",alarmTime);

    [self presentMessage:@"ALARM SET"];
}

- (IBAction)cancelAlarmAction:(id)sender
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self presentMessage:@"ALARM CANCEL"];

}

- (void)configureLocalNotificationWithData:(NSDate*)date
{
    UILocalNotification * localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;

    localNotif.alertBody = @"Time to wake up";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSLog(@"notification fire date %@",date);
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)presentMessage:(NSString *)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"SLEEP PAINTER ALARM "
                                                     message:message delegate:nil
                                           cancelButtonTitle:@"ok" otherButtonTitles:nil];
    
    [alert show];
    
}



@end
