//
//  PaintViewController.m
//  SleepPainter
//
//  Created by Shanshan ZHAO on 14/03/15.
//  Copyright (c) 2015 Shanshan ZHAO. All rights reserved.
//

#import "PaintViewController.h"

#define BUTTON_MARGIN         20
#define BUTTON_HEIGHT         50

@interface PaintViewController ()

@property (nonatomic, weak) CAShapeLayer *pathLayer;
@property (weak, nonatomic) IBOutlet UIButton *Owl;
@property (weak, nonatomic) IBOutlet UIView *paintingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paintViewWidthMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paintViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWithEmailButton;

@end
@implementation PaintViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
    [self startAnimation];
    [self.Owl setTitle:@"        ,___,\n ★.*(⌒,⌒)‧:*‧°★*\n        /)__ )\n          \"  \"" forState:UIControlStateNormal];
    
    [self.backButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [self.saveImageButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [self.shareWithEmailButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];




}

- (UIBezierPath *)myPath
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
        
    aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(self.paintingView.frame.origin.x + 10, self.paintingView.center.y)];
    
    // Draw the lines
    [aPath addLineToPoint:CGPointMake(100.0, self.paintingView.frame.origin.y)];
    [aPath addLineToPoint:CGPointMake(110.0, self.paintingView.frame.size.height+ self.paintingView.frame.origin.y)];
    [aPath addLineToPoint:CGPointMake(200.0, self.paintingView.frame.origin.y + 20)];
    [aPath addLineToPoint:CGPointMake(self.view.frame.size.width - 2* self.paintViewWidthMargin.constant, self.paintViewHeight.constant- 30)];
    
    
//    CGPoint point = self.view.center;
//    
//    [aPath moveToPoint:CGPointMake(self.paintingView.frame.origin.x + 10, self.paintingView.center.y)];
//    
//    for (CGFloat f = 0.0; f < M_PI * 2; f += 0.75)
//    {
//        point = CGPointMake(f / (M_PI * 2) * self.view.frame.size.width, sinf(f) * 200.0 + self.view.frame.size.height / 2.0);
//        [aPath addLineToPoint:point];
//    }
    
    return aPath;
}

- (void)startAnimation
{
    if (self.pathLayer == nil)
    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        
        shapeLayer.path = [[self myPath] CGPath];
        shapeLayer.strokeColor = [UIColor redColor].CGColor;
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = 20.0f;
        shapeLayer.lineJoin = kCALineJoinBevel;
        
        [self.view.layer addSublayer:shapeLayer];
        
        self.pathLayer = shapeLayer;
    }
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 5.0;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender
{
    
}

- (IBAction)saveMyPaint:(id)sender
{
    UIImage * image = [self saveImage:self.view];
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);

}

- (IBAction)shareWithEmail:(id)sender
{
    
}


-(UIImage *)saveImage:(UIView *)view
{
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(mainRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    
    CGContextFillRect(context, mainRect);
    [view.layer renderInContext:context];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
/*
-(IBAction)saveImageToAlbum:(id)sender
{
    UIImage * image = [self saveImage:self.view];
    
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}
*/
@end
