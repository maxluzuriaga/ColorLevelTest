//
//  CLTViewController.h
//  ColorLevelTest
//
//  Created by Max Luzuriaga on 1/6/13.
//  Copyright (c) 2013 Max Luzuriaga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLTViewController : UIViewController {
    UIImageView *blurView;
    UIView *popupView;
    double cachedValue;
}

@property (strong, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIView *innerColorView;
@property (strong, nonatomic) IBOutlet UIView *secondaryColorView;
@property (strong, nonatomic) IBOutlet UIButton *blurButton;

- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)blurScreen:(id)sender;
- (IBAction)editingEnded:(id)sender;

@end
