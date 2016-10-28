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
@property (strong, nonatomic) IBOutlet UIButton *audioControlBtn;


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
    BOOL isPlaying = [[RRAudioPlayer getInstance] onPlayButtonTapUp];
    [[RRAudioTrackInfo getInstance:self] onPlayButtonTapUp:isPlaying];
    if (isPlaying){
        [self.audioControlBtn setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
    } else {
        [self.audioControlBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    }
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
