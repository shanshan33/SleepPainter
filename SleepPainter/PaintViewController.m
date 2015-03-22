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

@property (weak, nonatomic) IBOutlet UIButton *Owl;
@property (weak, nonatomic) IBOutlet UIView *paintingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paintViewWidthMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paintViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWithEmailButton;

@property (nonatomic, retain) CALayer    *penLayer;
@property (nonatomic, retain) CALayer    *animationLayer;
@property (nonatomic, weak) CAShapeLayer *pathLayer;



@end
@implementation PaintViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
    [self.Owl setTitle:@"        ,___,\n ★.*(⌒,⌒)‧:*‧°★*\n        /)__ )\n          \"  \"" forState:UIControlStateNormal];
    
    [self.saveImageButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [self.shareWithEmailButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    
    self.animationLayer = [CALayer layer];
    self.animationLayer.frame = CGRectMake(self.paintingView.frame.origin.x, self.paintingView.frame.origin.y,
                                           self.view.frame.size.width - 4*self.paintViewWidthMargin.constant,
                                           self.view.frame.size.height - 280);
    [self.view.layer addSublayer:self.animationLayer];
    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    self.navigationItem.title = @"I DRAW YOUR DREAM...";
}

- (UIBezierPath *)myPath
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineCapRound;
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(0, 100)];
    
    // Draw the lines for test
    [aPath addLineToPoint:CGPointMake(100.0, 150)];
    [aPath addLineToPoint:CGPointMake(110.0, 300)];
    [aPath addLineToPoint:CGPointMake(200.0, 180)];
    [aPath addLineToPoint:CGPointMake(250.0, 340)];
 
    return aPath;
}

-(void)setupDrawingLayer
{
    if (self.pathLayer != nil)
    {
        [self.penLayer removeFromSuperlayer];
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
        self.penLayer = nil;
    }

    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.animationLayer.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,
                             (__bridge id)[UIColor orangeColor].CGColor,
                             (__bridge id)[UIColor yellowColor].CGColor,
                             (__bridge id)[UIColor greenColor].CGColor,
                             (__bridge id)[UIColor blueColor].CGColor,
                            (__bridge id)[UIColor purpleColor].CGColor];
                                     
    gradientLayer.startPoint = CGPointMake(0.0,0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    [self.animationLayer addSublayer:gradientLayer];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.animationLayer.bounds;
    
    shapeLayer.path = [[self myPath] CGPath];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 20.0f;
    shapeLayer.lineJoin = kCALineJoinBevel;
    [gradientLayer setMask:shapeLayer];
    self.pathLayer = shapeLayer;

    UIImage *penImage = [UIImage imageNamed:@"pencil_icon.png"];
    CALayer *penLayer = [CALayer layer];
    penLayer.contents = (id)penImage.CGImage;
    penLayer.anchorPoint = CGPointZero;
    penLayer.frame = CGRectMake(0.0f, 0.0f, penImage.size.width/2, penImage.size.height/2);
    [self.animationLayer addSublayer:penLayer];
    
    self.penLayer = penLayer;
    
}

- (void)startAnimation
{
    [self.pathLayer removeAllAnimations];
    [self.penLayer removeAllAnimations];

    self.penLayer.hidden = NO;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 5.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CAKeyframeAnimation *penAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    penAnimation.duration = 5.0;
    penAnimation.path = self.pathLayer.path;
    penAnimation.calculationMode = kCAAnimationPaced;
    penAnimation.delegate = self;
    [self.penLayer addAnimation:penAnimation forKey:@"position"];

}

- (IBAction)iDrawYourDream:(id)sender
{
        [self setupDrawingLayer];
        [self startAnimation];

}


- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.penLayer.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
