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
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWithEmailButton;

@property (nonatomic, retain) CALayer    *penLayer;
@property (nonatomic, retain) CALayer    *animationLayer;
@property (nonatomic, weak) CAShapeLayer *pathLayer;
@property (nonatomic,strong) CAGradientLayer * gradientLayer;

@property (weak, nonatomic) IBOutlet UILabel *drawLabel;

@property (nonatomic, strong)MFMailComposeViewController * mailController;


@end
@implementation PaintViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SP_background_12am.png"]]];
    [self.Owl setTitle:@"        ,___,\n ★.*(⌒,⌒)‧:*‧°★*\n        /)__ )\n          \"  \"" forState:UIControlStateNormal];
    [self.Owl setTintColor:[UIColor whiteColor]];
    
    [self.saveImageButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [self.shareWithEmailButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    
    [self.paintingView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"paintView_background"]]];
    self.animationLayer = [CALayer layer];
    
    self.animationLayer = self.paintingView.layer;
    [self.view.layer addSublayer:self.animationLayer];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.drawLabel.text = @"I 🎨 YOUR DREAM.. CLICK ME TO SEE";
    
    NSLog(@"Check if here receive the sleep duration: %ld",(long)self.sleepDuration);
}

- (UIBezierPath *)myPath
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineCapRound;
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(15, 200)];
    
    // Draw the lines
    
    for (int i = 0; i < 50; i++)
    {
        [aPath addLineToPoint:CGPointMake(arc4random_uniform(330)+15, arc4random_uniform(250)+ 50)];
    }
    return aPath;
}

-(void)setupDrawingLayer
{
    if (self.pathLayer != nil)
    {

        [self.penLayer removeFromSuperlayer];
        [self.pathLayer removeFromSuperlayer];
        [self.gradientLayer removeFromSuperlayer];
        self.pathLayer = nil;
        self.penLayer = nil;
        self.gradientLayer = nil;
    }

    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.paintingView.layer.bounds;
    
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:@[(__bridge id)[UIColor redColor].CGColor,
                                                                    (__bridge id)[UIColor orangeColor].CGColor,
                                                                    (__bridge id)[UIColor yellowColor].CGColor,
                                                                    (__bridge id)[UIColor greenColor].CGColor,
                                                                    (__bridge id)[UIColor blueColor].CGColor,
                                                                    (__bridge id)[UIColor brownColor].CGColor,
                                                                    (__bridge id)[UIColor purpleColor].CGColor]];
    //ramdon order of colors in array
    NSUInteger count = [mutableArray count];
    if (count > 1) {
        for (NSUInteger i = count - 1; i > 0; --i)
        {
            [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))];
        }
    }
    
    NSArray *randomArray = [NSArray arrayWithArray:mutableArray];
    self.gradientLayer.colors = randomArray;
    self.gradientLayer.startPoint = CGPointMake(0.0,0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    [self.animationLayer addSublayer:self.gradientLayer];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = [[self myPath] CGPath];
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.shadowColor = [UIColor grayColor].CGColor;
    shapeLayer.shadowOffset = CGSizeMake(0.0f, 8.0f);
    shapeLayer.shadowRadius = 2.0f;
    shapeLayer.shadowOpacity = 1.0f;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 25.0f;
    shapeLayer.lineJoin = kCALineJoinBevel;
    [self.gradientLayer setMask:shapeLayer];
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
    pathAnimation.duration = 20.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    CAKeyframeAnimation *penAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    penAnimation.duration = 20.0;
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
    self.mailController = [MFMailComposeViewController new];
    self.mailController.mailComposeDelegate = self;
    
    for (UIView * view in [self.view subviews])
    {
        if ([view isKindOfClass:[UIToolbar class]]) {
            view.hidden = YES;
        }
    }
    
    UIImage * image = [self saveImage:self.view];
    
    
    for (UIView * view in [self.view subviews])
    {
        if ([view isKindOfClass:[UIToolbar class]]) {
            view.hidden = NO;
        }
    }
    
    NSData * imageAsData = UIImagePNGRepresentation(image);
    [self.mailController addAttachmentData:imageAsData mimeType:@"image/png" fileName:@"paintYourDream.png"];
    [self.mailController setSubject:@"image From Sleep Painter"];
    
    [self presentViewController:self.mailController animated:YES completion:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


-(UIImage *)saveImage:(UIView *)view
{
    CGRect mainRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 80);
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
