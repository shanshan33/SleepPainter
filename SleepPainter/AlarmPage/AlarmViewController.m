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
#define ALARM_HOUR_SLIDER_SIZE           140
#define ALARM_MINUTES_SLIDER_SIZE        240


@interface AlarmViewController ()
{
    int dummyToggle; // to test sky image changing
}


@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *AlarmInfoLabel;

@property (strong,nonatomic)SleepPainterAlarmSlider * hourSlider;
@property (strong,nonatomic)SleepPainterAlarmSlider * minutesSlider;
@property (nonatomic) int alarmDuration;
@property (nonatomic, strong)NSDateFormatter * alarmPannelFormatter;
@property (nonatomic, strong)NSString * awakeHour;
@property (nonatomic, strong)NSString * awakeMins;

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
    self.awakeMins = @"0";
    self.awakeHour = @"0";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
    
    // Set up alarm panel
    NSDateFormatter *alarmFormat = [[NSDateFormatter alloc] init];
    [alarmFormat setDateFormat:@"h m  a"];
    self.AlarmInfoLabel.text = [NSString stringWithFormat:@"WAKE UP AT TODAY %@\n\nYOU HAVE %@ hr %@ min", [alarmFormat stringFromDate:[NSDate date]], self.awakeHour, self.awakeMins];
    
    //big slider to set mins
    self.minutesSlider = [[SleepPainterAlarmSlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - ALARM_HOUR_SLIDER_SIZE)/2, self.AlarmInfoLabel.frame.origin.y+ self.AlarmInfoLabel.frame.size.height + 30, ALARM_HOUR_SLIDER_SIZE, ALARM_HOUR_SLIDER_SIZE)];
    
    [self.minutesSlider addTarget:self action:@selector(newMinsValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.minutesSlider];
    
    // small slider to set hour
    self.hourSlider = [[SleepPainterAlarmSlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - ALARM_MINUTES_SLIDER_SIZE)/2, self.minutesSlider.center.y - ALARM_MINUTES_SLIDER_SIZE/2, ALARM_MINUTES_SLIDER_SIZE, ALARM_MINUTES_SLIDER_SIZE)];
    
    [self.hourSlider addTarget:self action:@selector(newHourValue) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.hourSlider];
    
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
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_3am.png"]]];
            break;
        case 1:
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
            break;
        default:
            break;
    }
    dummyToggle = 1 - dummyToggle;
}

-(void)newHourValue
{
    self.alarmDuration = 1440 - offset2(self.hourSlider.angle) * 4; // min
    NSDate * wakeTime = [[NSDate date] dateByAddingTimeInterval:self.alarmDuration * 60];
    NSDateFormatter * hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"hh"];
    
    self.awakeHour = [hourFormatter stringFromDate:wakeTime];
    
    NSString *dayDescription = @"TODAY";
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"d"];
    if ([[dayFormat stringFromDate:[NSDate date]] intValue] != [[dayFormat stringFromDate: [[NSDate date] dateByAddingTimeInterval:self.alarmDuration * 60]] intValue])
    {
        dayDescription = @"TOMORROW";
    }
    
    self.AlarmInfoLabel.text = [NSString stringWithFormat:@"WAKE ME UP AT %@\n\n%@H%@\n\nSLEEPING TIME:%d hr %d min", dayDescription,self.awakeHour,self.awakeMins ,self.alarmDuration/60, self.alarmDuration % 60];
    
    NSLog(@"wake time after set hours: %@",wakeTime);

    
}

-(void)newMinsValue
{
    self.alarmDuration = 360 - offset2(self.minutesSlider.angle)/4 ; // min
    NSDate * wakeTime = [[NSDate date] dateByAddingTimeInterval:self.alarmDuration *60];
    NSDateFormatter * minsFormatter = [[NSDateFormatter alloc] init];
    [minsFormatter setDateFormat:@"mm"];
    
    self.awakeMins = [minsFormatter stringFromDate:wakeTime];
    NSString *dayDescription = @"TODAY";
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"d"];
    if ([[dayFormat stringFromDate:[NSDate date]] intValue] != [[dayFormat stringFromDate: [[NSDate date] dateByAddingTimeInterval:self.alarmDuration * 60]] intValue])
    {
        dayDescription = @"TOMORROW";
    }
    
    self.AlarmInfoLabel.text = [NSString stringWithFormat:@"WAKE ME UP AT %@\n\n%@H%@\n\nSLEEPING TIME:%d hr %d min", dayDescription,self.awakeHour, self.awakeMins,self.alarmDuration/60, self.alarmDuration % 60];
    NSLog(@"wake time after set mins: %@",wakeTime);
    
}

#pragma set alarm actions
- (IBAction)setAlarmAction:(id)sender
{
    NSDate *currentDate = [NSDate date];
    NSDate *datePlusOneMinute = [currentDate dateByAddingTimeInterval:60];

    [self configureLocalNotificationWithData:datePlusOneMinute];
    NSLog(@"alarm time %@",datePlusOneMinute);

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
