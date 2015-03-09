//
//  SleepPainterAlarmSlider.m
//  SleepPainter
//
//  Modified by Shanshan ZHAO on 25/02/15.
//  Created by Yari Dareglia on 1/12/13.
//  Copyright (c) 2013 Yari Dareglia. All rights reserved.
//

#import "SleepPainterAlarmSlider.h"

// Helper functions
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )
#define offset(deg)     ( ((deg) + ALARM_SLIDER_ANGLEOFFSET) % 360 )

@interface SleepPainterAlarmSlider() {
    int radius;
}
@end

@implementation SleepPainterAlarmSlider

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setOpaque:NO];
        radius = self.frame.size.width / 2 - ALARM_SLIDER_PADDING;
        self.angle = offset(360);
    }
    return self;
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    // Need to track continuously
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint = [touch locationInView:self];
    [self movehandle:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
}


#pragma mark - Drawing

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //
    CGContextAddArc(ctx, self.frame.size.width / 2, self.frame.size.height / 2, radius, 0, M_PI * 2, 0);
    [[UIColor colorWithWhite:1.0f alpha:0.5f] setStroke];
    
    CGContextSetLineWidth(ctx, ALARM_SLIDER_PATH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //
    UIGraphicsBeginImageContext(CGSizeMake(ALARM_SLIDER_SIZE, ALARM_SLIDER_SIZE));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width / 2  , self.frame.size.height / 2, radius, 0, ToRad(self.angle), 0);
    [[UIColor whiteColor] set];
    
    CGContextSetLineWidth(imageCtx, ALARM_SLIDER_HANDLE);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    // Save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    // Clip Context to the mask
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    CGContextRestoreGState(ctx);
    
    [self drawTheHandle:ctx];
}

-(void) drawTheHandle:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    // Draw shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 2, [UIColor blackColor].CGColor);
    
    // Draw a white nob at particular poing over the circle
    CGPoint handleCenter =  [self pointFromAngle:self.angle];
    [[UIColor colorWithWhite:1.0f alpha:1.0f] set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, ALARM_SLIDER_HANDLE, ALARM_SLIDER_HANDLE));
    
    CGContextRestoreGState(ctx);
}


#pragma mark - Maths

-(void)movehandle:(CGPoint)lastPoint
{
    // Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    // Calculate the direction from a center point and a arbitrary position
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    // Store the new angle
    self.angle = 360 - angleInt;
    
    // Redraw
    [self setNeedsDisplay];
}

// Given the angle, get the point position on circumference with offset
-(CGPoint)pointFromAngle:(int)angleInt
{
    // Get the circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width / 2 - ALARM_SLIDER_HANDLE / 2, self.frame.size.height / 2 - ALARM_SLIDER_HANDLE / 2);
    
    // Calculate the point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));
    
    return result;
}

// Sourcecode from Apple example clockControl
// Calculate the direction in degrees from a center point to an arbitrary position
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped)
{
    CGPoint v = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag; // cosin
    v.y /= vmag; // sin
    double radians = atan2(v.y, v.x);
    result = ToDeg(radians);
    return (result >= 0 ? result : result + 360.0f);
}
@end