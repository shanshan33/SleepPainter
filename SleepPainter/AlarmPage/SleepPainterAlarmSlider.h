//
//  SleepPainterAlarmSlider.h
//  SleepPainter
//
//  Modified by Shanshan ZHAO on 25/02/15.
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALARM_SLIDER_SIZE           190
#define ALARM_SLIDER_PATH           1.0
#define ALARM_SLIDER_HANDLE         18
#define ALARM_SLIDER_PADDING        20
#define ALARM_SLIDER_ANGLEOFFSET    180
#define offset2(deg)                ( ((deg) + 360 - ALARM_SLIDER_ANGLEOFFSET) % 360 )
#define offset(deg)                 ( ((deg) + ALARM_SLIDER_ANGLEOFFSET) % 360 )


@interface SleepPainterAlarmSlider : UIControl

@property (nonatomic,assign) int angle;
@property (nonatomic) CGFloat sliderSize;


@end
