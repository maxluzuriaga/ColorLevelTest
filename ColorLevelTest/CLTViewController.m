//
//  CLTViewController.m
//  ColorLevelTest
//
//  Created by Max Luzuriaga on 1/6/13.
//  Copyright (c) 2013 Max Luzuriaga. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#import "UIImage+ImageEffects.h"

#import "CLTViewController.h"

@interface CLTViewController ()

- (UIColor *)mainColor;
- (UIColor *)paleColor;
- (UIColor *)secondaryColor;
- (void)updateColors;
- (void)dismissPopup;

@end

@implementation CLTViewController

dispatch_queue_t blurQueue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTarget:self];
    [item setAction:@selector(blurScreen:)];
    [[self navigationItem] setRightBarButtonItem:item];
    
    popupView = [[UIView alloc] initWithFrame:CGRectMake(80, 480, 160, 240)];
    popupView.layer.shadowColor = [[UIColor blackColor] CGColor];
    popupView.layer.shadowOffset = CGSizeMake(0, 0);
    popupView.layer.shadowOpacity = 0.3;
    popupView.layer.shadowRadius = 10.0;
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dismissButton setFrame:CGRectMake(30, 30, 100, 180)];
    [dismissButton setTitle:@"Resume" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissPopup) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setTag:1];
    
    [popupView addSubview:dismissButton];
    
    [self updateColors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stepperValueChanged:(id)sender {
    [self updateColors];
}

- (IBAction)blurScreen:(id)sender {
    if ([[self navigationController] isNavigationBarHidden]) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.window.frame.size.width, self.view.frame.size.height), NO, self.view.window.screen.scale);
        [self.view drawViewHierarchyInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSLog(@"%f x %f", bgImage.size.width, bgImage.size.height);
        
        bgImage = [bgImage applyLightEffect];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
        bgImageView.frame = CGRectMake(0, 0, self.view.window.frame.size.width, self.view.frame.size.height);
        bgImageView.tag = 542;
        
        [self.view addSubview:bgImageView];
    } else {
        UIView *imageView = [self.view viewWithTag:542];
        [imageView removeFromSuperview];
    }
    
    [[self navigationController] setNavigationBarHidden:![[self navigationController] isNavigationBarHidden] animated:YES];
}

- (IBAction)editingEnded:(id)sender {
    NSLog(@"Editing ended");
}

- (void)dismissPopup {
    [UIView animateWithDuration:0.3 animations:^(void) {
        [blurView setAlpha:0.0];
        [popupView setFrame:CGRectMake(80, -240, 160, 240)];
    } completion:^(BOOL finished) {
        [blurView removeFromSuperview];
        
        [popupView setFrame:CGRectMake(80, 480, 160, 240)];
        [popupView removeFromSuperview];
        
        [self.view setUserInteractionEnabled:YES];
    }];
}

- (void)updateColors
{
    [self.label setText:[NSString stringWithFormat:@"%f", self.stepper.value]];
    
    UIColor *main = [self mainColor];
    UIColor *secondary = [self secondaryColor];
    UIColor *pale = [self paleColor];
    
    [self.view setBackgroundColor:secondary];
    [self.colorView setBackgroundColor:main];
    [self.innerColorView setBackgroundColor:pale];
    [self.secondaryColorView setBackgroundColor:secondary];
    
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:secondary];
    
    popupView.backgroundColor = pale;
    UIButton *button = (UIButton *)[popupView viewWithTag:1];
    [button setTintColor:main];
}

- (UIColor *)mainColor
{
    // Blue: 87 constant
    // Red: starts 237 until halfway, ends 87
    // Green: starts 87, ends 237 (halfway through)
    
    float max = 237;
    float min = 87;
    
    float percent = self.stepper.value / 81.0;
    
    float percentRed = MAX(((percent * 2) - 1.0), 0);
    float percentGreen = MIN((percent * 2), 1);
    
    float red = max - ((max-min) * percentRed);
    float green = min + ((max-min) * percentGreen);
    float blue = min;
    
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1.0];
}

- (UIColor *)paleColor {
    // Blue: 230 constant
    // Red: starts 245 until halfway, ends 230
    // Green: starts 230, ends 245 (halfway through)
    
    float max = 245;
    float min = 230;
    
    float percent = self.stepper.value / 81.0;
    
    float percentRed = MAX(((percent * 2) - 1.0), 0);
    float percentGreen = MIN((percent * 2), 1);
    
    float red = max - ((max-min) * percentRed);
    float green = min + ((max-min) * percentGreen);
    float blue = min;
    
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1.0];
}

- (UIColor *)secondaryColor {
    // Blue: starts 148, rises until 25.66%, then constant
    // Red: starts 148, constant until 46%, then rises to the end
    // Green: starts 239, constant until 25.66%, then falls until 46%, then constant to the end
    
    float max = 240;
    float min = 112;
    
    float point1 = .216666666;
    float point2 = .42;
    
    float percent = self.stepper.value / 81.0;
    
    float percentRed;
    float percentGreen;
    float percentBlue;
    
    if (percent < point1) {
        percentRed = percent / point1;
        
        percentBlue = 0.0;
        percentGreen = 0.0;
    } else if ((percent >= point1) && (percent <= point2)) {
        percentBlue = (percent - point1) / (point2 - point1);
        
        percentGreen = 0.0;
        percentRed = 1.0;
    } else {
        percentGreen = (percent - point2) / (1.0 - point2);
        
        percentBlue = 1.0;
        percentRed = 1.0;
    }
    
    float red = max - ((max-min) * percentRed);
    float green = max - ((max-min) * percentGreen);
    float blue = min + ((max-min) * percentBlue);
    
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1.0];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
