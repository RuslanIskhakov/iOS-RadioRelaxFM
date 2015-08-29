//
//  RMFirstViewController.m
//  Radio Manhattan
//
//  Created by Deltasoft on 17.03.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#import "RRFirstViewController.h"
#import "RRAppDelegate.h"

@interface RMFirstViewController ()

@end

@implementation RMFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)OnTestBtnTouchUp:(id)sender {
    RMAppDelegate *appDelegate = (RMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate onTestClick];
}

@end
