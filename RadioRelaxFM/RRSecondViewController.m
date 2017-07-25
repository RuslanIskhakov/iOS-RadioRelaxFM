//
//  RRSecondViewController.m
//  Radio Relax FM
//
//  Created by Deltasoft on 17.03.14.
//  Copyright (c) 2014 Deltasoft. All rights reserved.
//
#include "Constants.h"
#import "RRSecondViewController.h"

@interface RRSecondViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionText;

@end

@implementation RRSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.versionText setText:VERSION_NUMBER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openOfficialWebSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WEB_SITE_URL]];
}


@end
