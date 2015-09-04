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
#import "RRAudioTrackInfo.h"


@interface RRFirstViewController ()
@property (weak, nonatomic) IBOutlet UILabel *audioTrackTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *audioAlbumCoverImageView;


@end

@implementation RRFirstViewController

- (void)viewDidLoad
{
    NSLog(@"View Did Load");
    [super viewDidLoad];
	self.audioTrackTitleLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnTestBtnTouchUp:(id)sender {
    [[RRAudioTrackInfo getInstance:self] onPlayButtonTapUp:[[RRAudioPlayer getInstance] onPlayButtonTapUp]];
}

- (void)onAudioTrackTitleUpdate:(NSString*)title
{
    NSLog(@"Receiving Audio Track Title: %@",title);
    [self performSelectorOnMainThread:@selector(setAudioTrackTitle:) withObject:title waitUntilDone:NO];
}

- (void) setAudioTrackTitle: (NSString *)title
{
    NSLog(@"Displaying Audio Track Title: %@",title);
    [self.audioTrackTitleLabel setText:title];
}

- (void)onAudioAlbumCoverUpdated:(UIImage*) cover
{
    NSLog(@"Receiving Audio Album Cover Image");
    [self performSelectorOnMainThread:@selector(setAudioAlbumCoverImage:) withObject:cover waitUntilDone:NO];
}

- (void)setAudioAlbumCoverImage:(UIImage*) cover
{
    NSLog(@"Displaying Audio Album Cover Image");
    [self.audioAlbumCoverImageView setImage:cover];
}

@end
