//
//  RRFirstViewController.m
//  Radio Relax FM
//
//  Created by Deltasoft on 17.03.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//

#define kCheckinMessage 100

#import "RRFirstViewController.h"
#import "RRAppDelegate.h"
#import "RRAudioPlayer.h"
#include <Foundation/NSPort.h>


@interface RRFirstViewController ()

@end

@implementation RRFirstViewController

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
    [[RRAudioPlayer getInstance] onPlayButtonTapUp];
}


@end
